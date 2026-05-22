# Public Incident Response Case Study

This is a sanitized public version of a real incident response case file for a small-business WordPress compromise. It is intended as a resume and job-search supplement. The documents preserve the investigation structure, reporting style, remediation sequence, evidence map, and technical reasoning while removing client-identifying and sensitive material.

## Incident Summary

Example Bistro's WordPress site was compromised during an automated campaign targeting WordPress installations on shared hosting. The first visible symptom was visitor redirection to unrelated external sites. Follow-on investigation showed that the compromise went beyond a simple JavaScript injection: the attacker had access to the hosting control panel, planted a secondary social-engineering payload in the SSH/SFTP settings, deployed multiple webshells, captured WordPress credentials, hid an attacker-created administrator account, and established database-backed persistence.

The strongest supported access chain was a ClickFix/paste-jacking attack. A site administrator appears to have encountered a fake "verify you are human" prompt that instructed them to copy and run text on a Windows machine. That text decoded to a PowerShell payload that downloaded a credential-stealing trojan from attacker infrastructure. The same payload family was later found planted in the hosting panel's SSH/SFTP username field, disguised as a CAPTCHA verification command. This gave the attacker a way to infect the next administrator who interacted with the setting.

The case was handled as a Tier 1 critical incident because it included active credential theft, remote code execution paths, persistent backdoors, hidden users, email interception, and evidence that the attacker had access outside the WordPress admin interface.

## Scope and Evidence

The investigation covered both backup and live-server evidence:

- 18,897 files from a WordPress backup were examined.
- A 20.88 MB database export was extracted and reviewed.
- A live WordPress XML export with 756 content items was analyzed.
- Hosting panel artifacts, SSH/SFTP settings, raw server findings, and WordPress filesystem evidence were reviewed.
- Malware samples were categorized into separate reports for the traffic distribution system, webshells, credential stealers, stealth toolkit, persistence layer, and ClickFix payload.
- An IOC registry, timeline, evidence inventory, credential exposure report, client report, technical report, remediation checklists, and post-eradication checklist were produced.

Raw database exports, archives, logs, recovered credential material, and executable malware samples are not included in this public version. The evidence inventory and redacted-artifact note preserve the evidence map without exposing sensitive client data or reusable attacker code.

## Key Findings

The live environment contained a layered malware kit:

- A 126 KB mu-plugin traffic distribution system that redirected visitors and exfiltrated tracking data.
- Five redundant webshells across non-standard WordPress directories.
- Three credential-stealing mechanisms, including login-page and theme-level hooks.
- A hidden administrator account concealed from normal WordPress interfaces.
- A stealth toolkit that hid artifacts, intercepted outgoing email, included WooCommerce order-harvesting capability, and logged administrator activity.
- Database-backed self-healing persistence, including stored malware backups and cron/transient residue.
- Theme-level backdoors in active and inactive themes.
- A malicious standard plugin performing obfuscated JavaScript injection.
- A planted ClickFix PowerShell payload in the hosting panel's SSH/SFTP settings.

Two WordPress credential sets were confirmed stolen in plaintext. Email interception was confirmed. Payment theft was ruled out: the business confirmed WooCommerce was never used for customer transactions, no WooCommerce customer/order records existed, the malware's WooCommerce harvesting store was empty, and card processing occurred outside WordPress.

## Response Actions

The response moved from triage to containment, eradication, and recovery:

