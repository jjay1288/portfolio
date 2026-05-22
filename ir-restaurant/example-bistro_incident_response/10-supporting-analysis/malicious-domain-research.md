# Malicious Domain Research: webanalytics-cdn.* Campaign

**Date:** March 10, 2026
**Status:** Active threat -- domains are only 20 days old

---

## WHOIS Intelligence

### All 4 Domains Registered in a Single Batch

| Field | webanalytics-cdn.sbs | webanalytics-cdn.cyou | webanalytics-cdn.cfd | webanalytics-cdn.icu |
|---|---|---|---|---|
| **Registry ID** | D626850672-CNIC | D626850675-CNIC | D626850680-CNIC | D626850684-CNIC |
| **Created** | 2026-02-18 22:31:20 UTC | 2026-02-18 22:31:33 UTC | 2026-02-18 22:31:47 UTC | 2026-02-18 22:32:00 UTC |
| **Updated** | 2026-02-23 22:32:23 UTC | 2026-02-23 22:32:23 UTC | 2026-02-23 22:32:23 UTC | 2026-02-23 22:32:23 UTC |
| **Expires** | 2027-02-18 | 2027-02-18 | 2027-02-18 | 2027-02-18 |
| **Registrar** | Global Domain Group LLC | Global Domain Group LLC | Global Domain Group LLC | Global Domain Group LLC |
| **Nameservers** | eve/jeremy.ns.cloudflare.com | randall/riya.ns.cloudflare.com | dom/lina.ns.cloudflare.com | may/vasilii.ns.cloudflare.com |
| **Cloudflare IPs** | 104.21.92.193 / 172.67.197.89 | 104.21.63.143 / 172.67.146.168 | 104.21.67.79 / 172.67.218.112 | 104.21.10.94 / 172.67.162.196 |

### Key Observations

1. **Sequential Registry IDs** (D626850672, 675, 680, 684) -- These were registered as a batch through the CentralNic registry
2. **40-second registration window** -- All 4 domains registered between 22:31:20 and 22:32:00 UTC on Feb 18, 2026
3. **Identical update timestamp** -- All updated at exactly 22:32:23 UTC on Feb 23, 2026 (likely Cloudflare DNS configuration)
4. **Single registrar** -- Global Domain Group LLC (IANA ID 3956), Oxnard, California
5. **Privacy-protected** -- All registrant information redacted
6. **Each domain uses different Cloudflare NS pairs** -- Different Cloudflare accounts or deliberate separation for resilience
7. **DNSSEC unsigned** on all 4 -- No authentication of DNS responses
8. **Domain age: ~20 days** as of this report

---

## Registrar: Global Domain Group LLC

| Detail | Value |
|---|---|
| Company | Global Domain Group LLC |
| IANA ID | 3956 |
| Location | Oxnard, California |
| WHOIS | www.registrar-abuse.invalid |
| Abuse Contact | abuse@globaldomaingroup.com / +1.8053943992 |
| FTC Action | **Warning letter issued by the Federal Trade Commission** |

### FTC Warning Letter

The U.S. Federal Trade Commission has issued a formal warning letter to Global Domain Group LLC. While the exact details were not accessible (403 response from FTC PDF), the existence of an FTC warning letter to a domain registrar is significant. FTC warning letters to registrars typically involve:
- Failure to adequately respond to abuse reports
- Facilitating fraudulent domain registrations
- Insufficient action against domains used for scams, phishing, or malware

This suggests Global Domain Group LLC has a documented history of being associated with abusive domain registrations.

---

## TLD Risk Assessment

All four TLDs used are among the most abused on the internet:

| TLD | Full Name | Typical Cost | Abuse Reputation |
|---|---|---|---|
| **.sbs** | Side By Side | ~$0.99/year | Very high abuse rate |
| **.cyou** | "See You Online" | ~$0.99/year | Very high abuse rate |
| **.cfd** | Clothing, Fashion, Design | ~$0.99/year | Very high abuse rate |
| **.icu** | "I See You" | ~$1.49/year | Very high abuse rate |

