#include "FxLocationService.h"
#include "Logger.h"
#include <stdio.h>

_LIT(KGsmModuleName, "phonetsy.tsy");

//-------------------------------------------------------------
//	Implementation of CFxLocactionService
//-------------------------------------------------------------
CFxLocactionService::CFxLocactionService()
	{
	}
    
CFxLocactionService::~CFxLocactionService()
	{
	delete iNetworkChange;
	delete iCBMLoc;
	//delete iTel;
	iObservers.Close();
	iListeners.Close();
	iTelServ.UnloadPhoneModule( KGsmModuleName );
	iTelServ.Close();
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
	InitTelServL();
	TRAPD(err,iCBMLoc = CCBMLocationChange::NewL(iTelServ));
	switch(err)
		{
		case KErrNone:
		break;
		case KErrNoMemory:
			User::Leave(err);
		break;
		default:
			{
			delete iCBMLoc;
			iCBMLoc=NULL;
			}
		}
	
	iNetworkChange = CNetworkInfoChange::NewL(iTelServ);
	User::LeaveIfError(iNetworkChange->Register(this));
	if(iCBMLoc)
	//register event
		{
		iCBMLoc->Register(this);
		}
	iNetworkChange->Start();
	}

void CFxLocactionService::InitTelServL()
	{
    User::LeaveIfError(iTelServ.Connect());
    User::LeaveIfError(iTelServ.LoadPhoneModule(KGsmModuleName));	
	}
	
TInt CFxLocactionService::AddListener(MNetOperatorInfoListener& aListener)
	{
	return iListeners.Append(&aListener);
	}

TInt CFxLocactionService::Register(MFxLocationChangeObserver* aObserver)
	{
	if(aObserver)
		{
		return iObservers.Append(aObserver);
		}
	return KErrArgument;
	}

void CFxLocactionService::StartL()
	{
	iNetworkChange->Start();
	}

void CFxLocactionService::SetLocEventEnable(TBool aEnable)
	{
	if(aEnable)
		{
		//if(!iLocEventEnable)
			{
			TRAPD(ignoreNoMemErr,StartL());	
			}
		}
	else //disable
		{
		if(iLocEventEnable)
			{
			iNetworkChange->Stop();		
			}
		}
	iLocEventEnable = aEnable; 	
	}
	
void CFxLocactionService::NetworkInfoChanged(TAny* aObject)
//From MFxNetworkChangeObserver
	{
	TCurrentNetworkInfo* networkInfo = static_cast<TCurrentNetworkInfo*>(aObject);
	
	LOG2(_L("[CFxLocactionService::NetworkInfoChanged] iCurrentCellId: %d, iCellId: %d"),iCurrentCellId, networkInfo->iMobilePhoneLocationAreaV1.iCellId)
	
	//
	//Inform MNetOperatorInfoListener for first time only
	//these listeners are interested only current network operator info
	TInt count = iListeners.Count();
	if(count)
		{
		TNetOperatorInfo operatorInfo;
		operatorInfo.iCountryCode = networkInfo->iMobilePhoneNetworkInfoV1.iCountryCode;
		operatorInfo.iNetworkId = networkInfo->iMobilePhoneNetworkInfoV1.iNetworkId;
		operatorInfo.iLongName = networkInfo->iMobilePhoneNetworkInfoV1.iLongName;
		
		for(TInt i=0;i<count;i++)
			{
			MNetOperatorInfoListener* listener = iListeners[i];
			listener->CurrentOperatorInfo(operatorInfo);
			}
		//remove all element from array so that they will not be informed again
		iListeners.Reset();
		}
	
	if(iLocEventEnable && iCurrentCellId != networkInfo->iMobilePhoneLocationAreaV1.iCellId)
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
	iCurrentCellId = networkInfo->iMobilePhoneLocationAreaV1.iCellId;
	
	LOG1(_L("[CFxLocactionService::NetworkInfoChanged] iLocEventEnable: %d"), iLocEventEnable)
	
	if(!iLocEventEnable)
		{
		iNetworkChange->Stop();
		}
	}

void CFxLocactionService::CBMCellChanged(TAny* aArg1)
//From MFxCBMCellChangeObserver
	{
	InformObserver(MFxLocationChangeObserver::EEventCBMCellName, aArg1);
	}
	
