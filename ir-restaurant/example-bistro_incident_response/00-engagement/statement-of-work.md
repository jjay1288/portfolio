# Statement of Work

> Historical engagement document. This public copy does not establish signatures, payment, or completion of every listed deliverable. Status entries retain their source dates.

## Security Incident Response — example-bistro.invalid

| Field | Value |
|---|---|
| **Case ID** | IR-2026-0310-EXBI |
| **Effective Date** | March 10, 2026 |
| **Formalization Date** | March 20, 2026 |
| **Document** | statement-of-work |
| **Version** | 1.0 |

---

## 1. Background

Example Bistro (example-bistro.invalid) operates a WordPress website on SharedHost Provider shared hosting serving as the primary online presence for a restaurant at [REDACTED CLIENT ADDRESS]. On or around March 10, 2026, the Client identified anomalous redirect behavior affecting site visitors. The Client engaged the Consultant to investigate the cause, determine the scope of compromise, remove any malicious code, and secure the site against further attack.

---

## 2. Objectives

1. Determine the root cause and method of compromise
2. Identify all malicious artifacts present on the site and hosting environment
3. Reconstruct the attacker's actions and timeline
4. Preserve forensic evidence in a documented and defensible manner
5. Eradicate all malicious artifacts completely and verifiably
6. Restore the site to a known-clean, hardened state
7. Assess and fulfill applicable breach notification obligations
8. Deliver technical and plain-language documentation of all findings

---

## 3. In-Scope Systems and Data

| System | Details | Authorization Source |
|---|---|---|
| example-bistro.invalid website | All files accessible via SSH/SFTP and wp-admin | Client verbal authorization March 10, 2026; formalized in Engagement Letter |
| SharedHost Provider hosting panel | Account associated with example-bistro.invalid | Client verbal authorization March 18, 2026 |
| WordPress database | example_bistro_db (MySQL) | Implicit in site access authorization |
| WordPress XML export | WXR export taken March 18, 2026 | In scope as part of site content analysis |
| AI1WM backup archive | .wpress backup taken March 8, 2026 | Client provided |
| DNS records | Public records for example-bistro.invalid | Public; no authorization required |
| Attacker infrastructure | Public WHOIS, DNS, and registration data for malicious domains | Public; no authorization required |

---

## 4. Out of Scope

The following are explicitly outside the scope of this engagement unless separately authorized in writing:

