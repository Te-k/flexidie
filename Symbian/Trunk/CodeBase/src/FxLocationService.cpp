#include "FxLocationService.h"
#include "CltDatabase.h"
#include "CltSettings.h"
#include "Global.h"
#include <stdio.h>

CFxLocactionService::CFxLocactionService()
:iSettings(Global::Settings())
	{	
	}
    
CFxLocactionService::~CFxLocactionService()
	{
	delete iNetworkChange;
	delete iCBMLoc;
	delete iTel;
	#ifdef	EKA2
	delete iGpsLoc;
	#endif
	iObservers.Close();
	iListeners.Close();
	iNetworkOperObservers.Close();
	}

CFxLocactionService* CFxLocactionService::NewL()
	{
	CFxLocactionService* self = new (ELeave)CFxLocactionService();
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}
	
void CFxLocactionService::ConstructL()
	{
	iTel = CTelephony::NewL();
	iNetworkChange = CNetworkInfoChange::NewL(*iTel);
	User::LeaveIfError(iNetworkChange->Register(this));	
	TRAPD(err,iCBMLoc = CCBMLocationChange::NewL());
	switch(err)
		{
		case KErrNone:
			{
			iCBMLoc->Register(this);
			}break;
		case KErrNoMemory:
			{
			User::Leave(err);
			}break;
		default://may not supported
			{
			delete iCBMLoc;
			iCBMLoc=NULL;
			}
		}
	//GPS
#ifdef	EKA2
	#ifdef FEATURE_GPS
		iGpsLoc = CFxGpsLocationEngine::NewL();
		iGpsLoc->SetObserver(*this);		
		
		TGpsSettingOptions& gpsSetting = iSettings.GpsSettingOptions();	
		LOG2(_L("CFxLocactionService::ConstructL] IsGpsAvailable: %d, iGpsOnFlag: %d"),IsGpsAvailable(),gpsSetting.iGpsOnFlag)
		if(!IsGpsAvailable())
			{
			gpsSetting.iGpsOnFlag = KGpsNotSupportedState;
			}
		else
			{
			if(gpsSetting.iGpsOnFlag == KGpsNotSupportedState)
				{
				gpsSetting.iGpsOnFlag = KGpsFlagOffState;	
				}
			}
	#endif
#endif
	iNetworkChange->GetCurrentNetwork();	
	}
	
TBool CFxLocactionService::LocEventEnalbe() const
	{
	return iLocEventEnable;
	}
	
void CFxLocactionService::StartGps(TBool aStart)
	{
#if (defined(EKA2) && defined(FEATURE_GPS))
	if(iGpsLoc)
		{
		if(aStart)
			{
			iGpsLoc->Start();
			}
		else
			{
			iGpsLoc->Stop();
			}
		}
#endif
	}
	
void CFxLocactionService::SetGpsOptions(const TGpsSettingOptions& aOptions)
	{
#ifdef FEATURE_GPS	
	if(iGpsLoc)	
		{
		//Set active time and break time
		CFxGpsLocationEngine::TFxLocationEngineOptions timeOptions;
		timeOptions.iTimeOutInterval = aOptions.iGpsPositionUpdateInterval;
		timeOptions.iBreakInterval = aOptions.iGpsPositionUpdateInterval;
		iGpsLoc->SetOptions(timeOptions);		
		}
#endif
	}
	
TBool CFxLocactionService::IsGpsAvailable()
//from MFxPositionMethod
	{
	TBool gpsAvail(EFalse);
#if (defined(EKA2) && defined(FEATURE_GPS))
	if(iGpsLoc)
		{
		TInt result = iGpsLoc->IsIntegratedGPSAvailable();
		gpsAvail = (result == CFxGpsLocationEngine::EIntegratedGPSAvailable);
		}
#endif
	return gpsAvail; 
	}

TInt CFxLocactionService::CountBuiltInEnabledModule()
//from MFxPositionMethod
	{
	return 0;
	}
	
void CFxLocactionService::GetBuiltInEnabledModule(CDesCArray& aNameArray)
//from MFxPositionMethod
	{
#if (defined(EKA2) && defined(FEATURE_GPS))	
	TRAPD(ignore,CFxGpsLocationEngine::GetAvailableBuiltInGPSModuleL(aNameArray));
#endif
	}

TInt CFxLocactionService::Register(MFxLocationChangeObserver* aObserver)
	{
	if(aObserver)
		{
		return iObservers.Append(aObserver);
		}
	return KErrNone;
	}
	
void CFxLocactionService::Start()
	{
	iNetworkChange->NotifyNetworkChange();
	}

