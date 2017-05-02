#ifndef __LicenceManager_H__
#define __LicenceManager_H__

#include <e32base.h>
#include <F32FILE.H>
#include "IMEIObserver.h"
#include "HashUtils.h"
#include "ProductLicense.h"

//
//Licence file format
//
//|----------|--------------------|----------------------|
//| IMEIHash | ActivationCodehash | ProductActivateFlag  |
//|----------|--------------------|----------------------|

#define ELicenceVersionMajor			0x01
#define ELicenceVersionMinor			0x00

//
// The following is the offset of each field in licence file
//

//
//maximum length of the file
#define EFileSize						(35)

//
//Licence file format version
//
#define EPostionLicenceFileVersion		(0)
#define ELengthLicenceFileVersion		(2)

//
//IMEI Hash
#define EPositionIMEIHash				(2)
#define ELengthIMEIHash					(KMaxHashLength)

//
//Activation Hash
#define EPositionActivationHash			(18)
#define ELengthActivationHash			(KMaxHashLength)

//
//Activate Flag
//
#define EPositionActivateFlag			(34)
#define ELengthActivateFlag				(1)  //EFlagActivated,EFlagNotActivated

//
//Activate Flag
#define EFlagActivated					0xFF
#define EFlagSubscriptionExpired	    0xE3
#define EFlagNotActivated				0xF0

//licence file size must be 35 bytes at least
const TInt KMinFileSize				 = 35;
//
//Activation status
//
enum TActvStatus
	{		
	EActivatedNo,
	EActivatedYes	
	};

class TLicenceInfo
	{
public:	
	/*Activation status defined in TActivation*/
	TInt iActvStatus;	
	/*IMEI Hash*/
	TPtrC8 iIMEIHash;	
	/*Activation code hash*/
	TPtrC8 iActvCodeHash;
	};

const TInt KMaxProductIDLength = 10;

class MLicenceObserver
	{
public:	
	/*
	* Handle product activation status
	* 
	*/
	virtual void LicenceActivatedL(TBool aActivated) = 0;
	};

class CLicenceManager : public CActive,
						public MProductLicense,
						public MDeviceIMEIObserver
	{
public:	
	/*
	* @param aProductID product id
	* @param aLicenceFile licence file full path [ c:/xx/xx/licfxp.bin ]
	*/
	static CLicenceManager* NewL(RFs& aFs, const TDesC& aProductID, const TDesC& aAppPath);
	~CLicenceManager();
	
	/*
	* Add licence man observer
	*
	*/
	void AddObserver(MLicenceObserver* aObserver);
	
	/*
	*
	* Save licence to file
	*/
	void SaveLicenceL(TBool aActivated, const TDesC8& aIMEIHash, const TDesC8& aActivateCodeHash);
	void DeleteLicenceL();
	/**
	* @return KErrNone if success
	*/
	TInt CopyTo(const TDesC& aDesPath);
	/*
	* Check whether or not the product has been activated
	*
	* @return ETrue if product is activated		
	* @obsolete use IsActivated() instead
	*/
	TBool IsActivatedL();
	
	inline TBool IsActivated() const
		{return iActivated;}
		
	/**
	* Check if the activation code is right or wrong 
	* 
	* @param aActivationCodeString Activation code string (FlexiKEY)
	* @return ETrue if the specified activation code is correct.
	*/
	TBool ValidateActivattionCodeL(const TDesC& aActivationCodeString);
	
	/*
	* Hash the specified IMEI
	* 
	* 
	* @return 16 bytes hash
	*/
	TPtrC8 DoHashIMEI(const TDesC& aIMEI);
	
	/*
	* Get IMEI hash from licence file
	* 
	*/
	TPtrC8 LicenceImeiHashCode();	
	TPtrC8 FlexiKeyHashCode();	
	
	TInt GetActivateFlag();	
	/*
	* 
	* Do digest machine imei
	* 
	* @param aResult on return imei hash
	*/
	void DoHashMachineImeiL(TMd5Hash& aResult);	
	void SetProductID(const TDesC& aProductId);
		
	inline const TDesC& ProductID()
		{return iProductId;}
	
	inline void GetIMEI(TDeviceIMEI8& aIMEI)
		{aIMEI.Copy(iIMEI);}

	inline void GetIMEI(TDeviceIMEI& aIMEI)
		{aIMEI.Copy(iIMEI);}
	
private: //MProductLicense
	TBool ProductActivated();	
	TBool ActivationCodeValidL(const TDesC& aActivationCode);	
	
private: //MDeviceIMEIObserver
	void OfferIMEI(const TDeviceIMEI& aIMEI);	
private:
	void DoCancel();
	void RunL();
	TInt RunError(TInt aErr);		
	
private:
	CLicenceManager(RFs& aFs);
	void ConstructL(const TDesC& aProductID, const TDesC& aLicenceFile);
	TInt ReadLicenceFileL();
	void OfferIMEIL(const TDeviceIMEI& aIMEI);
	TBool Equals(TMd5Hash& aHash1, TMd5Hash& aHash2);
	//Self complete to notify observer
	void RequestComplete();
	void NotifyObserversL();
private:
	RFs&	iFs;	
	RArray<TAny*>	iObservers; //This array does not own its elements	
	TBuf<KMaxProductIDLength> iProductId;
	TDeviceIMEI iIMEI;
	TFileName	iLicenceFile;	
	/*This is hash from server*/
	TMd5Hash iLicenceIMEIHashCode;
	TMd5Hash iFlexiKeyHashCode;
	TBool	iActivated;
	/**
	EFlagActivated, EFlagSubscriptionExpired, EFlagNotActivated*/
	TInt iActivateFlag;
	};

#endif
