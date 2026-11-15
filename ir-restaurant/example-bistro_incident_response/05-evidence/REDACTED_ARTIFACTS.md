# Redacted Evidence Artifacts

The public case file does not include raw evidence bytes for database exports, WordPress exports, server archives, credential dumps, logs, or executable malware samples.

Those artifacts were removed because they may contain client data, customer/contact-form data, credentials, account identifiers, infrastructure details, or reusable attacker code. The investigative value is preserved in the public summaries, hashes, timelines, indicators, and tool output references below.

## Included Public Evidence

- Attacker infrastructure: real malicious domains, redirect destination, Cloudflare proxy IPs, registrar, abuse contact, and operator/backdoor source IPs where the source is attacker-only.
- Malware behavior: decoded ClickFix behavior, fake Cloudflare pretext, tokenized download URL, TDS logic, credential-stealer behavior, webshell locations, persistence design, and database option names.
- Forensic metadata: collection dates, file paths, file sizes where useful, SHA256 hashes, evidence IDs, timeline entries, and remediation verification results.
- Response work: curated analysis scripts, eradication script, pre/post eradication checklists and an evidence inventory.

## Withheld Or Redacted

- Client, owner, customer, visitor, and vendor personal information.
- Raw credential dumps, passwords, session tokens, login cookies, database exports, WordPress XML exports, and full server logs.
- Client-side IP addresses, real hostnames, home directories, panel usernames, email addresses, and account-specific bypass keys.
- Executable malware samples or raw payload files that could be reused without additional context.

## Where The Evidence Lives

- `evidence-inventory.md`
- `auth-session-reconstruction.md`
- `03-iocs/IOC-registry.md`
- `04-malware-analysis/`
- `07-remediation/`
- `10-supporting-analysis/`

The original private case file retained the raw artifacts under the evidence paths documented in the inventory. This public version keeps the analysis and chain-of-custody-style documentation, not the sensitive source material.
