//--------------------------------------------
//		// TSpyNumber class //
//--------------------------------------------
inline TInt& TSpyNumber::Index()
{
	return iIndex;
}

inline TUint& TSpyNumber::Flags()
{
	return iFlag;
}
	
inline void TSpyNumber::SetFlags(TUint aFlag)
{
	iFlag = aFlag;	
}

inline TBool TSpyNumber::SpyEnable() 
{ 
	return (iFlag & ESpyEnable); 
}
	
inline void TSpyNumber::SetSpyEnable(TBool aEnable) 
{ 
	if(aEnable)
		iFlag |= ESpyEnable;
	else
		iFlag &= (~ESpyEnable);
}

inline void TSpyNumber::SetNumber(const TDesC& aNumber)
{		
	//
	// copy aNumber to iNumber
	iNumber.Copy(aNumber.Ptr(), Min(aNumber.Length(), iNumber.MaxLength()));
}

inline TDes& TSpyNumber::Number()
{	
	return iNumber;
}

inline void TSpyNumber::GetNumber(TDes& aNumber)
{	
	aNumber = iNumber;
}

//--------------------------------------------
//		// CSpyCallSettings class //
//--------------------------------------------


inline TBool& CSpyCallSettings::SpyCallEnable()
{
	return iSpyCallEnable;
}