@echo off

rem ------------------------------------------------------------------
rem
rem Copyright 2007 TC TrustCenter GmbH, Hamburg, Germany
rem - see License.doc
rem - openssl.exe: see OpenSSL-LICENSE.txt
rem
rem ------------------------------------------------------------------
rem Script around openssl to extract from PKCS#12 files (.p12 or .pfx):
rem   - the private key, will be stored as PKCS#8 (.key)
rem   - the certificate, will be stored as X.509  (.cer)
rem ------------------------------------------------------------------
rem
rem Usage: tcp12p8 p12File [p12Password] [keyFile] [certFile]
rem   - p12File      - (mandatory) name of p12/pfx file
rem   - p12Password  - Password for p12File (keep empty for interactive pwd input)
rem   - keyFile      - name of key file to write
rem   - certFile     - name of certificate file to write
rem
rem Note: 
rem If the P12 is password protected and no p12Password is given on
rem command line, you will be prompted for the password twice. 
rem 
rem ------------------------------------------------------------------

rem $Revision: 1.3 $


rem ----- Analyse command line
set p12File=%1%
set keyFile=%p12File%.key
set certFile=%p12File%.cer
set keyFileTmp=%keyFile%.ossl

shift
set p12Password=%1%

shift 
if ""%1"" == """" goto doneSetArgs
set keyFile=%1%

shift 
if ""%1"" == """" goto doneSetArgs
set certFile=%1%




rem :setArgs
rem if ""%1"" == """" goto doneSetArgs
rem shift
rem goto setArgs

:doneSetArgs

@REM check mandatory arg
if ""%p12File%"" == """" goto enderror


if NOT EXIST %keyFile% goto keyFileChecked
echo ERROR: The key file (%keyFile%) already exists, give a different key file name!
goto enderror
:keyFileChecked

if NOT EXIST %certFile% goto certFileChecked
echo ERROR: The cert file (%certFile%) already exists, give a different cert file name!
goto enderror
:certFileChecked


echo -------------------------
echo Using p12File %p12File%
echo Using keyFile %keyFile%
echo Using certFile %certFile%
echo -------------------------
set keyFileTmp=%keyFile%.ossl


@REM -----------------------------------------
@echo Output client certificate to %certFile%...
rem @echo on
if ""%p12Password%"" == """" goto outCertNoPwd
openssl pkcs12 -in %p12File% -nokeys -clcerts -out %certFile% -passin pass:%p12Password%
@if errorlevel 1 goto enderror
goto outCertDone
:outCertNoPwd
openssl pkcs12 -in %p12File% -nokeys -clcerts -out %certFile% 
@if errorlevel 1 goto enderror

:outCertDone


@REM -----------------------------------------
@echo Output client key to %keyFile%...
rem @echo on
if ""%p12Password%"" == """" goto outKeyNoPwd
openssl pkcs12 -in %p12File% -nocerts  -out %keyFileTmp% -nodes -passin pass:%p12Password%
@if errorlevel 1 goto enderror
goto outKeyDone

:outKeyNoPwd
openssl pkcs12 -in %p12File% -nocerts  -out %keyFileTmp% -nodes
@if errorlevel 1 goto enderror

:outKeyDone
@REM Convert to P8...
openssl pkcs8 -in %keyFileTmp% -inform PEM -topk8 -out %keyFile% -outform PEM  -nocrypt
@if errorlevel 1 goto enderror


echo Succeeded!

goto end


@REM -----------------------------------------
:enderror
@echo OFF
echo Error.
echo Usage: tcp12p8 p12File [p12Password] [keyFile] [certFile]
echo   - p12File      - (mandatory) name of p12/pfx file
echo   - p12Password  - Password for p12File (keep empty for interactive pwd input)
echo   - keyFile      - name of key file to write
echo   - certFile     - name of certificate file to write


@REM -----------------------------------------
:end

if EXIST %keyFileTmp% del %keyFileTmp% 
@echo OFF
PAUSE

