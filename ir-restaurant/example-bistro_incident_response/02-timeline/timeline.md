# Incident Timeline -- IR-2026-0310-EXBI

> Timing qualification: the source records containment at `10:05 PDT` on March 18 and eradication at `14:37–14:38 UTC` the same day, conflicting with the stated sequence. The labels are retained pending verification. The initial-access rows below are hypotheses, not endpoint observations.

**Case:** Example Bistro Website Compromise
**All timestamps in UTC unless noted. Server timestamps are PDT (UTC-7).**

---

## Pre-Incident (Threat Actor Preparation)

| Timestamp (UTC) | Source | Actor | Event | Significance |
|---|---|---|---|---|
| 2026-02-18 | WHOIS | Threat Actor | Registered `webanalytics-cdn.sbs`, `.cyou`, `.cfd`, `.icu` within 40-second window | C2/redirect infrastructure established |
| 2026-02-18 | WHOIS | Threat Actor | Registrar: Global Domain Group LLC; privacy-protected WHOIS | Attribution obscured |
| 2026-02-23 | DNS | Threat Actor | All 4 domains activated via Cloudflare DNS | Infrastructure goes live |

---

## Possible initial-access chain (unverified dates)

| Timestamp | Source | Actor | Event | Significance |
|---|---|---|---|---|
| Late Feb -- Early Mar 2026 | Hypothesis | Unknown | Possible administrator exposure to a ClickFix prompt | No endpoint evidence establishes this event |
| Late Feb -- Early Mar 2026 | Hypothesis | Unknown | Possible execution of a PowerShell downloader on an administrator workstation | Execution and second-stage behavior remain unverified |
| Late Feb -- Early Mar 2026 | Hypothesis | Unknown | Possible theft of hosting-panel credentials | One explanation for panel access; pre-transfer compromise also remains possible |

---

## Active Compromise (Server Evidence)

| Timestamp (PDT) | Source | Actor | Event | Significance |
|---|---|---|---|---|
| 2026-03-08 15:15:52 | File stat (mtime) | Threat Actor | `hello-biz-child/functions.php` modified | Active child theme receives bounded `__mu_deployer__` malware block before other observed payload timestamps |
| 2026-03-08 15:15:54 | File stat (mtime) | Threat Actor | `health-check.php` mu-plugin deployed | First observed mu-plugin timestamp |
| 2026-03-08 15:15:55 | File stat (mtime) | Threat Actor | `.htaccess` and `advanced-cache.php` modified | Cache-bypass/self-heal persistence established |
| 2026-03-08 15:15:56 | File stat (mtime) | Threat Actor | 4 webshells deployed: `font-metrics.php`, `wc-report-handler.php`, `wp-cache-stats.php`, `wp-locale-handler.php` | Redundant backdoor network established |
| 2026-03-08 15:15:58 | File stat (mtime) | Threat Actor | `wp-login.php` modified (credential stealer injected at line 1327) | Login credential harvesting begins |
| 2026-03-08 15:16:00 | File stat (mtime) | Threat Actor | `wp-user-query.php` mu-plugin deployed | Stealth toolkit + data harvesting activated |
| 2026-03-08 15:16:15 | File stat (mtime) | Threat Actor | `hello-biz/functions.php` modified | Parent-theme credential capture / admin-backdoor logic present in live file |
| 2026-03-08 ~15:16 | Analysis | Threat Actor | Database option `wp_session_tokens_config` created (168KB base64 malware backup) | Database-level persistence |
| 2026-03-08 ~15:16 | Analysis | Threat Actor | Database option `_pre_user_id` set to `8` | Hidden admin user tracking |
| 2026-03-08 18:16:18 | Database | Threat Actor | Hidden admin user `adminbackup1d8273` (ID 8) created | Persistent admin access established |
| 2026-03-10 03:47:05-03:47:07 | HTTPS error log | Threat Actor | Dynamic payload execution against `session-manager.php` triggers PHP parse errors from clients `102.230.151.144`, `172.13.233.8`, and `23.26.130.103` | Earliest preserved evidence that the TDS engine's eval path was being actively exercised on the live server |

---

## Malware Operations (Captured Activity)

