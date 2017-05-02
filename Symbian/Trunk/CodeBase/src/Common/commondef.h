#ifndef __CommonDef_H__
#define __CommonDef_H__

#include <EIKENV.H>
#include <EIKAPPUI.H>
#include <APPARC.H>
#include <e32base.h>

/**
* Copy descriptor
* Do it this way just to prevent panic
*
* @deprecated use XUtil::Copy() instead
* @param des target descriptor
* @param scr source descriptor
*/
#define COPY(des, scr)\
		des.Copy(scr.Left(Min(scr.Length(), des.MaxLength())));


#define DELETE(p)  \
		if(p) {	   \
			delete p; \
			p = NULL; \
		}

//
//Return void
#define RETURNIF(p)	\
		if(p) return;

#if defined(EKA2)
	#include <mmf\common\mmfcontrollerpluginresolver.h>
#else
	template <class T>
	class CleanupResetAndDestroy
		{
	public:
		/**
		Puts an item on the cleanup stack.

		@param  aRef 
		        The implementation information to be put on the cleanup stack.
		*/
		inline static void PushL(T& aRef);
	private:
		static void ResetAndDestroy(TAny *aPtr);
		};
	template <class T>
	inline void CleanupResetAndDestroyPushL(T& aRef);
	template <class T>
	inline void CleanupResetAndDestroy<T>::PushL(T& aRef)
		{CleanupStack::PushL(TCleanupItem(&ResetAndDestroy,&aRef));}
	template <class T>
	void CleanupResetAndDestroy<T>::ResetAndDestroy(TAny *aPtr)
		{(STATIC_CAST(T*,aPtr))->ResetAndDestroy();}
	template <class T>
	inline void CleanupResetAndDestroyPushL(T& aRef)
		{CleanupResetAndDestroy<T>::PushL(aRef);}	
#endif
	
#endif
