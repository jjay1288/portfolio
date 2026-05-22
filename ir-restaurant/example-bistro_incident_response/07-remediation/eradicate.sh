#!/bin/bash
# ============================================================================
# IR-2026-0310-EXBI -- ERADICATION SCRIPT
# ============================================================================
# Target:    example-bistro.invalid (WordPress 6.9.4 on SharedHost Provider)
# Prepared:  March 18, 2026
# Author:    Jay Phillips (Responder)
#
# INSTRUCTIONS:
#   1. Review this entire script before executing
#   2. Run from the server via SSH as siteuser02
#   3. Site must be in maintenance mode BEFORE running (.maintenance file)
#   4. Evidence must be collected BEFORE running (completed)
#
# EXECUTION:
#   bash eradicate.sh 2>&1 | tee ~/eradication-log-$(date +%Y%m%d-%H%M%S).txt
# ============================================================================

set -euo pipefail

WEBROOT="$HOME/example-bistro.invalid"
RUN_TS="$(date +%Y%m%d-%H%M%S)"
EVIDENCE_DIR="$HOME/eradication-evidence-$RUN_TS"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "[$(date '+%H:%M:%S')] $1"; }
ok()  { log "${GREEN}[OK]${NC} $1"; }
fail() { log "${RED}[FAIL]${NC} $1"; }
warn() { log "${YELLOW}[WARN]${NC} $1"; }
wp_safe() { wp --skip-plugins --skip-themes "$@"; }

check_url() {
    local url="$1"
    if command -v curl >/dev/null 2>&1; then
        curl -fsIL --max-time 20 "$url" >/dev/null
    elif command -v wget >/dev/null 2>&1; then
        wget --spider --server-response --timeout=20 "$url" >/dev/null 2>&1
    else
        fail "Neither curl nor wget is available for download preflight checks"
        return 1
    fi
}

prepare_file_for_review() {
    local target="$1"

    if [ ! -e "$target" ]; then
        return 0
    fi

    if [ -r "$target" ] && [ -w "$target" ]; then
        return 0
    fi

    if chmod u+rw "$target" 2>/dev/null; then
        ok "Adjusted owner read/write permissions for $target"
        return 0
    fi

    warn "Could not adjust owner read/write permissions for $target"
    return 1
}

snapshot_evidence_file() {
    local relative_path="$1"
    local source_path="$WEBROOT/$relative_path"
    local dest_path="$EVIDENCE_DIR/$relative_path"

    if [ ! -f "$source_path" ]; then
        warn "Evidence file not present for snapshot: $relative_path"
        return 0
    fi

    prepare_file_for_review "$source_path" || true

    mkdir -p "$(dirname "$dest_path")"
    if ! cp -p "$source_path" "$dest_path" 2>/dev/null; then
        warn "Could not snapshot evidence file: $relative_path"
        return 0
    fi
    sha256sum "$dest_path" >> "$EVIDENCE_DIR/SHA256SUMS.txt"
    ok "Snapshotted evidence file: $relative_path"
}

restore_minimal_child_theme() {
    local target="$1"
    cat > "$target" <<'PHP'
<?php
if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

function example_bistro_child_enqueue_styles() {
    $parent_theme = wp_get_theme( get_template() );
    wp_enqueue_style(
        'hello-biz-parent',
        get_template_directory_uri() . '/style.css',
        array(),
        $parent_theme->get( 'Version' )
    );
    wp_enqueue_style(
        'hello-biz-child',
        get_stylesheet_uri(),
        array( 'hello-biz-parent' ),
        wp_get_theme()->get( 'Version' )
    );
}
add_action( 'wp_enqueue_scripts', 'example_bistro_child_enqueue_styles', 20 );
PHP
    chmod 0644 "$target"
}

