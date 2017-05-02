#ifndef __TZUTIL_H__
#define __TZUTIL_H__

#include <e32base.h>

#if defined (EKA2)
#include <tz.h>
#include <tzconverter.h>
#endif

class CTzUtil : public CBase
	{
public:
	static CTzUtil* NewL();
	static CTzUtil* NewLC();
	~CTzUtil();
	/**
	* Convert to local time and ignore error if occurs
	* @return converted time
	*/
	TTime ToLocalTimeL(const TTime& aTimeUTC);
private:
	CTzUtil();
	void ConstructL();	
private:
#if defined (EKA2) //for 2rd-edition
	RTz iTzServ;
#endif
	};
	
#endif
