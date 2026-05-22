# Parse .wpress (All-in-One WP Migration) archive
# Reads headers sequentially, seeks past file content, outputs listing

$wpressPath = "C:\PublicCase\audit\src\www-example-bistro-dc-com-20260308-160015-9uc8zlqzsue6.wpress"
$outputPath = "C:\PublicCase\audit\wpress-file-listing.txt"

$HEADER_SIZE = 4377
$NAME_LEN = 255
$SIZE_LEN = 14
$MTIME_LEN = 12
$PATH_LEN = 4096

$headerBuf = New-Object byte[] $HEADER_SIZE

$fs = [System.IO.File]::Open($wpressPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
$totalSize = $fs.Length

$entries = [System.Collections.Generic.List[string]]::new()
$entryCount = 0
$offset = 0

$epoch = [DateTime]::new(1970, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)

Write-Host "Parsing wpress archive ($([math]::Round($totalSize / 1GB, 2)) GB)..."

try {
    while ($fs.Position + $HEADER_SIZE -le $totalSize) {
        $offset = $fs.Position

        # Read full header
        $bytesRead = 0
        while ($bytesRead -lt $HEADER_SIZE) {
            $n = $fs.Read($headerBuf, $bytesRead, $HEADER_SIZE - $bytesRead)
            if ($n -eq 0) { break }
            $bytesRead += $n
        }
        if ($bytesRead -lt $HEADER_SIZE) {
            Write-Host "Incomplete header at offset $offset, stopping."
            break
        }

        # Extract filename (bytes 0-254), trimming null bytes
        $nameRaw = [System.Text.Encoding]::UTF8.GetString($headerBuf, 0, $NAME_LEN).TrimEnd([char]0)

        # Stop conditions
        if ([string]::IsNullOrEmpty($nameRaw) -or $nameRaw -eq "end") {
            Write-Host "End marker reached at offset $offset (name='$nameRaw')."
            break
        }

        # Extract size (bytes 255-268)
        $sizeRaw = [System.Text.Encoding]::UTF8.GetString($headerBuf, $NAME_LEN, $SIZE_LEN).TrimEnd([char]0)
        $fileSize = [long]::Parse($sizeRaw)

        # Extract mtime (bytes 269-280)
        $mtimeRaw = [System.Text.Encoding]::UTF8.GetString($headerBuf, $NAME_LEN + $SIZE_LEN, $MTIME_LEN).TrimEnd([char]0)
        $mtimeUnix = [long]0
        if ([long]::TryParse($mtimeRaw, [ref]$mtimeUnix)) {
            $mtimeDate = $epoch.AddSeconds($mtimeUnix).ToString("yyyy-MM-dd HH:mm:ss")
        } else {
            $mtimeDate = "unknown"
        }

        # Extract path (bytes 281-4376)
        $pathRaw = [System.Text.Encoding]::UTF8.GetString($headerBuf, $NAME_LEN + $SIZE_LEN + $MTIME_LEN, $PATH_LEN).TrimEnd([char]0)

        # Format size for display
        if ($fileSize -ge 1MB) {
            $sizeDisplay = "$([math]::Round($fileSize / 1MB, 2)) MB"
        } elseif ($fileSize -ge 1KB) {
            $sizeDisplay = "$([math]::Round($fileSize / 1KB, 2)) KB"
        } else {
            $sizeDisplay = "$fileSize B"
        }

        $fullPath = if ($pathRaw) { "$pathRaw$nameRaw" } else { $nameRaw }
        $line = "$fullPath`t$fileSize`t$sizeDisplay`t$mtimeDate"
        $entries.Add($line)

        $entryCount++
        if ($entryCount % 500 -eq 0) {
            $pct = [math]::Round($fs.Position / $totalSize * 100, 1)
            Write-Host "  Processed $entryCount entries... ($pct% of file)"
        }

        # Seek past file content
        if ($fileSize -gt 0) {
            $newPos = $fs.Seek($fileSize, [System.IO.SeekOrigin]::Current)
        }
    }
} finally {
    $fs.Close()
    $fs.Dispose()
}

Write-Host "Total entries found: $entryCount"
Write-Host "Writing listing to $outputPath..."

$sb = [System.Text.StringBuilder]::new()
$sb.AppendLine("=== WPRESS ARCHIVE LISTING ===") | Out-Null
$sb.AppendLine("Archive: $wpressPath") | Out-Null
$sb.AppendLine("Total entries: $entryCount") | Out-Null
$sb.AppendLine("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')") | Out-Null
$sb.AppendLine("") | Out-Null
$sb.AppendLine("PATH`tBYTES`tSIZE`tMODIFIED") | Out-Null
$sb.AppendLine("----`t-----`t----`t--------") | Out-Null

foreach ($e in $entries) {
    $sb.AppendLine($e) | Out-Null
}

# Summary by directory
$sb.AppendLine("") | Out-Null
$sb.AppendLine("=== SUMMARY BY TOP-LEVEL DIRECTORY ===") | Out-Null

$dirStats = @{}
foreach ($e in $entries) {
    $parts = $e.Split("`t")
    $fp = $parts[0]
    $sz = [long]$parts[1]

    # Get top-level directory
    $segments = $fp.Split('/')
    if ($segments.Count -gt 1) {
        $topDir = $segments[0]
    } else {
        $topDir = "(root)"
    }

    if (-not $dirStats.ContainsKey($topDir)) {
        $dirStats[$topDir] = @{ Count = 0; Size = [long]0 }
    }
    $dirStats[$topDir].Count++
    $dirStats[$topDir].Size += $sz
}

foreach ($d in $dirStats.GetEnumerator() | Sort-Object { $_.Value.Size } -Descending) {
    $dSize = if ($d.Value.Size -ge 1MB) { "$([math]::Round($d.Value.Size / 1MB, 2)) MB" }
             elseif ($d.Value.Size -ge 1KB) { "$([math]::Round($d.Value.Size / 1KB, 2)) KB" }
             else { "$($d.Value.Size) B" }
    $sb.AppendLine("  $($d.Key)/`t$($d.Value.Count) files`t$dSize") | Out-Null
}

[System.IO.File]::WriteAllText($outputPath, $sb.ToString(), [System.Text.Encoding]::UTF8)
Write-Host "Done. Listing saved to $outputPath"