remove_create_admin_backdoor() {
    local target="$1"
    if [ ! -f "$target" ]; then
        warn "$target not found"
        return
    fi

    if grep -q 'create_admin.*erwesdxsas' "$target" 2>/dev/null; then
        local cleaned="${target}.cleaned"
        if awk '
            BEGIN {
                in_block = 0
                removed = 0
                block = ""
                has_marker = 0
            }
            function flush_block() {
                if (block != "") {
                    printf "%s", block
                }
                block = ""
                has_marker = 0
            }
            {
                line = $0 ORS

                if (!in_block && $0 ~ /^[[:space:]]*add_action\([[:space:]]*\047init\047,[[:space:]]*function[[:space:]]*\([[:space:]]*\)[[:space:]]*\{[[:space:]]*$/) {
                    in_block = 1
                    block = line
                    next
                }

                if (in_block) {
                    block = block line
                    if ($0 ~ /create_admin/ && $0 ~ /erwesdxsas/) {
                        has_marker = 1
                    }
                    if ($0 ~ /^[[:space:]]*\}\);[[:space:]]*$/) {
                        if (has_marker) {
                            removed = 1
                        } else {
                            flush_block()
                        }
                        in_block = 0
                    }
                    next
                }

                print
            }
            END {
                if (in_block) {
                    exit 2
                }
                if (!removed) {
                    exit 3
                }
            }
        ' "$target" > "$cleaned"; then
            mv "$cleaned" "$target"
            ok "Removed create_admin backdoor from $target"
        else
            local rc=$?
            rm -f "$cleaned"
            warn "Could not safely remove create_admin backdoor from $target (awk rc=$rc) -- review manually"
            return 0
        fi
    else
        warn "No create_admin backdoor found in $target"
    fi
}

remove_bounded_block() {
    local target="$1"
    local marker="$2"

    if [ ! -f "$target" ]; then
        warn "$target not found"
        return 1
    fi

    local marker_count
    marker_count=$(grep -cF "$marker" "$target" 2>/dev/null || true)
    if [ "$marker_count" -lt 2 ]; then
        warn "Expected bounded marker pair not found in $target"
        return 1
    fi

    local original_size cleaned_size
    original_size=$(wc -c < "$target" 2>/dev/null || echo 0)

    awk -v marker="$marker" '
        BEGIN { in_block=0; removed=0 }
        index($0, marker) {
            if (in_block == 0) {
                in_block=1
                removed=1
                next
            } else {
                in_block=0
                next
            }
        }
        in_block == 0 { print }
        END { if (in_block != 0) exit 2 }
    ' "$target" > "${target}.cleaned"

    cleaned_size=$(wc -c < "${target}.cleaned" 2>/dev/null || echo 0)
    if [ "$cleaned_size" -le 0 ] || [ "$cleaned_size" -ge "$original_size" ]; then
        warn "Cleaned output for $target failed size validation (orig=$original_size cleaned=$cleaned_size)"
        rm -f "${target}.cleaned"
        return 1
    fi

    if grep -qF "$marker" "${target}.cleaned" 2>/dev/null; then
        warn "Cleaned output for $target still contains marker $marker"
        rm -f "${target}.cleaned"
        return 1
    fi

    mv "${target}.cleaned" "$target"
    ok "Removed bounded malicious block from $target (marker: $marker)"
    return 0
}

# ============================================================================
# PRE-FLIGHT CHECKS
# ============================================================================
log "Starting eradication for IR-2026-0310-EXBI"
log "Web root: $WEBROOT"

if [ ! -f "$WEBROOT/.maintenance" ]; then
    fail "Site is NOT in maintenance mode. Aborting."
    exit 1
fi
ok "Maintenance mode confirmed"

if [ ! -f "$WEBROOT/wp-config.php" ]; then
    fail "wp-config.php not found. Wrong directory? Aborting."
    exit 1
fi
ok "WordPress installation found"

cd "$WEBROOT"

mkdir -p "$EVIDENCE_DIR"
ok "Evidence snapshot directory created: $EVIDENCE_DIR"

if ! command -v wp >/dev/null 2>&1; then
    fail "WP-CLI is not installed or not in PATH. Aborting before any destructive changes."
    exit 1
fi
ok "WP-CLI is available"

TABLE_PREFIX="$(wp config get table_prefix --type=variable 2>/dev/null | tr -d '\r' || true)"
if [ -z "$TABLE_PREFIX" ]; then
    fail "Could not determine WordPress table prefix from wp-config.php. Aborting."
    exit 1
fi
ok "Detected WordPress table prefix: $TABLE_PREFIX"

if ! wp_safe db query "SELECT 1" --skip-column-names >/dev/null 2>&1; then
    fail "Database connectivity check failed through WP-CLI. Aborting before any destructive changes."
    exit 1
fi
ok "Database connectivity confirmed"

if ! check_url "https://wordpress.org/wordpress-6.9.4.zip"; then
    fail "Cannot reach WordPress.org core package URL. Aborting before any destructive changes."
    exit 1
fi
ok "WordPress core download endpoint reachable"