| Timestamp (Unix) | Timestamp (UTC) | Source | Actor | Event |
|---|---|---|---|---|
| 1773163250 | ~2026-03-08 | `_wp_mail_queue_log` | Malware | Intercepted email: WP update to 6.9.2 (to [EMAIL-REDACTED]) |
| 1773187044 | 2026-03-10 23:57:24 UTC | `_wp_site_activity` | SiteOwnerUser | Login from `[IP-REDACTED]` captured by malware; user later attributed this IP to the site owner |
| 1773206407 | ~2026-03-09 | `_wp_mail_queue_log` | Malware | Intercepted email: WP update to 6.9.3 (to [EMAIL-REDACTED]) |
| 1773239143 | ~2026-03-09 | `_wp_mail_queue_log` | Malware | Intercepted email: New message from Example Bistro |
| 1773249677 | ~2026-03-09 | `_wp_mail_queue_log` | Malware | Intercepted email: WP update to 6.9.4 |
| 1773255434 | ~2026-03-09 | `_wp_mail_queue_log` | Malware | Intercepted email: New User Registration |
| 1773255434 | ~2026-03-09 | `_wp_site_activity` | Responder | User `ResponderAdmin` (ID 9) created |
| 1773255435 | ~2026-03-09 | `_wp_mail_queue_log` | Malware | Intercepted email: Login Details (to [EMAIL-REDACTED]) |
| ~2026-03-10 | | Credential dump | Threat Actor | webagency credentials captured (4 login events) |
| ~2026-03-10 | | Credential dump | Threat Actor | SiteOwnerUser credentials captured (2 login events) |
| 2026-03-11 06:38:30-18:17:19 | HTTPS access + error logs | Threat Actor | Repeated `POST /?wp_debug_session=<key>&mode=php` requests from at least 13 IPs, returning both `200` and `500` and correlating with `session-manager.php(546) : eval()'d code` parse errors | First preserved raw access-log proof of active operator use of the TDS backdoor |
| 2026-03-12 05:22:22-14:40:29 | HTTPS access + error logs | Threat Actor | Continued `wp_debug_session` execution attempts from `35.147.129.58`, `23.26.130.47`, `94.205.57.64`, and `79.146.6.139` | Confirms multi-day attacker interaction, not a single probe |
| 2026-03-13 03:06:22-21:41:41 | HTTPS access + error logs | Threat Actor | Renewed `wp_debug_session` activity from `186.158.145.170`, `68.58.140.166`, `23.26.130.254`, `75.97.69.103`, `23.26.130.47`, `76.127.171.140`, and `97.170.143.128` | Raw logs align with `_tds_stats` peak activity window |
| 2026-03-14 17:21:42-23:35:19 | HTTPS access + error logs | Threat Actor | Additional `wp_debug_session` use from `148.75.104.103`, `23.26.130.237`, and `81.38.174.52` | Confirms sustained post-compromise access via the same backdoor channel |
| 2026-03-15 05:53:57-06:22:48 | HTTPS access log | Threat Actor | `wp_debug_session` requests continue from `81.38.174.52` | Backdoor remained reachable on March 15 while admin/plugin events were being logged |

---

## Malware Operations (Captured Activity -- continued)

