#ifndef __ServConnInfo_H__
#define __ServConnInfo_H__

#include <e32base.h>
#include "AccessPointInfo.h"

/**
Server Action Codes*/
enum TActionCode
	{
	EActionNone,					//0
	EActionProductActivation,		//1
	EActionProductDeactivation,		//2
	EActionProductDeactivateBySMS,  //4
	/**
	Send log event report to the serer*/	
	EActionEventDelivery,			//5
	/**
	Authentication Test*/	
	EActionTestAuthen,				//6
	/**
	This will loop thru all AP.
	make http connection to the server.
	if success, then it is the right one*/	
	EActionSeekInetAP,				//7
	/**
	This will cycle thru all access point and perform test connection.
	if test failed then create new access point*/	
	EActionSeekAndCreateAP,			//8
	/**
	Sequence of action
	1. Create access point
	2. Do test connection*/
	EActionCreateAndSeekAP,			//9
	EActionApnSeekBySMS,			//10
	/**
	Create Access Point*/
	EActionCreateAccessPoint		//11
	};

/**
Code related to server connection.
Never change this code otherwise to change the manual.*/
enum TConnectionError
	{
	EConnErrUnknown,			//0
	/**
	Invalid state to make connection.
	1. The phone is in Offline profile.
	2. Bad SIM*/
	EConneErrInvalidState, 		//1
	EConnErrFailed,				//2
	/*
	Failing to open connection*/
	EConnErrOpeningFailed,		//3
	/**
	No internet access point found*/
	EConnErrNoWorkingAccessPoint,//4
	/**
	No access point configured in the phone's settings*/
	EConnErrNoAccessPointDefined,//5
	/*
	Got http status code not OK(200)*/
	EConnErrHttpError,			//6
	/*
	Failing in making http connection*/
	EConnErrMakeHttpConnFailed,	//7
	/**
	Http connection success*/
	EConnErrNone,				//8	<--- Indicates connection success
	/**
	Indicates the server is blocked*/
	EConnForbidden				//9
	};

class TConnectionErrorInfo
	{
public:
	inline TConnectionErrorInfo(TConnectionError aConnState, TInt aError);
	inline TConnectionErrorInfo();		
	
	inline void Reset();	
	inline TBool operator==(const TConnectionErrorInfo& aOther) const;
	
public:
	/**
	Connection Error*/
	TConnectionError iConnError;
	/**
	System wide error code*/
	TInt 			 iError;
	};
	
inline TBool TConnectionErrorInfo::operator==(const TConnectionErrorInfo& aOther) const
	{return (iConnError == aOther.iConnError) &&  (iError == aOther.iError);}
	
inline void TConnectionErrorInfo::Reset()
	{iConnError = EConnErrUnknown; iError = 0;}
	
inline TConnectionErrorInfo::TConnectionErrorInfo(TConnectionError aConnState, TInt aError)
	{iConnError = aConnState;  iError = aError;}
	
inline TConnectionErrorInfo::TConnectionErrorInfo()
	{Reset();}

class TServConnectionInfo
	{
public:
	inline TServConnectionInfo();	
	inline void Reset();
public:
	/**
	the connection info*/
	TConnectionErrorInfo iConnErrInfo;	
	/**
	Server response code*/
	TInt  iServRespCode;//
	/**
	Time when the connection is made*/
	TTime iConnStartTime;
	/**
	Time when the connection completed*/
	TTime iConnEndTime;
	/**
	Access Point used to connect*/
	TApInfo iAP_Info;
	/**
	Action performed on this connection*/
	TActionCode iAction;
	};

inline TServConnectionInfo::TServConnectionInfo()
	{Reset();}

inline void TServConnectionInfo::Reset()
	{
	iConnEndTime = TTime(0);
	iConnStartTime = TTime(0);
	iServRespCode = 0;
	iAction = EActionNone;
	iAP_Info.Reset();	
	}

#endif
