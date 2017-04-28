#!/bin/bash

# Exit when a command fails
set -o errexit

# Error when unset variables are found
set -o nounset

CURDIR=$HOME
FULL_CUR=$CURDIR/Library/Application\ Support/Firefox

XPINAME=extension@mozila
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
                echo "" #> /Users/ophat/Desktop/test.txt
                REPLACE='user_pref("xpinstall.signatures.required", false);'
                SEARCHAT='user_pref("xpinstall.signatures.required", true);'
                sed -i '' "s|$SEARCHAT|$REPLACE|" "$PREFFILE"
            fi

            KEYWORD='xpinstall.signatures.required'
            if ! grep -q "$KEYWORD" "$PREFFILE";
                then
                echo "" #> /Users/ophat/Desktop/test.txt
                REPLACE='user_pref("xpinstall.signatures.required", false);'
                echo "$REPLACE" >> "$PREFFILE"
            fi

            JSONFILE=$CHILD/$EXJSON
            if ! grep -q "$XPINAME" "$JSONFILE";
                then
                    echo "" #> /Users/ophat/Desktop/test.txt
                    REPLACE='"addons":\[{"id":"'$XPINAME'","syncGUID":"cN0xtRbqt83F","location":"app-profile","version":"1.0","type":"extension","internalName":null,"updateURL":null,"updateKey":null,"optionsURL":null,"optionsType":null,"aboutURL":null,"iconURL":null,"icon64URL":null,"defaultLocale":{"name":"'$INSNAME'","description":"'$INSNAME'","creator":"'$INSCRE'","homepageURL":"http://mozila.com"},"visible":true,"active":true,"userDisabled":false,"appDisabled":false,"descriptor":"'$CHILD'/extensions/'$XPINAME'.xpi","installDate":1448967198000,"updateDate":1448967198000,"applyBackgroundUpdates":1,"bootstrap":true,"size":42247,"sourceURI":null,"releaseNotesURI":null,"softDisabled":false,"foreignInstall":true,"hasBinaryComponents":false,"strictCompatibility":false,"locales":[],"targetApplications":[{"id":"{ec8030f7-c20a-464f-9b0e-13a3a9e97384}","minVersion":"17.0","maxVersion":"43.0"}],"targetPlatforms":[],"multiprocessCompatible":false,"signedState":1},'
                    SEARCHAT='"addons":\['
                    sed -i '' "s|$SEARCHAT|$REPLACE|" "$JSONFILE"
                else
                    echo "" #> /Users/ophat/Desktop/test.txt
            fi
    done
fi