| Timestamp (Unix) | Timestamp (UTC) | Source | Actor | Event |
|---|---|---|---|---|
| 2026-03-10 03:47 | File stat | Threat Actor | `session-manager.php` and `.bak` modified | TDS engine updated/redeployed |
| 1773411191 | 2026-03-13 14:13:11 UTC | `_wp_site_activity` | webagency | Login from `[IP-REDACTED]` captured by malware |
| 1773411437 | 2026-03-13 14:17:17 UTC | `_wp_site_activity` | webagency | Login from `[IP-REDACTED]` captured by malware |
| 1773696463 | 2026-03-16 21:27:43 UTC | `_wp_site_activity` | webagency | Login from `[IP-REDACTED]` captured by malware |
| 1773744997 | 2026-03-17 10:56:37 UTC | `_wp_site_activity` | webagency | Login from `[IP-REDACTED]` captured by malware |
| 1773787392 | 2026-03-17 22:43:12 UTC | `_wp_site_activity` | SiteOwnerUser | Login from `[IP-REDACTED]` captured by malware; user later attributed this IP to the site owner |
| 1773788124 | ~2026-03-15 | `_wp_site_activity` | Malware log | Plugin activated: hello-plus/hello-plus.php |
| 1773788253 | ~2026-03-15 | `_wp_site_activity` | Malware log | Plugin deactivated: hello-plus/hello-plus.php |
| 1773800830 | ~2026-03-15 | `_wp_mail_queue_log` | Malware | Intercepted email: New Admin Email Address (to [EMAIL-REDACTED]) |
| 1773802229 | ~2026-03-15 | `_wp_site_activity` | Malware log | Plugin activated: wordfence/wordfence.php |
| 2026-03-16 01:41:15-12:03:53 | HTTPS access + error logs | Threat Actor | `wp_debug_session` requests continue from `188.246.83.9`, `75.137.225.249`, `23.26.130.103`, `73.7.44.113`, `204.10.174.187`, and `23.26.95.205`; 500 responses correlate with `session-manager.php` eval parse errors | Confirms live attacker interaction with the backdoor continued through the day before the SharedHost Provider restore boundary |

### TDS Runtime Evidence (Database Telemetry)

| Date | Source | Event | Significance |
|---|---|---|---|
| 2026-03-09 | `_tds_stats` | 401 impressions, 0 recorded redirects | TDS tracking active by March 9 |
| 2026-03-10 | `_tds_stats` | 657 impressions, 0 recorded redirects | Confirms continued payload execution after initial deployment |
| 2026-03-11 | `_tds_stats` | 772 impressions, 0 recorded redirects | Malware remained active while admin logins occurred |
| 2026-03-12 | `_tds_stats` | 734 impressions, 0 recorded redirects | Persistent frontend execution |
| 2026-03-13 | `_tds_stats` | 900 impressions, 0 recorded redirects | Highest observed TDS activity day |
| 2026-03-14 | `_tds_stats` | 758 impressions, 0 recorded redirects | Continued activity |
| 2026-03-15 | `_tds_stats` | 815 impressions, 0 recorded redirects | Continued activity alongside plugin and email events |
| 2026-03-16 | `_tds_stats` | 572 impressions, 0 recorded redirects | Continued activity |
| 2026-03-17 | `_tds_stats` | 653 impressions, 0 recorded redirects | Malware activity persisted into the SharedHost Provider restore window |
| 2026-03-18 | `_tds_stats` | 146 impressions at time of analysis | Confirms payload still live during responder access |

---

## Incident Response

