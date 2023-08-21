#! /usr/bin/env sh

CONFIG_PATH="/opt/adguardhome/conf/AdGuardHome.yaml"

# Admin username
if [ -z "$ADMIN_USERNAME" ]; then
    echo "$(date -Iseconds) [error] Container requires ADMIN_USERNAME environment variable"
    exit 1
fi
sed -i "s|ADMIN_USERNAME|$ADMIN_USERNAME|g" "$CONFIG_PATH"

# Admin password
if [ -z "$ADMIN_PASSWORD" ]; then
    echo "$(date -Iseconds) [error] Container requires ADMIN_PASSWORD environment variable"
    exit 1
fi
ADMIN_PASSWORD_ENCRYPTED=$(htpasswd -B -n -b "$ADMIN_USERNAME" "$ADMIN_PASSWORD" | cut -d ":" -f 2)
sed -i "s|ADMIN_PASSWORD_ENCRYPTED|$ADMIN_PASSWORD_ENCRYPTED|g" "$CONFIG_PATH"

# Upstream DNS
if [ -z "$UPSTREAM_DNS" ]; then
    echo "$(date -Iseconds) [error] Container requires UPSTREAM_DNS environment variable"
    exit 1
fi
sed -i "s|UPSTREAM_DNS|$UPSTREAM_DNS|g" "$CONFIG_PATH"

# Allow filter
echo "$(date -Iseconds) [info] Applying allow filter rules (if any)"
if [ -n "$SPACE_SEPARATED_FILTER_ALLOW" ]; then
    # Add each rule from the allow list
    echo "$SPACE_SEPARATED_FILTER_ALLOW" | tr ' ' '\n' | while read -r FILTER_ALLOW; do
        echo "$(date -Iseconds) [info] ... allowing '$FILTER_ALLOW'"
        sed -i "s:  - FILTER_ALLOW:  - \"@@||$FILTER_ALLOW\"\n  - FILTER_ALLOW:g" "$CONFIG_PATH"
    done
fi
# Remove the allow placeholder
sed -i "/FILTER_ALLOW/d" $CONFIG_PATH

# Deny filter
echo "$(date -Iseconds) [info] Applying deny filter rules (if any)"
if [ -n "$SPACE_SEPARATED_FILTER_DENY" ]; then
    # Add each rule from the deny list
    echo "$SPACE_SEPARATED_FILTER_DENY" | tr ' ' '\n' | while read -r FILTER_DENY; do
        echo "$(date -Iseconds) [info] ... denying '$FILTER_DENY'"
        sed -i "s:  - FILTER_DENY:  - \"$FILTER_DENY\"\n  - FILTER_DENY:g" "$CONFIG_PATH"
    done
fi
# Remove the deny placeholder
sed -i "/FILTER_DENY/d" "$CONFIG_PATH"

# Final output
echo "$(date -Iseconds) [info] Finished configuring AdGuardHome"
