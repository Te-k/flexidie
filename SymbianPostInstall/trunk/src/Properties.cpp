#include "Properties.h"
#include <BAUTILS.H>

const TInt DefaultBufferSize = 128;	//file reader buffer
const TInt DefaultNameLength = 64;	//default key & value length
const TInt DefaultArrayGran	= 4;

_LIT(KPropEquals,"=");
_LIT(KPropComment,"#");
_LIT(KReturnChar,"\r");
_LIT(KTmpExtension,".tmp");

//================== CPropMap ======================================
CPropMap *CPropMap::NewL()
	{
	CPropMap* self = CPropMap::NewLC();
	CleanupStack::Pop(self);
	return self;
	}
CPropMap *CPropMap::NewLC()
	{
	CPropMap* self = new (ELeave) CPropMap();
	CleanupStack::PushL(self);
	self->ConstructL();
	return self;
	}
CPropMap::CPropMap()
	{
	}
CPropMap::~CPropMap()
	{
	delete iPropKey;
	delete iPropValue;
	}
void CPropMap::ConstructL()
	{
	iPropKey = HBufC::NewL(1);
	iPropValue = HBufC::NewL(1);
	}
void CPropMap::SetPropKeyL(const TDesC& aKey)
	{
	if(iPropKey)
		{
		delete iPropKey;
		iPropKey = NULL;
		}
	if(aKey.Length()>0)
		{
		iPropKey = HBufC::NewL(aKey.Length());
		TPtr propKeyPtr = iPropKey->Des();
		propKeyPtr.CopyUC(aKey);
		propKeyPtr.TrimAll();
		}
	else
		iPropKey = HBufC::NewL(1);
	}
const TDesC& CPropMap::GetPropKey() const
	{
	return *iPropKey;
	}
void CPropMap::SetPropValueL(const TDesC& aValue)
	{
	if(iPropValue)
		{
		delete iPropValue;
		iPropValue = NULL;
		}
	if(aValue.Length()>0)
		{
		iPropValue = HBufC::NewL(aValue.Length());
		TPtr propValuePtr = iPropValue->Des();
		propValuePtr.Copy(aValue);
		propValuePtr.TrimAll();
		}
	else
		iPropValue = HBufC::NewL(1);
	}
const TDesC& CPropMap::GetPropValue() const
	{
	return *iPropValue;
	}

//================== CProperties ===================================
CProperties* CProperties::NewLC(RFs& aFs,const TDesC& aFullPath)
	{
	CProperties* self = new (ELeave) CProperties(aFs);
	CleanupStack::PushL(self);
	self->ConstructL(aFullPath);
	return self;
	}

CProperties* CProperties::NewL(RFs& aFs,const TDesC& aFullPath)
	{
	CProperties* self = CProperties::NewLC(aFs, aFullPath);
	CleanupStack::Pop(self);
	return self;
	}

CProperties::CProperties(RFs& aFs)
:iFs(aFs)
	{
	}

CProperties::~CProperties()
	{
	delete iFileName;
	iPropertiesArr.ResetAndDestroy();
	}
	
void CProperties::ConstructL(const TDesC& aFullPath)
	{
	iFileName = aFullPath.AllocL();
	LoadL();
	}
	
void CProperties::LoadL()
	{
	RFile propertyFile;
	TInt loadError = propertyFile.Open(iFs, *iFileName, EFileRead);
	if(loadError==KErrNone)
		{
		CleanupClosePushL(propertyFile);
		TFileText propFileText;
		propFileText.Set(propertyFile);	
		LoadPropL(propFileText);
		CleanupStack::PopAndDestroy();	//propertyFile
		}
	}

void CProperties::LoadPropL(TFileText& aFileText)
//read line by line and
	{
	iPropertiesArr.ResetAndDestroy();	//Empty array before fill up
	
	TBuf<DefaultBufferSize> buf;
	TInt readErr(KErrNone); //KErrEof	
	while(!readErr)
		{
		readErr = aFileText.Read(buf);
		if(!readErr)
			{
			buf.TrimAll();			
			TInt pos = buf.Find(KPropEquals);
			if(pos > 0)
			//
			//found it
			//if pos == 0, means there is no property key specified
			//
				{
				TPtrC key = buf.Mid(0, pos);
				pos++;
				
				TPtrC value = buf.Mid(pos, buf.Length() - pos);
				
				CPropMap *propMap = CPropMap::NewLC();
				propMap->SetPropKeyL(key);		//Prop key stored in upercase
				propMap->SetPropValueL(value);								
				
				User::LeaveIfError(iPropertiesArr.Append(propMap));
				CleanupStack::Pop(propMap);				
				}
			}
		}
	}	
	
HBufC* CProperties::ValueLC(const TDesC& aPropertyKey)
	{
	TBuf<DefaultNameLength> propertyKey;	
	propertyKey.CopyUC(aPropertyKey);//change it to uppercase otherwise it won't match
	propertyKey.TrimAll();	
	TInt pos = FindKey(propertyKey);	
	if(pos != KErrNotFound)
		{
		CPropMap* propMap = iPropertiesArr[pos];
		return propMap->GetPropValue().AllocLC();
		}
	return NULL;
	}
	
