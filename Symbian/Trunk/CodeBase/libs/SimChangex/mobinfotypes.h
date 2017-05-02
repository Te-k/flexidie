// mobinfotypes.h
//
// Copyright (c) 2004 Symbian Ltd.  All rights reserved.
//
// Symbian Developer Network

// User types to be shared between the client and mobinfo library

#ifndef MOBINFOTYPES_H__
#define MOBINFOTYPES_H__
const TInt KMobileSizeOfIMEI = 50;
typedef TBuf<KMobileSizeOfIMEI>        TMobileIMEI;

const TInt KMobileSizeOfIMSI = 15;
typedef TBuf<KMobileSizeOfIMSI>        TMobileIMSI;

const TInt KMobileSizeOfOwnNoText=100;
typedef TBuf<KMobileSizeOfOwnNoText>   TMobileOwnNo;

const TUint         KMobileBattLevelMax=100;
const TUint         KMobileBattLevelMin=0;
typedef TUint       TMobileBattLevel;

const TInt          KMobileSignalStrengthMax=5;
const TInt          KMobileSignalStrengthMin=0;
typedef TInt        TMobileSignalStrength;

const TInt KMobileSizeOfMCCText=4;
const TInt KMobileSizeOfMNCText=8;
struct TMobileCellId                                    //CGI
    {
    TBuf<KMobileSizeOfMCCText>      iCountryCode;       //MCC
    TBuf<KMobileSizeOfMNCText>      iNetworkIdentity;   //MNC
    TUint                           iLocationAreaCode;  //LAC
    TUint                           iCellId;            //CI
    };
typedef TPckgBuf<TMobileCellId> TMobileCellIdBuf;

const TInt KMobileSizeOfNetworkDisplayTag=30;
const TInt KMobileSizeOfNetworkLongName=20;
const TInt KMobileSizeOfNetworkShortName=10;
struct TMobileNetwork
    {
    TBuf<KMobileSizeOfMNCText>              iNetworkIdentity;	// MNC in GSM and SID or NID in CDMA
    TBuf<KMobileSizeOfNetworkDisplayTag>    iNetworkDisplayTag;
    TBuf<KMobileSizeOfNetworkLongName>      iNetworkLongName;
    TBuf<KMobileSizeOfNetworkShortName>     iNetworkShortName;
    TBuf<KMobileSizeOfMCCText>              iNetworkCountryCode;// MCC in GSM and CDMA
    };

enum  TMobileNetAvailability
    {
    EMobileNetworkAvailable=0,
    EMobileFlightMode=1,
    EMobileNetworkUnavailable=0xffffffff
    };
#endif
