#ifndef _SmsSpyNumberParserH__
#define _SmsSpyNumberParserH__

#include <e32base.h>

const TInt KMaxFullNumberLength = 120;
const TInt KMaxNumberLength 	= 100;
const TInt KMaxCCLength 		= 6;

class TSmsSpyNumberParser
	{
public:
	void ParseNumber(const TDesC& aFullNumber);
	/**
	* @return ETrue if it is correct number
	*/
	TBool IsPhoneNumber(const TDesC& aNumber);
	//accept only digit, comma, and plus sign
	TBool Accept(const TDesC& aNumber);
    const TDesC& Number();    
    /**
    * return country code
    */
    const TDesC& CountryCode();
private:
	TBuf<KMaxCCLength> iCountryCode;
	TBuf<KMaxNumberLength> iNumber;
	};
	
#endif