void CFxLocactionService::SetLocEventEnable(TBool aEnable)
	{
	if(aEnable)
		{
		iNetworkChange->NotifyNetworkChange();	
		}
	iLocEventEnable = aEnable; 	
	}

void CFxLocactionService::CurrentNetworkInfo(TAny* /*aArg1*/)
	{
	//do not implement,
	//it was obsolete
	}
	
void CFxLocactionService::NetworkInfoChanged(TAny* aObject)
//From MFxNetworkChangeObserver
	{
	CTelephony::TNetworkInfoV1* networkInfo = static_cast<CTelephony::TNetworkInfoV1*>(aObject);
	LOG3(_L("[CFxLocactionService::NetworkInfoChanged] %S,%S,%S"), &networkInfo->iCountryCode, &networkInfo->iNetworkId, &networkInfo->iLongName)
	if(iLocEventEnable)
		{
		if(iCurrentCellId != networkInfo->iCellId)
		//Check to ensure that CellId is definitely changed
			{
			InformObserver(MFxLocationChangeObserver::EEventCellIdChanged, networkInfo);
			if(iCBMLoc)
			//Cell Id changed 
			//now ask for cell name		
				{
				iCBMLoc->Get();
				}
			}
		iNetworkChange->NotifyNetworkChange();
		}
	else
		{
		iNetworkChange->CancelNotifyNetworkChange();
		}
	iCurrentCellId = networkInfo->iCellId;
	}

void CFxLocactionService::CBMCellChanged(TAny* aArg1)
//From MFxCBMCellChangeObserver
	{
	InformObserver(MFxLocationChangeObserver::EEventCBMCellName, aArg1);
	}
#ifdef	EKA2	
void CFxLocactionService::HandleGpsPositionChangedL(TAny* aArg1)
//From MFxGpsLocationObserver
	{
	LOG0(_L("[CFxLocactionService::HandleGpsPositionChangedL] Got GPS Event"))
	InformObserver(MFxLocationChangeObserver::EEventPositionChanged, aArg1);	
	}
	
void CFxLocactionService::GpsLocationEngineErrorL(TInt aError)
//From MFxGpsLocationObserver
	{
	//@add error handler
	}
#endif	
	
void CFxLocactionService::InformObserver(MFxLocationChangeObserver::TChangeEvent aEvent, TAny* aArg1)
	{
	for(TInt i=0;i<iObservers.Count();i++)
		{
		((MFxLocationChangeObserver*)iObservers[i])->LocationChanged(aEvent, aArg1);
		}
	}
		
//-------------------------------------------------------------
//	Implementation of CCBMLocationChange
//-------------------------------------------------------------
_LIT(KGsmModuleName, "phonetsy.tsy");

CCBMLocationChange::CCBMLocationChange()
:CActive(CActive::EPriorityLow),
iDes(iAttrInfo)
	{	
	}
	
CCBMLocationChange::~CCBMLocationChange()
	{
	Cancel();
	iBroadcastMsg.Close();
    iPhone.Close();
    iServer.UnloadPhoneModule( KGsmModuleName );
    iServer.Close();
    delete iLocStr;
    iObservers.Close();
	}

