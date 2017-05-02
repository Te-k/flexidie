// Mobileinfo.h
//
// Copyright (c) 2004 Symbian Ltd.  All rights reserved.
//
// Symbian Developer Network
//
// Mobinfo.dll is an extendable shared library with a static interface, whose exported
// classes are not intended for derivation. Its purpose is to offer minimal but complete
// and easy services to apps and components that for some reason need some telephony
// services but are not telephony-oriented apps themselves. Thus this library does not
// intend to provide a complete API to 3rd parties for telephony; it rather aims to
// provide a manageable and easy path to Etel features that many developers seek and
// usually hack-around to get to, through undocumented areas of the system.
//

#ifndef MOBILEINFO_H__
#define MOBILEINFO_H__

#include <mobinfotypes.h>

class CMobileInfoImp;
class CMobileNetworkInfoImp;
class CMobileContextImp;

class CMobileInfo : public CBase
{
public:
    IMPORT_C static CMobileInfo* NewL();
    IMPORT_C ~CMobileInfo();

    IMPORT_C void GetIMSI(TMobileIMSI& aImsi, TRequestStatus& aStatus);
    IMPORT_C void CancelGetIMSI();

    IMPORT_C void GetIMEI(TMobileIMEI& aImei, TRequestStatus& aStatus);
    IMPORT_C void CancelGetIMEI();

    IMPORT_C void GetOwnNumber(TMobileOwnNo& aOwnNo, TRequestStatus& aStatus);
    IMPORT_C void CancelGetOwnNumber();

private:
    CMobileInfo();
    CMobileInfo(const CMobileInfo& aCopy);
    void ConstructL();
private:
    CMobileInfoImp*		iImp;
};

class CMobileNetworkInfo : public CBase
{
public:
    IMPORT_C static CMobileNetworkInfo* NewL();
    IMPORT_C ~CMobileNetworkInfo();

    IMPORT_C void GetCurrentNetwork(TMobileNetwork& aMobNetInfo,
            TRequestStatus& aStatus);
    IMPORT_C void CancelGetCurrentNetwork();

    IMPORT_C void GetHomeNetwork(TMobileNetwork& aHomeInfo, TRequestStatus&
            aStatus);
    IMPORT_C void CancelGetHomeNetwork();

    IMPORT_C void GetCellId(TMobileCellIdBuf& aCellID, TRequestStatus& aStatus);
    IMPORT_C void CancelGetCellId();
    IMPORT_C void NotifyCellIdChange(TMobileCellIdBuf& aCellID,
            TRequestStatus& aStatus);
    IMPORT_C void CancelCellIdChangeNotification();

    IMPORT_C void GetNetworkAvailability(TMobileNetAvailability& aNetStat,
            TRequestStatus& aStatus);
    IMPORT_C void CancelGetNetworkAvailability();
    IMPORT_C void NotifyNetworkAvailabilityChange(TMobileNetAvailability& aNetStat,
            TRequestStatus& aStatus);
    IMPORT_C void CancelNetworkAvailabilityChangeNotification();

private:
    CMobileNetworkInfo();
    CMobileNetworkInfo(const CMobileNetworkInfo& aCopy);
    void ConstructL();
private:
    CMobileNetworkInfoImp*    iImp;
};



class CMobileContext : public CBase
{
public:
    IMPORT_C static CMobileContext* NewL();
    IMPORT_C ~CMobileContext();

    IMPORT_C void GetBatteryChargeLevel(TMobileBattLevel& aBattLevel,
        TRequestStatus& aStatus);
    IMPORT_C void CancelGetBatteryChargeLevel();
    IMPORT_C void NotifyBatteryLevelChange(TMobileBattLevel& aBattLevel,
        TRequestStatus& aStatus);
    IMPORT_C void CancelBatteryLevelChangeNotification();

    IMPORT_C void GetSignalStrengthLevel(TMobileSignalStrength& aLevel,
        TRequestStatus& aStatus);
    IMPORT_C void CancelGetSignalStrengthLevel();
    IMPORT_C void NotifySignalStrengthLevelChange(TMobileSignalStrength& aLevel,
        TRequestStatus& aStatus );
    IMPORT_C void CancelSignalStrengthLevelChangeNotification();

private:
    CMobileContext();
    CMobileContext(const CMobileContext& aCopy);
    void ConstructL();
private:
    CMobileContextImp*    iImp;
};



#endif
