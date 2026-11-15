# Evidence Inventory & Chain of Custody

| Field          | Value                        |
|----------------|------------------------------|
| **Case ID**    | IR-2026-0310-EXBI            |
| **Document**   | evidence-inventory           |
| **Date**       | March 18, 2026               |
| **Classification** | CONFIDENTIAL               |
| **Analyst**    | Jay Phillips                 |
| **Subject**    | Example Bistro (example-bistro.invalid) -- Evidence Inventory |

---

## 1. Evidence Inventory

All evidence items are catalogued below with unique identifiers, descriptions, and integrity information. Evidence must be handled in accordance with standard digital forensics chain of custody procedures.

| Evidence ID | Description | Source | Date Collected | Collected By | Storage Location | Hash (SHA256) | Status |
|-------------|-------------|--------|----------------|--------------|------------------|---------------|--------|
| EVD-001 | WordPress AI1WM backup (.wpress file, 4.89 GB, 18,897 files) | SharedHost Provider hosting panel -- All-in-One WP Migration export | March 10, 2026 | Jay Phillips | `audit/src/` | `38e0d5851d84fccc56f99dbdb479d717a7f3f05afc5accc8021b1fd979b69a2d` | Initial pattern searches negative; see scope notes |
| EVD-002 | Extracted database dump (database.sql, 20.88 MB) | Extracted from EVD-001 | March 10, 2026 | Jay Phillips | `audit/` | `960650794a6a4cd3e34c6879af5ed952858f7ea6e8cc66a842507d375379112b` | Initial pattern searches negative; see scope notes |
| EVD-003 | Wpress file listing (wpress-file-listing.txt) | Extracted from EVD-001 -- full directory listing of backup contents | March 10, 2026 | Jay Phillips | `audit/` | `929bb2fb30d6892f49ae73a2eb10661d6d2a5ac817c2cd452b6e71baaa8ebeeb` | Complete |
| EVD-004 | Malware scan results (wpress_scan_results.txt, 190 KB) | Automated scan of EVD-001 contents | March 10, 2026 | Jay Phillips | `audit/` | `5056b62d8dabae124d4400afa147a5a44ddd38e94ba82ea37a704ae3dcaf8c72` | Complete |
| EVD-005 | WordPress XML export (example-bistro.WordPress.2026-03-18.xml, 4.1 MB) | Live site WordPress export tool | March 18, 2026 | Jay Phillips | `audit/` | `37bb42253140ccc459d7f40bb6f36ff96f4caf455d77bf64f19d4fa408da3bdb` | Initial pattern searches negative; see scope notes |
| EVD-006 | Decoded PowerShell payload (decode_payload.ps1) | Decoded from SharedHost Provider panel SSH/SFTP username field -- ClickFix attack | March 18, 2026 | Jay Phillips | `audit/` | `5f622b768053f42fd099ef93ba0c9ce6f0c4f9580c209e2d768301264cd2cd3c` | Decoded -- MALICIOUS |
| EVD-007 | Malicious domain research (malicious-domain-research.md) | OSINT research on C2 and staging domains | March 10, 2026 | Jay Phillips | `audit/` | N/A (research document) | Complete |
| EVD-008 | Server-side scan findings (server-scan-findings.md) | SSH-based server scan of live environment | March 18, 2026 | Jay Phillips | `audit/` | N/A (report document) | Complete |
| EVD-009 | Client-facing report (example-bistro-dc-client-report.md) | Analyst-produced deliverable | March 18, 2026 | Jay Phillips | `audit/` | N/A (report document) | Complete |
| EVD-010 | Technical security report (example-bistro-dc-security-report.md) | Analyst-produced deliverable | March 18, 2026 | Jay Phillips | `audit/` | N/A (report document) | Complete (updated March 18) |
| EVD-011 | Credential dump file contents | Extracted from `Stained_Heart_Red-600x500.png` on live server (`wp-content/uploads/2024/06/`) | March 18, 2026 | Jay Phillips | `05-evidence/malware-samples/exfil-data/Stained_Heart_Red-600x500.png` | `5a9799298236c327f77ed0c2200c7fbb213cbe44b4c943f05456bac5399c23d0` | Collected |
| EVD-012 | Intercepted email log | Extracted from `_wp_mail_queue_log` WordPress database option | March 18, 2026 | Jay Phillips | Documented in analysis reports | N/A (DB option value documented in MAL-004 analysis) | Documented |
| EVD-013 | Admin activity surveillance log | Extracted from `_wp_site_activity` WordPress database option | March 18, 2026 | Jay Phillips | Documented in analysis reports | N/A (DB option value documented in MAL-004 analysis) | Documented |
| EVD-014 | SharedHost Provider panel error logs | Provided by client (Site Owner) | March 18, 2026 | Jay Phillips | `audit/` | **FILE NOT ON DISK** -- not found in local evidence storage. Must be re-collected from client or confirmed as never saved to disk. | MISSING -- Requires re-collection |
| EVD-015 | Active child theme `functions.php` with bounded `__mu_deployer__` payload | Live server: `wp-content/themes/hello-biz-child/functions.php` | March 18, 2026 | Jay Phillips | `05-evidence/malware-samples/modified-theme/hello-biz-child.functions.php` | `5b278a019ef44c1c0a14cec22cbcef8450a307a68e48dd09485bceead2b8c70f` | Collected |
| EVD-016 | Hidden XOR TDS config/cache file | Live server: `wp-content/uploads/.7ed1995199.tmp` | March 18, 2026 | Jay Phillips | `05-evidence/malware-samples/persistence/7ed1995199.tmp` | `79734248db2a995f28abd46c74042f9165e22adf3917ad0e57c260d14c9e6524` | Collected |
| EVD-017 | Redirect guard operational log | Live server: `wp-content/uploads/.redirect_blocked.log` | March 18, 2026 | Jay Phillips | `05-evidence/malware-samples/persistence/redirect_blocked.log` | `40c026911b6bc7a472af995eefaa18610d87a8c87b94a8e7bc3c0ab2274254aa` | Collected |
| EVD-018 | Dormant `kaon` theme backdoor sample | Live server: `wp-content/themes/kaon/functions.php` | March 18, 2026 | Jay Phillips | `05-evidence/malware-samples/modified-theme/kaon.functions.php` | `01ae9f5b8f5ea8212896bfff1a9a74e6a9bb2237b76896f5df21839f349484ae` | Collected |
| EVD-019 | Dormant `lemonchili` theme backdoor sample | Live server: `wp-content/themes/lemonchili/functions.php` | March 18, 2026 | Jay Phillips | `05-evidence/malware-samples/modified-theme/lemonchili.functions.php` | `3fb4438893acdf431a4e11da603600f9b2b9e9c7fcf0da02b1934fe2edd1b1cd` | Collected |
| EVD-020 | Pre-containment webshell reachability proof | HTTP response tests confirming webshells returned `200 OK` via Hide My WP bypass parameter (`?bypass_key=[REDACTED-BYPASS-KEY]`) despite maintenance mode; post-containment tests confirming `503` after `.htaccess` PHP deny rules deployed to 5 directories | March 18, 2026 | Reviewer | Documented in supplemental-manual-remediation-report.md and timeline v1.3 | N/A (test results) | Documented |
| EVD-021 | Eradication evidence snapshot | Pre-eradication filesystem captures taken by `eradicate.sh` immediately before removal: `hello-biz/functions.php`, `hello-biz-child/functions.php`, `kaon/functions.php`, `lemonchili/functions.php`, `.7ed1995199.tmp`, `.redirect_blocked.log`, `.backup_time`, `SHA256SUMS.txt` | March 18, 2026 14:37 UTC | Jay Phillips (automated via eradicate.sh) | `05-evidence/eradication-evidence-20260318-143745.tar.gz` (also retained on server at `/home/siteuser02/eradication-evidence-20260318-143745/`) | Per `SHA256SUMS.txt` inside archive | Collected |

