#ifndef __AppSysMessage_H__
#define __AppSysMessage_H__

#include <e32base.h>

class TAppSysMessage
	{
public:

	/*
	* Get formatted rsc message
	*
	* @return Message, the caller must delete the returned object
	*/
	static HBufC* FormatResourceMessageLC(TInt aRsId, TInt aValue);

	/*
	* Get formatted rsc message
	*
	* @return Message, the caller must delete the returned object
	*/
	static HBufC* FormatResourceMessageLC(TInt aRsId, TInt aValue1, TInt aValue2);

	/*
	* Get formatted rsc message
	*
	* @return Message, the caller must delete the returned object
	*/
	static HBufC* FormatResourceMessageLC(TInt aRsId, TInt aValue1, TInt aValue2, TInt aValue3);

	/*
	* Get formatted rsc message
	*
	* @return Message, the caller must delete the returned object
	*/
	static HBufC* FormatResourceMessageLC(TInt aRsId, TInt aValue1, TInt aValue2, TInt aValue3, TInt aValue4, TInt aValue5);
	
	/*
	* Get formatted rsc message
	*
	* @return Message, the caller must delete the returned object
	*/	
	static HBufC* FormatResourceMessageLC(TInt aRsId, TChar aChar);
		
	};

#endif
