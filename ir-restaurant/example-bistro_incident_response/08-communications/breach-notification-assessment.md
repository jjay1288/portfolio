# Breach Notification Assessment

> Historical communication or assessment. Its dated action items and delivery status are not current confirmations. Initial-access and workstation claims must be read with the [incident report's evidence limits](../01-incident-report/IR-2026-0310-EXBI.md). This public copy does not establish notification delivery or a current legal determination.

## IR-2026-0310-EXBI — example-bistro.invalid

| Field | Value |
|---|---|
| **Case ID** | IR-2026-0310-EXBI |
| **Document** | breach-notification-assessment |
| **Analyst** | Jay Phillips |
| **Date** | March 20, 2026 |
| **Status** | FINAL — notifications pending send |

---

## 1. Incident Summary

Between approximately March 8 and March 18, 2026, example-bistro.invalid (a WordPress site hosted on SharedHost Provider shared hosting, operated by Example Bistro, [REDACTED CLIENT ADDRESS], Washington DC) was compromised by a threat actor operating a commodity Traffic Distribution System (TDS) campaign. The attacker gained access to the SharedHost Provider hosting panel via a ClickFix social engineering attack, installed 15 malicious files, a rogue plugin, and malicious database records. Among those components were three credential-harvesting mechanisms targeting the WordPress admin login.

The compromise was detected March 10, 2026. Full server access was obtained March 18, 2026. Eradication completed March 18, 2026.

**Case reference:** Full technical findings are in `example-bistro-dc-security-report.md` and malware analysis reports MAL-001 through MAL-006.

---

## 2. Data Inventory — What Was Exposed

### 2.1 Confirmed Credential Theft

The credential harvester (`MAL-003`) operated three simultaneous capture points and wrote output to a file disguised as a media image (`Stained_Heart_Red-600x500.png`). The file was recovered and its contents decoded.

| Person | Data Captured | Confirmation | Source |
|---|---|---|---|
| Agency Developer 1 (webagency) | Email: `agency-developer-1` + password | Confirmed plaintext in recovered file | MAL-003, Section 4 |
| Site Owner (SiteOwnerUser) | Username: `site-owner-user` + password | Confirmed plaintext in recovered file | MAL-003, Section 4 |
| Manager ([EMAIL-REDACTED]) | No capture confirmed | XOR entries decrypted — no match | MAL-003, Section 6.2 |
| AgencyAdmin2 | No capture confirmed | No login sessions observed during compromise window | Session reconstruction |

**Exposure window:** March 8, 2026 (malware deployment, per file timestamps) through March 18, 2026 (eradication). Any WordPress admin login during this period was captured.

### 2.2 Intercepted Outgoing Email

The malware's `_wp_mail_queue_log` option recorded metadata (recipient, subject, timestamp) for 7 outgoing emails. Email bodies were not stored in the log.

| # | Recipient | Subject | Sensitivity |
|---|---|---|---|
| 1 | [EMAIL-REDACTED] | WordPress 6.9.2 update notification | Low — automated system email |
| 2 | [EMAIL-REDACTED] | WordPress 6.9.3 update notification | Low — automated system email |
| 3 | [EMAIL-REDACTED] | "New message from EXAMPLE BISTRO" | **Medium** — contact form submission from a site visitor; body not recovered but minimally contains visitor name and email address |
| 4 | [EMAIL-REDACTED] | WordPress 6.9.4 update notification | Low — automated system email |
| 5 | [EMAIL-REDACTED] | New User Registration notification | Low — internal admin event |
| 6 | [EMAIL-REDACTED] | Login Details | Low — responder account setup email |
| 7 | [EMAIL-REDACTED] | New Admin Email Address | Low — system notification |

**The contact form submission (entry 3) is the only email with potential customer PII.** The body is not in our evidence; the metadata alone confirms a visitor submitted a contact form and the submission was visible to the attacker.

### 2.3 Visitor Tracking via sendBeacon

The TDS engine injected client-side JavaScript that transmitted the following to attacker-controlled servers (`webanalytics-cdn.*`) for each site visit during the compromise window:

- Full page URL
- Referrer URL
- User-Agent string (browser and OS)
- Screen resolution
- Browser language setting
- (Implicitly) visitor IP address as a byproduct of the HTTP request

**No names, email addresses, or financial data were collected this way.**

### 2.4 WooCommerce Order Data

**Confirmed by client (March 20, 2026):** WooCommerce is installed on the site but was never used for customer transactions. No customer order records, names, addresses, or payment data exist in the WooCommerce tables. The attacker's automated harvester (`_wc_analytics_data`) was also confirmed empty, consistent with this.

**No WooCommerce customer data was at risk.**

---

## 3. Regulatory Analysis

### 3.1 DC Code § 28-3852 — DC Security Breach Notification Act

**Statute:** DC Code § 28-3852 et seq.

**Definition of personal information (relevant subsection):**
> A user name or email address, in combination with a password or security question and answer that would permit access to an individual's online account.

**Assessment:**

| Affected Party | Data Matches Definition? | DC Resident? | Notification Required? |
|---|---|---|---|
| Agency Developer 1 | **Yes** — email + password captured | Unknown (contractor) | **Yes** — notify regardless of residency; confirmed statutory trigger |
| Site Owner | **Yes** — username + password captured | Likely yes (DC business owner, local IPs) | **Yes** |
| Site visitors (browsing data) | No — no name/email/password combination | Unknown | No |
| Contact form submitter | Possibly — name + email likely in form body, but body not recovered | Unknown | Cannot confirm trigger without body; advisory notification recommended |

**AG notification threshold:** DC § 28-3852(c) requires notification to the DC AG when more than 50 DC residents are affected. That threshold is not met. No AG filing required.

**Timing obligation:** "In the most expedient time possible and without unreasonable delay." Breach confirmed March 18, 2026; notifications should be sent no later than March 25, 2026 (one week).

---

### 3.2 Other State Laws

**Virginia (Va. Code § 18.2-186.6):** Covers SSN, financial account numbers, and driver's license numbers in combination with name. The credential theft does not meet the Virginia trigger. Visitor tracking data does not meet the Virginia trigger. **Not triggered.**

**Maryland (Md. Code, Com. Law § 14-3504):** Similar trigger elements as Virginia. **Not triggered.**

**Other states:** If site visitors from other states had their data collected, no US state breach notification law is triggered by browser tracking data (User-Agent, page URL, referrer) alone without a name/financial data combination. **Not triggered.**

---

### 3.3 PCI DSS

Example Bistro uses Square as its payment processor. Square processes card data externally; card numbers were never present on the WordPress server. **PCI DSS breach notification obligation: not applicable.**

---

### 3.4 GDPR

No evidence that Example Bistro knowingly targets EU users or has a business presence in the EU. **GDPR: not applicable.**

---

## 4. Decision Table

| Obligation | Required? | Action | Deadline | Status |
|---|---|---|---|---|
| Notify Agency Developer 1 (DC § 28-3852) | **Yes** | Send `webagency-breach-notification.md` | March 25, 2026 | DRAFT — pending send |
| Notify Site Owner (DC § 28-3852) | **Yes** | Send `site-owner-breach-notification.md` | March 25, 2026 | DRAFT — pending send |
| Notify DC Attorney General | No | — threshold not met | — | N/A |
| Notify Manager account holder | No — credentials not confirmed captured | Advisory: inform of incident scope | — | Covered in client report |
| Notify site visitors (browsing data) | No — legal trigger not met | Advisory: consider site notice | — | Recommended, not required |
| Notify contact form submitter | Cannot confirm — body not recovered | Covered by general site notice | — | Advisory |
| Notify WooCommerce customers | No — WooCommerce unused, no customer records exist | — | — | **Closed** — confirmed by client March 20, 2026 |
| PCI notification | No | — | — | N/A |
| GDPR notification | No | — | — | N/A |

---

## 5. Advisory: Voluntary Site Notice

While not legally required for visitor tracking data, publishing a brief incident notice on the Example Bistro website is recommended. This is standard practice for businesses that value transparency with their customers. A minimal notice would:

- Acknowledge that the site was affected by a security incident between approximately March 8 and March 18, 2026
- State that visitor browsing activity on the site may have been observed by a third party during that period
- State that no payment card data or customer account information was affected
- Note that the issue has been fully resolved and the site has been secured

This does not constitute an admission of legal liability and reduces reputational risk from visitors who may have noticed the redirect behavior and are wondering what happened.

---

## 6. WooCommerce Customer Assessment ~~(Pending)~~ — CLOSED

**Confirmed by client March 20, 2026:** WooCommerce was installed but never used for customer transactions. No customer records (orders, names, addresses, emails) exist in the WooCommerce tables. This is consistent with the forensic finding that `_wc_analytics_data` was empty.

No WooCommerce-related notification obligation exists. This item is closed.

---

## 7. Notification Drafts

| Document | Recipient | Location |
|---|---|---|
| Agency Developer 1 notification | agency-dev-1-agency.invalid | `08-communications/webagency-breach-notification.md` |
| Site Owner notification | [EMAIL-REDACTED] | `08-communications/site-owner-breach-notification.md` |

Both documents include a Delivery Record section to be completed upon send.

---

## 8. Case File Requirements

The following must be retained in the case file before the engagement is closed:

- [ ] Copy or screenshot of Agency Developer 1 notification as sent
- [ ] Delivery confirmation for Agency Developer 1 notification (reply, read receipt, or bounce record)
- [ ] Copy or screenshot of Site Owner notification as sent
- [ ] Delivery confirmation for Site Owner notification
- [ ] This assessment document (retained as the record that notification obligations were analyzed)
- [ ] Date of analysis and analyst name (above)

---

*Document Reference: IR-2026-0310-EXBI / breach-notification-assessment / March 20, 2026*
