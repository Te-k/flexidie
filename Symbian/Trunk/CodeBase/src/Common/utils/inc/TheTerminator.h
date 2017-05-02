#ifndef __THETERMINATOR_H__
#define __THETERMINATOR_H__

#include <e32base.h>
#include "Timeout.h"

class MDestructAO;

/**
* This class is used to solve Cutting Call Stack problem
* The terminator keeps a list of pointers to pointers so it can delete the object and null the pointer from the owner.
* It is a high priority active object to make the deletion to happen as soon as possible.
* @todo pls implement as sigleton dude
*/
class CTerminator : public CBase,
					public MTimeoutObserver
    {
public:
    static CTerminator* NewL();    
    ~CTerminator();
	
template<typename T>
	/**
	* Deferred delete operation
	* @param aObjToDelelte pointer to pointer of object to be deleted
	*		 after deletion the pointer from the owner will be NULL
	*/
	inline TInt DeletePP(T*& aToDelelte);
	
	/**
	* Deferred delete operation
	* @param aObjToDelelte pointer to object to be deleted
	*		 after deletion the pointer from the owner will NOT be NULL
	*		 the owner must null the owning object ifself
	*/
	inline TInt Delete(CBase* aToDelelte);
 	 	
 	inline TInt Delete(MDestructAO* aToDelelte);
	
private: //MTimeoutObserver
	void HandleTimedOutL();
	
private:
	CTerminator();
	void ConstructL();
	
private:
    TInt AddDestroyListPP(CBase** aToDelelte);
    TInt AddDestroyList(CBase* aToDelelte);
    TInt AddDestroyList(MDestructAO* aToDelelte);
    void SelfComplete();
    void Delete();
    void DoDeletePP();
    void DoDeleteP();
    void DoDestructAO();      
private:
	CTimeOut* iTimer;
    //pointers to pointers of object to be deleted
    RPointerArray<CBase*> iDestroyListPP;
    //pointers to object to be deleted
    RPointerArray<CBase> iDestroyList;
    RArray<MDestructAO*> iArrayOfDestructAO;
    TBool iDestroyMe;
    };
 
template<typename T>
inline TInt CTerminator::DeletePP(T*& aObjToDelelte)
    {
    TInt err(KErrArgument);
    CBase** objPtr = reinterpret_cast<CBase**>(&aObjToDelelte);
    if(*objPtr)
    	{
    	err = AddDestroyListPP(objPtr);
    	}
    return err;
    }

inline TInt CTerminator::Delete(CBase* aObjToDelelte)
    {
    TInt err(KErrArgument);
    if(aObjToDelelte)
    	{
    	err = AddDestroyList(aObjToDelelte);
    	}
    return err;
    }

inline TInt CTerminator::Delete(MDestructAO* aToDelelte)
	{	
	TInt err(KErrArgument);
	if(aToDelelte)
		{
		err=AddDestroyList(aToDelelte);		
		}
	return err;
	}
#endif //__THETERMINATOR_H__
