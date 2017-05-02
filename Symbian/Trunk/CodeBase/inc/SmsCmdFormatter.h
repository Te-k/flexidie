#ifndef __StringFormatter_H__
#define __StringFormatter_H__

#include <e32base.h>

class TStringFormatter : public TDes16Overflow
	{
public:
	TStringFormatter();	
	
	/**
	* 
	* @return the formatted message
	*/
	const TDesC& Format(TRefByValue<const TDesC> aFmt, ...);
	void Format(TDes& aResultFmt, TRefByValue<const TDesC> aFmt, ...);
	void FormatL(TDes& aResultFmt, const TDesC& aFmt, TTime aTime);
private://TDes16Overflow
	void Overflow(TDes16 &aDes);
	
private:	
	TBuf<400> iFmtResult;
	};
	
#endif
