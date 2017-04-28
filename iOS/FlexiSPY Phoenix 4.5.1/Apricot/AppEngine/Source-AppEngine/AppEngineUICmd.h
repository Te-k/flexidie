//
//  AppEngineUICmd.h
//  AppEngine
//
//  Created by Makara Khloth on 12/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kAppUI2EngineUnknownCmd = 0,
	kAppUI2EngineActivateCmd,
	kAppUI2EngineRequestActivateCmd,
	kAppUI2EngineDeactivateCmd,
	kAppUI2EngineUninstallCmd,
	kAppUI2EngineGetAboutCmd,
	kAppUI2EngineGetCurrentSettingsCmd,
	kAppUI2EngineGetLastConnectionsCmd,
	kAppUI2EngineGetLicenseInfoCmd,
	kAppUI2EngineGetDiagnosticCmd,
	kAppUI2EngineVisibilityCmd,
	kAppUI2EngineActivateURLCmd,
	kAppUI2EngineRequestActivateURLCmd
} AppEngineUICmd;