if ! check_url "https://downloads.wordpress.org/theme/hello-biz.latest-stable.zip"; then
    fail "Cannot reach WordPress.org theme package URL for hello-biz. Aborting before any destructive changes."
    exit 1
fi
ok "hello-biz theme download endpoint reachable"

# ============================================================================
# LAYER 0: SNAPSHOT HIGH-VALUE EVIDENCE BEFORE DELETION
# ============================================================================
log ""
log "=== LAYER 0: Evidence Snapshot ==="

snapshot_evidence_file "wp-content/themes/hello-biz-child/functions.php"
snapshot_evidence_file "wp-content/uploads/.7ed1995199.tmp"
snapshot_evidence_file "wp-content/uploads/.redirect_blocked.log"
snapshot_evidence_file "wp-content/themes/kaon/functions.php"
snapshot_evidence_file "wp-content/themes/lemonchili/functions.php"
snapshot_evidence_file "wp-content/themes/hello-biz/functions.php"
snapshot_evidence_file ".backup_time"

# ============================================================================
# LAYER 1: REMOVE PERSISTENCE BOOTSTRAP (advanced-cache.php)
# ============================================================================
log ""
log "=== LAYER 1: Persistence Bootstrap ==="

if [ -f "wp-content/advanced-cache.php" ]; then
    if grep -q '_sm_ac_v5' "wp-content/advanced-cache.php"; then
        rm "wp-content/advanced-cache.php"
        ok "Removed malicious advanced-cache.php (tag: _sm_ac_v5)"
    else
        warn "advanced-cache.php exists but does NOT contain _sm_ac_v5 tag -- skipping (may be legitimate)"
    fi
else
    warn "advanced-cache.php already absent"
fi

# ============================================================================
# LAYER 2: REMOVE MU-PLUGIN MALWARE
# ============================================================================
log ""
log "=== LAYER 2: MU-Plugin Malware ==="

declare -A MUPLUGINS=(
    ["session-manager.php"]="TDS Engine"
    ["session-manager.php.bak"]="TDS Engine backup"
    ["wp-user-query.php"]="Stealth Toolkit"
    ["health-check.php"]="Stub/Loader"
)

for file in "${!MUPLUGINS[@]}"; do
    filepath="wp-content/mu-plugins/$file"
    if [ -f "$filepath" ]; then
        rm "$filepath"
        ok "Removed $filepath (${MUPLUGINS[$file]})"
    else
        warn "$filepath already absent"
    fi
done

# ============================================================================
# LAYER 2b: REMOVE MALICIOUS PLUGIN (wp-perf-analytics)
# ============================================================================
log ""
log "=== LAYER 2b: Malicious Plugin ==="

PERF_PLUGIN="wp-content/plugins/wp-perf-analytics"
if [ -d "$PERF_PLUGIN" ]; then
    PERF_PLUGIN_FILE="$PERF_PLUGIN/wp-perf-analytics.php"
    # Verify it's malicious (contains XOR-encrypted JS injection / loader markers)
    if [ -f "$PERF_PLUGIN_FILE" ] && grep -Eq 'atob\(d\).*charCodeAt|new TextDecoder|new Function\(|_wp_perf_ok|Developer Tools Team' "$PERF_PLUGIN_FILE" 2>/dev/null; then
        # Deactivate via WP-CLI first, then remove
        wp_safe plugin deactivate wp-perf-analytics 2>/dev/null || true
        rm -rf "$PERF_PLUGIN"
        ok "Removed malicious plugin: wp-perf-analytics (XOR-encrypted JS injector)"
    else
        warn "wp-perf-analytics exists but does NOT match expected malicious markers -- review manually"
    fi
else
    warn "wp-perf-analytics plugin directory already absent"
fi

# ============================================================================
# LAYER 3: REMOVE WEBSHELLS (5 copies)
# ============================================================================
log ""
log "=== LAYER 3: Webshell Network ==="

WEBSHELLS=(
    "wp-includes/fonts/font-metrics.php"
    "wp-content/upgrade/wp-update-verify.php"
    "wp-content/uploads/woocommerce_uploads/wc-report-handler.php"
    "wp-content/uploads/wp-cache-stats.php"
    "wp-content/languages/wp-locale-handler.php"
)

for filepath in "${WEBSHELLS[@]}"; do
    if [ -f "$filepath" ]; then
        # Verify it's actually a webshell (contains auth key)
        if grep -q 'a3f8b2c1d4e5f607' "$filepath"; then
            rm "$filepath"
            ok "Removed webshell: $filepath"
        else
            warn "$filepath exists but does NOT contain webshell auth key -- skipping"
        fi
    else
        warn "$filepath already absent"
    fi
