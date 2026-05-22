# Incident Response Case File

**Case ID:** IR-2026-0310-EXBI
**Case Name:** Example Bistro Website Compromise
**Classification:** Tier 1 -- Critical Incident
**NIST SP 800-61 Phase:** Recovery / Post-Eradication

---

## Folder Structure

| Directory | Contents |
|---|---|
| `00-engagement/` | Engagement letter, statement of work, scope authorization |
| `01-incident-report/` | Main incident report, executive summary, client deliverables |
| `02-timeline/` | Detailed chronological timeline of attacker and responder actions |
| `03-iocs/` | Indicators of Compromise -- domains, IPs, hashes, file paths, DB artifacts |
| `04-malware-analysis/` | Per-artifact analysis: TDS engine, webshells, credential stealers, persistence mechanisms |
| `05-evidence/` | Evidence inventory, chain of custody log, acquisition notes |
| `06-compromised-credentials/` | Credential exposure report, affected accounts, rotation status |
| `07-remediation/` | Eradication checklist, hardening plan, verification procedures |
| `08-communications/` | Stakeholder notifications, client correspondence, vendor contacts |
| `09-tools/` | Curated public-safe scripts and tools used during investigation |
| `10-supporting-analysis/` | Supporting research and server-side findings retained for public review |

## Case Contacts

| Role | Name | Contact |
|---|---|---|
| Incident Handler | Jay Phillips | [EMAIL-REDACTED] |
| Site Owner | Manager ([REDACTED-OWNER-USERNAME]) | [EMAIL-REDACTED] |
| Site Owner | Site Owner | [EMAIL-REDACTED] / [EMAIL-REDACTED] |
| Developer | Agency Developer 1 (Web Agency) | agency-dev-1-agency.invalid |
| Developer | Agency Developer 2 | agency-dev-2-agency.invalid |
| Hosting Provider | SharedHost Provider | [EMAIL-REDACTED] |

## Classification Justification (Tier 1)

- Active credential theft confirmed (cleartext passwords captured)
- Customer-data harvesting capability present, but WooCommerce was confirmed unused and no customer/order/payment data existed in WordPress
- Hidden persistent admin access by threat actor
- Multi-layered persistence with database-level backup mechanism
- Active email interception of all site communications
- Ongoing risk: stolen credentials enable further access to business systems
