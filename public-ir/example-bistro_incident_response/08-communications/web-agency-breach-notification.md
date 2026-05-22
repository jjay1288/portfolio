# Breach Notification — Web Agency / Agency Developer 1

| Field | Value |
|---|---|
| **Case ID** | IR-2026-0310-EXBI |
| **Document** | webagency-breach-notification |
| **Date** | March 18, 2026 |
| **From** | Jay Phillips (Incident Responder, on behalf of Example Bistro) |
| **To** | Agency Developer 1 — agency-dev-1-agency.invalid |
| **Subject** | URGENT: Your Credentials Were Compromised — Example Bistro Website Incident |
| **Status** | DRAFT — pending send |
| **Sent Date** | *(update when sent)* |
| **Delivery Confirmation** | *(update when confirmed)* |

---

## Regulatory Basis

**Applicable law:** DC Code § 28-3852 (DC Security Breach Notification Act)

**Trigger:** The statute defines "personal information" to include *"a user name or email address, in combination with a password or security question and answer that would permit access to an individual's online account."* Agency Developer 1's email address (`agency-developer-1`) and password (`[REDACTED-PASSWORD]`) were captured in confirmed plaintext and stored on the compromised server. This is a direct match to the statutory definition regardless of Agency Developer 1's state of residence.

**Obligation:** Notification must be made "in the most expedient time possible and without unreasonable delay." No AG filing is required (fewer than 50 DC residents affected).

**Note on residency:** DC § 28-3852 technically covers DC residents. Agency Developer 1's state of residence is unknown. Notification is being issued regardless — the credential exposure is confirmed and notification is the appropriate duty-of-care response under any applicable state law.

**Case record requirement:** A copy of this notification and evidence of delivery (sent email, read receipt, or other confirmation) must be retained in the case file as proof of timely notification.

---

## Email Draft

**To:** agency-dev-1-agency.invalid
**Subject:** URGENT: Your Login Credentials Were Stolen — Action Required

---

Agency Developer 1,

I am writing on behalf of Example Bistro (example-bistro.invalid) to notify you that your WordPress administrator credentials were stolen as part of a confirmed security incident affecting the Example Bistro website.

**What happened:**

Between March 8 and March 18, 2026, the Example Bistro website was compromised by a threat actor who installed credential-stealing software inside the WordPress login system. This software silently recorded usernames and passwords every time anyone logged into the WordPress admin panel.

**What was captured:**

Your credentials were recorded in cleartext on four separate occasions:

- **Username:** agency-developer-1
- **Password:** redacted (follows the pattern you use for contractor logins — you will recognize it)

These credentials were found stored in a file on the compromised server and have been confirmed as fully exposed to the attacker.

**What we have already done:**

- Your WordPress administrator password for example-bistro.invalid has been rotated.
- Your WordPress administrator account has been removed from the site (your access is no longer needed for this engagement, and reducing the number of active admin accounts is part of the security remediation).
- The malware responsible for capturing your credentials has been fully removed from the site.

**What you need to do — urgently:**

1. **Change your password immediately on any service where you used `[REDACTED-PASSWORD]` or a similar pattern.** The password captured on the Example Bistro site follows a pattern we believe uses a client name prefix — in this case `MM` for Web Agency. If you use a similar structure on other client engagements (e.g., `CBcontractorlogin21!` for Example Bistro, or a different prefix for each client), every one of those passwords should be considered compromised and changed immediately. An attacker who recognizes this pattern only needs to try known client names to access your other accounts.

2. **Change your password on any service where you used `agency-developer-1` as your email/username**, particularly if the password was the same or similar.

3. **Check for unauthorized activity** on any accounts that may have been accessed with these credentials — email, hosting panels, other client WordPress sites, billing systems, and any tools you access via browser-saved passwords.

4. **Notify any other clients where you used a similar password pattern.** If other client sites share this credential structure, those site owners should be made aware so they can review their own access logs for unauthorized activity.

**One additional item — Elementor Pro license:**

The Elementor Pro license key associated with the Example Bistro site (`[REDACTED-LICENSE-KEY]`) was exposed during this incident. This key is registered to a Web Agency Elementor account. We ask that you log into your plugin-vendor.invalid account at your earliest convenience and rotate this license key. This is a low-urgency item (the exposed key cannot be used to access the site or its data), but it should be completed to prevent potential license seat abuse.

**If you have questions:**

Please contact me directly at [EMAIL-REDACTED]. I am happy to provide additional technical details or answer any questions about the scope of the incident.

We understand this is disruptive and we apologize for the circumstances. Prompt action on the items above will significantly reduce your exposure.

Jay Phillips
Jay Phillips — IR-2026-0310-EXBI

---

## Analyst Notes

- Agency Developer 1's WordPress account (user ID 4, username `webagency`) was deleted March 18, 2026 as part of account reduction hardening. Content was reassigned to SiteOwnerUser (user ID 2).
- The password pattern `[REDACTED-PASSWORD]` is a high-confidence indicator of credential reuse risk across Web Agency's client portfolio — the prefix `MM` and the `contractorlogin` base are likely consistent.
- Agency Developer 1 had SharedHost Provider panel access under the original `siteuser01` account at some point. His panel access has been revoked as part of the SharedHost Provider remediation (`siteuser02` replaced `siteuser01`). No action needed on his end for SharedHost Provider, but worth noting if he raises questions.
- Password has been redacted in the notification body. The actual captured password was `[REDACTED-PASSWORD]` — retained here in the analyst notes for case record only, not transmitted to Agency Developer 1.
- If Agency Developer 1 does not respond within 5 business days, consider escalating to Example Bistro ownership for a decision on further notification steps.

---

## Delivery Record

| Field | Value |
|---|---|
| Sent by | *(name)* |
| Sent date | *(date)* |
| Method | Email to agency-dev-1-agency.invalid |
| Confirmation | *(read receipt / reply / bounce / none)* |
| Follow-up deadline | 5 business days after send date |
| Retained in case file | *(yes/no — screenshot or forwarded copy)* |

---

*Document Reference: IR-2026-0310-EXBI / webagency-breach-notification / Draft March 18, 2026*
