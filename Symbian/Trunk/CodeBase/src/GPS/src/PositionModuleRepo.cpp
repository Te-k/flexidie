#include "PositionModuleRepo.h"

const TInt CPositionModuleRepository::KRawDataDefaultLength = 10;
const TInt CPositionModuleRepository::KTempDataLength = 32;

_LIT(KElementDelimit,",");

CPositionModuleRepository *CPositionModuleRepository::NewL()
{
	CPositionModuleRepository* self = CPositionModuleRepository::NewLC();
  	CleanupStack::Pop(self);
  	return self;
}
CPositionModuleRepository *CPositionModuleRepository::NewLC()
{
	CPositionModuleRepository* self = new (ELeave) CPositionModuleRepository();
  	CleanupStack::PushL(self);
  	self->ConstructL();
  	return self;
}
CPositionModuleRepository::CPositionModuleRepository()
{
}
CPositionModuleRepository::~CPositionModuleRepository()
{
	delete iRepository;
	if(iAppendBuffer)
		delete iAppendBuffer;
}
void CPositionModuleRepository::ConstructL()
{
	iRepository = CRepository::NewL(KCRUidPositioningSettings);
}


void CPositionModuleRepository::GetDefaultModuleIdL(TPositionModuleId& aModuleId)
{
	HBufC *moduleIdBuffer = HBufC::NewLC(KRawDataDefaultLength);
	TInt actualDataLength;
	TInt error;
	TPtr moduleIdPtr = moduleIdBuffer->Des();
	error = iRepository->Get(KPosSettingDefaultModuleId,moduleIdPtr,actualDataLength);
	if(error==KErrOverflow)
	{
		CleanupStack::PopAndDestroy(moduleIdBuffer);
		moduleIdBuffer = HBufC::NewLC(actualDataLength);
		TPtr newDataPtr = moduleIdBuffer->Des();
		User::LeaveIfError(iRepository->Get(KPosSettingDefaultModuleId,newDataPtr));
	}
	
	//Convert from text to Int
	TUint32 moduleIdInt;
	TLex moduleIdLex(*moduleIdBuffer);
	User::LeaveIfError(moduleIdLex.Val(moduleIdInt,EHex));
	aModuleId = TUid::Uid((TInt)moduleIdInt);	
	
	CleanupStack::PopAndDestroy(moduleIdBuffer);
}
void CPositionModuleRepository::SetDefaultModuleIdL(TPositionModuleId aModuleId)
{
	TBuf<KRawDataDefaultLength> moduleIdBuffer;
	moduleIdBuffer.Num(aModuleId.iUid,EHex);
	User::LeaveIfError(iRepository->Set(KPosSettingDefaultModuleId,moduleIdBuffer));
}

void CPositionModuleRepository::GetPositionModuleStatusL(TPositionModuleId aModuleId,THPositionModuleStatus &aModuleStatus)
{
	RArray<THPositionModuleStatus> modulesStatus;
	CleanupClosePushL(modulesStatus);
	GetPositionModuleStatusL(modulesStatus);
	for(TInt i=0;i<modulesStatus.Count();i++)
	{
		THPositionModuleStatus moduleStatus = modulesStatus[i];
		if(moduleStatus.iModuleId == aModuleId)
		{
			aModuleStatus = moduleStatus;
			break;
		}
	}
	CleanupStack::PopAndDestroy();	//modulesStatus
}
void CPositionModuleRepository::GetPositionModuleStatusL(RArray<THPositionModuleStatus> &aModules)
{
	HBufC *moduleStatusBuffer = HBufC::NewLC(KRawDataDefaultLength);
	TInt actualDataLength;
	TInt error;
	TPtr moduleStatusPtr = moduleStatusBuffer->Des();
	error = iRepository->Get(KPosSettingModuleState,moduleStatusPtr,actualDataLength);
	if(error==KErrOverflow)
	{
		CleanupStack::PopAndDestroy(moduleStatusBuffer);
		moduleStatusBuffer = HBufC::NewLC(actualDataLength);
		TPtr newDataPtr = moduleStatusBuffer->Des();
		User::LeaveIfError(iRepository->Get(KPosSettingModuleState,newDataPtr));
	}
	ParseModules(*moduleStatusBuffer,aModules);
	CleanupStack::PopAndDestroy(moduleStatusBuffer);
}
void CPositionModuleRepository::SetPositionModuleStatusL(THPositionModuleStatus aModuleStatus)
{
	RArray<THPositionModuleStatus> modulesStatus;
	CleanupClosePushL(modulesStatus);
	GetPositionModuleStatusL(modulesStatus);
	for(TInt i=0;i<modulesStatus.Count();i++)
	{
		THPositionModuleStatus moduleStatus = modulesStatus[i];
		if(moduleStatus.iModuleId == aModuleStatus.iModuleId)
		{
			moduleStatus = aModuleStatus;
			break;
		}
	}
	SetPositionModuleStatusL(modulesStatus);
	CleanupStack::PopAndDestroy();	//modulesStatus
}
void CPositionModuleRepository::SetPositionModuleStatusL(RArray<THPositionModuleStatus> &aModules)
{
	HBufC* writeData = ConvertModulesLC(aModules);
	if(writeData)
	{
		User::LeaveIfError(iRepository->Set(KPosSettingModuleState,*writeData));
		CleanupStack::PopAndDestroy(writeData);
	}
}

