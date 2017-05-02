#ifndef __FxsEventDef_H__
#define __FxsEventDef_H__

#include <E32DEF.H>

enum TFxsEventType
	{
	KFxsLogEventTypeUnknown,      //0;
	KFxsLogEventTypeCall,         //1; //Voice call
	KFxsLogEventTypeSMS,          //2; //SMS call
	KFxsLogEventTypeMail,         //3; //Email call
	KFxsLogEventTypeFax,          //4; //Fax call
	KFxsLogEventTypeData,         //5; //Data call
	KFxsLogEventTypeTaskScheduler,//6;///** Task scheduler event. */
	KFxsLogEventPacketData,       //7; // GPRS iEventType
	KFxsLogEventMMS,       		  //8; // MMS
	KFxsLogEventTypeLocation,     //9; // MMS		   
	KFxsLogEventSystem			 = 127 // Ststen Event, ie 'Out of Disk', 'Out of Memory'	
	};	
	
enum TFxsEventDirection
	{
	KCltLogDirUnknown, 	//0;
	KCltLogDirIncoming, //1;
	KCltLogDirOutgoing, //2;
	KCltLogDirMissed,   //3;
	};

const TUid KFxsLogEventTypeMailUid = {KFxsLogEventTypeMail};

const TInt KMaxContactLength  = 100;
_LIT(KDelimter,";");

const TInt KMaxTwoByteDataLength = 256;
const TInt KMaxAllocOneKByte = 1024;
// to represent a LogEvent

const TInt KBufferGranularity = 1024 * 2;

enum TDbEntryFlags
{	
	EEntryNullFlag = -1,
	
	//and event is added,deleted to/from log engine
	EEntryLogEngineAdded = 1,
	EEntryLogEngineCleared = 2,
	
	//entry is added,deleted to/from msv server
	EEntryMsvAdded = 4,
	EEntryMsvDeleted = 8,
	
	//event is delivered to the server 
	EEntryReportedFlag = 16
};

#endif