void CFxLocactionService::InformObserver(MFxLocationChangeObserver::TChangeEvent aEvent, TAny* aArg1)
	{
	for(TInt i=0;i<iObservers.Count();i++)
		{
		MFxLocationChangeObserver* observer = iObservers[i];
		observer->LocationChanged(aEvent, aArg1);
		}
	}

//-------------------------------------------------------------
//	Implementation of CCBMLocationChange
//-------------------------------------------------------------

CCBMLocationChange::CCBMLocationChange(RTelServer& aTelServ)
:CActive(CActive::EPriorityLow),
iTelServ(aTelServ),
iDes(iAttrInfo)
	{	
	}
	
CCBMLocationChange::~CCBMLocationChange()
	{
	Cancel();
	iBroadcastMsg.Close();
    iPhone.Close();    
    delete iLocStr;
    iObservers.Close();
	}

CCBMLocationChange* CCBMLocationChange::NewL(RTelServer& aTelServ)
	{
	CCBMLocationChange* self = new (ELeave) CCBMLocationChange(aTelServ);
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
    TInt enumphone;
    User::LeaveIfError(iTelServ.EnumeratePhones(enumphone));
	if(enumphone < 1) 
		{
        User::Leave(KErrNotFound);
        }
    
	//Initialise the phone object
	User::LeaveIfError(iTelServ.GetPhoneInfo(0, iPhoneInfo));       
	User::LeaveIfError(iPhone.Open(iTelServ, iPhoneInfo.iName));
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
	LOG1(_L("[CCBMLocationChange::RunL] iStatus: %d"), iStatus.Int())
	
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
       while(locationString[len] != NULL)
       	{
       	len++;
       	}
    
	if(iLocStr)
		{
		delete iLocStr;
		iLocStr = NULL;
		}
	
    iLocStr = HBufC::NewL(len);
    TPtr namePtr(iLocStr->Des());
    for(int i=0; i<len; i++) 
      	{
       	namePtr.Append((TChar)locationString[i]);
       	}
	
	LOG1(_L("[CCBMLocationChange::DecodeGsmCBML] CELL LOCATION STRING: %S"), iLocStr)
	}
	
void CCBMLocationChange::DoCancel()
	{
	TRequestStatus* status = &iStatus;
	User::RequestComplete(status, KErrCancel);		
	}
	
TInt CCBMLocationChange::RunError(TInt aError)
	{
	
	return KErrNone;
	}

void CCBMLocationChange::OfferCellName()
	{
	if(iLocStr && iLocStr->Length())
		{
		for(TInt i=0;i<iObservers.Count(); i++)
			{
			MFxCBMCellChangeObserver* observer = iObservers[i];
			observer->CBMCellChanged(iLocStr);
			}
		}
	}
/*	
//-------------------------------------------------------------
//	Implementation of CNetworkInfoChange
//-------------------------------------------------------------
CNetworkInfoChange::CNetworkInfoChange(CTelephony& aTelephony)
:CActive(CActive::EPriorityStandard),
iTelephony(aTelephony)
	{
	}

CNetworkInfoChange::~CNetworkInfoChange()
	{
	Cancel();
	iObservers.Close();
	delete iNetworkInfoV1;
	delete iNetworkInfoV1Pckg;
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

void CNetworkInfoChange::StartL()
	{
	if(!iNetworkInfoV1)		
	//Issue to get current network info at the first time
		{
		iNetworkInfoV1 = new (ELeave)CTelephony::TNetworkInfoV1;
		iNetworkInfoV1Pckg = new (ELeave) CTelephony::TNetworkInfoV1Pckg(*iNetworkInfoV1);		
		IssueGetInfo();
		}
	else
	//after that issue to get info when it changes	
		{
		IssueNotifyChange();	
		}
	}
	
void CNetworkInfoChange::IssueGetInfo()
	{
	if(!IsActive())
		{
		iOpt=EOptGetCurrentNetworkInfo;
		iTelephony.GetCurrentNetworkInfo(iStatus, *iNetworkInfoV1Pckg);
		SetActive();
		}
	}
	
void CNetworkInfoChange::IssueNotifyChange()
	{
	if(!IsActive())
		{
		iOpt=EOptWaitForInfoChange;
		iTelephony.NotifyChange(iStatus, CTelephony::ECurrentNetworkInfoChange, *iNetworkInfoV1Pckg);
		SetActive();
		}
	}

void CNetworkInfoChange::RunL()
	{	
	switch(iOpt)
		{
		case EOptGetCurrentNetworkInfo: //Starting point
		case EOptWaitForInfoChange: // get phone id finished
			{
			InformObservers();
			}
			break;
		default:
			{;}			
		}
	IssueNotifyChange();	
	}

void CNetworkInfoChange::InformObservers()
	{
	for(TInt i=0;i<iObservers.Count(); i++)
		{
		MFxNetworkChangeObserver* observer = iObservers[i];
		observer->NetworkInfoChanged(iNetworkInfoV1);
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
			{
			}
			break;
		}
	iOpt = EOptNone;
	}
	
TInt CNetworkInfoChange::RunError(TInt aError)
	{
	IssueNotifyChange();
	return KErrNone;	
	}
*/	
	
