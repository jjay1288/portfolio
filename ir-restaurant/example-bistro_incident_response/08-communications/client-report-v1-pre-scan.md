# Security Incident Report: Example Bistro Website

> Historical report; key conclusions superseded. The early searches did not establish a clean backup or exclude themes, plugins, or database persistence. Later child-theme findings invalidate that inference. Initial access and workstation execution remain unverified. Use the [incident report](../01-incident-report/IR-2026-0310-EXBI.md) for the reconciled findings. Public editorial review: November 15, 2026; the source wording below records the earlier assessment.

## example-bistro.invalid

**Prepared for:** Example Bistro Ownership
**Date:** March 18, 2026
**Status:** ~~Active Compromise -- Immediate Action Required~~ — **SUPERSEDED** — Full eradication completed March 18, 2026. This report is preserved as a pre-scan historical record only. See `client-report-v2-full-findings.md` for final findings.
**Severity:** Critical

> Historical note: This is the initial pre-scan client communication, preserved as part of the case record. It does **not** reflect the later SSH/server-side findings, decrypted credential results, DMARC verification, or emergency webshell containment. For the current client-facing position, use `client-report-v2-full-findings.md`.

---

## What Happened

Your website, example-bistro.invalid, has been hacked. Visitors to your site are being silently redirected to unrelated websites, and their browsing information is being collected by the attackers. This is not a targeted attack against Example Bistro specifically -- your site was caught up in a large-scale automated campaign that targets WordPress websites.

The attackers also gained access to your SharedHost Provider hosting account (the service that runs your website). They planted a hidden trap inside the hosting settings that was designed to infect any administrator's computer when they tried to manage the site.

**Your website content (pages, menus, photos, etc.) has not been damaged or altered.** The malicious code was inserted into the technical files that run your website behind the scenes, not into any of your visible content.

---

## How It Happened

The evidence pointed to this attack chain:

1. **Someone with site access encountered a fake security check** -- a pop-up disguised as a normal "Verify you are human" prompt. It told them to copy and paste text or use a keyboard shortcut.

2. **That text was a hidden system command.** Once pasted, it downloaded and ran a program from the attacker's server. It ran in the background with no visible prompt.

3. **That program stole saved login credentials** from the computer, including the username and password for your SharedHost Provider hosting account.

4. **Using those stolen credentials, the attackers logged into your SharedHost Provider account** and modified the behind-the-scenes files that power your website, inserting code that redirects your visitors to other sites.

5. **The attackers also set a second trap** inside your hosting settings. They replaced what should have been a simple username with another hidden command, so that the next person who tried to manage the website's server access would also have their computer infected.

---

## What the Attackers Are Doing

### Redirecting Your Visitors
When someone visits example-bistro.invalid, hidden code sends them to unrelated websites. The attackers track which compromised sites send them traffic. This is a monetized redirect scheme, either through ad fraud or by feeding victims into scam and phishing pages.

### Collecting Visitor Information
The hidden code also collects information about your visitors, including which pages they visit, where they came from, and technical details about their browser. This information is sent to the attacker's servers.

### The Attacker's Infrastructure
The attackers registered four fake "analytics" domain names on February 18, 2026, just weeks before the attack. They used extremely cheap, disposable web addresses (costing less than $1 each) and hid their identity behind privacy services. These domains are:

- webanalytics-cdn.sbs
- webanalytics-cdn.cyou
- webanalytics-cdn.cfd
- webanalytics-cdn.icu

None of these are real analytics services. The identical naming pattern across four different web addresses is a strategy to keep the attack running -- if one address gets blocked, the others continue working.

---

## What We've Done So Far

### Investigated Thoroughly
We have analyzed your website from multiple angles:

- **Website backup (March 8, 2026):** Examined all 18,897 files and the entire database. Result: completely clean. This told us the malicious code is not in your website's content, themes, or plugins.

- **Website content export (March 18, 2026):** Exported and analyzed all 756 content items (pages, posts, images, menus). Result: completely clean. All your content is safe.

- **SharedHost Provider hosting panel:** Discovered the hidden trap in the SSH settings and decoded it to understand exactly what it does and where it connects. This was the breakthrough that revealed how the attackers gained access.

- **Attacker infrastructure:** Researched all malicious domains, their registration details, hosting, and connections. Mapped out the attacker's methods and confirmed this is part of a larger campaign.

### Secured Initial Access
- Identified and documented the malicious code in the hosting settings
- Began the process of creating clean, secure access credentials
- Disabled the compromised SSH configuration

---

## What Needs to Happen Next

### Urgent (Within 24 Hours)

**1. Change your SharedHost Provider password and enable two-factor authentication**
Since the attackers had access to your SharedHost Provider account, the password must be changed immediately. Two-factor authentication (where you receive a code on your phone when logging in) should be turned on so that a stolen password alone is not enough to gain access.

**2. Determine if any computer was infected**
Find out whether anyone who manages the website recently encountered a "Verify you are human" pop-up that asked them to copy and paste something. If yes, treat that computer as compromised. Scan it immediately. Treat any browser-saved passwords on it as stolen.