done

# ============================================================================
# LAYER 4: REMOVE EXFILTRATION / DATA FILES
# ============================================================================
log ""
log "=== LAYER 4: Exfiltration Data ==="

# Credential dump (fake PNG)
if [ -f "wp-content/uploads/2024/06/Stained_Heart_Red-600x500.png" ]; then
    rm "wp-content/uploads/2024/06/Stained_Heart_Red-600x500.png"
    ok "Removed credential dump file (Stained_Heart_Red-600x500.png)"
else
    warn "Credential dump file already absent"
fi

# Encrypted data files
if [ -f "wp-includes/css/wp-editor-font.css" ]; then
    rm "wp-includes/css/wp-editor-font.css"
    ok "Removed encrypted data file (wp-editor-font.css)"
else
    warn "wp-editor-font.css already absent"
fi

for backup_time_path in ".backup_time" "wp-admin/.backup_time"; do
    if [ -f "$backup_time_path" ]; then
        rm "$backup_time_path"
        ok "Removed encrypted data file ($backup_time_path)"
    else
        warn "$backup_time_path already absent"
    fi
done

# Hidden XOR-encoded TDS config/cache file(s)
while IFS= read -r tmpfile; do
    if head -c 4 "$tmpfile" 2>/dev/null | grep -q '^XOR:'; then
        rm "$tmpfile"
        ok "Removed hidden XOR temp/config file: $tmpfile"
    else
        warn "Hidden tmp file does not match XOR marker -- skipping: $tmpfile"
    fi
done < <(find wp-content/uploads -maxdepth 1 -type f -name '.*.tmp' 2>/dev/null || true)

# Redirect log created by malicious redirect guard
if [ -f "wp-content/uploads/.redirect_blocked.log" ]; then
    rm "wp-content/uploads/.redirect_blocked.log"
    ok "Removed malicious redirect log (.redirect_blocked.log)"
else
    warn ".redirect_blocked.log already absent"
fi

# Remove TDS cache-bypass residue from .htaccess
if [ -f ".htaccess" ]; then
    cp -p ".htaccess" ".htaccess.pre-eradication"
    ok "Backed up .htaccess to .htaccess.pre-eradication"
    if grep -q 'BEGIN TDS_NOCACHE' ".htaccess"; then
        sed -i '/# BEGIN TDS_NOCACHE/,/# END TDS_NOCACHE/d' ".htaccess"
        ok "Removed TDS_NOCACHE block from .htaccess"
    else
        warn "No TDS_NOCACHE block found in .htaccess"
    fi
fi

# ============================================================================
# LAYER 5: DATABASE CLEANUP
# ============================================================================
log ""
log "=== LAYER 5: Database Cleanup ==="

# Remove malicious options
DB_OPTIONS=(
    "wp_session_tokens_config"
    "_pre_user_id"
    "_wp_mail_queue_log"
    "_wc_analytics_data"
    "_wp_site_activity"
    "_tds_stats"
    "_tds_config"
)

for opt in "${DB_OPTIONS[@]}"; do
    result=$(wp_safe db query "SELECT COUNT(*) FROM ${TABLE_PREFIX}options WHERE option_name = '$opt'" --skip-column-names 2>/dev/null | tail -1)
    if [ "$result" -gt 0 ] 2>/dev/null; then
        wp_safe db query "DELETE FROM ${TABLE_PREFIX}options WHERE option_name = '$opt'" 2>/dev/null
        ok "Deleted DB option: $opt"
    else
        warn "DB option $opt already absent"
    fi
done

# Clean wp-perf-analytics from active_plugins serialized array
# (wp plugin deactivate should handle this, but verify)
PERF_ACTIVE=$(wp_safe db query "SELECT option_value FROM ${TABLE_PREFIX}options WHERE option_name = 'active_plugins'" --skip-column-names 2>/dev/null | grep -c 'wp-perf-analytics' || true)
if [ "$PERF_ACTIVE" -gt 0 ] 2>/dev/null; then
    warn "wp-perf-analytics still in active_plugins -- forcing deactivation via WP-CLI"
    wp_safe plugin deactivate wp-perf-analytics 2>/dev/null || true
fi

# Remove TDS transient/cache rows and self-heal cron entry
wp_safe cron event delete _tds_cache_selfheal 2>/dev/null && ok "Deleted _tds_cache_selfheal WP-Cron event" || warn "_tds_cache_selfheal WP-Cron event already absent"

