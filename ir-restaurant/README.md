# WordPress compromise: investigation and recovery

**March 2026 · Small-business website · Incident handler: Jay Phillips**

The first symptom was intermittent visitor redirection. Server inspection later found webshells, credential-capture hooks, a hidden administrator account, and persistence in files and the WordPress database. Removing the visible redirect code would have left several ways to regain access.

This case records the response for a restaurant, identified here as **Example Bistro**. Names, contact details, and client infrastructure identifiers have been replaced. The reports attribute investigation and remediation work to Jay Phillips and separately record provider support and reviewer actions.

## Investigation

The case records analysis of an archive containing 18,897 files, a 20.88 MB database export, a WordPress content export, and live filesystem, authentication, and server-log evidence. The [evidence inventory](example-bistro_incident_response/05-evidence/evidence-inventory.md) identifies retained sources and missing items; raw evidence is not included here.

Three findings changed the response:

- **The archive was not a clean restore point.** Initial searches returned no matches for the selected patterns. Later analysis identified a malware-restoration block in the child theme and rejected both the March 10 archive and the oldest retained hosting backup as trusted theme sources. A negative search did not establish that the backup was clean.
- **Maintenance mode did not contain the webshells.** A bypass parameter still allowed direct requests to five malicious PHP files. The reviewer recorded directory-level PHP deny rules and follow-up request checks. Exact timing needs reconciliation: some containment entries are labelled PDT while eradication is recorded in UTC.
- **Persistence crossed several locations.** Mu-plugins, a cache bootstrap, theme code, scheduled tasks, and database options could restore removed components. Cleanup had to address the known mechanisms together.

## Response and verification

The records describe a coordinated cleanup on March 18, followed by manual correction of database and account-removal checks that the script had not resolved. WordPress core and the parent theme were reinstalled from vendor sources; the malicious child-theme block was removed; the hidden administrator and known persistence residues were deleted; and administrator/database credentials and session salts were rotated.

Verification recorded matching WordPress core checksums, removal of the known webshell paths, and a Wordfence scan reporting no issues. These checks support the reported cleanup of the identified artifacts. They do not establish the absence of every possible implant or resolve the unverified administrator workstation.

The [post-eradication checklist](example-bistro_incident_response/07-remediation/post-eradication-checklist.md) separates completed work from follow-up items such as MFA, workstation review, and provider confirmation. It also records that maintenance mode was lifted unintentionally during a rewrite flush. A running WAF alone does not establish that this transition carried no exposure.

## What the evidence establishes

| Finding | Evidence and limit |
| --- | --- |
| WordPress credentials were captured | Two credential pairs were recovered from attacker-controlled storage on the server. This is distinct from proving every later use or external transfer. |
| Email content was intercepted by site malware | Seven entries were recorded in the malware's mail log. The record does not establish capture of every email sent during the incident. |
| A ClickFix-style payload was planted in the hosting panel | Decoded code referenced the same domain family as the website malware. This supports a connection; it does not prove which workstation executed it or how the first compromise occurred. |
| The retained backup was already compromised | Later theme findings invalidate the early clean-backup conclusion. Pre-transfer infection and post-transfer panel compromise remain possible explanations. |
| WooCommerce harvesting code was present | The case records no WooCommerce customer/order data, an empty harvesting store, and payment processing outside WordPress. No payment-data theft was identified within the reviewed WordPress evidence; the external payment system was not assessed here. |

## Technical records

- [Incident report](example-bistro_incident_response/01-incident-report/IR-2026-0310-EXBI.md): findings, response, outcome, and unresolved access path.
- [Timeline](example-bistro_incident_response/02-timeline/timeline.md): dated observations and response actions, with hypotheses labelled.
- [Persistence analysis](example-bistro_incident_response/04-malware-analysis/MAL-005-persistence.md): dependencies that made partial cleanup insufficient.
- [Authentication reconstruction](example-bistro_incident_response/05-evidence/auth-session-reconstruction.md): what the login records can and cannot attribute.
- [IOC registry](example-bistro_incident_response/03-iocs/IOC-registry.md) and [analysis scripts](example-bistro_incident_response/09-tools/): detection and offline-analysis material.
- [Complete case index](example-bistro_incident_response/README.md): supporting reports, historical communications, and checklists.

Early client and technical reports remain as dated records. Their superseded conclusions are called out at the top of each document. See the [public review notes](../REVIEW-NOTES.md) for corrections and outstanding evidence gaps.