**3. Inspect and clean the server files**
We need to access the server directly (via SSH) to find and remove the malicious code from the technical files. This requires the clean access credentials currently being set up.

**4. Change all passwords**
Every password associated with your website and hosting should be changed:
- SharedHost Provider panel login
- WordPress admin accounts (all of them)
- FTP/SFTP access
- Database password
- Any connected services (Klaviyo email marketing, etc.)

### Short-Term (Within One Week)

**5. Reinstall WordPress core files**
The fastest and most reliable way to ensure all malicious code is removed is to replace the core WordPress files with fresh, verified copies from WordPress.org. This does not affect your content, pages, or images.

**6. Reduce the number of administrator accounts**
Your website currently has four accounts that all have full administrator access. Only accounts that actively need to manage the website should have administrator privileges. The developer accounts (Web Agency) should be downgraded unless they are actively working on the site.

**7. Strengthen website security settings**
- The "secret" login page address and security key are based on easily guessable words and should be changed to random strings
- Two-factor authentication should be enabled for all WordPress admin accounts
- File editing through the WordPress dashboard should be disabled

### Ongoing

**8. Add email security (DMARC)**
Your domain is currently missing a DMARC record, which means attackers could send fake emails that appear to come from @example-bistro.invalid. Given that the attackers had access to your hosting account, they may have information useful for impersonating your business. Adding a DMARC record prevents this.

**9. Report the malicious domains**
The attacker's domains should be reported to Cloudflare and Google Safe Browsing to help protect other people and websites.

**10. Consider upgrading your hosting**
Your website is on SharedHost Provider shared hosting, which means it shares a physical server with many other websites. This can be a risk factor. A managed WordPress hosting plan provides better isolation and built-in security scanning.

---

## Important Questions for the Owner

To help us complete the investigation and cleanup, we need answers to the following:

1. **Has anyone who manages the website recently encountered a "Verify you are human" pop-up that asked them to copy and paste something, or press keyboard shortcuts?** This is the leading theory for the initial compromise. If yes, that computer needs to be scanned immediately.

2. **Who currently has the SharedHost Provider panel login credentials?** We need to know all parties who could access the hosting account.

3. **Are the developer accounts (Web Agency -- Agency Developer 1 and Agency Developer 2) still actively working on the site?** If not, their admin access should be removed or downgraded.

4. **Was the website intentionally put into a "maintenance" state recently?** When we examined the backup, all plugins were deactivated, which is unusual for a live site.

5. **Are there any other websites hosted under the same SharedHost Provider account?** If so, they should be checked for similar compromises.

---

## Timeline of Events

| Date | Event |
|---|---|
| February 18, 2026 | Attackers register 4 malicious domain names (40-second window) |
| February 23, 2026 | Attackers configure the domains with hosting services |
| Late Feb -- Early Mar 2026 | Likely timeframe: administrator's computer compromised via fake CAPTCHA |
| Late Feb -- Early Mar 2026 | Likely timeframe: attackers gain SharedHost Provider panel access and inject website code |
| March 8, 2026 | Website backup taken (backup is clean -- malware is in files not captured by backup) |
| March 10, 2026 | Website compromise detected; investigation begins |
| March 10, 2026 | Backup and database fully analyzed -- confirmed clean |
| March 10, 2026 | Malicious domains researched and documented |
| March 18, 2026 | SharedHost Provider panel access obtained |
| March 18, 2026 | Malicious PowerShell payload discovered in SSH settings |
| March 18, 2026 | Payload decoded -- confirms link to same attacker campaign |
| March 18, 2026 | WordPress XML export analyzed -- confirmed clean |
| March 18, 2026 | Compromised SSH disabled; clean credentials being created |
| Pending | Server-side file inspection and malware removal |

---

## What This Means for Your Customers

Your website has WooCommerce installed. If customers made purchases or entered personal information during the compromise window, their browsing activity on the site may have been tracked. Based on the evidence available at that stage, the attack looked like a redirect-and-tracking operation, not a payment interception scheme.

**Payment card data is not at elevated risk** if you use a third-party payment processor (like Square, which is integrated with your site), because the card numbers are handled on the payment processor's servers, not on your website.

Once we complete the server-side investigation, we will have a clearer picture of exactly what data may have been exposed.

---

## Summary

Your website was compromised as part of a large automated campaign against WordPress sites. The attackers used a fake "verify you are human" prompt to infect an administrator's computer and steal hosting credentials. The injected code redirects visitors and tracks them.

Your visible content was not altered. The malicious code sits in the server-side files. With direct server access, we can remove it, reinstall clean WordPress files, and lock the site down.

The most urgent actions are: changing your SharedHost Provider password, enabling two-factor authentication, and determining if any administrator's computer was infected by the fake CAPTCHA trick.

---

*This report is part of an ongoing investigation. Additional findings from the server-side file inspection will be provided once SSH access is established.*