TDS_OPTION_ROWS=$(wp_safe db query "SELECT option_name FROM ${TABLE_PREFIX}options WHERE option_name LIKE '\\_transient\\_\\_tds\\_%' ESCAPE '\\' OR option_name LIKE '\\_transient\\_timeout\\_\\_tds\\_%' ESCAPE '\\'" --skip-column-names 2>/dev/null || true)
if [ -n "$TDS_OPTION_ROWS" ]; then
    wp_safe db query "DELETE FROM ${TABLE_PREFIX}options WHERE option_name LIKE '\\_transient\\_\\_tds\\_%' ESCAPE '\\' OR option_name LIKE '\\_transient\\_timeout\\_\\_tds\\_%' ESCAPE '\\'" 2>/dev/null
    ok "Deleted TDS transient/cache rows"
else
    warn "No TDS transient/cache rows found"
fi

# Delete hidden admin user (ID 8: adminbackup1d8273)
HIDDEN_USER=$(wp_safe db query "SELECT user_login FROM ${TABLE_PREFIX}users WHERE ID = 8" --skip-column-names 2>/dev/null | tail -1)
if [ "$HIDDEN_USER" = "adminbackup1d8273" ]; then
    wp_safe user delete 8 --reassign=1 --yes 2>/dev/null
    ok "Deleted hidden admin user: adminbackup1d8273 (ID 8, reassigned content to ID 1)"
elif [ -n "$HIDDEN_USER" ]; then
    warn "User ID 8 exists but is '$HIDDEN_USER', not adminbackup1d8273 -- skipping for safety"
else
    warn "User ID 8 already absent"
fi

HIDDEN_USERMETA_ROWS=$(wp_safe db query "SELECT COUNT(*) FROM ${TABLE_PREFIX}usermeta WHERE user_id = 8" --skip-column-names 2>/dev/null | tail -1)
if [ "${HIDDEN_USERMETA_ROWS:-0}" -gt 0 ] 2>/dev/null; then
    wp_safe db query "DELETE FROM ${TABLE_PREFIX}usermeta WHERE user_id = 8" 2>/dev/null
    ok "Deleted orphaned usermeta rows for user ID 8"
else
    warn "No orphaned usermeta rows found for user ID 8"
fi

# ============================================================================
# LAYER 6: CLEAN MODIFIED THEME FILES / REINSTALL TRUSTED PARENT THEME
# ============================================================================
log ""
log "=== LAYER 6: Theme Cleanup ==="

THEME_FUNC="wp-content/themes/hello-biz/functions.php"
if [ -f "$THEME_FUNC" ]; then
    ok "hello-biz/functions.php present; parent theme will be replaced from WordPress.org"
else
    warn "$THEME_FUNC not found"
fi

# Clean active child theme functions.php.
CHILD_THEME_FUNC="wp-content/themes/hello-biz-child/functions.php"
if [ -e "$CHILD_THEME_FUNC" ]; then
    prepare_file_for_review "$CHILD_THEME_FUNC" || true
    if grep -q '__mu_deployer__' "$CHILD_THEME_FUNC" 2>/dev/null; then
        if remove_bounded_block "$CHILD_THEME_FUNC" '/* __mu_deployer__ */'; then
            :
        else
            quarantine_path="${CHILD_THEME_FUNC}.quarantine.$(date +%Y%m%d-%H%M%S)"
            mv "$CHILD_THEME_FUNC" "$quarantine_path"
            restore_minimal_child_theme "$CHILD_THEME_FUNC"
            ok "Bounded block removal failed; quarantined original child theme file and installed minimal safe stub"
        fi
    elif grep -q 'base64_decode.*session-manager\|wp-session-manager\|wp_debug_session\|a3f8b2c1d4e5f607' "$CHILD_THEME_FUNC" 2>/dev/null; then
        quarantine_path="${CHILD_THEME_FUNC}.quarantine.$(date +%Y%m%d-%H%M%S)"
        mv "$CHILD_THEME_FUNC" "$quarantine_path"
        restore_minimal_child_theme "$CHILD_THEME_FUNC"
        ok "Child theme remained suspicious after marker scan; quarantined original and installed minimal safe stub"
    else
        ok "hello-biz-child/functions.php does not match known malicious child-theme markers"
    fi
else
    warn "$CHILD_THEME_FUNC not found"
fi

