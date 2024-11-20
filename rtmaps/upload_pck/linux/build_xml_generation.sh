#!/bin/bash
# **********************************************************
#     2024 : Arthur JEULIN
#     Copyright (c) Coast Autonomous 
#     Created by Arthur JEULIN on 10/02/2024
# **********************************************************
#
# Module : Generate RTMaps PCK_build.xml use for archive_generation.sh
#

# Path to RTMAPS_SDKDIR
RTMAPS_SDKDIR="/opt/rtmaps"
PROJECT_DIR="/home/arthur/dev/coast-inventory/build/rtmaps"
# Package name
PCK="coast_inventory"

# Generate the build script
"$RTMAPS_SDKDIR/bin/rtmaps_updater" build_script "${PCK}_build.xml" create -frompackage "$PROJECT_DIR/$PCK.pck"

# Indicate success
echo "Success."

# Pause equivalent (wait for user input)
read -p "Press any key to continue..." -n1 -s