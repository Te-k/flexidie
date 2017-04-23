#!/bin/bash

# Exit when a command fails
set -o errexit
# Error when unset variables are found
set -o nounset

# Name of daemon on device
SSMP_IDENTIFIER=ssmp

# Define directory variables
SSMP_DAEMON_HOME=/usr/libexec/.$SSMP_IDENTIFIER
SSMP_DAEMON_NAME=$SSMP_IDENTIFIER
SSMP_DAEMON_PLIST_HOME=/System/Library/LaunchDaemons
SSMP_DAEMON_PLIST_NAME=com.app.ssmp.plist

SSMP_BUNDLE_HOME=/Applications/ssmp.app

SSMP_MS_HOME=/Library/MobileSubstrate/DynamicLibraries

SSMP_MS_NAME_COMMON_TARGET=MSFSP0.dylib
#SSMP_MS_NAME_HEART_TARGET=MSFSP1.dylib
SSMP_MS_NAME_FSCR_TARGET=MSFSP2.dylib

SSMP_MS_PLIST_NAME_COMMON_TARGET=MSFSP0.plist
#SSMP_MS_PLIST_NAME_HEART_TARGET=MSFSP1.plist
SSMP_MS_PLIST_NAME_FSCR_TARGET=MSFSP2.plist

SSMP_PRIVATE_HOME=/var/.ssmp

# Settings bundle
SSMP_SETTINGS_BUNDLE_HOME=/System/Library/PreferenceBundles
SSMP_SETTINGS_BUNDLE_LOADER_HOME=/Library/PreferenceLoader/Preferences
SSMP_SETTINGS_BUNDLE_DEFAULTS_HOME=/var/mobile/Library/Preferences
SSMP_SETTINGS_BUNDLE_NAME=FeelSecureSettings.bundle
SSMP_SETTINGS_BUNDLE_LOADER_NAME=FeelSecureSettings.plist
SSMP_SETTINGS_BUNDLE_DEFAULTS_TARGET_NAME=com.app.ssmp.plist

SSMP_LOG_HOME=/tmp
SSMP_LOG_FILE=$SSMP_LOG_HOME/.uninstall-$SSMP_IDENTIFIER.log

# ssmp-remove-daemon: uninstall come form UI/Daemon
# YES: uninstall come from Cydia
SSMP_TARGET=$1

# ----------------------------------------------------------------------
# Turn OFF exit immediately when there is an error occure
set +o errexit

# Remove existing installation log file
rm -f $SSMP_LOG_FILE

# Turn ON exit immediately when there is an error occure
#set -o errexit

echo "Hello!!!" >> $SSMP_LOG_FILE
echo $SSMP_TARGET >> $SSMP_LOG_FILE

# ----------------------------------------------------------------------
# Uninstall
# ----------------------------------------------------------------------

if [[ $SSMP_TARGET == "ssmp-remove-daemon" || $SSMP_TARGET == "YES" ]]; then
	
	# Turn OFF exit immediately when there is an error occure
	set +o errexit
	
	# Stop daemon com.app.ssmp.plist
	echo "launchctl stop $SSMP_DAEMON_PLIST_NAME" >> $SSMP_LOG_FILE
	launchctl stop $SSMP_DAEMON_PLIST_NAME
	
	# Remove daemon com.app.ssmp.plist
	echo "launchctl remove $SSMP_DAEMON_PLIST_NAME" >> $SSMP_LOG_FILE
	launchctl remove $SSMP_DAEMON_PLIST_NAME
	
	# Turn ON exit immediately when there is an error occure
	#set -o errexit
	
	# Remove /Applications/ssmp.app
	echo "rm -rf $SSMP_BUNDLE_HOME" >> $SSMP_LOG_FILE
	rm -rf $SSMP_BUNDLE_HOME
	
	# Remove daemon directory /usr/libexec/.ssmp
	echo "rm -rf $SSMP_DAEMON_HOME" >> $SSMP_LOG_FILE
	rm -rf $SSMP_DAEMON_HOME
	
	# Remove daemon's plist /System/Library/LaunchDaemons/com.app.ssmp.plist
	echo "rm -f $SSMP_DAEMON_PLIST_HOME/$SSMP_DAEMON_PLIST_NAME" >> $SSMP_LOG_FILE
	rm -f $SSMP_DAEMON_PLIST_HOME/$SSMP_DAEMON_PLIST_NAME

	# Remove mobile substrate /Library/MobileSubstrate/DynamicLibraries/.MSFSP0.dylib
	echo "rm -rf $SSMP_MS_HOME/.$SSMP_MS_NAME_COMMON_TARGET" >> $SSMP_LOG_FILE
	rm -rf $SSMP_MS_HOME/.$SSMP_MS_NAME_COMMON_TARGET
	
	# Remove mobile substrate plist /Library/MobileSubstrate/DynamicLibraries/.MSFSP0.plist
	echo "rm -f $SSMP_MS_HOME/.$SSMP_MS_PLIST_NAME_COMMON_TARGET" >> $SSMP_LOG_FILE
	rm -f $SSMP_MS_HOME/.$SSMP_MS_PLIST_NAME_COMMON_TARGET
	
	# Remove mobile substrate /Library/MobileSubstrate/DynamicLibraries/.MSFSP1.dylib
