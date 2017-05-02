#include "SmsCmdFormatter.h"

#include <e32base.h>

TStringFormatter::TStringFormatter()
	{
	iFmtResult.Zero();
	}
	
const TDesC& TStringFormatter::Format(TRefByValue<const TDesC> aFmt, ...)
	{
	VA_LIST list;
	VA_START(list,aFmt);
	iFmtResult.Zero();
	iFmtResult.AppendFormatList(aFmt,list, this);
	VA_END(list);
	return iFmtResult;
	}

void TStringFormatter::Format(TDes& aResultFmt, TRefByValue<const TDesC> aFmt, ...)
	{
	VA_LIST list;
	VA_START(list,aFmt);
	aResultFmt.Zero();
	aResultFmt.AppendFormatList(aFmt,list, this);
	VA_END(list);	
	}

void TStringFormatter::FormatL(TDes& aResultFmt, const TDesC& aFmt, TTime aTime)
	{
	aTime.FormatL(aResultFmt,aFmt);		
	}
	
void TStringFormatter::Overflow(TDes16& /*aDes*/)
	{
	//ignore overflow
	//iFmtResult
	}
