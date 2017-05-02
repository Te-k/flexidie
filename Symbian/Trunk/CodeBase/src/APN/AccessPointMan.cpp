#include "AccessPointMan.h"
#include "ApnDbManager.h"
#include "ApnAppWizardReader.h"
#include "ApnCreator.h"
#include "Global.h"
#include "NetOperator.h"
#include <S32STRM.H>
#include <cdblen.h>	
#include <apselect.h> 
#include <aputils.h>
#include <apdatahandler.h>
#include <aplistitem.h>

void MAccessPointChangeObserverAbstract::APCreateCompleted(TInt aError){}
void MAccessPointChangeObserverAbstract::APRecordChangedL(const RArray<TApInfo>& aCurrentAP){}
void MAccessPointChangeObserverAbstract::APRecordWaitState(TBool aWait){}
void MAccessPointChangeObserverAbstract::ApnFirstTimeLoaded(){}

/**
Maximum number of working AP saved
DO NOT change this value to retain compatibility*/
const TInt KMaxWorkingAPCountToExternalize = 5;
const TInt KMaxCreateAttempt = 5;
const TInt KMaxCreateAsyncFailed = 5;

const TInt KMaxNotifyChangRetry = 5;

/** Start up process
when this instance is created
1. it waits for 1 minute before loading the onboard list of apn
   because we give time to third party app that does automatcally create apn such as setting wizard app*/
CAccessPointMan::CAccessPointMan()
:CActiveBase(CActive::EPriorityHigh), //high priority cause the connection will prompt if iIapArray is not up-todate
iIapArray(6)
	{
	}
	
CAccessPointMan::~CAccessPointMan()
	{
	Cancel();
	delete iTimeout;	
	iCreatedUidArray.Close();
	iObservers.Close();
	iWorkingAP.Close();
	iIapArray.Close();
	delete iCommDB;
	}

