# Indicator of Compromise Registry -- IR-2026-0310-EXBI

**Last Updated:** March 18, 2026
**Classification:** TLP:AMBER (share with IR team and hosting provider only)

---

## Network IOCs

### Malicious Domains (Attacker-Controlled)

| Domain | TLD | Registered | Registrar | Purpose | Status |
|---|---|---|---|---|---|
| `webanalytics-cdn.sbs` | .sbs | 2026-02-18 | Global Domain Group LLC | TDS redirect / JS injection | Active |
| `webanalytics-cdn.cyou` | .cyou | 2026-02-18 | Global Domain Group LLC | TDS redirect / JS injection | Active |
| `webanalytics-cdn.cfd` | .cfd | 2026-02-18 | Global Domain Group LLC | TDS redirect / JS injection / trojan host | Active |
| `webanalytics-cdn.icu` | .icu | 2026-02-18 | Global Domain Group LLC | TDS redirect / JS injection | Active |
| `landbankseeds.com` | .com | Unknown | Unknown | Final redirect destination | Active |

### Malicious URLs

| URL | Purpose |
|---|---|
| `https://webanalytics-cdn.cfd/api/index.php?a=dl&token=0c1bad9a7f58ee73b344fe187a616e97589e9e530acdabab057b4c439c58e74d&src=cloudflare&mode=cloudflare` | Trojan download endpoint |
| `https://webanalytics-cdn.{sbs,cyou,cfd,icu}/` | JavaScript redirect/tracking payload delivery |

### IP Addresses

| IP | Association | Notes |
|---|---|---|
| Cloudflare-proxied | All webanalytics-cdn domains | True origin IP hidden behind Cloudflare |

### Observed Administrative IPs (from access logs/activity logs)

| IP | User | Context |
|---|---|---|
| [IP-REDACTED] | webagency login | Logged by malware activity monitor; attribution not yet confirmed |
| [IP-REDACTED] | webagency login | Logged by malware activity monitor; attribution not yet confirmed |
| [IP-REDACTED] | webagency login | Logged by malware activity monitor; attribution not yet confirmed |
| [IP-REDACTED] | SiteOwnerUser login | User attributed to Example Bistro owner; treat as legitimate owner administration |
| [IP-REDACTED] | Manager login | User attributed to responder/admin; treat as legitimate response activity |

---

## Host IOCs -- Filesystem

### Malicious Files

| # | Path | Size (bytes) | SHA256 | Type | Classification |
|---|---|---|---|---|---|
| 1 | `wp-content/mu-plugins/session-manager.php` | 126,245 | (collect) | PHP | TDS Engine |
| 2 | `wp-content/mu-plugins/session-manager.php.bak` | 125,668 | (collect) | PHP | TDS Engine (backup) |
| 3 | `wp-content/mu-plugins/wp-user-query.php` | 6,878 | (collect) | PHP | Stealth Toolkit |
| 4 | `wp-content/mu-plugins/health-check.php` | 401 | (collect) | PHP | Stub/Loader |
| 5 | `wp-includes/fonts/font-metrics.php` | 5,807 | (collect) | PHP | Webshell v1.3 |
| 6 | `wp-content/upgrade/wp-update-verify.php` | 5,810 | (collect) | PHP | Webshell v1.3 |
| 7 | `wp-content/uploads/woocommerce_uploads/wc-report-handler.php` | 5,806 | (collect) | PHP | Webshell v1.3 |
| 8 | `wp-content/uploads/wp-cache-stats.php` | 5,808 | (collect) | PHP | Webshell v1.3 |
| 9 | `wp-content/languages/wp-locale-handler.php` | 5,803 | (collect) | PHP | Webshell v1.3 |
| 10 | `wp-content/advanced-cache.php` | ~500 | (collect) | PHP | Persistence / Auto-restore |
| 11 | `wp-content/uploads/2024/06/Stained_Heart_Red-600x500.png` | 365 | (collect) | Text (fake PNG) | Credential Dump |
| 12 | `wp-includes/css/wp-editor-font.css` | ~200 | (collect) | Encrypted data | Unknown exfil/config |
| 13 | `wp-admin/.backup_time` | ~350 | (collect) | Encrypted data | Unknown exfil/config |

