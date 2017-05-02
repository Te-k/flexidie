#ifndef __GENERAL_TIMER_H__
#define __GENERAL_TIMER_H__

#include <e32base.h>

#define	MODE_INTERVAL  2000
#define	MODE_DEST_TIME 2001

/*
* CGeneralTimer
* Simple implemented timer. start the timer and you'll get notify when timer end.
*/
class MGeneralTimerNotifier
{
	public:
		virtual void Time2GoL(TInt aError) = 0;
};

class CGeneralTimer : public CActive
{
	public:
	static CGeneralTimer * NewL(MGeneralTimerNotifier &ob);
	static CGeneralTimer * NewLC(MGeneralTimerNotifier &ob);
	~CGeneralTimer();	

	void StartTimer();
	void SetIntervalSecond(TInt	 s);
	void SetIntervalMilliSecond(TInt ms);
	void SetDestTime(const TTime &aTime);
	void SetRunningMode(TInt iMode);

	private:
    CGeneralTimer(MGeneralTimerNotifier &o);
	void ConstructL();

	void RunL();
	void DoCancel();
	TInt RunError(TInt aError);
	MGeneralTimerNotifier &observer;
	TBool iRunning;
	TInt runningMode;
	TTime destinationTime;
	RTimer iTimer;
	TInt64 iIntervalLeft;
	TInt64 iInterval;

	static const TInt KMaxIntervalMinutePerLoop;
	static const TInt KMaxIntervalMicroSecPerLoop;

};
#endif	//__GENERAL_TIMER_H__
