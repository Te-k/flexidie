#include <e32base.h>

/***
* Test connection progress info*/
class TTestConnectProgress
	{
public:
	/**
	* Operation label
	* ie Verifying Access Point, Performing Test Connection, and so on*/
	TPtrC iTitle;
	/**
	Access point name being used to connect*/
	TPtrC iAccessPointName;
	/**
	* Connection state string
	* ie connecting, connected, wait for server, and so on*/
	TPtrC iConnectionState;
	/**
	* Error code if any*/
	TInt  iError;
	};

/**
Test connection callback*/
class MTestConnectProgressCallBack
	{
public:
	/**
	* Call back fuction
	* 
	* @param aProgress callback info
	*/
	virtual void TestConnectCallback(const TTestConnectProgress& aProgress)= 0;
	
    /**
	* This will be called when the operation is completed either with error or success.
	* 
	* @param aErr KErrNone if test connection success otherwise error.
	*/
	virtual void TestConnectCompleted(TInt aErr) = 0;
	};