---

## 2. Evidence Notes

### EVD-001: WordPress AI1WM Backup
The 4.89 GB archive contains 18,897 recorded files and an extracted database. Initial pattern searches were negative, but later child-theme analysis identified malware-restoration code in backup-derived content. EVD-001 is evidence of the compromised environment, not a trusted restoration source. The negative searches of EVD-002 and the EVD-005 content export likewise do not establish the safety of the complete site.

### EVD-006: Decoded PowerShell Payload
The hosting panel SSH/SFTP username field contained an encoded PowerShell downloader with a ClickFix-style pretext. Decoding shows download, execution, and file-removal behavior. The stored artifact does not prove execution on a workstation or the behavior of the downloaded second stage.

### EVD-011: Credential Dump
The file `Stained_Heart_Red-600x500.png` is not a valid image file. It contains cleartext and XOR-encrypted WordPress credentials captured by the credential stealer components. Contains 9 entries total: 4 plaintext for webagency, 2 plaintext for SiteOwnerUser, and 3 XOR-encrypted entries. All 3 XOR-encrypted entries were decrypted on March 18, 2026 (see MAL-003 Section 6.1) and found to be re-captures of the same two accounts (webagency and SiteOwnerUser). No additional compromised accounts were identified.

### EVD-014: SharedHost Provider Panel Error Logs (MISSING)
This evidence item was referenced during analysis but the file is not present on disk in the expected storage location (`audit/`). The file was reportedly provided by the client (Site Owner) but may not have been saved to the local evidence directory, or may have been provided verbally/via screenshot rather than as a downloadable file. **Action required:** Re-collect from client or confirm with case lead whether this evidence was captured in another form (e.g., screenshot, verbal description documented in case notes).

