# SharedHost Provider Provider Follow-Up Request

| Field | Value |
|---|---|
| **Case ID** | IR-2026-0310-EXBI |
| **Document** | sharedhost-provider-followup |
| **Date** | March 18, 2026 |
| **From** | Jay Phillips (Incident Responder, on behalf of Example Bistro / example-bistro.invalid) |
| **To** | SharedHost Provider Trust & Safety / Security Team |
| **Subject** | Security Incident — example-bistro.invalid — Provider Follow-Up Requests |
| **Status** | DRAFT — pending send |

---

## Background

We are conducting a formal incident response engagement for the owner of **example-bistro.invalid**, hosted on SharedHost Provider shared hosting (server: `iad1-shared-b8-33.sharedhost.invalid`). The site suffered a full server-side compromise on or around **March 8, 2026**, following a social engineering (ClickFix) attack against a site administrator that resulted in stolen SharedHost Provider panel credentials.

A full eradication was completed on **March 18, 2026** by the incident response team under the new SharedHost Provider panel user `siteuser02`. SharedHost Provider support also performed a partial cleanup earlier the same day (removing `wp-content/mu-plugins/` and the `TDS_NOCACHE` block from `.htaccess`), for which we are grateful — though the remaining malware still required full coordinated eradication.

We have four follow-up requests that require SharedHost Provider's cooperation to complete the investigation and close the case.

---

## Request 1: Panel Audit Log and Login Records (March 8–18, 2026)

**What we need:**
Copies of all SharedHost Provider panel login events for the account associated with `example-bistro.invalid` during the period **March 8–18, 2026**, including:
- Source IP addresses for all successful and failed panel logins
- Timestamps (UTC)
- Any actions taken through the panel (file manager access, DNS changes, user creation, etc.)

**Why:**
We have confirmed that SharedHost Provider panel credentials were stolen via a browser-credential-harvesting trojan. Panel login records will allow us to determine the exact window during which the attacker had panel access, confirm whether any DNS or hosting configuration changes were made outside of normal administrator activity, and provide evidence for the incident timeline.

**Preservation request:** Please preserve these logs regardless of your standard retention schedule, as they may be needed for legal or regulatory purposes.

---

## Request 2: Inspection and Removal of `/home/siteuser01`

**What we need:**
SharedHost Provider to inspect, preserve a copy of, and then remove the home directory `/home/siteuser01` (the original compromised panel user).

**Why:**
The threat actor planted a malicious PowerShell payload in the SSH/SFTP username field of the SharedHost Provider panel interface. This is a ClickFix "paste-jacking" payload designed to be executed by the next administrator who interacts with that panel section. The payload was decoded during our investigation:

- **Encoding:** XOR-encrypted (key: `pgtPYT`), base64-wrapped
- **Comment used as disguise:** `# I am not a robot - Cloudflare ID: 85f261d8487fffbd`
- **Action:** Downloads and executes a credential-stealing trojan from `https://webanalytics-cdn.cfd/api/index.php`, then self-deletes

We do not know whether any files were left in `/home/siteuser01` by the attacker. The directory should be inspected for attacker-planted files before deletion. If anything is found, we request a copy be preserved and sent to us before removal.

---

## Request 3: Confirm No Rogue Panel Users, Subdomains, Redirects, or DNS Changes

**What we need:**
Confirmation that as of today:
- No additional SharedHost Provider panel users exist for the `example-bistro.invalid` account beyond those created by the legitimate site owner or our IR team (`siteuser02`)
- No subdomains, parked domains, or mirrored domains were added during the compromise window
- No DNS records for `example-bistro.invalid` or `www.example-bistro.invalid` were modified during the compromise window
- No panel-level redirects were added or modified

**Why:**
We have cleaned the WordPress installation, but the SharedHost Provider panel provides hosting-level controls that are outside our direct visibility. If the attacker added a subdomain, DNS redirect, or panel-level forward during the period they had panel access, these would survive our WordPress-level eradication and could provide a re-entry path or ongoing data exfiltration channel.

---

## Request 4: Confirm the SSH/SFTP Username-Field Payload Has Been Cleared

**What we need:**
Confirmation that the malicious PowerShell payload planted in the SSH/SFTP username field of the SharedHost Provider panel for the `siteuser01` account has been cleared from the panel interface.

**Why:**
As described in Request 2, the attacker planted a second-stage ClickFix payload in the SSH username field, visible to any SharedHost Provider support agent or administrator who views that panel section. If this field still contains the payload, any SharedHost Provider staff member who views the account could inadvertently execute it. We believe it may have already been cleared as part of SharedHost Provider support's earlier intervention, but we need explicit confirmation for our case record.

---

## Contact Information

**Incident Responder:** Jay Phillips
**Case Reference:** IR-2026-0310-EXBI
**Affected Domain:** example-bistro.invalid
**Affected Hosting Account User:** siteuser01 (original) / siteuser02 (current IR access user)
**Server:** iad1-shared-b8-33.sharedhost.invalid

Please reference case ID **IR-2026-0310-EXBI** in all correspondence.

---

*Document Reference: IR-2026-0310-EXBI / sharedhost-provider-followup / Draft March 18, 2026*
