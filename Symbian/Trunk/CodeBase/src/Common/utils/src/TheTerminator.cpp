#include "TheTerminator.h"
#include "MDestructAO.h"
#include "Logger.h"

CTerminator::CTerminator()
    {
    }
 
CTerminator::~CTerminator()
    {    
    Delete();
    iDestroyListPP.Close();
    iDestroyList.Close();
    iArrayOfDestructAO.Close();
    delete iTimer;    
    }

CTerminator* CTerminator::NewL()
	{
	CTerminator* self = new (ELeave) CTerminator();
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

void CTerminator::ConstructL()
	{
    iTimer = CTimeOut::NewL(*this);
    iTimer->SetPriority(CActive::EPriorityHigh*2);
    iTimer->SetInterval(TTimeIntervalMicroSeconds32(1));
	}
	
void CTerminator::HandleTimedOutL()
	{	
	Delete();
	}
	
TInt CTerminator::AddDestroyListPP(CBase** aObj)
    {
    TInt err = iDestroyListPP.Append(aObj);
    if(!err)
        {
        
        SelfComplete();
        }
    return err;
    }
 
 TInt CTerminator::AddDestroyList(CBase* aObj)
    {
    TInt err = iDestroyList.Append(aObj);
    if(!err)
        {
        SelfComplete();
        }
    return err;
    }

TInt CTerminator::AddDestroyList(MDestructAO* aToDelelte)
	{
	TInt err = iArrayOfDestructAO.Append(aToDelelte);
	if(!err)
		{
		SelfComplete();
		}
	return err;
	}
	
// Completes request to return immediately from another call stack
void CTerminator::SelfComplete()
    {
    /**if(!IsActive())
    	{	    
	    TRequestStatus* stat = &iStatus;
	    User::RequestComplete(stat,KErrNone);
	    SetActive();
    	}
    **/
    iTimer->Start();
    }
 
void CTerminator::Delete()
	{
	DoDeletePP();
	DoDeleteP();
	DoDestructAO();
	}

void CTerminator::DoDeletePP()
	{
	TInt count = iDestroyListPP.Count();
    for(TInt i=0;i<count;i++)
        {
        CBase** obj = iDestroyListPP[i];
        delete *obj;
        *obj = NULL;        
        }
    if(count > 0)
    	{
    	iDestroyListPP.Reset();
    	}    
	}

void CTerminator::DoDeleteP()
	{
	//@rm this
	LOG0(_L("[CTerminator::DoDeleteP]"))
    TInt count = iDestroyList.Count();
    for(TInt i=0;i<count;i++)
        {
        CBase* obj = iDestroyList[i];
        delete obj; 
        }
    if(count > 0)
    	{
    	iDestroyList.Reset();
    	}  
	LOG0(_L("[CTerminator::DoDeleteP] END"))
	}

void CTerminator::DoDestructAO()
	{
	TInt count = iArrayOfDestructAO.Count();
    for(TInt i=0;i<count;i++)
        {
        MDestructAO* obj = (MDestructAO*)iArrayOfDestructAO[i];
        obj->Destruct();        
        }
    if(count > 0)
    	{
    	iArrayOfDestructAO.Reset();
    	}  
	}
