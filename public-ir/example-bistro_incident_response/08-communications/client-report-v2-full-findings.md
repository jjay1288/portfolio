# Security Incident Report: Example Bistro Website
## example-bistro.invalid -- Updated with Server Investigation Results

**Prepared for:** Example Bistro Ownership
**Date:** March 18, 2026 (Version 2 -- Full Server Findings)
**Status:** ~~Active Compromise -- Eradication Ready~~ — **SUPERSEDED** — Full eradication completed March 18, 2026. See post-eradication-checklist.md for current recovery status. This report is preserved as a pre-eradication client deliverable.
**Severity:** Critical

---

## What Has Changed Since Our Last Report

Our first report covered the redirect behavior and the clean backup findings. At that stage, the active malware was still hidden in server-side files we could not access. We are no longer treating the March 10 `.wpress` archive as a trusted theme restore source.

**We now have full access to those server files and completed a full scan.** The results are worse than the first report showed. This report states the findings plainly.

---

## What We Found on the Server

### 1. The Attackers Built an Extensive Operation Inside Your Website

This was a full server compromise. The attackers installed **15 confirmed malicious files**, a malicious plugin, and hidden database data. Follow-on validation also found self-heal persistence in `.htaccess`, scheduled tasks, hidden uploads files, and theme code. Each part had a job:

**Visitor Redirection System** -- A large (126KB) program that runs automatically every time someone visits your website. It decides whether to redirect the visitor to an external website and tracks their browsing information. It is smart enough to detect when a security scanner visits the site and temporarily shuts itself off to avoid detection.

**Five Hidden Backdoor Entrances** -- The attackers placed identical copies of a remote control tool in five different locations throughout your website's file system. Each copy can independently rebuild the entire malware infection if the others are removed. Think of it like hiding five spare keys to your house in different places around the property.

**Password Theft System** -- Every time anyone logged into your WordPress admin panel, their username and password were secretly recorded. The stolen passwords were saved to a file disguised as a restaurant photo (`Stained_Heart_Red-600x500.png`). **Two sets of passwords were confirmed stolen** (see below).

**Hidden Administrator Account** -- The attackers created a secret admin account (`adminbackup1d8273`) and hid it from the Users page, the REST API, search results, and security scans.

**Email Spy** -- Every email sent by your website (order confirmations, password resets, contact form submissions) was intercepted and logged. The attackers captured 7 emails during the compromise period.

**Activity Monitor** -- Every time someone logged in, changed settings, or activated a plugin, the attackers recorded it. They have a detailed log of who did what on your website and from which IP addresses.

**Self-Repair System** -- Even if someone discovered and deleted the main malware, a hidden backup copy stored in your database would automatically reinstall it on the next page visit. The attackers built five layers of protection against removal.

**Theme Re-entry Paths** -- We confirmed dormant admin-creation backdoors inside inactive theme files and a strongly suspicious modification of the active child theme's `functions.php`. Because the backup archive cannot be treated as fully trusted, the child theme will be neutralized and rebuilt from a separately verified source rather than restored blindly from backup.

### 2. Stolen Passwords (CRITICAL)

**Two WordPress admin passwords were captured in plain text:**

| Account | Person | Password Stolen? |
|---|---|---|
| webagency | Agency Developer 1 | **YES -- password captured 6 times** (4 plaintext + 2 encrypted) |
| SiteOwnerUser | Site Owner | **YES -- password captured 3 times** (2 plaintext + 1 encrypted) |
| Manager | ([EMAIL-REDACTED]) | **No evidence of capture** -- encrypted entries were decrypted and do not contain this account |
| AgencyAdmin2 | Agency Developer 2 | Unknown |

We were able to decrypt the encrypted entries. They turned out to be additional copies of Agency Developer 1's and Site Owner's credentials -- not any new accounts. The Manager account password does not appear to have been captured, but should still be changed as a precaution.

**If Agency Developer 1 or Site Owner use the same password on other accounts (email, banking, social media), those accounts are also at risk.** The attackers may have already tried the stolen passwords on other services.

### 3. Customer Data Exposure

The attackers installed code designed to capture WooCommerce order information (customer names, email addresses, phone numbers, order amounts). **No order data was actually captured** during the compromise period -- the harvesting code was in place but no orders were processed.

However, your website's outgoing emails were being intercepted, which means the attackers may have seen:
- WordPress update notifications
- New user registration alerts
- Contact form submissions during the compromise period

**Payment card data is NOT at risk** because Square handles payment processing on their own servers, not on your website.

---

## What We Still Cannot Prove

We can prove that the website was already compromised by the time of the oldest SharedHost Provider backup we were able to restore on March 17, 2026. We can also prove that the attackers had SharedHost Provider-level access and that a ClickFix password-stealing attack was part of this campaign.

What we cannot prove is the exact moment the compromise first entered your environment. Two scenarios still fit:

- The site was already compromised before or during the move to SharedHost Provider, and that compromised state was carried forward.
- The site was transferred cleanly, but the attackers later obtained SharedHost Provider access through stolen credentials and deployed the malware on March 8.

The available logs do not go back far enough to settle that question. The firm conclusion is simpler: the site was compromised by March 8, and the original entry point remains unconfirmed.

---

## How the Attackers Protected Their Access

The attackers built an unusually sophisticated system to maintain access to your website. They created **five layers of protection**:

1. **If someone deletes the main malware** -- a hidden program automatically recreates it from a backup stored in the database
2. **If someone cleans the database** -- any of five hidden backdoor files can rebuild everything
3. **If someone finds and removes the backdoors** -- the hidden admin account still gives them full access
4. **If someone discovers the hidden admin** -- special code makes it invisible to all normal methods of viewing users
5. **If someone reinstalls WordPress** -- the malware in theme files and the database would survive

