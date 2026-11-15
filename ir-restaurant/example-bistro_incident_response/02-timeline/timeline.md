# Incident timeline — IR-2026-0310-EXBI

Times below are UTC. PDT equivalents are included where the response notes used server-local time. File modification times describe the retained metadata; they do not prove when the first compromise occurred.

| Date/time (UTC) | Event | Basis |
| --- | --- | --- |
| March 8 | Backup created with a March 8 timestamp in its filename | Retained archive listing; exact filename timezone not established |
| March 8, 22:15–22:16 | Several captured malicious files carry modification times in this interval | Original evidence tar metadata; not proof of initial access |
| March 10 | Archive catalogued and scanned; 18,897 entries and a 20.88 MB database export recorded | Listing and scan-output headers |
| March 10 onward | Available authentication reconstruction begins | Session and access-log analysis; earlier access remains unresolved |
| March 11–16 | Backdoor requests and matching PHP errors documented | Preserved server-analysis report; underlying access logs are not included in the public repository |
| March 18 | Live samples, credential-capture file, and database evidence collected | Evidence packages and database export |
| March 18, 17:05 (10:05 PDT) | Ronald Phillips applied PHP deny rules and recorded blocked requests to five webshells | Containment notes and evidence inventory EVD-020 |
| March 18, approximately 21:37 (14:37 PDT) | Coordinated cleanup and evidence capture began | Local timestamp in script-generated snapshot name; new archive directory and manifest timestamp 21:37:48 UTC |
| March 18, after cleanup | Manual database/account fixes, credential rotation, core-checksum checks, and webshell-removal verification recorded | Response notes and recovery checklist; exact minute-by-minute completion times not independently established |
| March 18, after cleanup | Maintenance mode lifted during a rewrite flush; site returned to service with WAF active | Recovery record |
| March 18, post-cleanup review | Core checksums and known-path checks passed; Wordfence reported no issues | Recorded verification outcomes |
| March 20 | Client non-use of WooCommerce for customer transactions recorded | Private case update; consistent with the empty harvesting store |

The initial-access date, endpoint execution, and later completion of outstanding follow-up actions are not established by the retained artifacts.

[Incident report](../01-incident-report/IR-2026-0310-EXBI.md) · [Evidence inventory](../05-evidence/evidence-inventory.md)
