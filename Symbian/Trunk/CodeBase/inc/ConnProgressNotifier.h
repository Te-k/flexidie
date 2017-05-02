// ConnProgressNotifier.H
#ifndef _ConnProgressNotifier_H__
#define _ConnProgressNotifier_H__
#include "CltConnOpener.h"

#include <e32base.h>
#include <Es_sock.h>

class CCltConnProgressNonifier : public CActive
{	
public:
	static CCltConnProgressNonifier* NewL(RConnection& aConnection,MConnectionObserver& aObserver);
	~CCltConnProgressNonifier();
	
private:
	CCltConnProgressNonifier(RConnection& aConn,MConnectionObserver& aObserver);
	void ConstructL();

public:
	void Start();
	
private: //Ca
	void RunL();
	void DoCancel();
	TInt RunError(TInt aError);
	
private:		
    TNifProgressBuf iProgress;
    TInt iState;
    
    RConnection& iConnection;
    MConnectionObserver& iObserver;	
    
    TInt iCurStage;
};
#endif