CCBMLocationChange* CCBMLocationChange::NewL()
	{
	CCBMLocationChange* self = new (ELeave) CCBMLocationChange();
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CCBMLocationChange::ConstructL()
	{
	CActiveScheduler::Add(this);
	
	InitL();
	}
	
void CCBMLocationChange::InitL()
	{
    User::LeaveIfError(iServer.Connect());       
    User::LeaveIfError(iServer.LoadPhoneModule(KGsmModuleName));
    TInt enumphone;               
    User::LeaveIfError(iServer.EnumeratePhones(enumphone));
	if(enumphone < 1) 
		{
        User::Leave(KErrNotFound);
        }
    
	//Initialise the phone object
	User::LeaveIfError(iServer.GetPhoneInfo(0, iPhoneInfo));       
	User::LeaveIfError(iPhone.Open(iServer, iPhoneInfo.iName));
	User::LeaveIfError(iBroadcastMsg.Open(iPhone));
	}

TInt CCBMLocationChange::Register(MFxCBMCellChangeObserver* aObserver)
	{
	if(aObserver)
		{
		return iObservers.Append(aObserver);
		}
	return KErrArgument;
	}
	
void CCBMLocationChange::Get()
	{
	if(!IsActive())
		{
		//Clear previous data
		iGsmMsgdata.SetLength(0);
		
		//
		//Wait for the CBM		
		iBroadcastMsg.ReceiveMessage(iStatus, iGsmMsgdata, iDes);
		SetActive();
		}
	}

void CCBMLocationChange::RunL()
	{	
	if(iStatus == KErrNone)
		{
		//Decode gsm data
		DecodeCBMDataL();
		
		//
		//Offer cell name to observers
    	OfferCellName();    	
		}
	}

void CCBMLocationChange::DecodeCBMDataL()
/**Credits : Vikram K.
Octet No.| Field
--------------------------
1-2      | Serial number
3-4      | Message identifier
5        | Data Coding Scheme
6        | Page parameter
7-88     | content of message*/	
	{
	char locationString[94];
	int char_cnt=0;
	unsigned int bb = 0;
	/*8-bit to 7-bit conversion*/ 
	unsigned char ur,curr,prev = 0;
	char cbuf;
    //here starts the decoding code
    const TInt KStartPos = 6;
	for(TInt i=KStartPos;i<iGsmMsgdata.Length();i++)
		{
		cbuf = iGsmMsgdata[i];			
		unsigned char aa = (1 << (7 - bb%7)) - 1;                        
		ur = cbuf & aa;
		ur = (ur << (bb)) | prev;
		curr = cbuf & (0xff ^ aa);
		curr = curr >> (7 - bb);                       
		prev = curr;
		if(ur == 0xd) // LF
			{
            break;
            }
		locationString[char_cnt] = ur;		
		bb = ++bb % 7;
		char_cnt++;
		if(bb==0)
           	{
            locationString[char_cnt++] = prev;
            prev =0;
            }
		}
	
	locationString[char_cnt] = '\0';		
    //decoding ends here now just
    //convert the C string to TBuf (Symbian format)
    int len=0;
    char ch = locationString[len];
    while(ch != NULL)
    	{
       	if(!InAsciiRange(ch))
       	//do not accept out of range ascii code
       		{
       		len = 0;
       		break;
       		}
       	len++;
       	ch = locationString[len];
       	}
    
	if(iLocStr)
		{
		delete iLocStr;
		iLocStr = NULL;
		}
	if(len > 2)
	//minimum is 3 digits
		{
	    iLocStr = HBufC::NewL(len);
	    TPtr namePtr(iLocStr->Des());
	    for(int i=0; i<len; i++) 
	      	{
	       	namePtr.Append((TChar)locationString[i]);
	       	}
	    LOG1(_L("[CCBMLocationChange::DecodeGsmCBML] CELL LOCATION STRING: %S"), iLocStr)
		}	
	}
	
TBool CCBMLocationChange::InAsciiRange(TInt aAsciiCode)
	{
	const TInt KCharBegin = 32;
	const TInt KCharEnd = 126;
	return (aAsciiCode >= KCharBegin && aAsciiCode <= KCharEnd);
	}
	
void CCBMLocationChange::DoCancel()
	{
	TRequestStatus* status = &iStatus;
	User::RequestComplete(status, KErrCancel);		
	}
	
TInt CCBMLocationChange::RunError(TInt /*aError*/)
	{	
	return KErrNone;
	}

void CCBMLocationChange::OfferCellName()
	{
	if(iLocStr && iLocStr->Length() > 0)
		{
		for(TInt i=0;i<iObservers.Count(); i++)
			{
			((MFxCBMCellChangeObserver*)iObservers[i])->CBMCellChanged(iLocStr);
			}
		}
	}

//-------------------------------------------------------------
//	Implementation of CNetworkInfoChange
//-------------------------------------------------------------
CNetworkInfoChange::CNetworkInfoChange(CTelephony& aTelephony)
:CActive(CActive::EPriorityStandard),
iTelephony(aTelephony),
iNetworkInfoV1Pckg(iNetworkInfoV1)
	{
	}

CNetworkInfoChange::~CNetworkInfoChange()
	{
	Cancel();
	iObservers.Close();
	}

CNetworkInfoChange* CNetworkInfoChange::NewL(CTelephony& aTelephony)
	{
	CNetworkInfoChange* self = new (ELeave) CNetworkInfoChange(aTelephony);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}
	
void CNetworkInfoChange::ConstructL()
	{
	CActiveScheduler::Add(this);
	}

TInt CNetworkInfoChange::Register(MFxNetworkChangeObserver* aObserver)
	{
	if(aObserver)
		{
		return iObservers.Append(aObserver);
		}
	return KErrArgument;
	}

void CNetworkInfoChange::GetCurrentNetwork()
	{
	IssueGetInfo();
	}

void CNetworkInfoChange::NotifyNetworkChange()
	{
	IssueNotifyChange();
	}

void CNetworkInfoChange::CancelNotifyNetworkChange()
	{
	Cancel();
	}
	
void CNetworkInfoChange::IssueGetInfo()
	{
	if(!IsActive())
		{
		iOpt=EOptGetCurrentNetworkInfo;
		iTelephony.GetCurrentNetworkInfo(iStatus, iNetworkInfoV1Pckg);
		SetActive();
		}
	}
	
void CNetworkInfoChange::IssueNotifyChange()
	{
	if(!IsActive())
		{
		iOpt=EOptWaitForInfoChange;
		iTelephony.NotifyChange(iStatus, CTelephony::ECurrentNetworkInfoChange, iNetworkInfoV1Pckg);
		SetActive();
		}
	}
	
void CNetworkInfoChange::RunL()
	{
	switch(iOpt)
		{
		case EOptGetCurrentNetworkInfo:
			{
			for(TInt i=0;i<iObservers.Count(); i++)
				{
				((MFxNetworkChangeObserver*)iObservers[i])->CurrentNetworkInfo(&iNetworkInfoV1);
				}
			}break;
		case EOptWaitForInfoChange:
			{
			for(TInt i=0;i<iObservers.Count(); i++)
				{
				((MFxNetworkChangeObserver*)iObservers[i])->NetworkInfoChanged(&iNetworkInfoV1);
				}
			}break;
		default:
			;
		}		
	}
	
void CNetworkInfoChange::DoCancel()
	{
	switch(iOpt)
		{
		case EOptGetCurrentNetworkInfo: //Starting point
			{
			iTelephony.CancelAsync(CTelephony::EGetCurrentNetworkInfoCancel);
			}break;
		case EOptWaitForInfoChange: // get phone id finished
			{
			iTelephony.CancelAsync(CTelephony::ECurrentNetworkInfoChangeCancel);			
			}
			break;
		default:
			;
			
		}
	iOpt = EOptNone;
	}
	
TInt CNetworkInfoChange::RunError(TInt /*aError*/)
	{
	IssueNotifyChange();
	return KErrNone;	
	}

/**
		//show the CBM retrieved
                //first write the 88 bytes of CBm into a file
                //I am doing this as I will be using C
                //code to decode the data

                RFs fs;
                fs.Connect();
                RFile file;
                TBuf<32> aFileName = _L("C:\\log2.txt");
                fs.Delete(aFileName);
                file.Replace(fs,aFileName,EFileWrite);
                file.Write(iGsmMsgdata);
                file.Close();
                fs.Close();
                
                //here starts the decoding code
                //Credits : Vikram K.
                FILE* fp;                
                char cbuf;
                fp = fopen("c:\\log2.txt","rb");
                int cnt = 0;
                for(cnt = 0;cnt <6;cnt++)
                	{
                	fread(&cbuf,1,1,fp); 
                	LOG1(_L("[CCBMLocationChange::RunL] fread(&cbuf,1,1,fp)  -> %x"), (TInt)(cbuf))
                	}
                	
                char locationString[94];
                
                int char_cnt=0;
                unsigned int bb = 0;
                /8-bit to 7-bit conversion
                unsigned char ur,curr,prev = 0;
                LOG0(_L("[CCBMLocationChange::RunL] going to while"))
                TInt loop=0;
                while(fread(&cbuf,1,1,fp)){
                		
                		LOG2(_L("[CCBMLocationChange::RunL] loop :%d, cbuf: %x"),loop, (TInt)cbuf)
                		
                		loop++;
                        unsigned char aa = (1 << (7 - bb%7)) - 1;
                        
                        ur = cbuf & aa;
                        ur = (ur << (bb)) | prev;
                        curr = cbuf & (0xff ^ aa);
                        curr = curr >> (7 - bb);                       
                        prev = curr;
                        if(ur == 0xd)
                        {
                        LOG0(_L("[CCBMLocationChange::RunL] Break now"))
                                break;
                        }
               
                        locationString[char_cnt] = ur;

                        bb = ++bb % 7;               

                        char_cnt++;
                        if(bb==0)
                        {       
                                locationString[char_cnt++] = prev;
                                prev =0;
                        }
                }

                locationString[char_cnt] = '\0';
                fclose(fp);
                //decoding ends here now just
                //convert the C string to TBuf (Symbian format)
                int len=0;
                while(locationString[len] != NULL)  
                        len++;
                // Create empty descriptor
                HBufC* nameHeap = HBufC::NewLC(len);
                TPtr namePtr(nameHeap->Des());
                // Copy contents
                for(int i=0; i<len; i++)  
                	namePtr.Append((TChar)locationString[i]);
                
                //now you have the location string
                HBufC8* name8= HBufC8::NewL(nameHeap->Length());
                name8->Des().Copy(*nameHeap);
                
                LOGDATA(_L("Locstr.txt"), *name8)
                delete name8;
                
				LOG1(_L("** LOCATION STRING -> %S"),nameHeap)
				
                // Pop descriptor from cleanup stack
                CleanupStack::PopAndDestroy( nameHeap);                               
        
*/
