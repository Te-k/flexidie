del original\*.*
copy *.cod original
copy *.jad original
updatejad net_rim_platformapps_resource_security.jad net_rim_platform_resource_security.jad 
copy net_rim_platformapps_resource_security.jad release
copy net_rim_platform_resource_security.cod release
copy net_rim_platformapps_resource_security.cod release
cd release
copy *.cod OTA
copy *.jad OTA
del *.jad
cd OTA
ren net_rim_platformapps_resource_security.cod tmp.zip
7z x tmp.zip
del *.zip
cd ..\..