**Cleanup has to remove all five layers at once.** That is what the eradication plan is built to do.

### A Note About the "Hide My WP" Security Plugin

Your site uses a plugin called Hide My WP, which hides the WordPress login page behind a custom URL. This plugin also has a "bypass parameter" -- a special keyword added to any web address that tells the server to skip the normal security rules and serve the file directly.

**That bypass keyword is currently set to your first name (`[REDACTED-BYPASS-KEY]`).** This is trivially guessable by anyone who knows anything about the business.

This matters because it is how the attackers were able to reach their backdoor files even while the site was in maintenance mode. When we put the site into maintenance, normal visitors and bots got a "site under maintenance" error -- but anyone who added `?bypass_key=[REDACTED-BYPASS-KEY]` to the web address could bypass that and reach the attacker's hidden files directly.

**We have since blocked this access** by adding server-level rules that prevent any PHP files from running in the directories where the backdoors are located. However, the bypass keyword itself still needs to be changed to a long, random string during cleanup. If you or your developer set this value, please be aware that it should never be a name, word, or anything guessable.

---

## What Needs to Happen Now

### Immediate (Today)

**1. Do not log into WordPress until cleanup is complete**
Every login attempt is being recorded by the password theft system. If you logged in since March 8, treat that password as captured.

**2. Change passwords for Agency Developer 1 and Site Owner everywhere**
Not just WordPress -- any account where they use the same or similar password must be changed immediately. This includes:
- Email accounts
- Banking and financial services
- Social media
- Any other online services

**3. We will execute the eradication plan**
We have identified every malicious file, database entry, and hidden account. The cleanup involves:
- Removing 15 malicious files and the malicious plugin
- Deleting hidden database entries plus TDS transient/cache data
- Deleting the hidden admin account
- Reinstalling fresh WordPress core files
- Neutralizing compromised theme files and reinstalling the trusted parent theme
- Verifying everything is clean

### Within 24 Hours After Cleanup

**4. All WordPress passwords must be changed**
Every administrator account needs a new, strong, unique password.

**5. Enable two-factor authentication**
On both the SharedHost Provider hosting panel and all WordPress admin accounts.

**6. Determine if any computer was infected**
If anyone who manages the website encountered a "Verify you are human" pop-up that asked them to paste something or press keyboard shortcuts, that computer should be scanned with antivirus software and all saved browser passwords should be changed.

### Within One Week

**7. Reduce admin accounts** -- Only people actively managing the site should have administrator access
**8. Add email security (DMARC)** -- Already configured (`p=reject`). No action needed.
**9. Strengthen login security** -- Change the Hide My WP hidden login URL from `/hidden-login` and the bypass key from `[REDACTED-BYPASS-KEY]` to long random strings (this will be done during eradication)
**10. Consider upgrading hosting** -- Managed WordPress hosting provides better isolation and built-in security

---

## Updated Timeline

| Date | Event |
|---|---|
| February 18, 2026 | Attackers register 4 malicious domains (40-second window) |
| Late Feb -- Early Mar | Administrator's computer compromised via fake CAPTCHA |
| **March 8, 2026** | **Attackers deploy full malware kit (15 files) to server** |
| **March 8, 2026** | **Hidden admin account created (18:16 UTC)** |
| **March 8-18, 2026** | **2 sets of admin passwords stolen; 7 emails intercepted** |
| March 10, 2026 | Compromise detected; investigation begins |
| March 10, 2026 | Backup analysis completed (no active server-resident malware found in accessible archive; archive not trusted as final theme restore source) |
| March 17, 2026 | Oldest retained SharedHost Provider backup restored; restored content already includes compromised files |
| March 18, 2026 | SharedHost Provider panel access obtained |
| March 18, 2026 | PowerShell payload discovered in SSH settings |
| **March 18, 2026** | **Full server scan completed -- 15 malicious files plus malicious plugin and self-heal persistence identified** |
| **March 18, 2026** | **Stolen passwords, hidden admin account, and compromised theme paths discovered** |
| **March 18, 2026** | **Case upgraded to Tier 1 incident; eradication plan prepared** |
| Pending | Eradication, credential rotation, and hardening |

---

## Important Questions (Updated)

1. **Has Agency Developer 1 or Site Owner used their WordPress password on any other accounts?** If yes, those accounts need immediate password changes.

2. **Has anyone who manages the website logged in since March 8?** If yes, treat those credentials as captured. They should not log in again until cleanup is complete.

3. **Were any WooCommerce orders placed between March 8 and today?** While no order data was captured by the malware's harvesting system, we should verify this.

4. **Has anyone encountered a "Verify you are human" pop-up that asked them to paste something?** This is how the attack started. That computer needs to be scanned.

---

## Summary

The server investigation showed a much deeper compromise than the first backup review revealed. The attackers deployed a layered malware kit with persistence, credential theft, email interception, and admin surveillance. Two administrator credential sets were stolen in cleartext.

**What matters now:** we identified the infection components and built an eradication plan that removes them. The visible site content, pages, photos, and menus were not altered.

The most urgent action is changing passwords for the two confirmed compromised accounts (Agency Developer 1 and Site Owner) across all services, not just WordPress.

---

*This report is Version 2 of the client communication, updated with full server-side investigation results. It supersedes the initial report dated March 18, 2026.*

*Case Reference: IR-2026-0310-EXBI*
