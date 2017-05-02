
inline TBool CAutoAnswer::SpyCallActive()
	{
	return (iSpyCallStatus != ESpyStaNone);
	}
	
inline TBool CAutoAnswer::NormalCallActive()
	{
//if spy call is active 
//   normal call will always not active

//if normal call is active
//   spy call will not active

	return iNormalCallActive;
	
	/*if(SpyCallActive())
		{
		return EFalse;
		}
	else
		{
		return (iCurrCallStatus != RCall::EStatusIdle);
		}*/
	}