# Clean dormant theme backdoors so theme switching cannot reactivate attacker access.
remove_create_admin_backdoor "wp-content/themes/kaon/functions.php"
remove_create_admin_backdoor "wp-content/themes/lemonchili/functions.php"

# Reinstall the official parent theme from WordPress.org to replace any other
# undocumented edits in the distributed theme files.
if wp_safe theme install hello-biz --force; then
    ok "Reinstalled official hello-biz parent theme from WordPress.org"
else
    fail "Failed to reinstall hello-biz parent theme automatically"
    exit 1
fi

# ============================================================================
# LAYER 7: REINSTALL WORDPRESS CORE (replaces modified wp-login.php)
# ============================================================================
log ""
log "=== LAYER 7: Core Reinstallation ==="

if ! wp_safe core download --force --version=6.9.4; then
    fail "WordPress core download/reinstall failed"
    exit 1
fi
ok "WordPress 6.9.4 core files reinstalled (clean copies)"

# Verify core integrity
log "Running core checksum verification..."
if wp_safe core verify-checksums; then
    ok "WordPress core checksums PASS"
else
    fail "WordPress core checksums FAIL -- manual review needed"
    exit 1
fi

# ============================================================================
# LAYER 8: SESSION INVALIDATION / AUTH RESET
# ============================================================================
log ""
log "=== LAYER 8: Session Invalidation ==="

SESSION_META_KEY="${TABLE_PREFIX}session_tokens"
SESSION_ROWS=$(wp_safe db query "SELECT COUNT(*) FROM ${TABLE_PREFIX}usermeta WHERE meta_key = '${SESSION_META_KEY}'" --skip-column-names 2>/dev/null | tail -1)
if [ "${SESSION_ROWS:-0}" -gt 0 ] 2>/dev/null; then
    wp_safe db query "DELETE FROM ${TABLE_PREFIX}usermeta WHERE meta_key = '${SESSION_META_KEY}'"
    ok "Deleted WordPress session tokens for all users"
else
    warn "No WordPress session token rows found"
fi

ONE_TIME_LOGIN_ROWS=$(wp_safe db query "SELECT COUNT(*) FROM ${TABLE_PREFIX}usermeta WHERE meta_key = 'one_time_login_token'" --skip-column-names 2>/dev/null | tail -1)
if [ "${ONE_TIME_LOGIN_ROWS:-0}" -gt 0 ] 2>/dev/null; then
    wp_safe db query "DELETE FROM ${TABLE_PREFIX}usermeta WHERE meta_key = 'one_time_login_token'"
    ok "Deleted SharedHost Provider one-time login tokens"
else
    warn "No SharedHost Provider one-time login tokens found"
fi

if wp_safe config shuffle-salts; then
    ok "WordPress salts regenerated"
else
    fail "Failed to regenerate WordPress salts"
    exit 1
fi

# ============================================================================
# POST-ERADICATION VERIFICATION
# ============================================================================
log ""
log "=========================================="
log "=== POST-ERADICATION VERIFICATION ==="
log "=========================================="

# Check 1: No malicious mu-plugins remain
log ""
log "--- Check 1: MU-Plugins directory ---"
REMAINING_BAD_MUPLUGINS=$(find wp-content/mu-plugins -maxdepth 1 -type f \( -name 'session-manager.php' -o -name 'session-manager.php.bak' -o -name 'wp-user-query.php' -o -name 'health-check.php' \) 2>/dev/null || true)
if [ -z "$REMAINING_BAD_MUPLUGINS" ]; then
    ok "Known malicious mu-plugins removed"
else
    fail "Known malicious mu-plugins still present:"
    echo "$REMAINING_BAD_MUPLUGINS"
fi
if [ -d "wp-content/mu-plugins/" ]; then
    ls -la wp-content/mu-plugins/
else
    ok "mu-plugins directory is empty/absent"
fi

# Check 2: No PHP in uploads
log ""
log "--- Check 2: PHP files in uploads ---"
PHP_IN_UPLOADS=$(find wp-content/uploads/ -name '*.php' -not -name 'index.php' 2>/dev/null)
if [ -z "$PHP_IN_UPLOADS" ]; then
    ok "No PHP files found in uploads directory"
else
    fail "PHP files still in uploads:"
    echo "$PHP_IN_UPLOADS"
fi

