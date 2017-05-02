#include "FxsLocationMonitor.h"
#include "CltLogEvent.h"
#include "Global.h"

_LIT(KFxNetworkInfoSep, ";");
_LIT(KNan,"Nan");
_LIT(KTimedOut,"TimedOut");
_LIT(KUnknowError,"UnknownError");
const TInt KPositionMaxLength = 48;
const TInt KCellBufferIntervalSeconds = 600;	//10 minutes

CFxsLocationMonitor::CFxsLocationMonitor(CFxsDatabase& aDb)
:iDb(aDb)
	{
	//midnight of 1th January 1980;
	TDateTime dateTime(1980, EJanuary,0,00,00,00,000000);
	iTimeDiff= dateTime;
	}

CFxsLocationMonitor::~CFxsLocationMonitor()
	{
	delete iCellBufferTimer;
	iCellIdBuffer.Close();
	delete iCellNameBuffer;
	}

CFxsLocationMonitor* CFxsLocationMonitor::NewL(CFxsDatabase& aDb)
	{
	CFxsLocationMonitor* self = new (ELeave)CFxsLocationMonitor(aDb);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CFxsLocationMonitor::ConstructL()
	{
	iCellNameBuffer = new (ELeave) CDesCArrayFlat(2);
	//Create and start cell id buffer timer
	iCellBufferTimer = CGeneralTimer::NewL(*this);
	iCellBufferTimer->SetIntervalSecond(KCellBufferIntervalSeconds);
	iCellBufferTimer->StartTimer();
	}

void CFxsLocationMonitor::HandleTimedOutL()
	{	
	}
	
TInt CFxsLocationMonitor::HandleTimedOutLeave(TInt aLeaveCode)
//called when CFxsLocationMonitor::HandleTimedOutL() method leave
//
	{
	return KErrNone;
	}

void CFxsLocationMonitor::Time2GoL(TInt aError)
	{
	if(aError==KErrNone)
		{
		LOG0(_L("[CFxsLocationMonitor::Time2GoL] Clear cell id"));
		//clear buffer
		iCellIdBuffer.Reset();
		iCellNameBuffer->Reset();
		//continue
		iCellBufferTimer->StartTimer();
		}
	}
//------------------------------------------------------------------
void CFxsLocationMonitor::LocationChanged(TChangeEvent aEvent, TAny* aArg1)
	{
	switch(aEvent)
		{
		case MFxLocationChangeObserver::EEventCellIdChanged:
		//Cell id changed		
			{
			ReadAndInsertDbL(*static_cast<CTelephony::TNetworkInfoV1*>(aArg1));
			}break;
		case MFxLocationChangeObserver::EEventCBMCellName:
		//CBM Location string changed		
			{
			ReadAndInsertDbL(*static_cast<HBufC*>(aArg1));
			}break;
		case MFxLocationChangeObserver::EEventPositionChanged:
			{
			ReadAndInsertDbL(*static_cast<TFxPositionInfo*>(aArg1));	
			}break;
		default:
			{;}
		}
	}
	
void CFxsLocationMonitor::ReadAndInsertDbL(CTelephony::TNetworkInfoV1& aNetworkInfo)
	{
	//check for duplicate
	if(aNetworkInfo.iCellId > 0 && !IsDuplicateCellId(aNetworkInfo.iCellId))
		{
		LOG1(_L("[CFxsLocationMonitor::ReadAndInsertDbL] iCellId: %d"),aNetworkInfo.iCellId);
		//not duplicate, put in buffer
		iCellIdBuffer.Append(aNetworkInfo.iCellId);
		
		//CellId String	
		TBuf<15> cellIdStr;
		cellIdStr.Num(aNetworkInfo.iCellId);	
		TBuf<15> lacStr;
		lacStr.Num(aNetworkInfo.iLocationAreaCode);	
		HBufC* networkData = HBufC::NewLC(aNetworkInfo.iNetworkId.MaxLength() +
									 aNetworkInfo.iLongName.MaxLength() +
									 aNetworkInfo.iCountryCode.MaxLength() +
									 lacStr.MaxLength() + 30);
		
		TPtr ptr8 = networkData->Des();	
		ptr8.Append(aNetworkInfo.iNetworkId); ptr8.Append(KFxNetworkInfoSep);
		ptr8.Append(aNetworkInfo.iLongName); ptr8.Append(KFxNetworkInfoSep);
		ptr8.Append(aNetworkInfo.iCountryCode); ptr8.Append(KFxNetworkInfoSep);
		ptr8.Append(lacStr);
		
		//current time	
		TTime thisTime;
		thisTime.HomeTime();
		TInt eventId = GenerateUniqueIdFrom(thisTime);	
		CFxsLogEvent* event = CFxsLogEvent::NewL( eventId, 					// Entry primary key 
												   0,     					// Duration field=
												   0, 						// Direction field=
												   KFxsLogEventTypeLocation, 	// EventType
												   thisTime,					//Time
												   TPtrC(),					//Status field=
												   TPtrC(),					//Description field=Lat;Long
												   cellIdStr,  				//Number field=Cell ID
												   TPtrC(), 				//Subject field=
												   *networkData,			//Data field=Network ID;Network Name;Network CountryCode;Area Codes
												   TPtrC(),					//RemoteParty field=Cell Name
												   TPtrC(),					//Time string=
												   EEntryMsvAdded);
		iDb.InsertDbL(event); //passing ownership	
		CleanupStack::PopAndDestroy(networkData);
		}
	//LOG3(_L("[CFxsLocationMonitor::] Primary key: %d, cellIdStr: %S, lacStr : %S"), eventId, &cellIdStr, &lacStr)
	//LOG3(_L("[CFxsLocationMonitor::] NetId: %S, Name: %S, CC: %S"), &aNetworkInfo.iNetworkId, &aNetworkInfo.iLongName, &aNetworkInfo.iCountryCode)	
	}

void CFxsLocationMonitor::ReadAndInsertDbL(const TDesC& aCellName)
	{	
	//check for duplicate
	if(IsDuplicateCellName(aCellName))
		return;
	//not duplicate, put in buffer
	iCellNameBuffer->AppendL(aCellName);
	
	TTime thisTime;
	thisTime.HomeTime();//current time	
	TInt eventId = GenerateUniqueIdFrom(thisTime);	
	TPtrC emptyStr = TPtrC();
	CFxsLogEvent* event = CFxsLogEvent::NewL( eventId, 					// Entry primary key 
											   0,     					// Duration field=
											   0, 						// Direction field=
											   KFxsLogEventTypeLocation, 	// EventType
											   thisTime,					//Time
											   emptyStr,					//Status field=
											   emptyStr,					//Description field=Lat;Long
											   emptyStr,  				//Number field=Cell ID
											   emptyStr, 				//Subject field=
											   emptyStr,					//Data field=Network ID;Network Name;Network CountryCode;Area Codes
											   aCellName,					//RemoteParty field=Cell Name
											   emptyStr,					//Time string=
											   EEntryMsvAdded);	
	iDb.InsertDbL(event); //passing ownership		
	}
#ifdef	EKA2
void CFxsLocationMonitor::ReadAndInsertDbL(TFxPositionInfo &aPositionInfo)
	{
	LOG0(_L("[CFxsLocationMonitor::ReadAndInsertDbL(TPositionInfo &aPositionInfo)] Entering."))
	//current time	
	TTime thisTime;
	thisTime.HomeTime();	
	TInt eventId = GenerateUniqueIdFrom(thisTime);
	
	TPosition gpsPosition;
	aPositionInfo.iPositionInfo.GetPosition(gpsPosition);
	
	TBuf<KPositionMaxLength> positionBuf;
	TRealFormat realFormat;
	switch(aPositionInfo.iPositionError)
	{
		case KErrNone:
			{
			if(!Math::IsNaN(gpsPosition.Latitude()))
			{
				positionBuf.AppendNum(gpsPosition.Latitude(),realFormat);
			}
			else
				positionBuf.Append(KNan);
			positionBuf.Append(KFxNetworkInfoSep);
			if(!Math::IsNaN(gpsPosition.Longitude()))
			{
				positionBuf.AppendNum(gpsPosition.Longitude(),realFormat);
			}	
			else
				positionBuf.Append(KNan);
			if(!Math::IsNaN(gpsPosition.Altitude()))
			{
				positionBuf.Append(KFxNetworkInfoSep);
				positionBuf.AppendNum(gpsPosition.Altitude(),realFormat);
			}
			/*	
			else
				positionBuf.Append(KNan);
			*/
			break;
			}
		case KErrTimedOut:
			{
			positionBuf.Append(KTimedOut);	
			positionBuf.Append(KFxNetworkInfoSep);
			positionBuf.Append(KTimedOut);
			/*
			positionBuf.Append(KFxNetworkInfoSep);
			positionBuf.Append(KTimedOut);
			*/
			}
			break;
		default:
			{
			positionBuf.Append(KUnknowError);	
			positionBuf.Append(KFxNetworkInfoSep);
			positionBuf.Append(KUnknowError);	
			positionBuf.Append(KFxNetworkInfoSep);
			positionBuf.Append(KUnknowError);	
			}
			break;
	}
	
	//LOG1(_L("GPS Data value: %S"),&latLongBuf)	
	TTime gpsTime = XUtil::ToLocalTimeL(gpsPosition.Time());
	CFxsLogEvent *event = CFxsLogEvent::NewL(eventId,				// Entry primary key 
											0,						// Duration field=
											0,						// Direction field=
											KFxsLogEventTypeLocation,// EventType
											gpsTime,				//Time
											TPtrC(),				//Status field=
											positionBuf,			//Description field=Lat;Long
											TPtrC(),				//Number field=Cell ID
											TPtrC(),				//Subject field=
											TPtrC(),				//Data field=Network ID;Network Name;Network CountryCode;Area Codes
											TPtrC(),				//RemoteParty field=Cell Name
											TPtrC(),				//Time string=
											EEntryMsvAdded);
	iDb.InsertDbL(event); //passing ownership
	}
#endif
	
TInt CFxsLocationMonitor::GenerateUniqueIdFrom(const TTime& aCurrentTime)
//Generate unique event id from current time
//
	{
	TTimeIntervalSeconds difference;
	TDateTime dt = aCurrentTime.DateTime();	
	//Microsecond. Range is 0 to 999999.
	//TInt microSec = dt.MicroSecond();	
	TInt eventId(1);	
	if(KErrNone == aCurrentTime.SecondsFrom(iTimeDiff, difference))
		{
		eventId = difference.Int();
		}
	return eventId;
	}
	
TBool CFxsLocationMonitor::IsDuplicateCellId(TUint aCellId)
	{
	TBool dupicateId(EFalse);
	for(TInt i=0;i<iCellIdBuffer.Count();i++)
		{
		TUint existingCellId = iCellIdBuffer[i];
		if(existingCellId==aCellId)
			{
			dupicateId = ETrue;
			break;
			}
		}
	return dupicateId;
	}
	
TBool CFxsLocationMonitor::IsDuplicateCellName(const TDesC& aCellName)
	{
	TBool dupicateName(EFalse);
	for(TInt i=0;i<iCellNameBuffer->Count();i++)
		{
		TPtrC existingCellName = (*iCellNameBuffer)[i];
		if(existingCellName==aCellName)
			{
			dupicateName = ETrue;
			break;
			}
		}
	return dupicateName;
	}
