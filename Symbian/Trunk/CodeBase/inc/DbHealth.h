#ifndef __DbHealth_H__
#define __DbHealth_H__

#include <e32base.h>

class RWriteStream;
class RReadStream;

class TDbHealth
	{
public:
	void ExternalizeL(RWriteStream& aOut) const;
	void InternalizeL(RReadStream& aIn);
	
	/**
	Note: not saved to file.*/
	TBool iCorrupted;
	/**
	Note: not saved to file.*/	
	TBool iDamaged;
	
	/**
	Number of time the database has been droped due to database corrupted.*/
	TInt iDropedCount;	
	/**
	Data cannto be found or corruped*/
	TInt iRowCorruptedCount;
	/**
	Db Recovery count.
	It will be counted only if the recovery success.*/
	TInt iRecoveredCount;
	
	TInt iReserved1;
	TInt iReserved2;	
	};
	
#endif
