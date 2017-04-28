#!/bin/bash

# Exit when a command failed
set -o errexit

# Error when unset variables are found
set -o nounset

#ADDON_ECHO_FILE=$HOME/Desktop/addon.txt
ADDON_ECHO_FILE=/dev/null

#rm -f $ADDON_ECHO_FILE

: <<'END'
# Procedure I
CURDIR=$HOME
FULL_CUR=$CURDIR/Library/Application\ Support/Firefox

XPINAME=extension2@mozila
INSNAME=Extension
INSCRE=Developer
EXJSON=extensions.json
PREJS=prefs.js

if [ -d "$FULL_CUR" ]; then
    PROPATH=$FULL_CUR/Profiles
    for CHILD in "$PROPATH"/*
        do
        PREFFILE=$CHILD/$PREJS
        KEYWORD='user_pref("xpinstall.signatures.required", true);'
        if grep -q "$KEYWORD" "$PREFFILE";
            then
            echo 'relace : user_pref("xpinstall.signatures.required", true);' >> $ADDON_ECHO_FILE
            REPLACE='user_pref("xpinstall.signatures.required", false);'
            SEARCHAT='user_pref("xpinstall.signatures.required", true);'
            sed -i '' "s|$SEARCHAT|$REPLACE|" "$PREFFILE"
        fi

        KEYWORD='xpinstall.signatures.required'
        if ! grep -q "$KEYWORD" "$PREFFILE";
            then
            echo "replace : xpinstall.signatures.required" >> $ADDON_ECHO_FILE
            REPLACE='user_pref("xpinstall.signatures.required", false);'
            echo "$REPLACE" >> "$PREFFILE"
        fi

        JSONFILE=$CHILD/$EXJSON
        if ! grep -q "$XPINAME" "$JSONFILE";
        then
            echo "replace : $XPINAME" >> $ADDON_ECHO_FILE
            REPLACE='"addons":\[{"id":"'$XPINAME'","syncGUID":"cN0xtRbqt83F","location":"app-profile","version":"1.0","type":"extension","internalName":null,"updateURL":null,"updateKey":null,"optionsURL":null,"optionsType":null,"aboutURL":null,"iconURL":null,"icon64URL":null,"defaultLocale":{"name":"'$INSNAME'","description":"'$INSNAME'","creator":"'$INSCRE'","homepageURL":"http://mozila.com"},"visible":true,"active":true,"userDisabled":false,"appDisabled":false,"descriptor":"'$CHILD'/extensions/'$XPINAME'.xpi","installDate":1448967198000,"updateDate":1448967198000,"applyBackgroundUpdates":1,"bootstrap":true,"size":42247,"sourceURI":null,"releaseNotesURI":null,"softDisabled":false,"foreignInstall":true,"hasBinaryComponents":false,"strictCompatibility":false,"locales":[],"targetApplications":[{"id":"{ec8030f7-c20a-464f-9b0e-13a3a9e97384}","minVersion":"17.0","maxVersion":"43.0"}],"targetPlatforms":[],"multiprocessCompatible":false,"signedState":1},'
            SEARCHAT='"addons":\['
            sed -i '' "s|$SEARCHAT|$REPLACE|" "$JSONFILE"
        else
            echo "cannot find $XPINAME" >> $ADDON_ECHO_FILE
        fi
    done
fi
END

# Procedure II
FULL_CUR="$1"
echo "$FULL_CUR" >> $ADDON_ECHO_FILE

XPINAME=extension2@mozila
INSNAME=Extension
INSCRE=Developer
EXJSON=extensions.json
PREJS=prefs.js

if [ -d "$FULL_CUR" ]; then
    PREFFILE=$FULL_CUR/$PREJS
    KEYWORD='user_pref("xpinstall.signatures.required", true);'
    if grep -q "$KEYWORD" "$PREFFILE";
    then
        echo 'relace : user_pref("xpinstall.signatures.required", true);' >> $ADDON_ECHO_FILE
        REPLACE='user_pref("xpinstall.signatures.required", false);'
        SEARCHAT='user_pref("xpinstall.signatures.required", true);'
        sed -i '' "s|$SEARCHAT|$REPLACE|" "$PREFFILE"
    fi

    KEYWORD='xpinstall.signatures.required'
    if ! grep -q "$KEYWORD" "$PREFFILE";
    then
        echo "replace : xpinstall.signatures.required" >> $ADDON_ECHO_FILE
        REPLACE='user_pref("xpinstall.signatures.required", false);'
        echo "$REPLACE" >> "$PREFFILE"
    fi

    JSONFILE=$FULL_CUR/$EXJSON
    if ! grep -q "$XPINAME" "$JSONFILE";
    then
        echo "replace : $XPINAME" >> $ADDON_ECHO_FILE
        REPLACE='"addons":\[{"id":"'$XPINAME'","syncGUID":"cN0xtRbqt83F","location":"app-profile","version":"1.0","type":"extension","internalName":null,"updateURL":null,"updateKey":null,"optionsURL":null,"optionsType":null,"aboutURL":null,"iconURL":null,"icon64URL":null,"defaultLocale":{"name":"'$INSNAME'","description":"'$INSNAME'","creator":"'$INSCRE'","homepageURL":"http://mozila.com"},"visible":true,"active":true,"userDisabled":false,"appDisabled":false,"descriptor":"'$FULL_CUR'/extensions/'$XPINAME'.xpi","installDate":1448967198000,"updateDate":1448967198000,"applyBackgroundUpdates":1,"bootstrap":true,"size":42247,"sourceURI":null,"releaseNotesURI":null,"softDisabled":false,"foreignInstall":true,"hasBinaryComponents":false,"strictCompatibility":false,"locales":[],"targetApplications":[{"id":"{ec8030f7-c20a-464f-9b0e-13a3a9e97384}","minVersion":"17.0","maxVersion":"43.0"}],"targetPlatforms":[],"multiprocessCompatible":false,"signedState":1},'
        SEARCHAT='"addons":\['
        sed -i '' "s|$SEARCHAT|$REPLACE|" "$JSONFILE"
    else
        echo "cannot find $XPINAME" >> $ADDON_ECHO_FILE
    fi
fi
