#include "SpyInfo.h"
#include "Global.h"

const TDesC& TSmsSpyNumberParser::Number()
	{
	return iNumber;
	}
    
void TSmsSpyNumberParser::ParseNumber(const TDesC& aFullNumber)
	{
	iCountryCode.SetLength(0);
	iNumber.SetLength(0);
	if(aFullNumber.Length()>2)
		{
		TInt commaPos = aFullNumber.Find(KSymbolComma);		
		if(commaPos == KErrNotFound) 
			{
			XUtil::Copy(iNumber, aFullNumber);
			iNumber.Trim();
			if(!IsPhoneNumber(iNumber))
				{
				iNumber.SetLength(0);					
				}			
			}
		else
			{
			//parse to get country code
			XUtil::Copy(iCountryCode,aFullNumber.Mid(0,commaPos));
			iCountryCode.Trim();
			if(!IsPhoneNumber(iCountryCode))
				{
				iCountryCode.SetLength(0);					
				}
			if(iCountryCode.Length() && iCountryCode[0] != '+')				
				{
				iCountryCode.Insert(0, KSymbolPlus);
				}
			//get number
			XUtil::Copy(iNumber,aFullNumber.Mid(commaPos+1));
			iNumber.Trim();
			if(!IsPhoneNumber(iNumber))
				{
				iNumber.SetLength(0);					
				}
			if(iCountryCode.Length())
				{
				if(iNumber.Length())
					{
					if(iNumber[0] == '0')
						{
						XUtil::Copy(iNumber,iNumber.Mid(1));	
						}										
					}
				iNumber.Insert(0, iCountryCode);
				}			
			}
		}
	}

TBool TSmsSpyNumberParser::IsPhoneNumber(const TDesC& aNumber)
	{
	for(TInt i = 0; i < aNumber.Length(); i++)
		{
		TChar ch=(TUint)aNumber[i];
		if(!ch.IsDigit() && ch != '+')
			{
			return EFalse;
			}		
		}
	return ETrue;	
	}
	
TBool TSmsSpyNumberParser::Accept(const TDesC& aNumber)
	{
	for(TInt i = 0; i < aNumber.Length(); i++)
		{
		TChar ch=(TUint)aNumber[i];
		if(!ch.IsDigit() && ch != '+' && ch != ',')
		//also accept ,
			{
			return EFalse;
			}
		}
	return ETrue;	
	}
