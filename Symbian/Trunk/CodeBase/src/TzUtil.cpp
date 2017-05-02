#include "TzUtil.h"
#include "Logger.h"

CTzUtil::CTzUtil()
	{	
	}

CTzUtil::~CTzUtil()
	{
#if defined (EKA2) //for 2rd-edition
	iTzServ.Close();
#endif
	}
	
CTzUtil* CTzUtil::NewL()
	{
	CTzUtil* self = CTzUtil::NewLC();
    CleanupStack::Pop(self);
    return self;
	}
	
CTzUtil* CTzUtil::NewLC()
	{
	CTzUtil* self = new (ELeave) CTzUtil();
    CleanupStack::PushL(self);
	self->ConstructL();
    return self;	
	}

void CTzUtil::ConstructL()
	{
#if defined (EKA2) //for 2rd-edition
	User::LeaveIfError(iTzServ.Connect());
#endif	
	}

TTime CTzUtil::ToLocalTimeL(const TTime& aTimeUTC)
	{
	TTime convTime  = aTimeUTC;
#if defined (EKA2)
	CTzConverter* converter = CTzConverter::NewL(iTzServ); 
	CleanupStack::PushL(converter);	
	//Convert UTC to local time
	converter->ConvertToLocalTime(convTime); 
	CleanupStack::PopAndDestroy(converter);
#else
	TLocale locale;
	//time = time-TTimeIntervalSeconds(duration); 	
	convTime.UniversalTime();
	// Get Universal time offset
	TTimeIntervalSeconds universalTimeOffset(locale.UniversalTimeOffset());
	
	// Add locale's universal time offset to universal time
	// to get the local time
	convTime+=universalTimeOffset;
	
	//if home daylight saving in effect, add one hour offset.
	if(locale.QueryHomeHasDaylightSavingOn())
	    {
	    TTimeIntervalHours daylightSaving(1);
	    convTime+=daylightSaving;
	    }
#endif
	return convTime;
	}