### Malicious Plugins (disguised as legitimate)

| # | Path | Size (bytes) | SHA256 | Type | Classification |
|---|---|---|---|---|---|
| 14 | `wp-content/plugins/wp-perf-analytics/wp-perf-analytics.php` | 5,780 | `96780cfb26165a1378529319739508c67e126417f49c73793d5d2c2178464146` | PHP | XOR-encrypted JS Injector (client-side TDS) |

### Modified Core Files

| File | Expected Size | Actual Size | Modification |
|---|---|---|---|
| `wp-login.php` | ~50,700 | 51,723 | Credential stealer injected at line 1327 |

### Modified Theme Files

| File | Modification |
|---|---|
| `wp-content/themes/hello-biz/functions.php` | TWO injections: (1) Hidden admin creator backdoor via `?create_admin=erwesdxsas` (creates user `adminpro`/`@@Admin234$`); (2) Credential stealer appended (authenticate filter hook, priority 999) |

---

## Host IOCs -- Database

### Malicious Options (wp_s8yhai_options)

| option_name | Size | Purpose | Cleanup Action |
|---|---|---|---|
| `wp_session_tokens_config` | 168,328 bytes | Base64-encoded backup of session-manager.php | DELETE |
| `_pre_user_id` | 1 byte (value: `8`) | Hidden admin user ID for stealth queries | DELETE |
| `_wp_mail_queue_log` | 663 bytes | Intercepted outgoing email log | DELETE (preserve as evidence first) |
| `_wc_analytics_data` | 0 bytes | WooCommerce order harvesting target (option absent from live DB as of March 18 -- consistent with never-populated or removed during SharedHost Provider partial cleanup) | DELETE if present |
| `_wp_site_activity` | 682 bytes | Admin action surveillance log | DELETE (preserve as evidence first) |

### Malicious User

| Field | Value |
|---|---|
| user_id | 8 |
| user_login | `adminbackup1d8273` |
| user_email | `adminbackup@wordpress.org` |
| user_registered | 2026-03-08 18:16:18 |
| wp_s8yhai_capabilities | `a:1:{s:13:"administrator";b:1;}` |
| wp_s8yhai_user_level | 10 |

---

## Host IOCs -- Behavioral

### Webshell Authentication

| Indicator | Value |
|---|---|
| GET parameter | `_wph` |
| Auth prefix | `a3f8b2c1d4e5f607` |
| Mode parameter | `m` (values: `p`, `r`, `l`, `t`, `h`, `u`, `s`) |
| Version | 1.3 |

### Anti-Detection (User-Agent Strings)

The malware pauses operation when these strings are detected in User-Agent:

```
Wordfence, Sucuri, WPScan, Nessus, Acunetix, Burp, Nikto, sqlmap
```

### Credential Exfiltration Path

| Indicator | Value |
|---|---|
| Base64-encoded path | `d3AtY29udGVudC91cGxvYWRzLzIwMjQvMDYvU3RhaW5lZF9IZWFydF9SZWQtNjAweDUwMC5wbmc=` |
| Decoded path | `wp-content/uploads/2024/06/Stained_Heart_Red-600x500.png` |
| Injection marker | `d3AtY29udGVudC91cGxvYWRz` (base64 for `wp-content/uploads`) |

### Fake Plugin (wp-perf-analytics)

| Indicator | Value |
|---|---|
| Plugin Name | WP Performance Analytics |
| Plugin URI | `https://developer.wordpress.org/plugins/` (fake -- points to generic WordPress developer page) |
| Author | Developer Tools Team (fake) |
| Version | 1.2.51 |
| XOR key | 240 (decimal) |
| Hook | `wp_footer` priority 99999 |
| Anti-detection cookies | `_cf_verified`, `_wp_perf_ok` |
| Skips roles | administrator, editor, author |
| Skips User-Agents | bot, crawl, spider, lighthouse, pagespeed, semrush, ahrefs, mj12, dotbot, bingpreview, slurp, yandex, duckduck, facebookexternalhit, twitterbot, whatsapp, telegram, googlebot |