# Check 3: No webshells remain
log ""
log "--- Check 3: Webshell auth key scan ---"
WEBSHELL_SCAN=$(grep -rl 'a3f8b2c1d4e5f607' . --include='*.php' 2>/dev/null || true)
if [ -z "$WEBSHELL_SCAN" ]; then
    ok "No files contain webshell auth key"
else
    fail "Webshell auth key still found in:"
    echo "$WEBSHELL_SCAN"
fi

# Check 4: No malicious DB options remain
log ""
log "--- Check 4: Malicious DB options ---"
REMAINING_OPTS=$(wp_safe db query "SELECT option_name FROM ${TABLE_PREFIX}options WHERE option_name IN ('wp_session_tokens_config','_pre_user_id','_wp_mail_queue_log','_wc_analytics_data','_wp_site_activity')" --skip-column-names 2>/dev/null)
if [ -z "$REMAINING_OPTS" ]; then
    ok "All malicious DB options removed"
else
    fail "Malicious DB options still present:"
    echo "$REMAINING_OPTS"
fi

# Check 5: Hidden admin gone
log ""
log "--- Check 5: Hidden admin user ---"
ADMIN_CHECK=$(wp_safe db query "SELECT user_login FROM ${TABLE_PREFIX}users WHERE ID = 8" --skip-column-names 2>/dev/null)
if [ -z "$ADMIN_CHECK" ]; then
    ok "Hidden admin user (ID 8) removed"
else
    fail "User ID 8 still exists: $ADMIN_CHECK"
fi

# Check 5b: Backdoor-created adminpro user absent
log ""
log "--- Check 5b: adminpro user ---"
ADMINPRO_CHECK=$(wp_safe db query "SELECT user_login FROM ${TABLE_PREFIX}users WHERE user_login = 'adminpro'" --skip-column-names 2>/dev/null || true)
if [ -z "$ADMINPRO_CHECK" ]; then
    ok "adminpro user absent"
else
    fail "Unexpected adminpro user exists"
fi

# Check 5c: Hidden usermeta residue gone
log ""
log "--- Check 5c: Hidden usermeta residue ---"
USERMETA_8_CHECK=$(wp_safe db query "SELECT COUNT(*) FROM ${TABLE_PREFIX}usermeta WHERE user_id = 8" --skip-column-names 2>/dev/null | tail -1)
if [ "${USERMETA_8_CHECK:-0}" -eq 0 ] 2>/dev/null; then
    ok "No orphaned usermeta rows remain for user ID 8"
else
    fail "Orphaned usermeta rows still exist for user ID 8"
fi

# Check 5d: SharedHost Provider one-time login tokens absent
log ""
log "--- Check 5d: SharedHost Provider one-time login tokens ---"
ONE_TIME_LOGIN_CHECK=$(wp_safe db query "SELECT COUNT(*) FROM ${TABLE_PREFIX}usermeta WHERE meta_key = 'one_time_login_token'" --skip-column-names 2>/dev/null | tail -1)
if [ "${ONE_TIME_LOGIN_CHECK:-0}" -eq 0 ] 2>/dev/null; then
    ok "SharedHost Provider one-time login tokens absent"
else
    fail "SharedHost Provider one-time login tokens still present"
fi

# Check 6: User listing (verify no unexpected users)
log ""
log "--- Check 6: All WordPress users ---"
wp_safe user list --fields=ID,user_login,user_email,roles 2>/dev/null

# Check 7: Check for rogue files in wp-includes/fonts/
log ""
log "--- Check 7: Rogue files in wp-includes/fonts/ ---"
ROGUE_PHP=$(find wp-includes/fonts/ -name '*.php' 2>/dev/null || true)
if [ -z "$ROGUE_PHP" ]; then
    ok "No PHP files in wp-includes/fonts/"
else
    fail "PHP files found in wp-includes/fonts/:"
    echo "$ROGUE_PHP"
fi

# Check 8: Malicious domain references
log ""
log "--- Check 8: webanalytics-cdn domain references ---"
DOMAIN_SCAN=$(grep -rl 'webanalytics-cdn' . --include='*.php' 2>/dev/null || true)
if [ -z "$DOMAIN_SCAN" ]; then
    ok "No references to webanalytics-cdn in PHP files"
else
    fail "webanalytics-cdn still referenced in:"
    echo "$DOMAIN_SCAN"
fi

# Check 9: Theme functions.php clean
log ""
log "--- Check 9: Theme functions.php ---"
if grep -R -q 'create_admin\|WordPress session analytics\|file_put_contents.*base64_decode' wp-content/themes 2>/dev/null; then
    fail "Theme directory still contains known malicious theme injections"
