#include "CltDocument.h"

#include "CltAppUi.h"
#include "CltSettingMan.h"
#include "CltDatabase.h"
#include "Logger.h"
#include <eikenv.h>
#include <APGWGNAM.H>

CCltDocument::CCltDocument(CEikApplication& aApp)
:CAknDocument(aApp)
	{
#ifdef EKA2	
	//do something different
#else
	iHideFromTaskList = ETrue;
#endif
	}

CCltDocument* CCltDocument::NewL(CEikApplication& aApp)
	{	
	CCltDocument* self = new (ELeave) CCltDocument(aApp);
	CleanupStack::PushL(self);
	self->ConstructL();
	CleanupStack::Pop(self);
	return self;
	}

CEikAppUi* CCltDocument::CreateAppUiL()
	{	
	return new (ELeave) CFxsAppUi;
	}
CCltDocument::~CCltDocument()
	{	
	}

void CCltDocument::ConstructL()
	{
	Logger::CreateLogsDir();	
	}
 
void CCltDocument::UpdateTaskNameL(CApaWindowGroupName* aWgName)
//hide its icon from phone task list	
//KAppIsHidden 
	{
	CAknDocument::UpdateTaskNameL(aWgName);
	aWgName->SetHidden(iHideFromTaskList);
	aWgName->SetSystem(iHideFromTaskList);	
	}
