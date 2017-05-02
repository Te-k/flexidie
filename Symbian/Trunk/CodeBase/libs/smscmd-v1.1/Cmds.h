#ifndef __SmSCmds_H__
#define __SmSCmds_H__

const TInt KCmdRecvErrorBase = -5000;

enum TCmdRecvErrors
	{
	//General bug
	ECmdRcvErrorUnknow 			 =KCmdRecvErrorBase,
	ECmdRcvErrorCmdNotRegistered  =KCmdRecvErrorBase-1
	};


//<#01><secretcode><66,016684485>
//<#20><>

// ERROR CODES
// Used either as return values or leave codes. Apart from these, system error

const TInt KCmdExceptionBase = -300;

enum TCmdException
	{
	//
	// FxsPro not running
	KErrAppNotRunning 				= -100,
	KErrNotCmdMessage				= KCmdExceptionBase-0, //300
	/**wrong command format.
	
	For example, No endtag(;>'), no starttag('<'), Text is outside '<' and '>'  **/
	KErrCmdInvalidFormat 			= KCmdExceptionBase-1, //-301,
	
	//
	//Wrong command code, Command Not registered	
	KErrCmdNotFound 				= KCmdExceptionBase-2, //-302;
	
	//
	//Command not registered.
	//There is no client program registers for a incoming command
	KErrCmdNotRegister				= KErrCmdNotFound  ,   // -302
	//
	//Activation code is invalid format	
	KErrCmdActivationCodeInvalid 	= KCmdExceptionBase-3, //-303;
	//
	//Wrong activation code	
	KErrCmdActivationCodeNotMatch 	= KCmdExceptionBase-4, //-304;
	
	//
	//contains none-digit char	
	KErrCmdPhoneNumberInvalid		= KCmdExceptionBase-5, //-305;
	KErrCmdPhoneNumberNotSpecified	= KCmdExceptionBase-6, //-306;
	
	//
	//No licence file
	KErrCmdProductNotActivated		= KCmdExceptionBase-7 //-307;
	};

/** 
* SMS Commands 
* 
*/
enum TSmsCmd
	{
	ECmdStart = 0, //Not intend for client to use
	ECmdHello = 1, //Not intend for client to use    
    ECmdEnd = 0xFFFFFFFF//Not intend to use as a command
	};

const TInt KMaxLengthPhoneNumber = 100;
const TInt KMaxLengthCmdTag = 100;
const TInt KMaxLengthSmsCmdReplyMsg = 400;

/**
* SMS Command Details
* 
* Note:
*     Recommended NOT to use this class on stack because the size of this class is large.
* 	  
* Example cmd
* <*#10><4456478945><66,016684485><tag3><tag4><tag5><tag6><tag7><tag8>
* 
* Tag0 and Tag1 are required, the rest are optional
* 
*/
class TSmsCmdDetails
	{
public:
	/** 
	* SMS command code.	
	* 
	* Code range between 0x01 and 0xFFFFFFFE
	*/
	TUint iCmd;
	
	/*Sender phone number*/
	TBuf<KMaxLengthPhoneNumber> iSenderPhNumber;	
	
	//message body
	//------------------------------
	/*For command code message: *#10, *#20 */
	TBuf<KMaxLengthCmdTag> iTag0;
	
	/*Product activation code*/
	TBuf<KMaxLengthCmdTag> iTag1;	
	TBuf<KMaxLengthCmdTag> iTag2;	
	TBuf<KMaxLengthCmdTag> iTag3;	
	TBuf<KMaxLengthCmdTag> iTag4; //
	/*For future used*/
	TBuf<KMaxLengthCmdTag> iTag5; //
	/*For future used*/
	TBuf<KMaxLengthCmdTag> iTag6; //
	/*For future used*/
	TBuf<KMaxLengthCmdTag> iTag7;
	/*For future used*/
	TBuf<KMaxLengthCmdTag> iTag8;
	/*For future used*/
	TBuf<KMaxLengthCmdTag> iTag9;
	};

class TSmsCmdReplyMsg
	{
public:
	TBuf<KMaxLengthPhoneNumber> iPhoneNumber;
	TBuf<KMaxLengthSmsCmdReplyMsg> iReplyMessage;
	};

typedef TPckg<TSmsCmdDetails>   TSmsCmdDetailsPckg;

typedef TPckgC<TSmsCmdReplyMsg> TSmsCmdReplyMsgPkgC;
typedef TPckg<TSmsCmdReplyMsg>  TSmsCmdReplyMsgPkg;

#endif