### EVD-012 & EVD-013: Database Surveillance
The attacker configured WordPress hooks to intercept all outgoing emails (`wp_mail`) and log all administrator activity. These logs were stored as serialized data in custom options table entries, providing the attacker with ongoing intelligence about site operations and communications.

---

## 3. Chain of Custody Log

| Date | Action | Performed By | Notes |
|------|--------|--------------|-------|
| March 10, 2026 | Case opened; AI1WM backup (EVD-001) obtained from SharedHost Provider panel | Jay Phillips | Backup downloaded via SharedHost Provider file manager. Case initiated based on client report of suspicious site behavior. |
| March 10, 2026 | Backup analyzed; database extracted (EVD-002); file listing generated (EVD-003) | Jay Phillips | Wpress archive extracted and catalogued. Database dump isolated for separate analysis. Initial malware scan conducted (EVD-004). |
| March 10, 2026 | Domain research completed (EVD-007) | Jay Phillips | OSINT investigation of C2 domains, staging infrastructure, and threat actor indicators. |
| March 18, 2026 | SharedHost Provider panel access obtained | Jay Phillips | Client provided panel credentials. New admin user `siteuser02` created. ClickFix payload discovered in SSH/SFTP username field and decoded (EVD-006). |
| March 18, 2026 | SSH access established via new credentials (siteuser02) | Jay Phillips | Direct server access enabled for live environment forensic analysis. Previous credentials compromised by ClickFix attack. |
| March 18, 2026 | WordPress XML export collected (EVD-005) | Jay Phillips | Full content export from live WordPress installation for content integrity verification. |
| March 18, 2026 | Full server-side scan completed (EVD-008) | Jay Phillips | Comprehensive file system analysis via SSH. 15 malicious files identified across 5 persistence layers. Credential dump, surveillance logs, and hidden admin account discovered. |
| March 18, 2026 | Additional live host artifacts copied to local evidence storage (EVD-015 through EVD-019) | Jay Phillips | Pulled active child-theme payload, hidden XOR temp file, redirect guard log, and dormant `kaon`/`lemonchili` backdoor files via SSH/SCP. Local SHA256 hashes matched remote SHA256 hashes at collection time. |
| March 18, 2026 | Case upgraded to Tier 1 Incident Response | Jay Phillips | Severity escalated based on findings: active credential theft, 5-layer persistence, hidden admin account, database-level persistence, and ClickFix social engineering attack on site owner. Case reclassified from security audit to full incident response. |
| March 18, 2026 10:05 PDT | Emergency containment: `.htaccess` PHP execution deny rules deployed to 5 webshell directories | Reviewer | Hide My WP bypass parameter (`?bypass_key=[REDACTED-BYPASS-KEY]`) identified as allowing direct webshell access despite maintenance mode. Containment `.htaccess` files deployed to `wp-includes/fonts/`, `wp-content/upgrade/`, `wp-content/uploads/woocommerce_uploads/`, `wp-content/uploads/`, and `wp-content/languages/`. All 5 webshell URLs confirmed returning `503` post-deployment. Documented as EVD-020. |
| March 18, 2026 | EVD-001 (.wpress archive) hash integrity verified | Reviewer | SHA256 hash recomputed from local copy at `audit/src/www-example-bistro-dc-com-20260308-160015-9uc8zlqzsue6.wpress`. Computed hash `38e0d5851d84fccc56f99dbdb479d717a7f3f05afc5accc8021b1fd979b69a2d` matches recorded hash. Archive integrity confirmed -- no tampering detected. |
| March 18, 2026 | XOR-encrypted credential entries (EVD-011) decrypted | Reviewer | 3 XOR-encrypted entries in `Stained_Heart_Red-600x500.png` decrypted using site hostname `www.example-bistro.invalid` and key derivation formula from MAL-003 Section 6. All entries are re-captures of webagency and SiteOwnerUser accounts. Manager account ([EMAIL-REDACTED]) NOT present. Decryption procedure and results documented in MAL-003 Sections 6.1-6.2 and CRED-001 Section 2.3. |
| March 18, 2026 | EVD-014 confirmed not on disk | Reviewer | SharedHost Provider panel error logs (EVD-014) searched for in all evidence storage locations. File not found. Flagged for re-collection from client or confirmation with case lead. |
| March 18, 2026 14:37–14:38 UTC | Full eradication executed; EVD-021 collected | Jay Phillips | `eradicate.sh` ran all 8 removal layers. Pre-removal snapshot of all targeted files captured automatically by script to `/home/siteuser02/eradication-evidence-20260318-143745/` with SHA256 manifest. Archive downloaded locally as `05-evidence/eradication-evidence-20260318-143745.tar.gz` (EVD-021). |
| March 18, 2026 ~14:45 UTC | EVD-021 downloaded and extracted locally | Jay Phillips | Eradication evidence snapshot downloaded via SCP. SHA256SUMS.txt inside archive verified against expected pre-eradication malware file hashes. |

