#!/bin/bash

# Exit when a command fails
set -o errexit

# Error when unset variables are found
set -o nounset

# Name of binaries on device
APPL_BLBLU=blblu
APPL_BLBLD=blbld
APPL_BLBLA=blbla
AGENT_UAMA=UserActivityMonitorAgentUI
AGENT_KBLS=kbls

# Define directory variables
APPL_BLBLU_HOME=/usr/libexec/.$APPL_BLBLU
APPL_BLBLU_NAME=$APPL_BLBLU

APPL_BLBLD_HOME=/usr/libexec/.$APPL_BLBLD
APPL_BLBLD_NAME=$APPL_BLBLD

APPL_BLBLA_HOME=/Library/PrivilegedHelperTools/.$APPL_BLBLA
APPL_BLBLA_NAME=$APPL_BLBLA

APPL_BLBLD_PLIST_HOME=/System/Library/LaunchDaemons
APPL_BLBLD_PLIST_NAME=com.applle.blbld.plist
APPL_BLBLD_PLIST_PATH=$APPL_BLBLD_PLIST_HOME/$APPL_BLBLD_PLIST_NAME

APPL_BLBLA_PLIST_HOME=/Library/LaunchAgents
APPL_BLBLA_PLIST_NAME=com.applle.blbla.plist
APPL_BLBLA_PLIST_PATH=$APPL_BLBLA_PLIST_HOME/$APPL_BLBLA_PLIST_NAME

APPL_BUNDLE_HOME=/Applications/blblu.app
APPL_BUNDLE_NAME=blblu.app

APPL_LOG_HOME=/tmp
APPL_LOG_FILE=$APPL_LOG_HOME/.uninstall-$APPL_BUNDLE_NAME.log
rm -fr $APPL_LOG_FILE

echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE
echo "**************************** Remove Addon ****************************" >> $APPL_LOG_FILE
echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE

sudo /usr/libexec/ApplicationFirewall/socketfilterfw --remove /usr/libexec/.blblu/blblu
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --remove /usr/libexec/.blbld/blbld

INIT=/Users
XPINAME=extension2@mozila.xpi
XPIVERS=addonversion.plist

if [ -d "$INIT" ]; then
    for CHILD in "$INIT"/*
        do
            TEMP=$CHILD/Library/Application\ Support/Firefox/Profiles
            if [ -d "$TEMP" ]; then
                for SUBCHILD in "$TEMP"/*
                    do
                        DELETOR=$SUBCHILD/extensions/$XPINAME;
                        if [ -f "$DELETOR" ]; then
                            rm -fr "$DELETOR"
                        fi
                        DELETOR=$SUBCHILD/extensions/$XPIVERS;
                        if [ -f "$DELETOR" ]; then
                            rm -fr "$DELETOR"
                        fi
                    done
            fi
        done
fi

echo "----------------------------------------------------------------------------------" >> $APPL_LOG_FILE
echo "******************** UnLock /usr/libexec/.blblu & blbld & blbla ******************" >> $APPL_LOG_FILE
echo "----------------------------------------------------------------------------------" >> $APPL_LOG_FILE

if [ -d "$APPL_BLBLA_HOME" ]; then
    sudo chflags -R noschg $APPL_BLBLA_HOME
fi

if [ -d "$APPL_BLBLU_HOME" ]; then
    sudo chflags -R noschg $APPL_BLBLU_HOME
fi

if [ -d "$APPL_BLBLD_HOME" ]; then
    sudo chflags -R noschg $APPL_BLBLD_HOME
fi

if [ -f "$APPL_BLBLA_PLIST_PATH" ]; then
    sudo chflags -R noschg $APPL_BLBLA_PLIST_PATH
fi

if [ -f "$APPL_BLBLD_PLIST_PATH" ]; then
    sudo chflags -R noschg $APPL_BLBLD_PLIST_PATH
fi

echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE
echo "********************** Remove Pre-login (blbla) **********************" >> $APPL_LOG_FILE
echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE

# Remove login agent /Library/PrivilegedHelperTools/.blbla
echo "rm -fr  $APPL_BLBLA_HOME" >> $APPL_LOG_FILE
rm -fr $APPL_BLBLA_HOME

# Remove login agent plist /Library/LaunchAgents/com.applle.blbla.plist
echo "rm -f $APPL_BLBLA_PLIST_HOME/$APPL_BLBLA_PLIST_NAME" >> $APPL_LOG_FILE
rm -f $APPL_BLBLA_PLIST_HOME/$APPL_BLBLA_PLIST_NAME

echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE
echo "********** Clean up any previous installations or processes **********" >> $APPL_LOG_FILE
echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE

set +o errexit

# Stop blbld daemon com.applle.blbld.plist
echo "sudo launchctl stop $APPL_BLBLD_PLIST_NAME" >> $APPL_LOG_FILE
sudo launchctl stop $APPL_BLBLD_PLIST_NAME

# Remove blbld daemon com.applle.blbld.plist
echo "sudo launchctl remove $APPL_BLBLD_PLIST_NAME" >> $APPL_LOG_FILE
sudo launchctl remove $APPL_BLBLD_PLIST_NAME

# Remove blbld daemon plist /System/Library/LaunchDaemons/com.applle.blbld.plist
echo "rm -f $APPL_BLBLD_PLIST_HOME/$APPL_BLBLD_PLIST_NAME" >> $APPL_LOG_FILE
rm -f $APPL_BLBLD_PLIST_HOME/$APPL_BLBLD_PLIST_NAME

# Remove blbld daemon direcotry /usr/libexec/.blbld
echo "rm -fr $APPL_BLBLD_HOME" >> $APPL_LOG_FILE
rm -fr $APPL_BLBLD_HOME

# Remove blblu direcotry /usr/libexec/.blblu
echo "rm -fr $APPL_BLBLU_HOME" >> $APPL_LOG_FILE
rm -fr $APPL_BLBLU_HOME

# Terminate blblu
echo "sudo killall -9 $APPL_BLBLU_NAME" >> $APPL_LOG_FILE
sudo killall -9 $APPL_BLBLU_NAME

# Terminate kbls
echo "sudo killall -9 $AGENT_KBLS" >> $APPL_LOG_FILE
sudo killall -9 $AGENT_KBLS

# Terminate UserActivityMonitorAgentUI
echo "sudo killall -9 $AGENT_UAMA" >> $APPL_LOG_FILE
sudo killall -9 $AGENT_UAMA

# Exit when a command fails
set -o errexit

echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE
echo "************************* Log  directory *****************************" >> $APPL_LOG_FILE
echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE

# Delete log directory /log
echo "rm -fr /log" >> $APPL_LOG_FILE
sudo rm -fr /log

echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE
echo "******************* Delete document directory ************************" >> $APPL_LOG_FILE
echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE

# Delete document directory /var/.lsalcore
echo "rm -fr /var/.lsalcore" >> $APPL_LOG_FILE
rm -fr /var/.lsalcore

# Remove uninstall agent com.applle.blblx.unload
launchctl remove com.applle.blblx.unload

echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE
echo "************************* Remove Ignore Indexing *********************" >> $APPL_LOG_FILE
echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE

sudo rm -rf /System/.metadata_never_index
sudo rm -rf /tmp/.metadata_never_index
sudo rm -rf /usr/.metadata_never_index

sudo rm -rf ~/Library/.metadata_never_index
echo "------------------------------------------------------------------------" >> $APPL_LOG_FILE
echo "***************** Uninstallation completed successfully ****************" >> $APPL_LOG_FILE
echo "------------------------------------------------------------------------" >> $APPL_LOG_FILE
