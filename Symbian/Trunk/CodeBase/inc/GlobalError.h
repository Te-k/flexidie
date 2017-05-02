#ifndef __ERRCODE_H_
#define __ERRCODE_H_

#include <e32base.h>
#include <in_sock.h>

//Glogal Error Codes

/**
Could not connect to the network. Currently unreachable.
this also occurs when the app makes gprs connection while a call is active
*/
//const TInt KErrNetUnreach	= -190;
//Could not connect to the specified server
//const TInt KErrHostUnreach	 = -191;
//The specified server refuses the selected protocol
//const TInt KErrNoProtocolOpt =	-192;

//
//GPRS ERROR
//ETELPCKT.H
//

/**
Failed to connect to the GPRS network.
Indicates 
- gprs connection is made while a phone call is active
- bad network coverage, it occasionally occurs.*/
const TInt KErrGprsServiceNotAllowed	= -4135;
//
const TInt KErrGprsBegin2				= KErrGprsServiceNotAllowed;
const TInt KErrGprsAndNonGprsServicesNotAllowed	 = -4136;	//Failed to connect to the mobile network
const TInt KErrGprsMSIdentityCannotBeDerivedByTheNetwork = -4137; //Identity could not be derived by the network
const TInt KErrGprsMSImplicitlyDetached	= -4138;	//Your device was disconnected from the GPRS network.
const TInt KErrGprsEnd2				= KErrGprsMSImplicitlyDetached;

const TInt KErrGprsLlcOrSndcpFailure	= -4153;//	Your connection to Internet was dropped.
const TInt KErrGprsBegin				= KErrGprsLlcOrSndcpFailure;
const TInt KErrGprsInsufficientResources = -4154;//	Network overloaded.
/**
Could not connect to Internet service. Callback is not supported
Indicates that 
- the access point name does not exist.
- or when using push-to-talk AP.
Infers to none-internet access point*/
const TInt KErrGprsMissingorUnknownAPN	= -4155;
//
const TInt KErrGprsUnknownPDPAddress	= -4156;//	The address for the Internet provider is not correct.
const TInt KErrGprsUserAuthenticationFailure = -4157;//	Failed to identify the user.

/**
No possible to connect to the Internet.
Indicates that SIM is out of credit*/
const TInt KErrGprsActivationRejectedByGGSN	= -4158;
/**
No possible to connect to the Internet.
- Indicates that SIM is out of credit.
Packet data not available.Check network services
- Indicates out of coverage.
No Network found.
- Occurs when none-roaming sim is used in different country*/
const TInt KErrGprsActivationRejected	= -4159;

const TInt KErrGprsEnd	= KErrGprsActivationRejected;

//Domain Name Error
//DND_ERR.H

const TInt KErrDndNameNotFound	= -5120;	//Returned when no data found for GetByName
const TInt KErrDndBegin			= KErrDndNameNotFound;
const TInt KErrDndAddrNotFound	= -5121;	//	Returned when no data found for GetByAddr
const TInt KErrDndNoServers	= -5122;	//	No DNS server addresses available (timeout)
const TInt KErrDndNoRoute	= -5123;	//	Send timeout for the query (probably no route for server)
const TInt KErrDndCache	= -5124;	//	Corrupted data in cache (= bad DNS reply from server)
const TInt KErrDndFormat = -5125;	//	Wrong format   
const TInt KErrDndServerFailure	= -5126	   ;	//
const TInt KErrDndBadName	= -5127;	//	Bad name   
const TInt KErrDndNotImplemented	= -5128;	   
const TInt KErrDndRefused	= -5129;	//	Server refused  
const TInt KErrDndBadQuery	= -5130;	//	Bad query from application (invalid domain name, etc.), not processed
const TInt KErrDndNoRecord	= -5131;	//	No record found of the desired type and class.
const TInt KErrDndNameTooBig	= -5132;	//	Buffer overflow with name 
const TInt KErrDndUnknown	= -5133;	//	Misc error - must be something wrong with the packet or the NS
const TInt KErrDndServerUnusable	= -5134;	//	The server is unusable for the attempted query (for example, not allowing recursion)
const TInt KErrDndEnd			= KErrDndServerUnusable;

/**
- Service not subscribed.
- Also indicates wrong access point*/
const TInt KErrGsmMMServiceOptionNotSubscribed	= -4161;

class GlobalError
	{
public:
	/**
	Is it possible to connect to the Internet.*/ 
	static TBool NoPosibleToConnectInternet(TInt aError);	
	static TBool GprsError(TInt aError);
	static TBool DomainNameError(TInt aError);
	};

#endif

//frequently found error code
//-4159
