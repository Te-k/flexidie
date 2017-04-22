                       Readme for TC-ConvertP12
                       ========================

TC-ConvertP12 is a script around openssl to extract from PKCS#12 files
(.p12 or .pfx) the following:
  - the private key, will be stored as PKCS#8 (.key)
  - the certificate, will be stored as X.509  (.cer)

------------------------------------------------------------------

Usage: tcp12p8 p12File [p12Password] [keyFile] [certFile]
  - p12File      - (mandatory) name of p12/pfx file
  - p12Password  - Password for p12File (keep empty for interactive pwd input)
  - keyFile      - name of key file to write
  - certFile     - name of certificate file to write


Note: 
If the P12 is password protected and no p12Password is given on
command line, you will be prompted for the password twice. 

------------------------------------------------------------------

Licenses:
Please observe the license conditions in License.doc and
OpenSSL-LICENSE.txt. 