- Confirmed that the accessible backup and content export were clean, which shifted the investigation toward live server files outside normal WordPress content.
- Researched attacker infrastructure and mapped the redirect/C2 domain family.
- Decoded the planted PowerShell payload and tied it to the same attacker infrastructure used by the website malware.
- Established clean server access through a new hosting-panel user.
- Reconstructed attacker activity from live server files, WordPress data, and preserved logs.
- Deployed emergency `.htaccess` deny rules to block direct PHP execution in webshell directories while maintenance mode was active.
- Authored and executed a coordinated `eradicate.sh` cleanup script that removed multiple persistence layers in one maintenance window.
- Reinstalled WordPress core from a verified source and verified checksums.
- Removed the hidden administrator account and related usermeta.
- Removed malicious mu-plugins, webshells, malicious plugin artifacts, exfiltration files, database options, cron residue, and theme backdoors.
- Rotated WordPress administrator passwords, MySQL credentials, hosting-panel access, and session salts.
- Cleared one-time-login token material after identifying the hosting provider's legitimate SSO helper plugin as an alternate auth path.
- Enabled or verified Wordfence WAF protection, login brute-force protection, XML-RPC blocking, file permission normalization, and SPF/DKIM/DMARC alignment.
- Prepared breach notification analysis and draft notifications for affected credential holders.

Post-eradication verification found WordPress core clean, no remaining known webshell access, no remaining hidden attacker user, and a clean Wordfence scan.

## Artifacts Worth Reviewing

Start here if you are reviewing this as a portfolio sample:

- [Client-facing report](example-bistro-dc-client-report.md)
- [Technical incident report](example-bistro_incident_response/01-incident-report/IR-2026-0310-EXBI.md)
- [Incident timeline](example-bistro_incident_response/02-timeline/timeline.md)
- [IOC registry](example-bistro_incident_response/03-iocs/IOC-registry.md)
- [Malware analysis reports](example-bistro_incident_response/04-malware-analysis/)
- [Evidence inventory](example-bistro_incident_response/05-evidence/evidence-inventory.md)
- [Redacted evidence note](example-bistro_incident_response/05-evidence/REDACTED_ARTIFACTS.md)
- [Credential exposure report](example-bistro_incident_response/06-compromised-credentials/CRED-001-exposure-report.md)
- [Eradication checklist](example-bistro_incident_response/07-remediation/eradication-checklist.md)
- [Post-eradication checklist](example-bistro_incident_response/07-remediation/post-eradication-checklist.md)
- [Breach notification assessment](example-bistro_incident_response/08-communications/breach-notification-assessment.md)
- [Analysis and remediation tooling](example-bistro_incident_response/09-tools/)
- [Supporting infrastructure research and server findings](example-bistro_incident_response/10-supporting-analysis/)

## Skills Demonstrated

This case shows hands-on work across the incident lifecycle:

- WordPress and shared-hosting incident response
- Malware triage and behavioral analysis
- PowerShell payload decoding
- Webshell and persistence analysis
- IOC development and detection logic
- Timeline reconstruction from partial evidence
- Credential exposure assessment
- Client-facing and technical reporting
- Production remediation scripting
- Evidence preservation and chain-of-custody-style documentation
- Practical hardening after eradication
- Clear communication of uncertainty and attribution limits

## Sanitization Notes

Public replacements are consistent throughout the case file:

| Original category | Public replacement |
| --- | --- |
| Client business name | Example Bistro |
| Client domain | example-bistro.invalid |
| Client owner/contact | Site Owner |
| External web agency/developers | Web Agency / Agency Developer 1 / Agency Developer 2 |
| Hosting provider | SharedHost Provider |
| Client CDN or DNS security provider, if applicable | CDN Provider |
| Consultant email and personal emails | [EMAIL-REDACTED] |
| Lead analyst name | Jay Phillips |
| Client address, account names, home directories, panel usernames | Redacted or replaced with generic account labels |
| Client-side visitor, admin, origin, and infrastructure IP addresses | [IP-REDACTED] |
| Attacker domains, redirect destinations, registrar, operator source IPs, and Cloudflare infrastructure | Retained where they are attacker-only and safe to share |

## Public Safety Policy

Raw evidence was not reproduced byte-for-byte when it contained private client data, credentials, database/export content, raw logs, archives, or executable malware samples. The public case file keeps the analysis and evidence inventory, but omits the sensitive source artifacts.
