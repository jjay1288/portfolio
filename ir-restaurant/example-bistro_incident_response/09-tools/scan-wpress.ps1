$ErrorActionPreference = 'Stop'

<#
.SYNOPSIS
    Scans an All-in-One WP Migration .wpress archive for suspicious strings.

.DESCRIPTION
    This tool was used to triage a large WordPress backup without extracting the
    full archive. It performs chunked byte searches with overlap and returns
    bounded context around each match. Pattern sets are grouped so the same
    scanner can be used for broad malware triage or higher-signal follow-up.

    This script does not execute archive contents.

.PARAMETER ArchivePath
    Path to the .wpress archive.

.PARAMETER OutputPath
    Optional path for a text report. If omitted, matches are written to stdout.

.PARAMETER PatternSet
    basic: broad indicators used for initial triage.
    suspicious: higher-signal malware and webshell strings.
    extended: both sets.

.PARAMETER ContextBytes
    Number of bytes shown before and after a match.

.PARAMETER MaxMatches
    Maximum matches returned per pattern.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ArchivePath,

    [string]$OutputPath,

    [ValidateSet('basic', 'suspicious', 'extended')]
    [string]$PatternSet = 'extended',

    [int]$ContextBytes = 300,

    [int]$MaxMatches = 25
)

if (-not (Test-Path -LiteralPath $ArchivePath)) {
    throw "Archive not found: $ArchivePath"
}

Add-Type -TypeDefinition @'
using System;
using System.IO;
using System.Text;
using System.Collections.Generic;

public class ChunkedByteSearcher
{
    public static List<string> Search(string filePath, string searchTerm, int contextBytes, int maxMatches)
    {
        var results = new List<string>();
        byte[] searchBytes = Encoding.UTF8.GetBytes(searchTerm);
        int searchLen = searchBytes.Length;
        int chunkSize = 16 * 1024 * 1024;
        int overlap = searchLen + contextBytes;
        byte[] buffer = new byte[chunkSize + overlap];

        using (var fs = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.Read, 65536, FileOptions.SequentialScan))
        {
            long fileLength = fs.Length;
            long position = 0;

            while (position < fileLength && results.Count < maxMatches)
            {
                fs.Position = position;
                long remaining = fileLength - position;
                int readSize = remaining < buffer.Length ? (int)remaining : buffer.Length;
                int bytesRead = fs.Read(buffer, 0, readSize);
                if (bytesRead < searchLen) break;

                int searchLimit = bytesRead < chunkSize ? bytesRead - searchLen + 1 : chunkSize;
                if (searchLimit < 0) searchLimit = 0;

                for (int i = 0; i < searchLimit; i++)
                {
                    bool found = true;
                    for (int j = 0; j < searchLen; j++)
                    {
                        if (buffer[i + j] != searchBytes[j]) { found = false; break; }
                    }

                    if (found)
                    {
                        long absPos = position + i;
                        int ctxStart = Math.Max(0, i - contextBytes);
                        int ctxEnd = Math.Min(bytesRead, i + searchLen + contextBytes);
                        var sb = new StringBuilder();
                        sb.Append("MATCH@");
                        sb.Append(absPos);
                        sb.Append("|");

                        for (int k = ctxStart; k < ctxEnd; k++)
                        {
                            byte b = buffer[k];
                            if (b >= 32 && b <= 126) sb.Append((char)b);
                            else if (b == 10 || b == 13) sb.Append('\n');
                            else sb.Append('.');
                        }

                        results.Add(sb.ToString());
                        if (results.Count >= maxMatches) break;
                        i += searchLen - 1;
                    }
                }

                position += chunkSize;
            }
        }

        return results;
    }
}
'@ -Language CSharp

$basicPatterns = @(
    'webanalytics-cdn',
    'landbankseeds',
    'base64_decode',
    'gzinflate',
    'str_rot13',
    'create_function',
    'shell_exec',
    'passthru',
    'eval(',
    'assert(',
    'system(',
    '$_REQUEST',
    '$_POST',
    'preg_replace'
)

$suspiciousPatterns = @(
    'eval(base64_decode',
    'eval(gzinflate',
    'eval(str_rot13',
    'eval(gzuncompress',
    'assert(base64_decode',
    'base64_decode($_',
    'document.write(unescape',
    'String.fromCharCode',
    'fromCharCode',
    'php_uname',
    'move_uploaded_file',
    'wp_insert_user',
    'add_action(''init'', ''',
    'curl_exec',
    'proc_open',
    'popen(',
    'pcntl_exec',
    'extract($_',
    'parse_str($_',
    'chmod(',
    'c99shell',
    'r57shell',
    'FilesMan',
    'b374k',
    'WSO '
)

switch ($PatternSet) {
    'basic' { $patterns = $basicPatterns }
    'suspicious' { $patterns = $suspiciousPatterns }
    default { $patterns = $basicPatterns + $suspiciousPatterns | Select-Object -Unique }
}

$report = [System.Text.StringBuilder]::new()
[void]$report.AppendLine("WPRESS MALWARE TRIAGE SCAN")
[void]$report.AppendLine("Archive: $ArchivePath")
[void]$report.AppendLine("Pattern set: $PatternSet")
[void]$report.AppendLine("Scan date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
[void]$report.AppendLine("=" * 80)

foreach ($pattern in $patterns) {
    Write-Host "Scanning for: $pattern"
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $matches = [ChunkedByteSearcher]::Search($ArchivePath, $pattern, $ContextBytes, $MaxMatches)
    $sw.Stop()

    [void]$report.AppendLine("")
    [void]$report.AppendLine("=" * 80)
    [void]$report.AppendLine("PATTERN: $pattern")
    [void]$report.AppendLine("RESULT: $($matches.Count) matches in $($sw.Elapsed.TotalSeconds.ToString('F1'))s")

    if ($matches.Count -eq 0) {
        [void]$report.AppendLine("NO MATCHES FOUND")
        continue
    }

    foreach ($match in $matches) {
        $sepIdx = $match.IndexOf('|')
        [void]$report.AppendLine("")
        [void]$report.AppendLine("--- $($match.Substring(0, $sepIdx)) ---")
        [void]$report.AppendLine($match.Substring($sepIdx + 1))
    }
}

if ($OutputPath) {
    [System.IO.File]::WriteAllText($OutputPath, $report.ToString(), [System.Text.Encoding]::UTF8)
    Write-Host "Report written to: $OutputPath"
} else {
    Write-Output $report.ToString()
}
