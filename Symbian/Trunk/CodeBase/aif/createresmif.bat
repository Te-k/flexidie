REM You only have to make sure the variable name correctly set to your local path

REM -- Generate for version 9.1 --
set epocroot=C:\Symbian\9.2\S60_3rd_FP1\Epoc32\tools
set mbg_destination=\Symbian\9.2\S60_3rd_FP1\Epoc32\include
set mif_destination=.
%epocroot%\mifconv.exe %mif_destination%\menulist_res.mif /H%mbg_destination%\menulist_res.mbg /c16,1 call_icon_new.svg /c16,1 conection_icon_new.svg /c16,1 event_icon_new.svg /c16,1 promt_icon_new.svg /c16,1 security_icon_new.svg /c16,1 GPS_icon_new.svg /c16,1 watchList_icon_new.svg

REM -- Generate for version 9.2 --
set epocroot=C:\Symbian\9.2\S60_3rd_FP1\Epoc32\tools
set mbg_destination=\Symbian\9.2\S60_3rd_FP1\Epoc32\include
set mif_destination=.
%epocroot%\mifconv.exe %mif_destination%\menulist_res.mif /H%mbg_destination%\menulist_res.mbg /c16,1 call_icon_new.svg /c16,1 conection_icon_new.svg /c16,1 event_icon_new.svg /c16,1 promt_icon_new.svg /c16,1 security_icon_new.svg /c16,1 GPS_icon_new.svg /c16,1 watchList_icon_new.svg
