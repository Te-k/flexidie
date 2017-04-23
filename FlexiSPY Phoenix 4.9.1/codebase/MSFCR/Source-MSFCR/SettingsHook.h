//
//  SettingsHook.h
//  MSFCR
//
//  Created by Benjawan Tanarattanakorn on 9/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulletinBoardAppDetailController.h"
#import "BBSectionInfo.h"
#import "RestrictionManagerUtils.h"

static const NSString *kWhatsAppID = @"net.whatsapp.WhatsApp";


// When restriction is enabled, Alert Style (None, Banners, Alerts) will be changed to 'None' if the user clicks either one of the Alert Styles
HOOK(BulletinBoardAppDetailController, setAlertType$specifier$, void, id arg1, id arg2) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>		BulletinBoardAppDetailController	 -->  setAlertType specifier");
	DLog(@"> arg1: %@", arg1)	// NSNumber
	DLog(@"> arg2: %@", arg2)	// PSSpecifier
	
	NSNumber *alertType = arg1;
			
	PSSpecifier *mySpecifier = [self specifier];
	NSDictionary *properties = [mySpecifier properties];
	DLog(@"> [self specifier] %@",		mySpecifier);
	DLog(@"> [self identifier] %@",		[mySpecifier identifier]);
	DLog(@"> [self properties] %@",		properties);
		
	BBSectionInfo *object = [properties objectForKey:@"BBSECTION_INFO_KEY"];	
	if ([ [object sectionID] isEqualToString:kWhatsAppID]) {
		if ([[RestrictionManagerUtils sharedRestrictionManagerUtils] restrictionEnabled]) {		
			DLog (@"> hard code alert type for WhatsApp")
			alertType = [NSNumber numberWithInt:0];	// 0 none, 1 banner, 2 alert
		}
	}			
	CALL_ORIG(BulletinBoardAppDetailController, setAlertType$specifier$, alertType, arg2);
}

// When restriction is enabled, Notification Center toggle (On or Off) will be changed to 'Off' if the user presses the toggle
HOOK(BulletinBoardAppDetailController, setShowInNotificationCenter$specifier$, void, id arg1, id arg2) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>		BulletinBoardAppDetailController	 -->  setShowInNotificationCenter specifier");
	DLog(@"> arg1: %@", arg1)	// __NSCFBoolean (private subclass of NSNumber)   0 disable , 1 enable
	DLog(@"> arg2: %@", arg2)	// PSSpecifier
	
	id inNotificationCenter = arg1;
	
	PSSpecifier *mySpecifier = [self specifier];
	DLog(@" [self specifier] %@",		mySpecifier);
	DLog(@" [self identifier] %@",		[mySpecifier identifier]);
	DLog(@" [self properties] %@",		[mySpecifier properties]);
	
	NSDictionary *properties = [mySpecifier properties];
	BBSectionInfo *object = [properties objectForKey:@"BBSECTION_INFO_KEY"];	
	if ([[object sectionID] isEqualToString:kWhatsAppID]) {
		if ([[RestrictionManagerUtils sharedRestrictionManagerUtils] restrictionEnabled]) {		
			DLog (@"> hard code alert type for WhatsApp")
			inNotificationCenter = [NSNumber numberWithInt:0];
		}
	}		
	CALL_ORIG(BulletinBoardAppDetailController, setShowInNotificationCenter$specifier$, inNotificationCenter, arg2);
}