### Hidden Admin Creator Backdoor (functions.php injection)

| Indicator | Value |
|---|---|
| Trigger parameter | `?create_admin=erwesdxsas` |
| Created username | `adminpro` |
| Created password | `@@Admin234$` |
| Created email | `adminbackup@wordpress.org` |
| Created role | administrator |
| Status | Never triggered (user does not exist in DB) |

### ClickFix Payload

| Indicator | Value |
|---|---|
| XOR key | `pgtPYT` |
| Fake Cloudflare ID | `85f261d8487fffbd` |
| Campaign token | `0c1bad9a7f58ee73b344fe187a616e97589e9e530acdabab057b4c439c58e74d` |
| advanced-cache.php tag | `_sm_ac_v5` |

---

## Detection Signatures

### YARA Rule (Webshell)

```yara
rule example_bistro_Webshell_v13 {
    meta:
        description = "Webshell found in example-bistro.invalid compromise"
        case = "IR-2026-0310-EXBI"
        date = "2026-03-18"
    strings:
        $auth = "_wph" ascii
        $key = "a3f8b2c1d4e5f607" ascii
        $mode_p = "\"p\"&&isset($_POST[\"c\"])" ascii
        $mode_r = "wp_session_tokens_config" ascii
        $mode_h = "wp_hash_password" ascii
        $version = "\"v\":\"1.3\"" ascii
    condition:
        $auth and $key and any of ($mode_*)
}
```

### YARA Rule (Credential Stealer)

```yara
rule example_bistro_CredStealer {
    meta:
        description = "Credential stealer injection pattern"
        case = "IR-2026-0310-EXBI"
    strings:
        $marker = "d3AtY29udGVudC91cGxvYWRz" ascii
        $path = "U3RhaW5lZF9IZWFydF9SZWQtNjAweDUwMC5wbmc=" ascii
        $func = "file_put_contents" ascii
        $login = "$_POST[\"log\"]" ascii
    condition:
        $marker and $func and ($path or $login)
}
```

### Grep Patterns (for scanning other sites)

```bash
# Webshell detection
grep -rl 'a3f8b2c1d4e5f607' /path/to/wordpress/
grep -rl '_sm_ac_v5' /path/to/wordpress/
grep -rl 'wp_session_tokens_config' /path/to/wordpress/ --include='*.php'

# Credential stealer detection
grep -rl 'd3AtY29udGVudC91cGxvYWRz' /path/to/wordpress/ --include='*.php'
grep -rl 'Stained_Heart_Red' /path/to/wordpress/

# TDS engine detection
grep -rl 'webanalytics-cdn' /path/to/wordpress/
grep -rl '_wp_session_paused' /path/to/wordpress/ --include='*.php'

# Hidden admin detection
wp db query "SELECT * FROM wp_options WHERE option_name = '_pre_user_id'"
wp db query "SELECT * FROM wp_users WHERE user_email LIKE 'adminbackup@wordpress.org' AND user_login LIKE 'adminbackup%'"

# Fake plugin (wp-perf-analytics) detection
grep -rl 'atob(d).*charCodeAt.*\^k' /path/to/wordpress/ --include='*.php'
grep -rl '_wp_perf_ok\|_cf_verified.*wp_perf' /path/to/wordpress/ --include='*.php'
find /path/to/wordpress/wp-content/plugins/ -name 'wp-perf-analytics.php'

# Hidden admin creator backdoor detection
grep -rl 'create_admin.*erwesdxsas' /path/to/wordpress/ --include='*.php'
grep -rl "adminpro.*@@Admin234" /path/to/wordpress/ --include='*.php'
```

---

*Document: IR-2026-0310-EXBI / IOC Registry v1.0*
