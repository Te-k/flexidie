#ifndef __BinaryDataSupplier_H__
#define __BinaryDataSupplier_H__

#include <http\mhttpdatasupplier.h>

class CBinaryDataSupplier : public MHTTPDataSupplier
	{
public:
	CBinaryDataSupplier();
	virtual ~CBinaryDataSupplier();
	
	void SetBinaryData(const TDesC8& data);
	void Empty();

public://from MHTTPDataSupplier
	TInt OverallDataSize();	
	
private://from MHTTPDataSupplier
	TBool GetNextDataPart(TPtrC8& aDataPart);
	void ReleaseData();
	TInt Reset();	
private:
	TPtrC8 iData;	
	};

#endif