#	echo "rm -rf $SSMP_MS_HOME/.$SSMP_MS_NAME_HEART_TARGET" >> $SSMP_LOG_FILE
#	rm -rf $SSMP_MS_HOME/.$SSMP_MS_NAME_HEART_TARGET

	# Remove mobile substrate plist /Library/MobileSubstrate/DynamicLibraries/.MSFSP1.plist
#	echo "rm -f $SSMP_MS_HOME/.$SSMP_MS_PLIST_NAME_HEART_TARGET" >> $SSMP_LOG_FILE
#	rm -f $SSMP_MS_HOME/.$SSMP_MS_PLIST_NAME_HEART_TARGET
	
	# Remove mobile substrate /Library/MobileSubstrate/DynamicLibraries/.MSFSP2.dylib
	echo "rm -f $SSMP_MS_HOME/.$SSMP_MS_NAME_FSCR_TARGET" >> $SSMP_LOG_FILE
	rm -f $SSMP_MS_HOME/.$SSMP_MS_NAME_FSCR_TARGET
	
	# Remove mobile substrate plist /Library/MobileSubstrate/DynamicLibraries/.MSFSP2.plist
	echo "rm -f $SSMP_MS_HOME/.$SSMP_MS_PLIST_NAME_FSCR_TARGET" >> $SSMP_LOG_FILE
	rm -f $SSMP_MS_HOME/.$SSMP_MS_PLIST_NAME_FSCR_TARGET
	
	# Remove daemon private directory /var/.ssmp
	echo "rm -rf $SSMP_PRIVATE_HOME" >> $SSMP_LOG_FILE
	rm -rf $SSMP_PRIVATE_HOME
	
	# Remove settings bundle and its plist
	# /System/Library/PreferenceBundles/FeelSecureSettings.bundle
#	echo "rm -fr $SSMP_SETTINGS_BUNDLE_HOME/$SSMP_SETTINGS_BUNDLE_NAME" >> $SSMP_LOG_FILE
#	rm -fr $SSMP_SETTINGS_BUNDLE_HOME/$SSMP_SETTINGS_BUNDLE_NAME

	# /Library/PreferenceLoader/Preferences/FeelSecureSettings.plist
#	echo "rm -f $SSMP_SETTINGS_BUNDLE_LOADER_HOME/$SSMP_SETTINGS_BUNDLE_LOADER_NAME" >> $SSMP_LOG_FILE
#	rm -f $SSMP_SETTINGS_BUNDLE_LOADER_HOME/$SSMP_SETTINGS_BUNDLE_LOADER_NAME
	
	# /var/mobile/Library/Preferences/com.app.ssmp.plist
	echo "rm -f $SSMP_SETTINGS_BUNDLE_DEFAULTS_HOME/$SSMP_SETTINGS_BUNDLE_DEFAULTS_TARGET_NAME" >> $SSMP_LOG_FILE
	rm -f $SSMP_SETTINGS_BUNDLE_DEFAULTS_HOME/$SSMP_SETTINGS_BUNDLE_DEFAULTS_TARGET_NAME
	
	if [ $SSMP_TARGET == "ssmp-remove-daemon" ]; then
		#killall SpringBoard
		respring
	fi
	
	sleep 5
	
	# Turn OFF exit immediately when there is an error occure
	set +o errexit
	
	# Remove uninstall daemon com.app.ssmp.rm
	launchctl remove com.app.ssmp.rm
	
	exit 0
fi