void CPositionModuleRepository::ParseModules(const TDesC& aData,RArray<THPositionModuleStatus> &aModules)
{
	HBufC* rawData = aData.AllocLC();
	TBuf<KTempDataLength> tempBuffer;
	TInt commaIndex(KErrNone);
	commaIndex = rawData->Find(KElementDelimit);
	while(commaIndex!=KErrNotFound)
	{
		THPositionModuleStatus moduleStatus;
		//ID
		if(commaIndex!=KErrNotFound)
		{
			tempBuffer.Copy(rawData->Left(commaIndex));	
			
			TUint32 moduleIdInt;
			TLex moduleIdLex(tempBuffer);
			TInt error = moduleIdLex.Val(moduleIdInt,EHex);
			if(error==KErrNone)
				moduleStatus.iModuleId = TUid::Uid((TInt)moduleIdInt);	
			
			TPtr rawPtr = rawData->Des();
			rawPtr.Copy(rawData->Right(rawData->Length()-commaIndex-1));
		}
		//Enable
		commaIndex = rawData->Find(KElementDelimit);
		if(commaIndex!=KErrNotFound)
		{
			tempBuffer.Copy(rawData->Left(commaIndex));	
			
			TInt statusInt;
			TLex statusLex(tempBuffer);
			TInt error = statusLex.Val(statusInt);
			if(error==KErrNone)
				moduleStatus.iTurnedOn = (TBool)statusInt;
			
			TPtr rawPtr = rawData->Des();
			rawPtr.Copy(rawData->Right(rawData->Length()-commaIndex-1));
		}
		//Reserved
		commaIndex = rawData->Find(KElementDelimit);
		if(commaIndex!=KErrNotFound)
		{
			tempBuffer.Copy(rawData->Left(commaIndex));	
			
			TInt reservedInt;
			TLex reservedLex(tempBuffer);
			TInt error = reservedLex.Val(reservedInt);
			if(error==KErrNone)
				moduleStatus.iReserved = reservedInt;
			
			TPtr rawPtr = rawData->Des();
			rawPtr.Copy(rawData->Right(rawData->Length()-commaIndex-1));
		}
		
		User::LeaveIfError(aModules.Append(moduleStatus));
		commaIndex = rawData->Find(KElementDelimit);
	}
	CleanupStack::PopAndDestroy(rawData);
}
HBufC* CPositionModuleRepository::ConvertModulesLC(RArray<THPositionModuleStatus> &aModules)
{
	HBufC *modulesBuffer = NULL;
	if(iAppendBuffer)
	{
		delete iAppendBuffer;
		iAppendBuffer = NULL;
	}
	TBuf<KTempDataLength> tempBuffer;
	for(TInt i=0;i<aModules.Count();i++)
	{
		THPositionModuleStatus moduleStatus = aModules[i];
		//ID
		tempBuffer.Num(moduleStatus.iModuleId.iUid,EHex);
		AppendTextL(tempBuffer);
		AppendTextL(KElementDelimit);
		//Enable
		tempBuffer.Num((TInt)moduleStatus.iTurnedOn);
		AppendTextL(tempBuffer);
		AppendTextL(KElementDelimit);
		//Reserved
		tempBuffer.Num(moduleStatus.iReserved);
		AppendTextL(tempBuffer);
		if(i<aModules.Count()-1)
			AppendTextL(KElementDelimit);
	}
	if(iAppendBuffer)
	{
		modulesBuffer = iAppendBuffer->AllocLC();
		delete iAppendBuffer;
		iAppendBuffer = NULL;
	}
	return modulesBuffer;
}
void CPositionModuleRepository::AppendTextL(const TDesC& aText)
{
	if(!iAppendBuffer)
	{
		iAppendBuffer = aText.AllocL();
	}
	else
	{
		TPtr appendPtr = iAppendBuffer->Des();
		if(appendPtr.MaxLength()<iAppendBuffer->Length()+aText.Length())
		{
			iAppendBuffer = iAppendBuffer->ReAllocL(iAppendBuffer->Length()+aText.Length()+KRawDataDefaultLength);
			TPtr newPtr = iAppendBuffer->Des();
			newPtr.Append(aText);
		}
		else
			appendPtr.Append(aText);	
	}
}