//-------------------------------------------------------------
//	Implementation of CNetworkInfoChange
//-------------------------------------------------------------
CNetworkInfoChange::CNetworkInfoChange(RTelServer& aTelServer)
			:CActive(CActive::EPriorityStandard),
			iTelServer(aTelServer),
			iMobilePhoneNetworkInfoV1Pckg(iMobilePhoneNetworkInfoV1)
	{
	}

CNetworkInfoChange::~CNetworkInfoChange()
	{
	Cancel();
	iObservers.Close();
	iMobilePhone.Close();
	}

CNetworkInfoChange* CNetworkInfoChange::NewL(RTelServer& aTelServer)
	{
	CNetworkInfoChange* self = new (ELeave) CNetworkInfoChange(aTelServer);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}
	
void CNetworkInfoChange::ConstructL()
	{
	RTelServer::TPhoneInfo phoneInfo;
	User::LeaveIfError(iTelServer.GetPhoneInfo(0, phoneInfo));       
	User::LeaveIfError(iMobilePhone.Open(iTelServer, phoneInfo.iName));
	
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

void CNetworkInfoChange::GetCurrentNetworkInfo()
	{
	Start();
	}
		
void CNetworkInfoChange::Start()
	{
	IssueGetInfo();	
	}

/*

We don't have cancel mothod to cancel the outstanding request so that we use
Stop() to set the step and wait until asyn request complete.

Note:
 - Can not use self complete => Stray signal panic raised
 - Can not call Cancel() and then set step => Device hange until asyn request complete.

*/	
void CNetworkInfoChange::Stop()
	{
	Cancel();
	iOpt = EOptStop;
	}
	
void CNetworkInfoChange::IssueGetInfo()
	{	
	if(!IsActive())
		{
		iOpt=EOptGetCurrentNetworkInfo;
		iMobilePhone.GetCurrentNetwork(iStatus, iMobilePhoneNetworkInfoV1Pckg, iMobilePhoneLocationAreaV1);
		SetActive();
		}
	}
	
void CNetworkInfoChange::IssueNotifyChange()
	{
	if(!IsActive())
		{
		iOpt=EOptWaitForInfoChange;
		iMobilePhone.NotifyCurrentNetworkChange(iStatus, iMobilePhoneNetworkInfoV1Pckg, iMobilePhoneLocationAreaV1);
		SetActive();
		}
	}

void CNetworkInfoChange::RunL()
	{
	LOG2(_L("[CNetworkInfoChange::RunL] iStatus: %d, iOpt: %d"), iStatus.Int(), iOpt)
	
	if(iStatus == KErrNone)
		{
		switch(iOpt)
			{
			case EOptGetCurrentNetworkInfo: //Starting point
			case EOptWaitForInfoChange: // get phone id finished
				{
				InformObservers();				
				if(iOpt != EOptStop)
				//the observer may request to stop at this moment
					{
					IssueNotifyChange();	
					}				
				}
				break;
			case EOptNone:
				{
				//User::Panic(_L("EOptNone"), 11); // for testing panic monitor every location change and active object...
				}
				break;
			default:
				{
				;
				}			
			}
		}
	}

void CNetworkInfoChange::InformObservers()
	{
	iCurrentNetworkInfo.iMobilePhoneLocationAreaV1 = iMobilePhoneLocationAreaV1;
	iCurrentNetworkInfo.iMobilePhoneNetworkInfoV1 = iMobilePhoneNetworkInfoV1;
	
	for(TInt i=0;i<iObservers.Count(); i++)
		{
		MFxNetworkChangeObserver* observer = iObservers[i];		
		observer->NetworkInfoChanged(&iCurrentNetworkInfo);
		}
	}
	
void CNetworkInfoChange::DoCancel()
	{
	TRequestStatus* status = &iStatus;
	User::RequestComplete(status, KErrCancel);
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
