#include "ActiveBase.h"
#include "Logger.h"

CActiveBase::CActiveBase(TInt aPriority)
:CActive(aPriority)
	{
	}
	
CActiveBase::~CActiveBase()
	{
	}

void CActiveBase::AddToActiveScheduler()
	{
	CActiveScheduler::Add(this);
	}
	
void CActiveBase::Error(TInt aError)
	{
	LOG2(_L("[%S::RunError] aError: %d"), &ClassName(), aError)
	switch(aError)
		{
		case KErrNoMemory:
			{
			//add to low mem history
			}break;
		default:
			;
		}
	}
