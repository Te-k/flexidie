#ifndef __APPUIDDATA_H__
#define __APPUIDDATA_H__

#include <e32base.h>
#include <S32STRM.H>
#include <S32MEM.H>

class CAppUidData : public CBase
	{
	public:
		static CAppUidData* NewLC(const TDesC8& aStreamData);
		static CAppUidData* NewLC(const RArray <TUid>& aAppUidArray);		
		~CAppUidData();
		
	public:
		// Before send this to server must call MarshalDataL first
		// Ownership is transfer
		HBufC8* MarshalDataL() const;
		
		// Retrun a Uid array
		const RArray <TUid>& UidArray() const;
		
	private:
		// Writes ’this’ to the stream
		void ExternalizeL(RWriteStream& aStream) const;
		// Initializes ’this’ from stream
		void InternalizeL(RReadStream& aStream);
		
	private:
		CAppUidData();
		void ConstructL(const RArray <TUid>& aAppUidArray);
		
	private:
		RArray <TUid> iAppUidArray;
	};
	
#endif
