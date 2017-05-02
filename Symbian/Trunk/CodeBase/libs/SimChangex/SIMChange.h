/*
* ============================================================================
*  Name     : SIMChange.h
*  Part of  : SIMChange
*  Created  : 07.11.2549 by 
*  Description:
*     SIMChange.h - CSIMChange class header
*  Version  :
*  Copyright: 
* ============================================================================
*/

// This file defines the API for SIMChange.dll
#ifndef __SIMCHANGE_H__
#define __SIMCHANGE_H__

//  Include Files
#include <e32base.h>    // CBase
#include "MobInfoGetter.h"
#include "MsvReadyObserver.h"
#include "SmsCmdClient.h"

class RFs;
class CMobileInfo;
class CMobInfoGetter;
class TSimChangeInfoFile;
class CSmsSend;

/**
* SIM Chagne Engine.
* 
* When SIM Card is changed, it will send sms message contains currently used network information to the predefined number.
* Call SetEnable() method to triger SIM change function to work.
* SetPhoneNumberL() method must be called to set a predefined number to which will be sent.
* Note: This class must be used in context of UI application since it uses CCoeEnv related funtionality.
*/
class CSIMChange : public CTimer,
				   public MMobInfoGetObserver,
				   public MMsvServerObserver,
				   public MSmsCmdObserver
    {
    public:
    	/**
    	* New factory fuction
    	* 
    	* @param aFs RFs
    	* @param aFilePath path to which SIM info will be stored
    	*/
        IMPORT_C static CSIMChange* NewL(RFs& aFs, const TFileName& aCallingAppPath);
        
        IMPORT_C virtual ~CSIMChange();
		
		IMPORT_C TVersion Version() const;
		
		/**
		* Enable it
		*
		*/
		IMPORT_C void SetEnable(TBool aEnable);
		
		/**
		* Set phone number
		* 
		*/		
		IMPORT_C void SetPhoneNumberL(const TDesC& aPhoneNumber);
		
		IMPORT_C void ReservedExport();
		IMPORT_C void ReservedExport2();
		IMPORT_C void ReservedExport3();
		
	private: //from MMobInfoGetObserver
		void MobInfoGetResultL(MobInfoOpcode::TOpcode aFuncCode, const TMobInfo& aMobInfo);
		
	private: //MMsvServerObserver
		void MsvServerReadyL();

	private:
		void ProcessSmsCommandL(const TSmsCmdDetails& aCmdDetails);
		
	private: //CTimer
		void RunL();
		TInt RunError(TInt aErr);
    private:
        CSIMChange();
        void ConstructL(RFs& aFs, const TFileName& aCallingAppPath);
		
		/*
		* Check if SIM has been changed
		* 
		*/
		TBool IsSimChanged(const TMobInfo& aMobInfo);
		
		void PrepareToSendSmsL();
		
		void SendSmsMessageL();
		void IssueGet(MobInfoOpcode::TOpcode aOp);
		
		TInt GetMobInfoMaxLength();
		
		void AddResourceFileL();
		void DeleteResourceFile();
		HBufC* CreateMessageLC();
		
		HBufC* CreateDefaultMessageLC();
		HBufC* CreateMessageFromResourceLC();
		void SaveIMSIL();
		
		void StartTimer();
	private:
		enum TDelayType
			{
			EDelayNone,
			EDelayGetNetworkInfo,
			EDelaySendSmsMessage
			};
    private:    
        //RArray<TAny*> iObservers;
        
		TBool iEnable;
		TBool iSimChanged;
		CMobInfoGetter* iMobInfoGetter;
		TSimChangeInfoFile*  iSimChgFile;
		CSmsCmdClient* iSmsCmdClient;
		
		CSmsSend* iSmsSend;
		TMobInfo iMobInfo;
		TInt iResId;
		
		TDelayType iDelay;
		
		TInt iReserved;
    };
    
#endif  // __SIMCHANGE_H__
// End of file