| Timestamp | Source | Actor | Event |
|---|---|---|---|
| 2026-03-10 | Detection | Responder | Website compromise detected; investigation opened |
| 2026-03-10 | Analysis | Responder | AI1WM backup analyzed (18,897 files) -- no server-resident malware found in accessible archive |
| 2026-03-10 | Analysis | Responder | Database dump analyzed (20.88 MB) -- CLEAN |
| 2026-03-10 | Research | Responder | Malicious domains researched; 4 webanalytics-cdn domains + landbankseeds.com documented |
| 2026-03-11 18:57 | Action | Responder | Investigator account `ResponderAdmin` (ID 9) created |
| 2026-03-17 15:43 | Evidence | Credential dump | Last credential written to Stained_Heart_Red-600x500.png |
| 2026-03-17 21:40 | Action | SharedHost Provider | Oldest available SharedHost Provider backup restored to new SSH user `siteuser02` during user migration | Explains March 17 file birth/ctime values on restored content |
| 2026-03-17 22:01 | Evidence | File stat | Restored file set under new user retains older compromise-era mtimes but receives new March 17 birth/ctime metadata | File birth/ctime after this point should not be interpreted as original attacker deployment time |
| 2026-03-17 22:01 | Evidence | File stat | `wp-update-verify.php` present in restored content with preserved malicious mtime | Confirms oldest SharedHost Provider backup still contained compromised webshell content |
| 2026-03-18 | Action | Responder | SharedHost Provider panel access obtained |
| 2026-03-18 | Discovery | Responder | PowerShell ClickFix payload found in SSH username field |
| 2026-03-18 | Analysis | Responder | Payload decoded (XOR key `pgtPYT`, downloads from webanalytics-cdn.cfd) |
| 2026-03-18 | Analysis | Responder | WordPress XML export taken and analyzed -- CLEAN |
| 2026-03-18 | Action | Responder | SSH key auth configured for `siteuser02` |
| 2026-03-18 | Action | Responder | `.user.ini` and `wordfence-waf.php` paths fixed (siteuser01 -> siteuser02) |
| 2026-03-18 | Action | Responder | Database password rotated and updated in wp-config.php |
| 2026-03-18 | Action | Responder | WordPress verified operational (HTTP 200) |
| 2026-03-18 | Action | SharedHost Provider Support | Partial cleanup: removed `wp-content/mu-plugins/` directory and `TDS_NOCACHE` block from `.htaccess` | Removed TDS auto-load path and cache-bypass rule, but remaining file, database, theme, and auth-layer persistence was not addressed; infection still required full coordinated eradication |
| 2026-03-18 | Scan | Responder | Full server-side malware scan completed |
| 2026-03-18 | Analysis | Responder | Raw SharedHost Provider access/error logs correlated to direct `wp_debug_session` backdoor use from March 11-16 and eval-path execution errors from March 10-16 | Tightens active-compromise timeline with preserved server evidence |
| 2026-03-18 | Analysis | Responder | Exact authenticated admin session reconstruction completed from `session_tokens`, `_wp_site_activity`, and HTTPS access logs | Corrects earlier approximate login dates, documents precise login windows for `SiteOwnerUser`, `webagency`, and `Manager`, and attributes `[IP-REDACTED]` to ownership and `[IP-REDACTED]` to responder activity |
| 2026-03-18 | Analysis | Responder | `webagency` admin sessions reviewed against preserved HTTPS logs | Current evidence confirms post-compromise WordPress logins and credential theft; Agency Developer 1 is now known to have had SharedHost Provider panel access, making him a plausible access path, but the evidence still does not tie him to the March 8 initial deployment window |
| 2026-03-18 | Analysis | Responder | Root-compromise timing re-evaluated against backup scope and restore evidence | Oldest retained SharedHost Provider backup already contained compromised content, but current evidence cannot distinguish a pre-transfer compromise carried into SharedHost Provider from a post-transfer compromise using stolen SharedHost Provider credentials |
| 2026-03-18 | Finding | Responder | Active malicious plugin `wp-perf-analytics` confirmed on host | Additional code-injection vector identified |
| 2026-03-18 | Finding | Responder | `_tds_cache_selfheal` WP-Cron event, `TDS_NOCACHE` `.htaccess` block, `_tds*` transients, hidden XOR uploads temp file discovered | Additional TDS self-heal persistence confirmed |
| 2026-03-18 | Finding | Responder | `hello-biz/functions.php`, `kaon/functions.php`, and `lemonchili/functions.php` contain `create_admin=erwesdxsas` admin-creation backdoor logic | Active and dormant theme-based re-entry paths identified |
| 2026-03-18 | Finding | Responder | Live `hello-biz-child/functions.php` contains a bounded `/* __mu_deployer__ */` malware block that restores `session-manager.php`, scatter webshells, and fallback plugin code | Child theme can be surgically cleaned by removing bounded marker block; fallback quarantine only if additional malicious code remains |
| 2026-03-18 | Finding | Responder | March 10 `.wpress` archive and oldest SharedHost Provider backup are not treated as trusted theme restoration sources | Backup-derived content may preserve compromised theme files |
| 2026-03-18 | Finding | Responder | 15 confirmed malicious files, 1 malicious plugin, multiple persistence residues, 1 hidden admin, 2 stolen credential sets identified |
| 2026-03-18 | Action | Responder | Case upgraded to Tier 1 -- full incident response initiated |
| 2026-03-18 10:05 PDT | Finding | Reviewer | Hide My WP bypass parameter (`?bypass_key=[REDACTED-BYPASS-KEY]`) discovered to allow direct HTTP access to all 5 webshells despite maintenance mode; `font-metrics.php` confirmed returning `200 OK` with bypass | Maintenance mode was NOT providing effective containment |
| 2026-03-18 10:05 PDT | Action | Reviewer | Deployed `.htaccess` PHP execution deny rules to all 5 webshell directories: `wp-includes/fonts/`, `wp-content/upgrade/`, `wp-content/uploads/woocommerce_uploads/`, `wp-content/uploads/`, `wp-content/languages/` | Emergency containment -- blocks attacker webshell access |
| 2026-03-18 10:05 PDT | Verification | Reviewer | All 5 webshell URLs confirmed returning `503` across 3 test vectors: no params, bypass param only, bypass + auth key. Site homepage still returns `503` (maintenance mode intact) | Containment verified -- attacker remote access via webshells is now blocked |
| 2026-03-18 ~14:20 UTC | Action | Responder | Pre-eradication checklist completed; all go/no-go items passed; `hello-biz-child/functions.php` permissions corrected (was `--w-------`) |
| 2026-03-18 ~14:30 UTC | Action | Responder | `eradicate.sh` uploaded via SCP; CRLF line endings stripped; script staged for execution |
| 2026-03-18 14:37–14:38 UTC | Action | Responder | `eradicate.sh` executed — 8 malware layers removed: persistence bootstrap, mu-plugins, malicious plugin, webshells, exfil files, DB cleanup, theme cleanup (core reinstall, `hello-biz` reinstalled from WordPress.org, `__mu_deployer__` block removed), session invalidation + salt rotation |
| 2026-03-18 ~14:45 UTC | Action | Responder | Evidence snapshot archived at `/home/siteuser02/eradication-evidence-20260318-143745/`; downloaded to `05-evidence/eradication-evidence-20260318-143745.tar.gz` |
| 2026-03-18 ~14:50 UTC | Action | Responder | Post-script FAILs resolved manually: malicious DB options deleted via direct SQL; user ID 8 deleted via direct SQL + `wp user delete`; fonts/ PHP FAIL confirmed false positive (legitimate WP 6.9.4 core classes) |
| 2026-03-18 ~15:00 UTC | Verification | Responder | WordPress core checksums verified clean; `wp-includes/fonts/.htaccess` removed (leftover containment file); final checksum pass confirmed clean |
| 2026-03-18 ~15:10 UTC | Action | Responder | All 5 WordPress administrator passwords rotated via WP-CLI `--skip-plugins --skip-themes`; MySQL password rotated, `wp-config.php` updated and verified |
| 2026-03-18 ~15:15 UTC | Action | Responder | `DISALLOW_FILE_EDIT` added to `wp-config.php`; PHP memory limit raised to 256M in `wp-config.php` and `.user.ini`; resolves Elementor OOM crashes on SharedHost Provider shared hosting |
| 2026-03-18 ~15:30 UTC | Action | Responder | Maintenance mode lifted (unintentional — `wp rewrite flush --hard` with plugins loaded removed `.maintenance`); site went live; Wordfence already in protecting mode; this does not establish absence of exposure during the transition |
| 2026-03-18 ~15:45 UTC | Action | Responder | Developer accounts webagency (ID 4) and AgencyAdmin2 (ID 5) deleted; content reassigned to SiteOwnerUser (ID 2) |
| 2026-03-18 ~16:00 UTC | Verification | Responder | Wordfence firewall confirmed in protecting mode (`firewallEnabled=1`, `wafStatus=enabled`, `blockBadPOST=1`); login brute-force protection enabled (`loginSecurityEnabled=1`, 4 failures / 5 min window, 240 min lockout) |
| 2026-03-18 ~16:30 UTC | Action | Responder | WP Ghost 5.5.02 installed from WordPress.org; verified clean (no eval/base64/webshell indicators); deactivated — "ghost" mode incompatible with SharedHost Provider shared hosting .htaccess constraints; Wordfence brute-force protection serving as interim wp-login.php protection |
| 2026-03-18 ~17:00 UTC | Verification | Responder | All 4 remaining containment `.htaccess` files confirmed absent; all 5 former webshell URLs return 404 (intermittent 503 on 3 URLs is transient SharedHost Provider mod_fcgid load, not malware-related; confirmed by log check and repeated testing) |

---

*Document: IR-2026-0310-EXBI / Timeline v1.3*