These TLDs are favored by attackers because:
- Extremely low cost (under $2/year each = ~$8 total for all 4 domains)
- Minimal registration verification
- High volume of registrations makes abuse reports harder to process
- Registries for these TLDs have historically been slow to act on abuse

---

## Infrastructure Analysis

### Cloudflare as a Shield

All 4 domains (plus the redirect target `landbankseeds.com`) are proxied through Cloudflare:

- **True origin servers are hidden** -- Cloudflare acts as a reverse proxy, making it impossible to determine the real hosting from DNS alone
- **Free SSL** -- Cloudflare provides free SSL certificates, making the malicious domains appear "secure" in browsers
- **Anti-forensics** -- Server logs at the origin only see Cloudflare IPs, not end-user IPs
- **Abuse process is slow** -- Cloudflare's abuse process requires multiple steps and Cloudflare historically passes complaints to the hosting provider rather than taking direct action

### Redirect Target: landbankseeds.com

| Field | Value |
|---|---|
| IPv4 | 104.21.62.243 / 172.67.140.163 (Cloudflare) |
| Relationship | Used as redirect destination with `?src=www.example-bistro.invalid` parameter |
| Purpose | Monetization endpoint -- the `src` parameter tracks which compromised site generated the traffic |

---

## Public Threat Intelligence Status

### Zero Public Reports Found

An exact-match search for all 4 domains across the public internet returned **zero results**:
- Not indexed by Google
- Not reported on VirusTotal (public results)
- Not listed on URLhaus (abuse.ch)
- Not found on ThreatFox
- Not found on ANY.RUN
- Not found on Sucuri SiteCheck public reports

**This is consistent with the domains being only 20 days old.** The lack of public reporting means:
1. The campaign is new and not yet widely documented
2. Few compromised site owners have identified and reported the specific domains
3. Security researchers haven't published analysis yet
4. The domains may not yet be on common blocklists

### This Makes Reporting More Important

Since these domains are not yet in threat intel databases, **filing abuse reports now** will help protect other sites being targeted by the same campaign.

---

## Campaign Pattern Analysis

### Matches Known WordPress Injection Campaigns

The techniques used match well-documented WordPress malware campaigns:

| Technique | This Campaign | Balada Injector | Other Known Campaigns |
|---|---|---|---|
| Bulk domain registration | Yes (4 domains, 40 seconds) | Yes (70+ domains over years) | Common |
| Domain rotation | Yes (4 TLDs for same label) | Yes (new domain each wave) | Common |
| Cheap/disposable TLDs | Yes (.sbs, .cyou, .cfd, .icu) | Yes (.biz, various) | Common |
| Cloudflare proxy | Yes (all domains) | Sometimes | Common |
| Fake analytics naming | Yes ("webanalytics-cdn") | No (uses random word combos) | Variant |
| navigator.sendBeacon | Yes | Not documented | Less common |
| Targets Windows users | Likely | Not specifically | Some campaigns |
| Bypasses admin detection | Likely | Yes | Common |
| Injection outside wp-content | Yes (backup is clean) | Yes (siteurl infections, core files) | Common |

### Differences from Balada Injector

While similar in overall approach, this campaign has distinct characteristics:
1. **Fake analytics naming** -- "webanalytics-cdn" is designed to blend in with legitimate analytics tools, unlike Balada's random word combinations
2. **navigator.sendBeacon()** -- A more modern data exfiltration technique not commonly associated with Balada
3. **landbankseeds.com** as redirect target -- Balada typically uses different redirect chains
4. **Registrar** -- Balada has used various registrars
5. **All domains registered simultaneously** -- Balada tends to register domains in waves over time

**Assessment:** This is likely a **separate campaign** from Balada Injector, possibly a newer operation that has adopted some of Balada's techniques while adding its own innovations.

---

## Related Research: WordPress Redirect Malware Landscape

### Similar Active Campaigns (2025-2026)