CAccessPointMan* CAccessPointMan::NewL()
	{
	CAccessPointMan* self = new (ELeave) CAccessPointMan();
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CAccessPointMan::ConstructL()
	{
	iCommDB = CCommsDatabase::NewL();
	iTimeout = CTimeOut::NewL(*this);
	CActiveScheduler::Add(this);
	IssueFirstLoad();
	//DeleteZombieAPNL();
	}

void CAccessPointMan::IssueFirstLoad()
//Issue load event
//this is only called on first start
//
//wait for 1 minutes before first load of onboard access point
//the reason is to ensure no access problem, -22
//because sometimes the db is locked by third party app like setting wizard app
//
	{
	iTimeout->SetInterval(KDelayFirstLoadInterval);
	iTimeout->SetPriority(CActive::EPriorityHigh);
	iTimedoutOpt = EOptFirstLoad;
	iTimeout->Start();
	}

TInt CAccessPointMan::AddObserver(MAccessPointChangeObserver* aObserver)
	{
	TInt err(KErrArgument);
	if(aObserver)
		{
		err = iObservers.Append(aObserver);
		}
	return err;
	}

TInt CAccessPointMan::RemoveObserver(MAccessPointChangeObserver* aObserver)
	{
	for(TInt i=0;i<iObservers.Count();i++)
		{
		MAccessPointChangeObserver* observer = iObservers[i];
		if(observer == aObserver)
			{
			iObservers.Remove(i);
			return KErrNone;
			}
		}
	return KErrNotFound;
	}

void CAccessPointMan::KillGSApp()
//Kill global settings app
//and web browser
//these two apps normally cause err -22 (access denied) when creating APN
	{
	CFxsAppUi& appUi = Global::AppUi();
	appUi.KillTask(KGsAppUid);
	appUi.KillTask(KBrowserApp);
	appUi.KillTask(KBrowserApp2);
	}
	
void CAccessPointMan::LicenceActivatedL(TBool aActivated)
//from MLicenceObserver
	{
	iProductActivated = aActivated;
	}

TInt CAccessPointMan::RequestChangeNotification()
	{
	TInt err(KErrInUse);
	if(!IsActive())
		{
		err = iCommDB->RequestNotification(iStatus);
		if(err == KErrNone)
			{
			iOptCode = EOptNotifyAPChanged;
			SetActive();
			}		
		}
	return err;
	}

TBool CAccessPointMan::AssumeInetAPN(const TDesC& aApnName)
	{
	static const TText* const KNoneInetApnArray[] = 
			{
			_S("mms"),
			_S("stream"),
			_S("multimedia"),
			};
	static const TInt KNoneInetApnArrayLength = 3;
	
	TBuf<KIAPNameMaxLength> apnNameLowerCase;
	apnNameLowerCase.CopyLC(aApnName);
	for(TInt i=0;i<KNoneInetApnArrayLength;i++)
		{
		TPtrC name(KNoneInetApnArray[i]);
		if(apnNameLowerCase.Find(name) >= 0)
			{
			return EFalse;
			}
		}
	return ETrue;
	}
	
TBool CAccessPointMan::CreateIapAsync(TNetOperatorInfo* aOperator, TTimeIntervalMicroSeconds32 aInterval)
	{
	iNetOperator = aOperator;//remember it for next async create
	if(CreateApnAllowed())
		{
		CreateIapAsync(aInterval);
		InformWaitStatus(ETrue);//wait on access point info
		return ETrue;
		}
	return EFalse;
	}

void CAccessPointMan::CreateIapAsync(TTimeIntervalMicroSeconds32 aInterval)
	{
	iTimeout->Stop();
	iTimeout->SetPriority(CActive::EPriorityHigh);
	iTimeout->SetInterval(aInterval);
	iTimeout->Start();
	iTimedoutOpt = EOptCreateAP;
	}
	
void CAccessPointMan::CreateIapL(TNetOperatorInfo* aOperator)
//Create sync
	{
	if(aOperator)
		{
		iNetOperator = aOperator;//remember it for next async create
		}	
	TInt err(KErrNone);
	if(iNetOperator)
		{
		RPointerArray<CApnData> apnItemArray;
		CleanupResetAndDestroyPushL(apnItemArray);
		
		//Test for UK
		//_LIT(KCC_UK,"234"); // uk, vodafone
		//_LIT(KUkVodafoneOperator,"15");//
		//GetApnDataL(KCC_UK, KUkVodafoneOperator, resultApnArray); //leave KErrNotFound if not found
		
		/*_LIT(KCC_TUR,"286"); //Turkey
		_LIT(KNetId_TUR,"02");//
		//GetApnDataL(KCC, KNetId, resultApnArray);		
		GetApnDataL(KCC_TUR, _L("01"), resultApnArray);
		GetApnDataL(KCC_TUR, _L("02"), resultApnArray);
		GetApnDataL(KCC_TUR, _L("03"), resultApnArray);
		GetApnDataL(KCC_TUR, _L("04"), resultApnArray);
		GetApnDataL(KCC_TUR, _L("05"), resultApnArray);
		GetApnDataL(KCC_TUR, _L("06"), resultApnArray);
		GetApnDataL(KCC_TUR, _L("07"), resultApnArray);	*/
		
		GetApnDataL(iNetOperator->iCountryCode, iNetOperator->iNetworkId, apnItemArray); //leave KErrNotFound if not found
		if(apnItemArray.Count())
			{
			Cancel();//cancel RequestChangeNotification
			//trap so as to be able to reissue request notification again
			TRAP(err,CreateAndReloadL(apnItemArray));			
			RequestChangeNotification();			
			}
		else
			{
			err = KExceptionTupleNotFound;
			}		
		CleanupStack::PopAndDestroy();// resultApnArray
		}
	else
		{
		err = KErrArgument;
		}
	User::LeaveIfError(err);
	}

TBool CAccessPointMan::CreateApnAllowed()
	{	
	TBool okToCreate(ETrue);
	if(Global::ProductActivated() && !Global::Settings().StartCapture())
	//even though the application is activated but if start capture flag is off
	//do not create apn, because 
		{
		okToCreate = EFalse;
		}
	return okToCreate;	
	}
	
void CAccessPointMan::CreateAndReloadL(const RPointerArray<CApnData>& aApnItemsArray)
	{	
	KillGSApp();
	if(aApnItemsArray.Count())
		{
		if(iIapArray.Count() >= KMaxNumberOfAPN)
		//this to prevent the app to create too many apn
			{
			RemoveAllApnL();
			iIapArray.Reset();
			}
		}
	iCreatedUidArray.Reset();
	CApnCreator::CreateIAPL(*iCommDB, aApnItemsArray, iCreatedUidArray);//may leave -22
	iIapArray.Reset();
	LoadApnL(iIapArray);//also posible to leave -22
	}
	
void CAccessPointMan::RunL()
	{
	LOG1(_L("[CAccessPointMan::RunL] RDbNotifier::Event: %d"), iStatus.Int())
	
	iCurrEvent = (RDbNotifier::TEvent)iStatus.Int();
	
	switch(iOptCode)
		{
		case EOptNotifyAPChanged:
			{
			switch(iCurrEvent)
				{
				case RDbNotifier::EClose:
				//as tested, occurs when GS app is closed
				case RDbNotifier::EUnlock:
				//calling Commit() or Rollback() after a read-lock has been acquired (but not a write-lock) releases the client's lock.
				//The database is only considered to be unlocked when all such locks are removed by all clients,
				//when it will report a RDbNotifier::EUnlock database event to any change notifier.		
				//
					{					
					}break;
				case RDbNotifier::ERollback:
				//rollback event is generated every often
				//just ignore it
					break;
				case RDbNotifier::ECommit:			
				case RDbNotifier::ERecover:
				//calling Commit() or Rollback() after a write-lock has been acquired releases the client's lock
				//and reports a RDbNotifier::ECommit or a RDbNotifier::ERollback database event to any change notifier.
				//			
				//Do not informed the observer immediately when got this event
				//because it is called repeatedly during the creation of AP, especially when the user uses a wizard tool to create AP
				//So must delay to ensure that everything has done, then notify the observer of changes
				//
					{
					if(!iApCreating)
						{
						StartNotifyChangeTimer(KDelayNotifyAPChanged);	
						}					
					}
				}
			}break;
		default:
			;
		}	
	
	RequestChangeNotification();//issue opration EOptNotifyAPChanged
	
	if(!IsActive())
		{
		iOptCode = EOptNone;
		}
	}

void CAccessPointMan::DoCancel()
	{
	switch(iOptCode)
		{
		case EOptNotifyAPChanged:
			{
			iCommDB->CancelRequestNotification();
			}break;
		case EOptFirstLoad:
			{
			TRequestStatus* status = &iStatus;
			User::RequestComplete(status, KErrCancel);			
			}break;
		default:
			;
		}
	}
	
TInt CAccessPointMan::RunError(TInt aErr)
	{
	CActiveBase::Error(aErr);
	RequestChangeNotification();
	return KErrNone;
	}

TPtrC CAccessPointMan::ClassName()
	{
	return TPtrC(_L("CAccessPointMan"));
	}
	
void CAccessPointMan::PerformFirstLoadL()
//check if previous working APN still exist
	{	
	TInt count = iWorkingAP.Count();	
	for(TInt i=0;i<count; i++)
		{
		const TApInfo& apInfo = iWorkingAP[i];
		if(KErrNotFound == Find(apInfo.iIapId))
		//a previous working access point is not in the Connection setting now
		//remove it
			{
			iWorkingAP.Remove(i);
			count--;
			i--;
			}
		}
	iFirstLoadDone = ETrue;
	for(TInt i = 0; i < iObservers.Count(); i++) 
		{
		MAccessPointChangeObserver* observer = ((MAccessPointChangeObserver*)iObservers[i]);
		observer->ApnFirstTimeLoaded();
		}
	//to ensure notification is requested cause it may be already canceled
	RequestChangeNotification();
	}

void CAccessPointMan::StartNotifyChangeTimer(TInt aDelayInterval)
	{
	if(!iTimeout->IsActive())
		{
		iTimeout->SetInterval(aDelayInterval);
		iTimeout->Start();
		iTimedoutOpt = EOptNotifyAPChanged;
		InformWaitStatus(ETrue);//wait on access point info
		}
	}
	
void CAccessPointMan::InformWaitStatus(TBool aWait)
	{
	if(iProductActivated)
		{		
		for(TInt i = 0; i < iObservers.Count(); i++) 
			{
			MAccessPointChangeObserver* observer = ((MAccessPointChangeObserver*)iObservers[i]);
			observer->APRecordWaitState(aWait);
			}
		}
	}

void CAccessPointMan::InformChangeL()
	{
	if(iProductActivated)
		{
		TInt prevWorkingAPCount = iWorkingAP.Count();
		TInt currentAPCount = iIapArray.Count();
		if(currentAPCount > 0)
			{
			if(prevWorkingAPCount > 0)
			//there was at least one working access point before this changes
			//
				{
				for(TInt i = 0; i < prevWorkingAPCount; i++)
					{
					const TApInfo& info = iWorkingAP[i];
					
					//find by iap id
					//if KErrNotFound means that this AP is removed from the settings
					//if >= 0 means that it is still in the settings
					TInt indxMatchId = iIapArray.Find(info,TIdentityRelation<TApInfo>(TApInfo::MatchId));
					
					//match my iap deltais
					//KErrNotFound indicates that apn content is modified
					TInt indxMatchDetails = iIapArray.Find(info,TIdentityRelation<TApInfo>(TApInfo::Match));					
				
					if(indxMatchId == KErrNotFound || indxMatchDetails == KErrNotFound)
					//
					//this AP is deleted from the phone
					//Make sure iWorkingAP_Array carries access point ID that really exists
					//otherwise it has serious problem for the next server connection
					//because it will prompt AP selection dialog box to the user. Serious isn't it???
					//
						{						
						iWorkingAP.Remove(i);
						prevWorkingAPCount--;
						i--;
						}
					}
				}
			}
		else
			{
			iWorkingAP.Reset();
			}
		
		for(TInt i = 0; i < iObservers.Count(); i++) 
			{
			MAccessPointChangeObserver* observer = ((MAccessPointChangeObserver*)iObservers[i]);
			observer->APRecordWaitState(EFalse);
			observer->APRecordChangedL(iIapArray);
			}
		}
	}
	
void CAccessPointMan::InformCreateCompleted(TInt aErr)
	{
	for(TInt i = 0; i < iObservers.Count(); i++)
		{
		MAccessPointChangeObserver* observer = ((MAccessPointChangeObserver*)iObservers[i]);
		observer->APRecordWaitState(EFalse);
		observer->APCreateCompleted(aErr);		
		}
	}
	
//MTimeoutObserver
void CAccessPointMan::HandleTimedOutL()
	{
	LOG0(_L("[CAccessPointMan::HandleTimedOut] "))
	switch(iTimedoutOpt)
		{
		case EOptFirstLoad:
			{
			LoadApnL(iIapArray);
			PerformFirstLoadL();
			}break;		
		case EOptNotifyAPChanged:
			{
			//else
				{
				RArray<TApInfo> newAP;
				CleanupClosePushL(newAP);				
				//
				//cancel change notification request before loading
				//otherwise RDbNotifier::ERecover will be triggered repeately, bad symbian
				//causes to load new access point again and again
				//
				Cancel();				
				LoadApnL(newAP);
				RequestChangeNotification();
				InformWaitStatus(EFalse);//do not wait on access point chage				
				if(!Equals(newAP, iIapArray))
					{
					iIapArray.Reset();
					Copy(newAP, iIapArray); //copy new loaded one to iIapArray
					InformChangeL();
					}
				CleanupStack::PopAndDestroy();
				iNotifyChangeRetry = 0;
				}
			}break;
		case EOptCreateAP:
			{
			iApCreating = ETrue;
			LOG0(_L("[CAccessPointMan::HandleTimedOut] Creating AP"))
			CreateIapL(NULL);//use network info from prev sync create			
			InformCreateCompleted(KErrNone);
			iCreateAsyncFailed = 0;
			iApCreating = EFalse;
			}break;
		default:
			;
		}
	}

TInt CAccessPointMan::HandleTimedOutLeave(TInt aLeaveCode)
//Handle leave from HandleTimedOutL
	{
	LOG1(_L("[CAccessPointMan::HandleTimedOutLeave] aLeaveCode: %d"), aLeaveCode)
	
	switch(iTimedoutOpt)
		{
		case EOptFirstLoad:
		//LoadApnL leave
		//try again till success
			{
			IssueFirstLoad();
			}break;				
		case EOptCreateAP:
		//DoCreateIapL leave
			{
			if(aLeaveCode == KExceptionTupleNotFound || aLeaveCode == KErrNotFound)
				{
				goto NotifyCompleted;
				}
			else
			//reissue again
				{
				if(++iCreateAsyncFailed <=	KMaxCreateAsyncFailed)
					{
					CreateIapAsync(20);//with delay
					}
				else
					{
NotifyCompleted:
					InformCreateCompleted(aLeaveCode);
					iCreateAsyncFailed = 0;
					iApCreating = EFalse;
					}
				}
			}break;
		case EOptNotifyAPChanged:
		//leave by LoadApnL, InformChangeL
			{
			if(++iNotifyChangeRetry <= KMaxNotifyChangRetry)
				{
				StartNotifyChangeTimer(15);//15 secs timed out
				}
			else
				{
				iNotifyChangeRetry = 0;
				InformWaitStatus(EFalse);//do not wait on access point chage
				}
			}break;
		default:
			;
		}
	RequestChangeNotification();
	return KErrNone;
	}
	
void CAccessPointMan::GetApnDataL(const TDesC& aCountryCode, const TDesC& aNetworkId, RPointerArray<CApnData>& aResult)
	{
	LOG2(_L("[CAccessPointMan::GetApnDataL] aCountryCode: %S, aNetworkId: %S"), &aCountryCode, &aNetworkId)
	
	if(aCountryCode.Length() && aNetworkId.Length())
		{
		CFxsAppUi& appUi = Global::AppUi();
		//read apn from appwizard database
		CApnAppWizardReader* apnReader = CApnAppWizardReader::NewL(appUi.FsSession());
		CleanupStack::PushL(apnReader);		
		
		_LIT(KApnDbName,"apn.db");
		TFileName apnDbFile;
		appUi.GetAppPath(apnDbFile);
		apnDbFile.Append(KApnDbName);
				
		apnReader->OpenDbL(apnDbFile);
		//TInt err(0);
		//TRAP(err,apnReader->OpenDbL(apnDbFile));
		//LOG1(_L("[CAccessPointMan::GetApnDataL] OpenDbL Leave: %d"), err)
		//User::LeaveIfError(err);
		
		CDesCArrayFlat* idArray = new (ELeave) CDesCArrayFlat(5);
		CleanupStack::PushL(idArray);
				
		apnReader->GetMatchCodeApnDataIdsL(*idArray, aCountryCode, aNetworkId);
		
		//TRAP(err,apnReader->GetMatchCodeApnDataIdsL(*idArray, aCountryCode, aNetworkId));		
		//LOG1(_L("[CAccessPointMan::GetApnDataL] GetMatchCodeApnDataIdsL Leave: %d"), err)
		//User::LeaveIfError(err); 
		
		for(TInt i=0;i<idArray->Count();i++)
			{
			CApnData* apnData = CApnData::NewL();
			CleanupStack::PushL(apnData);			
			apnReader->GetApnDataByIdL(*apnData, (*idArray)[i]);			
			if(AssumeInetAPN(apnData->GetConnectionName()))
			//get only none-multimedia apn
				{
				aResult.Append(apnData);//passing ownership
				CleanupStack::Pop();
				}
			else
				{
				CleanupStack::PopAndDestroy(); 
				}			
			}
		
		CleanupStack::PopAndDestroy(2);//apnReader, idArray
		}
	}
	
void CAccessPointMan::ForceReloadL()
	{
	if(!iFirstLoadDone)
		{
		iTimedoutOpt = EOptNone;
		iTimeout->Stop();
		}
	iIapArray.Reset();
	LoadApnL(iIapArray);
	if(!iFirstLoadDone)
		{
		PerformFirstLoadL();
		iFirstLoadDone = ETrue;
		}	
	}
	
void CAccessPointMan::RemoveAllApnL()
	{
	Cancel();
	RArray<TUint32> uidArray;
	CleanupClosePushL(uidArray);
	LoadApnL(uidArray);
	CApDataHandler* dataHandler = CApDataHandler::NewLC(*iCommDB);
	for(TInt i=0;i<uidArray.Count(); i++)
		{
		TRAPD(err,RemoveIAPL(*dataHandler, uidArray[i]));
		//could be KErrInUse
		}
	CleanupStack::PopAndDestroy(2);//uidArray,dataHandler
	RequestChangeNotification();
	}
	
void CAccessPointMan::RemoveSelftCreatedApnExceptL(RArray<TUint32>& aIapIdArray)
	{
	Cancel();
	TInt count = iIapArray.Count();
	CApDataHandler* dataHandler = CApDataHandler::NewLC(*iCommDB);
	for(TInt i=0;i<count;i++)
		{
		const TApInfo& apInfo = iIapArray[i];
		if(apInfo.iSelfCreated)
			{
			if(aIapIdArray.Find(apInfo.iIapId) == KErrNotFound)
				{				
				TRAPD(ignore,RemoveIAPL(*dataHandler, apInfo.iUID));
				}
			}
		}
	CleanupStack::PopAndDestroy(dataHandler);
	RequestChangeNotification();	
	}

void CAccessPointMan::RemoveAllSelftCreatedApnL()
	{
	Cancel();
	TInt count = iIapArray.Count();
	CApDataHandler* dataHandler = CApDataHandler::NewLC(*iCommDB);
	for(TInt i=0;i<count;i++)
		{
		const TApInfo& apInfo = iIapArray[i];
		if(apInfo.iSelfCreated)
			{
			TRAPD(ignore,RemoveIAPL(*dataHandler, apInfo.iUID));
			}
		}
	CleanupStack::PopAndDestroy(dataHandler);
	RequestChangeNotification();	
	}
	
void CAccessPointMan::RemoveIAPL(CApDataHandler& aApHandler, TUint32 aUID)
	{
	aApHandler.RemoveAPL(aUID);
	}
	
void CAccessPointMan::LoadApnL(RArray<TApInfo>& aResult)
	{
	CApSelect* apSelect = CApSelect::NewLC(*iCommDB,KEApIspTypeAll,
										   EApBearerTypeGPRS|EApBearerTypeCDMA,
										   KEApSortUidAscending);
	
	CApDataHandler* dataHandler = CApDataHandler::NewLC(*iCommDB);	
	CApUtils* apUtils = CApUtils::NewLC(*iCommDB);
   	if(apSelect->MoveToFirst())
   		{
   		TApInfo apInfo;
   		TBuf<100> displayName;
       	do {
       	    apInfo.Reset();
       	    displayName.SetLength(0);
       		CApAccessPointItem* apItem = CApAccessPointItem::NewLC();       		
		    dataHandler->AccessPointDataL( apSelect->Uid(), *apItem);
		    
			//iap Id
			apInfo.iIapId = apUtils->IapIdFromWapIdL(apSelect->Uid());			
			//Connection Name
			XUtil::Copy(apInfo.iDisplayName, apItem->ConnectionName());				
			//Ap Name
			const HBufC* apName = apItem->ReadConstLongTextL(EApGprsAccessPointName);			
			if(apName)
				{
				TPtrC apNameDesC(*apName);
				XUtil::Copy(apInfo.iName, apNameDesC);
				}
			apItem->ReadBool(EApGprsIfPromptForAuth, apInfo.iPromptForAuth);
			//mark as selft created			
			//apInfo.iUID = apSelect->Uid();
			apInfo.iUID = apItem->WapUid();
			apInfo.iSelfCreated = iCreatedUidArray.Find(apInfo.iUID) != KErrNotFound;
			if(!apInfo.iPromptForAuth)
				{
				apItem->ReadBool(EApProxyUseProxy, apInfo.iProxyInfo.iUseProxy);
				if(apInfo.iProxyInfo.iUseProxy)
					{
					apItem->ReadUint(EApProxyPortNumber,apInfo.iProxyInfo.iPort);
					const HBufC* proxyAddr = apItem->ReadConstLongTextL(EApProxyServerAddress);
					if(proxyAddr)
						{
						TPtrC proxAddrX(*proxyAddr);						
						XUtil::Copy(apInfo.iProxyInfo.iAddr, proxAddrX);
						}
					}
				aResult.Append(apInfo);
				}
		  LOG6(_L("Internet: %d, iapId: %d, Uid: %d, iapName: %S, DisplayName: %S, iSelfCreated: %d"),apUtils->IAPExistsL(apSelect->Uid()), apInfo.iIapId , apSelect->Uid(), &apInfo.iName, &apInfo.iDisplayName, apInfo.iSelfCreated)
		  CleanupStack::PopAndDestroy();
       	  }
       	while(apSelect->MoveNext());
   		}
   	CleanupStack::PopAndDestroy(3);
   	LOG1(_L("[CAccessPointMan::LoadApnL] End, Count: %d"), iIapArray.Count())
	}
	
void CAccessPointMan::LoadApnL(RArray<TUint32>& aUIDArray)
	{
	CApSelect* apSelect = CApSelect::NewLC(*iCommDB,
										   KEApIspTypeAll,
										   EApBearerTypeGPRS|EApBearerTypeHSCSD|EApBearerTypeCDMA,//Excludes EApBearerTypeCSD
										   KEApSortUidAscending);
   	if(apSelect->MoveToFirst())
   		{
       	do {
       	   aUIDArray.Append(apSelect->Uid());		  
       	   }
       	while(apSelect->MoveNext());
   		}
   	CleanupStack::PopAndDestroy(1);	
	}
	
TInt CAccessPointMan::CountAP()
	{
	if(iFirstLoadDone)
		{
		return iIapArray.Count();	
		}
	return 0;
	}

RArray<TApInfo>& CAccessPointMan::AllAccessPoints()
	{
	return iIapArray;
	}

TBool CAccessPointMan::Equals(const RArray<TApInfo>& aFirstArray, const RArray<TApInfo>& aSecondArray)
	{
	TInt firstArrcount = aFirstArray.Count();
	if(firstArrcount == aSecondArray.Count())
		{
		for(TInt i=0;i<firstArrcount;i++)
			{
			const TApInfo& apInfo = aFirstArray[i];
			TInt posFound = aSecondArray.Find(apInfo,TIdentityRelation<TApInfo>(TApInfo::Match));
			if(posFound == KErrNotFound)
				{				
				return EFalse;
				}
			}
		return ETrue;
		}
	return EFalse;
	}

void CAccessPointMan::Copy(const RArray<TApInfo>& aSrc, RArray<TApInfo>& aDes)
	{
	for(TInt i=0;i<aSrc.Count();i++)
		{
		aDes.Append(aSrc[i]);
		}
	}

void CAccessPointMan::Copy(const RArray<TUint32>& aSrc, RArray<TUint32>& aDes)
	{
	for(TInt i=0;i<aSrc.Count();i++)
		{
		aDes.Append(aSrc[i]);
		}	
	}
	
TInt CAccessPointMan::Find(const TApInfo& aApInfo)
	{
	return iIapArray.Find(aApInfo,TIdentityRelation<TApInfo>(TApInfo::Match));
	}
	
TInt CAccessPointMan::Find(const TUint32 aIapId)
	{
	TApInfo apInfo;
	apInfo.iIapId = aIapId;
	return iIapArray.Find(apInfo,TIdentityRelation<TApInfo>(TApInfo::MatchId));
	}

void CAccessPointMan::GetInetAccessPoints(RArray<TApInfo>& aAccessPointArr)
	{
	for(TInt i=0;i<iIapArray.Count();i++ )
		{
		aAccessPointArr.Append(iIapArray[i]);		
		}
	}

void CAccessPointMan::GetSelfCreatedAccessPoints(RArray<TApInfo>& aAccessPointArr)
	{
	for(TInt i=0;i<iIapArray.Count();i++ )
		{
		const TApInfo& apInfo = iIapArray[i];
		if(apInfo.iSelfCreated)
			{
			aAccessPointArr.Append(apInfo);
			}
		}
	}

void CAccessPointMan::SetWorkingAccessPoints(const RArray<TApInfo>& aWorkingAP)
	{
	iWorkingAP.Reset();
	for(TInt i=0;i<aWorkingAP.Count();i++)
		{
		iWorkingAP.Append(aWorkingAP[i]);
		}
	}
	
const RArray<TApInfo>& CAccessPointMan::WorkingAccessPoints()
	{
	return iWorkingAP;	
	}

void CAccessPointMan::ResetWorkingAPN()
	{
	iWorkingAP.Reset();
	}

void CAccessPointMan::ResetAllAPN()
	{
	iIapArray.Reset();
	}
	
void CAccessPointMan::ExternalizeL(RWriteStream& aOut) const
	{
	TInt workingCount = iWorkingAP.Count();
	aOut.WriteInt32L(workingCount);
	//save to file
	for(TInt i=0;i<workingCount;i++)
		{
		const TApInfo& apInfo = iWorkingAP[i];
		aOut << apInfo;
		}	
	}
	
void CAccessPointMan::InternalizeL(RReadStream& aIn)
//at this point, all access points are not loaded yet
//consistency check must be done when they are loaded
//@see PerformFirstLoadL() method
	{
	iWorkingAP.Reset();
	TInt count = aIn.ReadInt32L();
	for(TInt i=0; i < count; i++)
		{
		TApInfo apInfo;
		aIn >> apInfo;
		if(apInfo.iIapId > 0)
			{
			iWorkingAP.Append(apInfo);	
			}		
		}
	}
	
void CAccessPointMan::DeleteZombieAPNL()
	{
	CCommsDatabase* db = CCommsDatabase::NewL(EDatabaseTypeIAP);
	CleanupStack::PushL(db);	
	CCommsDbTableView* table = db->OpenIAPTableViewMatchingBearerSetLC(ECommDbBearerUnknown|ECommDbBearerCSD|ECommDbBearerGPRS,ECommDbConnectionDirectionOutgoing);	
	if (table->GotoFirstRecord() == KErrNone) {	
		TPtrC commdbNameCol(COMMDB_NAME);
		TPtrC commdbIDCol(COMMDB_ID);
		TBuf<100> iapName;
		TUint32 iapId; 
		do {
			table->ReadTextL(commdbNameCol,iapName);
			table->ReadUintL(commdbIDCol, iapId);			
			
			LOG2(_L("[CAccessPointMan::DeleteZombieAPNL] iIapId[%d] COMMDB_NAME: %S"),iapId,&iapName)
			//table->DeleteRecord();
			//table->UpdateRecord();
		} while (table->GotoNextRecord() == KErrNone);
	}
	
	CleanupStack::PopAndDestroy(2);
	}
	
/////////////////// FOR DEBUG /////////////////// 
void CAccessPointMan::AddDummyWorkingAPL()
	{	
/*	TApInfo apInfo;
	apInfo.iIapId = 9;
	apInfo.iDisplayName = _L("Connection_1");
	apInfo.iName = _L("net_1");
	iWorkingAP.Append(apInfo);
	//apInfo.Reset();

	apInfo.iIapId = 10;
	apInfo.iDisplayName = _L("Connection_10");
	apInfo.iName = _L("net_10");
	iWorkingAP.Append(apInfo);
	//apInfo.Reset();
apInfo.iIapId = 11;
	apInfo.iDisplayName = _L("Connection_11");
	apInfo.iName = _L("net_11");
	iWorkingAP.Append(apInfo);
	//apInfo.Reset();

apInfo.iIapId = 12;
	apInfo.iDisplayName = _L("Connection_12");
	apInfo.iName = _L("net_12");
	iWorkingAP.Append(apInfo);
	//apInfo.Reset();

apInfo.iIapId = 13;
	apInfo.iDisplayName = _L("Connection_13");
	apInfo.iName = _L("net_13");
	iWorkingAP.Append(apInfo);
	//apInfo.Reset();

apInfo.iIapId = 140;
	apInfo.iDisplayName = _L("Connection_14");
	apInfo.iName = _L("net_14");
	iWorkingAP.Append(apInfo);
	//apInfo.Reset();

apInfo.iIapId = 15;
	apInfo.iDisplayName = _L("Connection_15");
	apInfo.iName = _L("net_15");
	iWorkingAP.Append(apInfo);
//apInfo.Reset();

apInfo.iIapId = 16;
	apInfo.iDisplayName = _L("Connection_16");
	apInfo.iName = _L("net_16");
	iWorkingAP.Append(apInfo);
//	apInfo.Reset();

apInfo.iIapId = 17;
	apInfo.iDisplayName = _L("Connection_17");
	apInfo.iName = _L("net_17");
	iWorkingAP.Append(apInfo);
	//apInfo.Reset();								

apInfo.iIapId = 18;
	apInfo.iDisplayName = _L("Connection_18");
	apInfo.iName = _L("net_18");
	iWorkingAP.Append(apInfo);
	//apInfo.Reset();								

apInfo.iIapId = 19;
	apInfo.iDisplayName = _L("Connection_19");
	apInfo.iName = _L("net_19");
	iWorkingAP.Append(apInfo);
	//apInfo.Reset();								

apInfo.iIapId = 20;
	apInfo.iDisplayName = _L("Connection_20");
	apInfo.iName = _L("net_20");
	iWorkingAP.Append(apInfo);
	//apInfo.Reset();

apInfo.iIapId = 21;
	apInfo.iDisplayName = _L("Connection_21");
	apInfo.iName = _L("net_21");
	iWorkingAP.Append(apInfo);
	//apInfo.Reset();								

apInfo.iIapId = 22;
	apInfo.iDisplayName = _L("Connection_22");
	apInfo.iName = _L("net_22");
	iWorkingAP.Append(apInfo);
	//apInfo.Reset();								

apInfo.iIapId = 23;
	apInfo.iDisplayName = _L("Connection_23");
	apInfo.iName = _L("net_23");
	iWorkingAP.Append(apInfo);
	//apInfo.Reset();								

apInfo.iIapId = 24;
	apInfo.iDisplayName = _L("Connection_24");
	apInfo.iName = _L("net_24");
	iWorkingAP.Append(apInfo);
	//apInfo.Reset();								
	*/
	}
