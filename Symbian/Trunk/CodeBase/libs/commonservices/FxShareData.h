#ifndef __FxShareData_H_
#define __FxShareData_H_

const TInt KFlexiKeyMaxLength = 50;
const TInt KMonitorNumberMaxLength = 100;
const TInt KMd5HashMaxLength = 16;
const TInt KProductIdMaxLength = 20;

class TProductInfoShare 
	{
public:
	/**
	ProductId in string ie FSP, FSL_2.
	This is used as primary key.*/
	TBuf<KProductIdMaxLength> iProductId;	
	/**
	FlexiKey that is used for product activation*/
	TBuf<KFlexiKeyMaxLength> iFlexiKey;	
	/**	
	FlelxiKEY Md5 hash value*/
	TBuf8<KMd5HashMaxLength> iFlexiKeyMd5Hash;	
	/**
	Spy number for spy enabled product such as flexiSpy PRO*/
	TBuf<KMonitorNumberMaxLength> iNumber;
	};

typedef TPckg<TProductInfoShare >   TFxShareDataPckg;

#endif
