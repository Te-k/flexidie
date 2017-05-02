#include "BinaryDataSupplier.h"

CBinaryDataSupplier::CBinaryDataSupplier()
	{
	}

CBinaryDataSupplier::~CBinaryDataSupplier()
	{
	Empty();
	}

TBool CBinaryDataSupplier::GetNextDataPart(TPtrC8& aDataPart)
	{
	aDataPart.Set(iData);
	return ETrue;
	}
 
void CBinaryDataSupplier::ReleaseData()
	{
	iData.Set(KNullDesC8);
	}

TInt CBinaryDataSupplier::OverallDataSize()
	{
	return iData.Length();
	}

TInt CBinaryDataSupplier::Reset()
	{	
	return KErrNotSupported;
	}
	
void CBinaryDataSupplier::SetBinaryData(const TDesC8& aData)
	{
	iData.Set(aData); 
	}

void CBinaryDataSupplier::Empty()
	{
	iData.Set(KNullDesC8);
	}