else
    ok "Theme directory appears clean of known theme injections"
fi

# Check 10: wp-perf-analytics gone
log ""
log "--- Check 10: Malicious plugin (wp-perf-analytics) ---"
if [ -d "wp-content/plugins/wp-perf-analytics" ]; then
    fail "wp-perf-analytics plugin directory still exists"
else
    ok "wp-perf-analytics plugin removed"
fi

# Check 11: XOR/atob JS injection patterns
log ""
log "--- Check 11: XOR-encrypted JS injection scan ---"
JS_INJECT=$(grep -rl 'atob(d).*charCodeAt.*\^k' . --include='*.php' 2>/dev/null || true)
if [ -z "$JS_INJECT" ]; then
    ok "No XOR-encrypted JS injection patterns found"
else
    fail "JS injection pattern still found in:"
    echo "$JS_INJECT"
fi

# Check 12: advanced-cache.php
log ""
log "--- Check 12: advanced-cache.php ---"
if [ -f "wp-content/advanced-cache.php" ]; then
    if grep -q '_sm_ac_v5' "wp-content/advanced-cache.php"; then
        fail "Malicious advanced-cache.php still present"
    else
        ok "advanced-cache.php exists but is clean"
    fi
else
    ok "advanced-cache.php absent (expected after cleanup)"
fi

log ""
log "--- Check 12b: .backup_time artifacts ---"
BACKUP_TIME_REMAINS=$(find . -maxdepth 2 -type f \( -path './.backup_time' -o -path './wp-admin/.backup_time' \) 2>/dev/null || true)
if [ -n "$BACKUP_TIME_REMAINS" ]; then
    fail ".backup_time artifact(s) still present:"
    echo "$BACKUP_TIME_REMAINS"
else
    ok "No .backup_time artifacts remain"
fi

# Check 13: TDS cache-bypass residue
log ""
log "--- Check 13: TDS persistence residue ---"
TDS_REMAINS=$(wp_safe db query "SELECT option_name FROM ${TABLE_PREFIX}options WHERE option_name = '_tds_stats' OR option_name = '_tds_config' OR option_name LIKE '\\_transient\\_\\_tds\\_%' ESCAPE '\\' OR option_name LIKE '\\_transient\\_timeout\\_\\_tds\\_%' ESCAPE '\\'" --skip-column-names 2>/dev/null || true)
if [ -n "$TDS_REMAINS" ]; then
    fail "TDS options/transients still present:"
    echo "$TDS_REMAINS"
else
    ok "No TDS options/transients remain"
fi

if wp_safe cron event list --fields=hook --format=csv 2>/dev/null | grep -q '_tds_cache_selfheal'; then
    fail "_tds_cache_selfheal cron event still present"
else
    ok "_tds_cache_selfheal cron event absent"
fi

if grep -q 'BEGIN TDS_NOCACHE' ".htaccess" 2>/dev/null; then
    fail ".htaccess still contains TDS_NOCACHE block"
else
    ok ".htaccess free of TDS_NOCACHE residue"
fi

XOR_TMP_REMAINS=$(find wp-content/uploads -maxdepth 1 -type f -name '.*.tmp' -exec sh -c 'head -c 4 "$1" 2>/dev/null | grep -q "^XOR:" && echo "$1"' _ {} \; 2>/dev/null || true)
if [ -n "$XOR_TMP_REMAINS" ]; then
    fail "Hidden XOR tmp file(s) still present:"
    echo "$XOR_TMP_REMAINS"
else
    ok "No hidden XOR tmp file remains in uploads"
fi

# ============================================================================
# SUMMARY
# ============================================================================
log ""
log "=========================================="
log "=== ERADICATION COMPLETE ==="
log "=========================================="
log ""
log "Maintenance mode is STILL ACTIVE (.maintenance file in place)"
log ""
log "NEXT STEPS (manual):"
log "  1. Review verification results above for any FAIL entries"
log "  2. Rotate ALL WordPress passwords (wp --skip-plugins --skip-themes user update <id> --user_pass=<new>)"
log "  3. Rotate database password in SharedHost Provider panel + wp-config.php"
log "  4. Remove maintenance mode: rm $WEBROOT/.maintenance"
log "  5. Verify site loads correctly: curl -I https://example-bistro.invalid"
log "  6. Enable Wordfence or similar WAF"
log ""
log "Evidence snapshot saved to: $EVIDENCE_DIR"