---

## 4. Evidence Hash Verification Summary

All evidence items with computable SHA256 hashes have been verified. The table below summarizes hash status for every evidence item.

| Evidence ID | Hash Status | Notes |
|-------------|-------------|-------|
| EVD-001 | **VERIFIED** | Recomputed from local copy; matches recorded hash |
| EVD-002 | Recorded | Hash recorded at extraction time |
| EVD-003 | Recorded | Hash recorded at generation time |
| EVD-004 | Recorded | Hash recorded at scan completion |
| EVD-005 | Recorded | Hash recorded at export time |
| EVD-006 | Recorded | Hash recorded at decode time |
| EVD-007 | N/A | Research document (not binary evidence) |
| EVD-008 | N/A | Report document (not binary evidence) |
| EVD-009 | N/A | Report document (not binary evidence) |
| EVD-010 | N/A | Report document (not binary evidence) |
| EVD-011 | Recorded | Hash recorded at collection from live server |
| EVD-012 | N/A | Database option value (documented in MAL-004) |
| EVD-013 | N/A | Database option value (documented in MAL-004) |
| EVD-014 | **MISSING** | File not on disk; requires re-collection |
| EVD-015 | Recorded + verified at collection | Local hash matched remote hash at SCP time |
| EVD-016 | Recorded + verified at collection | Local hash matched remote hash at SCP time |
| EVD-017 | Recorded + verified at collection | Local hash matched remote hash at SCP time |
| EVD-018 | Recorded + verified at collection | Local hash matched remote hash at SCP time |
| EVD-019 | Recorded + verified at collection | Local hash matched remote hash at SCP time |
| EVD-020 | N/A | Test results (documented in reports) |

---

## 5. Evidence Handling Sign-Off

This section provides formal acknowledgment that evidence was handled in accordance with the requirements specified in Section 6 below.

### Analyst Sign-Off

| Role | Name | Responsibilities | Signature / Acknowledgment |
|------|------|-----------------|---------------------------|
| **Lead Analyst** | Jay Phillips | Primary evidence collector and analyst. Responsible for initial collection (EVD-001 through EVD-014), server-side artifact collection (EVD-015 through EVD-019), hash computation, and chain of custody documentation. | ________________________________ Date: ________ |
| **Reviewer** | *(Reviewer name)* | Independent review of evidence integrity, hash verification, XOR credential decryption, containment actions (EVD-020), and evidence inventory audit. | ________________________________ Date: ________ |

### Witness Acknowledgment

| Statement | Name | Signature | Date |
|-----------|------|-----------|------|
| I confirm that evidence items EVD-001 through EVD-020 were handled in accordance with the chain of custody procedures documented in this inventory. I have reviewed the hash verification summary and confirm no evidence of tampering. | ________________________________ | ________________________________ | ________ |

### Outstanding Items Requiring Resolution

| Item | Issue | Required Action | Assigned To | Due Date |
|------|-------|----------------|-------------|----------|
| EVD-014 | File not located on disk | Re-collect SharedHost Provider panel error logs from client, or confirm with case lead that this evidence was captured in another form | Jay Phillips | Before case closure |
| EVD-002 through EVD-006 | Hashes recorded but not independently re-verified | Recompute SHA256 hashes from local copies and confirm they match recorded values | Reviewer | Before case closure |

---

## 6. Evidence Handling Requirements

1. **Storage**: All digital evidence must be stored in encrypted volumes with access limited to authorized incident response personnel.
2. **Integrity**: SHA256 hashes must be computed for all binary evidence at time of collection and verified before any analysis.
3. **Copies**: Work only with forensic copies. Original evidence files must remain unmodified in the evidence storage directory.
4. **Retention**: All evidence must be retained for a minimum of 12 months following case closure, or longer if required by legal proceedings.
5. **Disposal**: Evidence disposal requires written authorization from the case lead and the client.

---

*Document Reference: IR-2026-0310-EXBI / evidence-inventory / Generated March 18, 2026*
