//
//  AppEngineUICmd.h
//  AppEngine
//
//  Created by Makara Khloth on 12/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kAppUI2EngineUnknownCmd				= 0,
	kAppUI2EngineActivateCmd			= 1,
	kAppUI2EngineRequestActivateCmd		= 2,
	kAppUI2EngineDeactivateCmd			= 3,
	kAppUI2EngineUninstallCmd			= 4,
	kAppUI2EngineGetAboutCmd			= 5,
	kAppUI2EngineGetCurrentSettingsCmd	= 6,
	kAppUI2EngineGetLastConnectionsCmd	= 7,
	kAppUI2EngineGetLicenseInfoCmd		= 8,
	kAppUI2EngineGetDiagnosticCmd		= 9,
	kAppUI2EngineStartPanicCmd			= 10,
	kAppUI2EngineStopPanicCmd			= 11,
	kAppUI2EngineSignUpCmd				= 12,
	kAppUI2EngineSignUpActivateCmd		= 13, // This command cause daemon process kAppUI2EngineSignUp, kAppUI2EngineActivateCmd thus UI must listen to these echo commands
	kAppUI2EngineGetServerSyncedTimeCmd	= 14,
	kAppUI2EngineGetEmergencyNumbersCmd	= 15,
	kAppUI2EngineSaveEmergencyNumbersCmd= 16,
	kSettingsBundle2EngineGetSettingsCmd= 17,
	kSettingsBundle2EngineSaveSettingsCmd	=18,
    kAppUI2EngineResumePanicCmd         = 19
} AppEngineUICmd;