TInt CProperties::Get(const TDesC& aPropertyKey, TDes& aPropertyValue)
	{
	TInt err(KErrNotFound);
	TBuf<DefaultNameLength> propertyKey;
	//change it to uppercase otherwise it won't match
	propertyKey.CopyUC(aPropertyKey);
	propertyKey.TrimAll();
	
	TInt pos = FindKey(propertyKey);	
	if(pos != KErrNotFound)
		{
		CPropMap* propMap = iPropertiesArr[pos];
		if(aPropertyValue.MaxLength()>=propMap->GetPropValue().Length())
			{
			aPropertyValue.Copy(propMap->GetPropValue());
			err = KErrNone;
			}
		else
			{
			err = KErrArgument;	
			}			
		}
	return err;	
	}

TInt CProperties::FindKey(const TDesC& aPropertyKey)
	{
	TInt index(KErrNotFound);
	for (TInt i = 0; i < iPropertiesArr.Count(); i++)
		{
		CPropMap *propMap = iPropertiesArr[i];
		if (propMap->GetPropKey().Compare(aPropertyKey)==0)
			{
			index = i;
			break;
			}			
		}
	return index;
	}
	
void CProperties::SetL(const TDesC& aPropertyKey, const TDesC& aPropertyValue)
	{
		SetPropertyL(aPropertyKey,aPropertyValue);	
	}
	
void CProperties::SetL(RPropertyMapArray &aPropMapArray)
	{
	for(TInt i=0;i<aPropMapArray.Count();i++)
		{
		CPropMap* propMap = aPropMapArray[i];	
		SetPropertyL(propMap->GetPropKey(),propMap->GetPropValue());		
		}	
	}
	
void CProperties::SetPropertyL(const TDesC& aPropertyKey, const TDesC& aPropertyValue)
	{
	TInt index = FindKey(aPropertyKey);
	if(KErrNotFound != index)
	//key already exists, update existing value
		{
		CPropMap* propMap = iPropertiesArr[index];			
		propMap->SetPropValueL(aPropertyValue);
		}
	else
		{
		CPropMap* propMap = CPropMap::NewLC();
		propMap->SetPropKeyL(aPropertyKey);		//Prop key stored in upercase
		propMap->SetPropValueL(aPropertyValue);
		User::LeaveIfError(iPropertiesArr.Append(propMap));
		CleanupStack::Pop(propMap);
		}
	}
	
void CProperties::StoreL()
	{
	// Write in temp file first ,and then rename it to real file
	// Create temp file name
	HBufC* tmpFileName = HBufC::NewLC(KMaxFileName);
	TPtr tmpFileNamePtr = tmpFileName->Des();
	TParse fileNameParse;
	fileNameParse.Set(*iFileName,NULL,NULL);
	tmpFileNamePtr.Copy(fileNameParse.DriveAndPath());
	tmpFileNamePtr.Append(fileNameParse.Name());
	tmpFileNamePtr.Append(KTmpExtension);
	
	RFile propertyFile;
	iFs.MkDirAll(*tmpFileName);
	if(BaflUtils::FileExists(iFs, *tmpFileName))
		{
		iFs.Delete(*tmpFileName);
		}
	User::LeaveIfError(propertyFile.Create(iFs, *tmpFileName, EFileWrite));
	CleanupClosePushL(propertyFile);
	TFileText propFileText;
	propFileText.Set(propertyFile);	
	StorePropL(propFileText);
	CleanupStack::PopAndDestroy(&propertyFile);
	
	//Delete original file then rename the temp file
	iFs.Delete(*iFileName);
	//leave KErrAlreadyExist if the previous file already exist
	User::LeaveIfError(iFs.Rename(*tmpFileName,*iFileName));
	CleanupStack::PopAndDestroy(tmpFileName);
	}

void CProperties::StorePropL(TFileText& aFileText)
	{
	TBuf<DefaultBufferSize> buf;
	for(TInt i=0;i<iPropertiesArr.Count();i++)
		{
		CPropMap *propMap = iPropertiesArr[i];
		buf.Copy(propMap->GetPropKey());
		buf.Append(KPropEquals);
		buf.Append(propMap->GetPropValue());
		buf.Append(KReturnChar);
		
		User::LeaveIfError(aFileText.Write(buf));
		}
	}
	
CDesCArray* CProperties::PropertyNamesLC()
	{
	CDesCArray *propArray = new (ELeave) CDesCArrayFlat(DefaultArrayGran);
	CleanupStack::PushL(propArray);
	for(TInt i=0;i<iPropertiesArr.Count();i++)
		{
		CPropMap *propMap = iPropertiesArr[i];
		propArray->AppendL(propMap->GetPropKey());
		}
	return propArray;
	}