| Campaign | Domains Used | Injection Method | Source |
|---|---|---|---|
| MoesSec-documented | analytitwave.com, analyticssnoden.com, metricaltic.com | Core JS files / theme header.php | [MoeSec Research](https://moesec.com/blog/research/wordpress-redirect-malware/) |
| Sucuri-documented | cdn1.massearchtraffic.top, streamain.top | Theme functions.php | [Sucuri Blog](https://blog.sucuri.net/2025/01/malware-redirects-wordpress-traffic-to-harmful-sites.html) |
| Balada Injector | 70+ domains (legendarytable.com, etc.) | Plugin vulns, siteurl modification | [Sucuri Blog](https://blog.sucuri.net/2023/04/balada-injector-synopsis-of-a-massive-ongoing-wordpress-malware-campaign.html) |
| **This campaign** | webanalytics-cdn.{sbs,cyou,cfd,icu} | Outside wp-content (core/htaccess/config) | This investigation |

### Common Injection Points (Not Captured by AI1WM Backups)

Per Sucuri and other researchers, the most common injection locations outside `wp-content/` are:
1. **Theme `functions.php`** -- But this IS in wp-content and our scan found it clean
2. **WordPress core `wp-includes/` files** -- Modified `template-loader.php`, `default-filters.php`, `script-loader.php`
3. **Root `index.php`** -- Standard WordPress bootstrap file modified
4. **`.htaccess`** -- Apache redirect rules or `php_value auto_prepend_file`
5. **`wp-config.php`** -- Injected `require()` or inline PHP
6. **`.user.ini`** -- PHP configuration overrides (e.g., `auto_prepend_file`)

---

## Recommended Actions

### Immediate: Report the Domains

1. **Cloudflare Abuse** -- https://abuse.cloudflare.com
   - Report all 4 webanalytics-cdn domains + landbankseeds.com
   - Include the WHOIS data showing coordinated registration
   - Reference the JavaScript injection found on example-bistro.invalid

2. **Global Domain Group LLC** -- abuse@globaldomaingroup.com
   - Report all 4 domains as malicious
   - Include evidence of coordinated bulk registration for malware distribution
   - Note the FTC warning letter history

3. **Google Safe Browsing** -- https://safebrowsing.google.com/safebrowsing/report_badware/
   - Report all 4 domains + landbankseeds.com
   - This will trigger warnings in Chrome, Firefox, and Safari

4. **abuse.ch** -- Submit to URLhaus and ThreatFox
   - URLhaus: https://urlhaus.abuse.ch/
   - ThreatFox: https://threatfox.abuse.ch/
   - These feed into many security products and blocklists

5. **CentralNic Registry** -- Since all domains are registered through CentralNic
   - Report coordinated abuse to the registry level

### Medium-term: Monitor for New Domains

Given the attacker's pattern, expect:
- New domains using the same `webanalytics-cdn` label on other TLDs
- New domains using variations like `web-analytics-cdn`, `webanalytics-api`, `cdn-webanalytics`, etc.
- The same registrar (Global Domain Group LLC) being used for future registrations
- The same Cloudflare infrastructure pattern

---

## Timeline

| Date | Event |
|---|---|
| 2026-02-18 22:31-22:32 UTC | All 4 webanalytics-cdn domains registered via Global Domain Group LLC |
| 2026-02-23 22:32:23 UTC | All 4 domains updated (likely Cloudflare DNS configuration) |
| 2026-03-08 | AI1WM backup of example-bistro.invalid taken (CLEAN -- malware not in wp-content/db) |
| 2026-03-08 | SOA serial updated for example-bistro.invalid DNS |
| 2026-03-10 | Live site confirmed compromised with injected scripts from all 4 domains |
| 2026-03-10 | This investigation initiated |

**The compromise of example-bistro.invalid occurred sometime between Feb 23 (when domains were configured) and Mar 10 (when detected). The backup on Mar 8 being clean suggests the injection is in files outside the backup scope, not that it happened after the backup.**