- Any systems, accounts, or data not listed in Section 3
- Other websites hosted under the same SharedHost Provider account (unless found to be part of the same compromise and separately authorized)
- Web Agency systems, accounts, or client sites (Agency Developer 1's other engagements)
- Penetration testing or vulnerability scanning of example-bistro.invalid beyond what is necessary to verify remediation
- Forensic examination of any end-user device (e.g., the administrator's Windows PC that may have been compromised via ClickFix)
- Pursuit of attribution beyond what is derivable from artifacts already on the Client's systems
- Legal proceedings or law enforcement liaison (notification of findings is within scope; active law enforcement engagement is not)
- Ongoing managed security monitoring after case closure

---

## 5. Deliverables

| # | Deliverable | Description | Status |
|---|---|---|---|
| 1 | Initial Security Report | Technical findings from backup and DNS analysis | Complete — `example-bistro-dc-security-report.md` |
| 2 | Client-Facing Report (v1) | Plain-language summary for site owner, pre-server-access | Complete — `08-communications/client-report-v1-pre-scan.md` |
| 3 | Client-Facing Report (v2) | Updated plain-language report with full server findings | Complete — `08-communications/client-report-v2-full-findings.md` |
| 4 | Malware Analysis Reports | Per-artifact technical analysis (MAL-001 through MAL-006) | Complete — `04-malware-analysis/` |
| 5 | IOC Registry | Formal indicator of compromise registry with YARA rules and detection signatures | Complete — `03-iocs/IOC-registry.md` |
| 6 | Attack Timeline | Chronological reconstruction of attacker and responder actions | Complete — `02-timeline/timeline.md` |
| 7 | Evidence Package | Collected malware samples, decoded payloads, database evidence export | Complete — `05-evidence/` |
| 8 | Credential Exposure Report | Confirmed compromised accounts, captured credential analysis | Complete — `06-compromised-credentials/` |
| 9 | Pre-Eradication Checklist | Go/no-go checklist for eradication execution | Complete — `07-remediation/pre-eradication-checklist.md` |
| 10 | Eradication Script | Production bash script for coordinated multi-layer malware removal | Complete — `07-remediation/eradicate.sh` |
| 11 | Post-Eradication Verification | Confirmation that all artifacts were removed and site is clean | Pending — to be completed after eradication run |
| 12 | Breach Notification Assessment | Regulatory analysis and notification obligation determination | Complete — `08-communications/breach-notification-assessment.md` |
| 13 | Breach Notification — Agency Developer 1 | Draft notification letter, regulatory basis, delivery record | Draft complete — `08-communications/web-agency-breach-notification.md` |
| 14 | Breach Notification — Site Owner | Draft notification letter, regulatory basis, delivery record | Draft complete — `08-communications/site-owner-breach-notification.md` |
| 15 | Engagement Letter | Formal authorization and terms document | Complete — `00-engagement/engagement-letter.md` |
| 16 | Statement of Work | This document | Complete — `00-engagement/statement-of-work.md` |
| 17 | Lessons Learned Report | Post-incident review and process improvement recommendations | Pending — to be completed at case closure |

---

## 6. Timeline

| Date | Milestone | Status |
|---|---|---|
| March 10, 2026 | Engagement commenced; initial triage begun | Complete |
| March 10, 2026 | Backup and database forensics complete | Complete |
| March 10, 2026 | Initial security report and client report v1 delivered | Complete |
| March 18, 2026 | SharedHost Provider panel access obtained | Complete |
| March 18, 2026 | Full server scan complete; all artifacts identified | Complete |
| March 18, 2026 | Eradication script and checklist complete | Complete |
| March 18, 2026 | Client report v2 delivered | Complete |
| March 18, 2026 | Eradication executed | Complete |
| March 20, 2026 | Breach notification assessment complete | Complete |
| March 20, 2026 | Engagement letter and SOW formalized | Complete |
| By March 25, 2026 | Breach notifications sent to Agency Developer 1 and Site Owner | Pending |
| TBD | Post-eradication verification complete | Pending |
| TBD | Lessons learned report delivered | Pending |
| TBD | Case closed | Pending |

---

## 7. Access Requirements

The following access was required and was provided by or on behalf of the Client:

| Access | Provided By | Date Provided | Notes |
|---|---|---|---|
| AI1WM .wpress backup file | Client | March 10, 2026 | Backup dated March 8, 2026 |
| WordPress XML export | Client | March 18, 2026 | Exported March 18, 2026 |
| SharedHost Provider panel credentials | Client | March 18, 2026 | New admin account `siteuser02` created |
| SSH access to server | Via SharedHost Provider panel | March 18, 2026 | Used for server-side file examination and eradication |
| WordPress admin access | Via credentials / one-time login token | March 17–18, 2026 | Used for plugin audit and DB queries |

---

## 8. Client Responsibilities

The Client is responsible for:

1. **Providing timely access** to all systems and credentials necessary for the engagement
2. **Designating an authorized contact** who can make decisions about the site during the engagement (Site Owner / [EMAIL-REDACTED])
3. **Coordinating the maintenance window** — ensuring no other parties (SharedHost Provider support, developers) make changes to the live site during eradication
4. **Sending the breach notification letters** — or authorizing the Consultant to send them on the Client's behalf — by March 25, 2026
5. **Implementing all post-eradication hardening steps** — credential rotation, 2FA enablement, DMARC record, and admin account reduction — within the timelines specified in the client report
6. **Notifying the Consultant** of any new anomalous behavior observed after case closure within the 30-day post-closure monitoring window
7. **Retaining a copy of all deliverables** — the Consultant will maintain the case file for one year but the Client should keep their own copy

---

## 9. Consultant Responsibilities

The Consultant is responsible for:

1. Conducting all investigation and remediation activities with reasonable care and professional skill
2. Documenting all actions taken on the Client's systems in the eradication log and case file
3. Preserving forensic evidence in a manner that maintains integrity and chain of custody
4. Communicating material findings to the Client in a timely manner
5. Performing eradication only within a coordinated maintenance window and only after the pre-eradication checklist is complete
6. Delivering all items listed in Section 5 within the timelines in Section 6
7. Treating all Client information as confidential per the Engagement Letter

---

## 10. Acceptance Criteria

The engagement is considered complete when:

- [ ] All malicious artifacts identified in the IOC registry have been removed and removal verified
- [ ] WordPress core files have been replaced with verified clean copies
- [ ] All compromised credentials have been rotated
- [ ] 2FA has been enabled on SharedHost Provider panel and WordPress admin accounts
- [ ] Post-eradication verification confirms the site is clean and operating normally
- [ ] Breach notifications have been sent and delivery confirmed or documented
- [ ] Lessons learned report has been delivered
- [ ] Client has signed off on case closure

---

## 11. Change Control

Any material change to the scope of work — including adding systems, extending the engagement timeline, or performing work beyond what is described here — requires written agreement from both parties before the additional work begins. The Consultant will provide a revised scope and fee estimate for any out-of-scope work.

---

*Document Reference: IR-2026-0310-EXBI / statement-of-work / v1.0 / March 20, 2026*
