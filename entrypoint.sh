#! /usr/bin/env sh

# Generate the config file
/opt/adguardhome/conf/generate.sh

# Run AdGuardHome with command line arguments
/opt/adguardhome/AdGuardHome "$@"
