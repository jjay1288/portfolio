# WordPress compromise: investigation and recovery

**March 2026 · Small-business website · Incident handler: Ronald Phillips**

A restaurant's WordPress site was intermittently redirecting visitors to unrelated sites. The investigation found five webshells, captured administrator credentials, a hidden account, and several mechanisms that restored malware after partial cleanup. The response combined evidence collection, containment, coordinated removal, credential rotation, and verification.

The client is identified here as **Example Bistro**. I was the sole responder, handling evidence collection, analysis, containment, eradication, credential recovery, and verification. Client identities, credentials, and raw malware are excluded from this portfolio.

## Investigation and decisions

**A negative backup search was insufficient.** The March 8 backup was catalogued on March 10: 18,897 entries and a 20.88 MB database export. Searches found no occurrences of the selected redirect domains, but returned many matches for general PHP functions. Those results required interpretation and did not certify the archive as clean.

The archive listing records the child theme's `functions.php` at **1,095 bytes**. The later live-server evidence contains a **170,140-byte** version with a bounded malware-deployment block. This establishes a substantial difference between the archived listing and the captured live file; it does not prove the larger payload was in the archive. Given the remaining uncertainty about backup integrity, cleanup used fresh vendor files and targeted removal of the live child-theme block.

**Maintenance mode was not effective containment.** I found that a bypass parameter still allowed requests to five webshells. I applied directory-level PHP deny rules and checked that requests were blocked across three test variants. The snapshot and server-local time basis place this containment before the coordinated cleanup on March 18.

**Removing one component would leave restoration paths.** Static inspection confirmed a database-backed cache bootstrap, theme backdoors, a malicious child-theme deployment block, and distributed webshells. Cleanup had to address these together, followed by manual fixes where script checks showed residual database options or an account-removal problem.

## Findings and outcome

The retained credential file contains **nine records: six plaintext and three encoded**. Offline decoding of the three encoded entries matched the same two account/password pairs already captured in plaintext. The database export contains **seven email-metadata entries (recipient, subject, and timestamp)**, **eleven administrator-activity entries**, and an empty WooCommerce harvesting store. These are observed captures, not proof of every subsequent use or external transfer.

Cleanup began at approximately **21:37 UTC on March 18 (14:37 PDT)**. The evidence snapshot's archive timestamps and seven matching manifest hashes substantiate that time and preserve the files as captured. The response records then describe core and parent-theme reinstalls, removal of the malicious child-theme block and other persistence, deletion of the hidden administrator, password rotation, and session invalidation.

The recorded post-cleanup checks include matching WordPress core checksums, removal of the known webshell paths, and a Wordfence scan reporting no issues. Maintenance mode was lifted unintentionally during a rewrite flush; the site returned to service with its WAF active. The verification supports removal of the identified artifacts, while workstation review, MFA confirmation, and provider follow-up remained open in the retained record.

## Initial access and scope limits

A ClickFix-style PowerShell downloader was found in a hosting-panel field. Its download domain overlaps with the website malware's infrastructure. That supports an association, but does not establish the original entry point, execution on a particular workstation, or the identity of the operator. The available access-log reconstruction starts after the apparent deployment window.

The client reported that payments were processed outside WordPress. The retained WordPress evidence does not show payment-data theft; external payment systems were outside this investigation.

## Supporting work

- [Technical incident report](example-bistro_incident_response/01-incident-report/IR-2026-0310-EXBI.md)
- [Timeline](example-bistro_incident_response/02-timeline/timeline.md)
- [Evidence inventory and verification](example-bistro_incident_response/05-evidence/evidence-inventory.md)
- [Persistence analysis](example-bistro_incident_response/04-malware-analysis/MAL-005-persistence.md)
- [Authentication reconstruction](example-bistro_incident_response/05-evidence/auth-session-reconstruction.md)
- [Analysis scripts](example-bistro_incident_response/09-tools/) and [complete technical index](example-bistro_incident_response/README.md)

*Public case edition: November 15, 2026. Incident results describe March 2026; they are not a current assessment of the site.*
