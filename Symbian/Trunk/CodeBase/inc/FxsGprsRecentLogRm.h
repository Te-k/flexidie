#ifndef __FxsGprsRecentLogRm_H__
#define __FxsGprsRecentLogRm_H__

#include <e32base.h>
#include <logview.h>

class CLogClient;
class CLogViewRecent;
class CLogFilter;
class CLogViewEvent;

class CFxsGprsRecentLogRm : public CActive
	{
public:
	static CFxsGprsRecentLogRm* NewL(/*CLogClient& aLogCli*/);
	virtual ~CFxsGprsRecentLogRm();
	
	/**	
	* Remove
	* @leave OOM
	*/
	void RemoveLastEventL();
	/**
	* Remove, ignore OOM
	* if in case OOM, the log will not ge deleted
	*/
	void RemoveLastEvent();
	/**
	* Remove all gprs connection event
	*/
	void RemoveAllEvent();
private: //CActive
	void RunL();
	void DoCancel();
	TInt RunError(TInt aError);

private:
	CFxsGprsRecentLogRm(/*CLogClient& aLogCli*/);
	void ConstructL();	
	void IssueGetRecentEventL();
	void IssueRemoveEventL();
	void RetreiveAndIssueRemoveL();
	/**
	* Issue get event
	* 
	* @return ETrue if issued
	*/
	TBool GetFirstL();
private:
	enum TStep
		{	
		EStepNone,
		EStepGetEvent, //getting recent event
		EStepFilterEvent,
		EStepRemovEvent, //deleting event
		EStepDone		   //done, 
		};	
	CLogClient*	iLogCli;
	//CLogViewRecent is not working for gprs	
	CLogViewEvent*	iLogView;	
	CLogFilter* ipFilter;	
	TStep	iStep;
	TLogId	iLogIdToRemove;
	TBool iRemoveAll;
	};

#endif
