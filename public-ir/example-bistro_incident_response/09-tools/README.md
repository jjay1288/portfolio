# Curated Analysis Tools

This folder contains the public-safe tools worth keeping with the case file. One-off scratch scripts used during exploration were removed from the public version.

## Included

| Tool | Purpose |
| --- | --- |
| `parse-wpress.ps1` | Parses an All-in-One WP Migration `.wpress` archive and produces a file listing without extracting the full archive. |
| `scan-wpress.ps1` | Chunked string scanner for `.wpress` archives. Replaces the original one-off search and section-extraction scripts with a reusable scanner. |
| `decode_payload.ps1` | Safe decoder for the recovered ClickFix PowerShell payload. It prints the decoded payload and does not execute it. |

## Removed From Public Version

The original working directory included short-lived helper scripts for pulling individual result sections, checking one pattern family, and summarizing intermediate scan output. Those were useful during the live investigation but not useful as portfolio artifacts. Their behavior is covered by `scan-wpress.ps1` and the written analysis reports.
