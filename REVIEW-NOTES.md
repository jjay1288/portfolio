# Public edition review — November 15, 2026

The March incident records were edited for this portfolio. Source dates and analyst/reviewer attribution are retained; Git history preserves the preceding public edition. This review did not repeat the investigation or test the affected systems.

## Evidence corrections

| Topic | Treatment in this edition |
| --- | --- |
| Backup safety | Replaced the clean-backup conclusion in the case summary and evidence inventory. Later child-theme findings mean the archive is not a trusted restore source. Early reports retain their historical wording beneath a correction notice. |
| Initial access | Labelled ClickFix and stolen hosting-panel credentials as a leading explanation, not an established first entry point. The planted payload and shared infrastructure do not prove workstation execution or identify an operator. |
| Credential and email exposure | Distinguished recovered captures from evidence of external transfer; seven mail-log entries do not establish interception of all email. |
| Payment data | Limited the conclusion to the reviewed WordPress records. External payment systems were outside this investigation. |
| Return to service | Removed the claim that an active WAF proved there was no exposure when maintenance mode was lifted unintentionally. |
| Platform rebuild | Removed unsupported cost, performance, delivery-time, and immunity claims. Static publishing can reduce server-side components but still relies on protected accounts and deployment systems. |
| Writing | Shortened repetitive introductions, replaced dramatic descriptions with observed behavior, removed decorative status symbols, and corrected an authorship inference based only on tracking parameters. |

## Open questions

- The first compromise point remains unresolved. Available HTTPS logs begin after the recorded deployment window.
- Some March 18 containment entries use `10:05 PDT`; eradication entries use `14:37–14:38 UTC`. The source order and timezone labels conflict. They are retained and flagged, not silently converted into a fabricated sequence.
- Early reports call the archive a March 8 backup, while the later inventory records collection on March 10. Archive creation time and acquisition time need verification against original metadata.
- The evidence inventory lists a missing panel-error-log artifact. This review did not recover it.
- Workstation inspection, notification delivery, and later completion of remaining follow-ups are not established by the public record.
- Engagement terms and notification documents are historical drafts or case records. Their presence does not establish signatures, payment, delivery, or a current legal determination.

Recorded attribution and technical artifact strings are retained. The corrections concern the interpretation and presentation of the evidence.
