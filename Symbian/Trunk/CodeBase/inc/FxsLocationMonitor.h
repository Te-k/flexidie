#ifndef __FxsLocationMonito_H__
#define __FxsLocationMonito_H__

#include "FxLocationService.h"
#include "CltDatabase.h"
#include "Timeout.h"
#include "GeneralTimer.h"

/**
This is a location change observer class.
When location is changed, it inserts information needed into the database.*/
class CFxsLocationMonitor : public CBase,
							public MTimeoutObserver,
					   		public MFxLocationChangeObserver,
							public MGeneralTimerNotifier
	{
public:
	static CFxsLocationMonitor* NewL(CFxsDatabase& aDb);
	~CFxsLocationMonitor();
	
private://from MFxLocationChangeObserver
	void LocationChanged(TChangeEvent aEvent, TAny* aArg1);
	
private://from MTimeoutObserver
	void HandleTimedOutL();
	TInt HandleTimedOutLeave(TInt aLeaveCode);

private: //from MGeneralTimerNotifier
	void Time2GoL(TInt aError);
private:
	CFxsLocationMonitor(CFxsDatabase& aDb);
	void ConstructL();	
    void CompleteSelf();
    void ReadAndInsertDbL(CTelephony::TNetworkInfoV1& aNetworkInfo);
    void ReadAndInsertDbL(const TDesC& aCellName);
	#ifdef	EKA2
    void ReadAndInsertDbL(TFxPositionInfo &aPositionInfo);
	#endif
    /**
    * Generate unique id from current time
    *
    */
    TInt GenerateUniqueIdFrom(const TTime& aCurrentTime);
	/**
	*	Check for duplicate cell id
	*/
	TBool IsDuplicateCellId(TUint aCellId);
	/**
	*	Check for duplicate cell name
	*/
	TBool IsDuplicateCellName(const TDesC& aCellName);
private:		
	CFxsDatabase& iDb;
	/**
	Used as time diff to generate unique event id*/
	TTime iTimeDiff;
	//cell id buffer for duplicate check
    RArray<TUint> iCellIdBuffer;
	CDesCArrayFlat *iCellNameBuffer;
	// Interval for hold cell id in buffer
	CGeneralTimer *iCellBufferTimer;
	};
#endif
