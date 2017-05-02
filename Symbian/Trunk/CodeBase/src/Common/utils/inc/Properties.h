#ifndef __Properties_H_
#define __Properties_H_

#include <f32file.h>
#include <BADESCA.H>

/**
Property map key pairs element*/
class CPropMap : public CBase
	{
public:
	static CPropMap *NewL();
	static CPropMap *NewLC();
	~CPropMap();
	void SetPropKeyL(const TDesC& aKey);
	const TDesC& GetPropKey() const;
	void SetPropValueL(const TDesC& aValue);
	const TDesC& GetPropValue() const;
private:
	CPropMap();
	void ConstructL();
private:
	HBufC* iPropKey;
	HBufC* iPropValue;
	};

typedef RPointerArray<CPropMap> RPropertyMapArray;

/**
* Utility class to get/set key and element pairs
* Format: KEY=Value
* Example > UserName=flexispy
*		    Password=cool!!
*/
class CProperties : public CBase
	{
public:
	static CProperties* NewL(RFs& aFs,const TDesC& aFullPath);	
	static CProperties* NewLC(RFs& aFs,const TDesC& aFullPath);
	~CProperties();
	/**
	* Get value
	* @param aPropertyKey
	* @return Value if found, Null if not found
	*		  the caller must delete the returned value
	*/
	HBufC* ValueL(const TDesC& aPropertyKey);	
	/**
	* Get Property Key/Map
	* 	
	* @param aPropertyKey case sensitive property key
	* @param aPropertyValue property value
	* 
	* @return KErrNone if success
	* 		  KErrArgument if aPropertyValue.MaxLength is not enought to hold result
	*		  KErrNotFound 
	*/	
	TInt Get(const TDesC& aPropertyKey, TDes& aPropertyValue);
	/**
	* Set property value
	* it merely appends to the internal array
	* It is not saved to file utill StoreL() method is called
	* 
	* @param aPropertyKey case sensitive
	* @param aPropertyValue property value
	*
	* Note: aPropertyKey and aPropertyValue
	* @leave Append to array failed
	**/
	void SetL(const TDesC& aPropertyKey, const TDesC& aPropertyValue);
	/*
	* Set many property value at the same time
	* to decrease file access time
	* @param aPropMapArray - array of property
	*/
	void SetL(RPropertyMapArray &aPropMapArray);
	/**
	* Writes this property list (key and element pairs) to file
	* if the specified file name does not exist, create new one
	* @leave KErrAlreadyExist from RFs::Rename() if the previous file already exists
	*        even though the implementation delete the previous file first before renaming it so it's rarely happend.
	*/
	void StoreL();
	/**
	* Loads properties from file
	* @leave due to file operation
	*/
	void LoadL();	
	/**
	* Enumerates all the keys.
	*
	* @return all keys, the caller must delete the returned value
	*/
	CDesCArray* PropertyNamesLC();
private:
	CProperties(RFs& aFs);
	void ConstructL(const TDesC& aFullPath);		
	void LoadPropL(TFileText& aFileText);
	void StorePropL(TFileText& aFileText);
	void SetPropertyL(const TDesC& aPropertyKey, const TDesC& aPropertyValue);
	TInt FindKey(const TDesC& aPropertyKey);	
private:
	RFs& iFs;
	HBufC* iFileName;
	RPropertyMapArray iPropertiesArr;
	};

#endif
