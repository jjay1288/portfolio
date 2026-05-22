# Breach Notification — Site Owner (SiteOwnerUser)

| Field | Value |
|---|---|
| **Case ID** | IR-2026-0310-EXBI |
| **Document** | site-owner-breach-notification |
| **Date** | March 20, 2026 |
| **From** | Jay Phillips (Incident Responder, on behalf of Example Bistro) |
| **To** | Site Owner — [EMAIL-REDACTED] |
| **Subject** | URGENT: Your Credentials Were Compromised — Example Bistro Website Incident |
| **Status** | DRAFT — pending send |
| **Sent Date** | *(update when sent)* |
| **Delivery Confirmation** | *(update when confirmed)* |

---

## Regulatory Basis

**Applicable law:** DC Code § 28-3852 (DC Security Breach Notification Act)

**Trigger:** The statute defines "personal information" to include *"a user name or email address, in combination with a password or security question and answer that would permit access to an individual's online account."* Site Owner's WordPress username (`site-owner-user`) and password were captured in confirmed plaintext and stored on the compromised server. This is a direct match to the statutory definition.

**Additional context:** Site Owner is understood to be the site owner and a DC-area resident (login sessions confirmed from IP `[IP-REDACTED]`, attributed to her). DC § 28-3852 applies directly.

**Obligation:** Notification must be made "in the most expedient time possible and without unreasonable delay." No AG filing required (fewer than 50 DC residents affected).

**Case record requirement:** A copy of this notification and evidence of delivery must be retained in the case file.

---

## Email Draft

**To:** [EMAIL-REDACTED]
**Subject:** URGENT: Your Login Credentials Were Stolen — Example Bistro Website Incident

---

Site Owner,

As part of our ongoing investigation into the Example Bistro website compromise, I need to inform you directly that your WordPress administrator credentials were among those captured by the attackers.

**What happened:**

Between March 8 and March 18, 2026, the Example Bistro website was compromised by a threat actor who installed credential-stealing software inside the WordPress login system. This software silently recorded usernames and passwords each time anyone logged into the WordPress admin panel.

**What was captured:**

Your credentials were recorded on multiple occasions:

- **Username:** site-owner-user
- **Password:** redacted (you will recognize it — it is the password you were using for WordPress admin access during this period)

These credentials were found stored in a file on the compromised server. They have been confirmed as fully exposed to the attacker and should be considered compromised on any service where they were used.

**What we have already done:**

- Your WordPress administrator password for example-bistro.invalid has been rotated as part of the site cleanup.
- The malware responsible for capturing credentials has been fully removed from the site.
- All active WordPress sessions were terminated during remediation.
- The file containing the captured credentials has been deleted from the server (a copy was preserved for forensic evidence before deletion).

**What you need to do — urgently:**

1. **If you used this password on any other service** — email, banking, other websites, Apple ID — change it on every one of those services immediately. Even a strong password is compromised once it has been captured.

2. **Change your SharedHost Provider panel password** if you haven't already. The attacker had access to the SharedHost Provider panel during the compromise. While your panel password itself may not have been captured by the WordPress credential stealer, it is prudent to rotate it now.

3. **Enable two-factor authentication (2FA)** on your SharedHost Provider account and your new WordPress admin account. This ensures that even if a password is captured in the future, it alone is not enough to gain access.

4. **Check your email account** ([EMAIL-REDACTED] / [EMAIL-REDACTED]) for any unusual activity or login notices. If the attacker recognizes the captured WordPress password from other services, your email could also be at risk.

5. **Check for any unfamiliar charges or account changes** on services linked to the email addresses associated with your Example Bistro hosting and administration.

**What this does NOT affect:**

Your website content — pages, menus, photos, and posts — was not damaged or altered. Your customer payment data processed through Square is not at risk (card numbers are handled on Square's servers, not on your website). The malicious code has been fully removed and the site has been secured.

**If you have questions:**

Please contact me directly at [EMAIL-REDACTED]. I am available to walk through any of the above steps with you or answer questions about what was found.

I know this is a lot to take in. The most important step is changing any password that was the same as your Example Bistro WordPress password, starting with email and banking accounts.

Jay Phillips
Jay Phillips — IR-2026-0310-EXBI

---

## Analyst Notes

- Site Owner's current WordPress password was rotated during eradication. The notification instructs her to change passwords on *other services* where the captured password may have been reused.
- The captured password (`[REDACTED-PASSWORD]`) is high-entropy and appears password-manager-generated. Reuse on other services is less likely than with Agency Developer 1's pattern-based password, but still must be assumed until confirmed otherwise.
- Site Owner also had an email intercepted by `_wp_mail_queue_log` (to `[EMAIL-REDACTED]` — subject: "New Admin Email Address"). This is a system notification and does not contain sensitive customer data, but it confirms the attacker saw this email address.
- Site Owner's login at `[IP-REDACTED]` (Firefox 148, macOS 10.15) is attributed to legitimate owner activity. No suspicious post-compromise logins are attributed to her account.
- The Manager account (`[EMAIL-REDACTED]`) was also attributed to Site Owner or the site owner in the session reconstruction. Confirm with Site Owner whether she also controls the Manager account — if so, she should be aware that account's activity was also monitored by the attacker's surveillance log, even though its credentials were not captured by the stealer.

---

## Delivery Record

| Field | Value |
|---|---|
| Sent by | *(name)* |
| Sent date | *(date)* |
| Method | Email to [EMAIL-REDACTED] |
| Confirmation | *(read receipt / reply / bounce / none)* |
| Follow-up deadline | 5 business days after send date |
| Retained in case file | *(yes/no — screenshot or forwarded copy)* |

---

*Document Reference: IR-2026-0310-EXBI / site-owner-breach-notification / Draft March 20, 2026*
