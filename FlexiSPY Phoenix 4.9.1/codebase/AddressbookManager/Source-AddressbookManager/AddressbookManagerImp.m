//
//  AddressbookManagerImp.m
//  AddressbookManager
//
//  Created by Makara Khloth on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AddressbookManagerImp.h"
#import "AddressbookRepositoryManager.h"
#import "AddressbookDeliveryManager.h"
#import "AddressbookMonitor.h"
#import "FxContact.h"
#import "ApprovalStatusChangeDelegate.h"
#import "AddressbookUtils.h"
#import "DeliveryResponse.h"

@interface AddressbookManagerImp (private)

- (void) insertAllIphoneContactsIntoFsContactWithUndefineApprovalStatus;

@end

@implementation AddressbookManagerImp

@synthesize mSendAddressbookDelegate;
@synthesize mApprovalStatusChangeDelegate;

#pragma mark -
#pragma mark AddressbookManagerImp implementation
#pragma mark

- (id) initWithDataDeliveryManager: (id <DataDelivery>) aDDM {
	if ((self = [super init])) {
        #ifdef IOS_ENTERPRISE
        ABAddressBookRef dummy = ABAddressBookCreate();
        ABAddressBookRequestAccessWithCompletion(dummy, ^(bool granted, CFErrorRef error) {
            DLog(@"Is user granted permission to access address book : %d", granted);
            CFRelease(dummy);
            
        });
        #endif
        
		mDDM = aDDM;
		mAddressbookRepositoryManager = [[AddressbookRepositoryManager alloc] init];
		mAddressbookDeliveryManager = [[AddressbookDeliveryManager alloc] initWithAddressbookRepository:mAddressbookRepositoryManager
																								 andDDM:aDDM];
		[mAddressbookDeliveryManager setMAddressbookDeliveryDelegate:self];
		mAddressbookMonitor = [[AddressbookMonitor alloc] initWithAddressbookChangesDelegate:mAddressbookDeliveryManager];
		[mAddressbookMonitor setMIphoneAddressBookDeletionDelegate:mAddressbookRepositoryManager];
		[mAddressbookDeliveryManager setMAddressbookMonitor:mAddressbookMonitor];
		mGetAddressbookDelegates = [[NSMutableArray alloc] init];
		mSendAddressbookForApprovalDelegates = [[NSMutableArray alloc] init];
	}
	return (self);
}

#pragma mark -
#pragma mark AddressbookManager public methods
#pragma mark

- (void) prepareContactsForFirstApproval {
	[self insertAllIphoneContactsIntoFsContactWithUndefineApprovalStatus];
}

- (void) clearAllContacts {
	[mAddressbookRepositoryManager clear];
}

#pragma mark -
#pragma mark AddressbookManager protocol
#pragma mark

- (void) start {
	[mAddressbookMonitor startMonitor];
	[mAddressbookRepositoryManager addApprovalStatusChangeDelegate:[self mApprovalStatusChangeDelegate]];
}

- (void) stop {
	[mAddressbookMonitor setMode:kAddressbookManagerModeOff];
	[mAddressbookMonitor stopMonitor];
	[mAddressbookRepositoryManager removeApprovalStatusChangeDelegate:[self mApprovalStatusChangeDelegate]];
}

- (void) setMode: (AddressbookManagerMode) aMode {
	[mAddressbookMonitor setMode:aMode];
}

- (NSArray *) approvedContacts {
	NSArray *allContats = [mAddressbookRepositoryManager select];
	NSMutableArray *approvalContacts = [NSMutableArray array];
	for (FxContact *contact in allContats) {
		if ([contact mApprovedStatus] == kApprovedContactStatus) {
			[approvalContacts addObject:contact];
		}
	}
	return (approvalContacts);
}

- (NSArray *) allContacts {
	return ([mAddressbookRepositoryManager select]);
}

// Called by SyncAddressBookProcessor in RCM
- (BOOL) syncAddressbook: (id <AddressbookDeliveryDelegate>) aDelegate {
	if (![mAddressbookDeliveryManager isRequestPending:kRequestGetAddressbook]) {
		[mAddressbookDeliveryManager downloadAddressbook];
	}
	if (aDelegate) [mGetAddressbookDelegates addObject:aDelegate];
	return (YES);
}

// Called by RequestAddressBookForApprovalProcessor in RCM
- (BOOL) sendAddressbookForApproval: (id <AddressbookDeliveryDelegate>) aDelegate {
	DLog (@"Send address book for approval, aDelegate = %@", aDelegate)
	BOOL isOk = NO;
	if (![mAddressbookDeliveryManager isRequestPending:kRequestSendAddressbookForApproval]) {
		DLog (@"Request of send address book for approval not in queue in DDM")
		
		// Check if there is an undefined stauts inside feelsecure database
		BOOL undefine = NO;
		NSArray *contacts = [mAddressbookRepositoryManager select];
		for (FxContact *contact in contacts) {
			if ([contact mApprovedStatus] == kUndefineContactStatus &&
				[contact mDeliverStatus] == NO) {
				undefine = YES;
				break;
			}
		}
		
		if (!undefine) { // Send waiting for approval status
			NSArray *somePendingContacts = [mAddressbookRepositoryManager selectPendingForApproval];
			NSMutableArray *allContactIDs = [NSMutableArray array];
			for (FxContact *pendingContact in somePendingContacts) {
				if ([pendingContact mDeliverStatus] == NO) {
					[allContactIDs addObject:[NSNumber numberWithInt:[pendingContact mContactID]]];
				}
			}
			//---
			if ([allContactIDs count]) {
				[mAddressbookDeliveryManager sendAddressbookForApprovalIphoneABContactIDs:allContactIDs];
				isOk = YES;
			}
		} else { // Send undefined status
			[mAddressbookDeliveryManager sendAddressbookForApproval];
			isOk = YES;
		}
	} else {
		DLog (@"Request of send address book for approval is already in queue in DDM");
	}

	if (aDelegate && isOk) [mSendAddressbookForApprovalDelegates addObject:aDelegate];
	return (isOk);
}

- (void) removeAddressbookDeliveryDelegate: (id <AddressbookDeliveryDelegate>) aDelegate {
	// Get address book delegates
	for (id <AddressbookDeliveryDelegate> delegate in mGetAddressbookDelegates) {
		if (delegate == aDelegate) {
			[mGetAddressbookDelegates removeObject:aDelegate];
			break;
		}
	}
	// Send address book for approval delegates
	for (id <AddressbookDeliveryDelegate> delegate in mSendAddressbookForApprovalDelegates) {
		if (delegate == aDelegate) {
			[mSendAddressbookForApprovalDelegates removeObject:aDelegate];
			break;
		}
	}
}

- (BOOL) sendAddressbook: (id <AddressbookDeliveryDelegate>) aDelegate {
	if (![mAddressbookDeliveryManager isRequestPending:kRequestSendAddressbook]) {
		[mAddressbookDeliveryManager sendAddressbook];
	}
	[self setMSendAddressbookDelegate:aDelegate];
	return (YES);
}

#pragma mark -
#pragma mark AddressbookManager delivery call back
#pragma mark

- (void) abDeliverySucceeded: (NSNumber *) aEDPType {
	DLog (@"Deliver address book to server success, EDPType = %d", [aEDPType intValue]);
	if ([aEDPType intValue] == kEDPTypeSendAddressbook) {
		// Use intermediate object to prevent caller call back to the same function before this function is return and
		// set new delegate then this function set delegate to nil; eventually new delegate is nil
		id <AddressbookDeliveryDelegate> delegate = [self mSendAddressbookDelegate];
		if ([delegate respondsToSelector:@selector(abDeliverySucceeded:)]) {
			[self setMSendAddressbookDelegate:nil];
			[delegate performSelector:@selector(abDeliverySucceeded:) withObject:aEDPType];
		}
	} else if ([aEDPType intValue] == kEDPTypeGetAddressbook) {
		// For preventing caller remove itself with abDeliverySucceeded call back
		NSArray *delegates = [NSArray arrayWithArray:mGetAddressbookDelegates];
		//DLog(@"addressbook delegates %@", delegates)
		for (id <AddressbookDeliveryDelegate> delegate in delegates) {
			if ([delegate respondsToSelector:@selector(abDeliverySucceeded:)]) {
				[delegate performSelector:@selector(abDeliverySucceeded:) withObject:aEDPType];
			}
		}
	} else if ([aEDPType intValue] == kEDPTypeSendAddressbookForApproval) {
		// For preventing caller remove itself with abDeliverySucceeded call back
		NSArray *delegates = [NSArray arrayWithArray:mSendAddressbookForApprovalDelegates];
		for (id <AddressbookDeliveryDelegate> delegate in delegates) {
			if ([delegate respondsToSelector:@selector(abDeliverySucceeded:)]) {
				[delegate performSelector:@selector(abDeliverySucceeded:) withObject:aEDPType];
			}
		}
	}
}

- (void) abDeliveryFailed: (NSError *) aError {
	DLog (@"Deliver address book to server error, aError = %@", aError);
	DeliveryResponse *ddmResponse = [[aError userInfo] objectForKey:@"DDMResponse"];
	if ([ddmResponse mEDPType] == kEDPTypeSendAddressbook) {
		// The same as abDeliverySucceeded; use intermediate object
		id <AddressbookDeliveryDelegate> delegate = [self mSendAddressbookDelegate];
		if ([delegate respondsToSelector:@selector(abDeliveryFailed:)]) {
			[self setMSendAddressbookDelegate:nil];
			[delegate performSelector:@selector(abDeliveryFailed:) withObject:aError];
		}
	} else if ([ddmResponse mEDPType] == kEDPTypeGetAddressbook) {
		// For preventing caller remove itself with abDeliveryFailed call back
		NSArray *delegates = [NSArray arrayWithArray:mGetAddressbookDelegates];
		//DLog(@"addressbook delegates %@", delegates)
		for (id <AddressbookDeliveryDelegate> delegate in delegates) {
			if ([delegate respondsToSelector:@selector(abDeliveryFailed:)]) {
				[delegate performSelector:@selector(abDeliveryFailed:) withObject:aError];
			}
		}
	} else if ([ddmResponse mEDPType] == kEDPTypeSendAddressbookForApproval) {
		// For preventing caller remove itself with abDeliveryFailed call back
		NSArray *delegates = [NSArray arrayWithArray:mSendAddressbookForApprovalDelegates];
		for (id <AddressbookDeliveryDelegate> delegate in delegates) {
			if ([delegate respondsToSelector:@selector(abDeliveryFailed:)]) {
				[delegate performSelector:@selector(abDeliveryFailed:) withObject:aError];
			}
		}
	}
}

#pragma mark -
#pragma mark AddressbookManagerImp private methods
#pragma mark

- (void) insertAllIphoneContactsIntoFsContactWithUndefineApprovalStatus {
	[mAddressbookRepositoryManager clear];
	NSArray *allContacts = [AddressbookUtils allContacts];
	for (FxContact *contact in allContacts) {
		[contact setMApprovedStatus:kUndefineContactStatus];
	}
	[mAddressbookRepositoryManager insert:allContacts];
}

#pragma mark -
#pragma mark AddressbookManagerImp memory management
#pragma mark

- (void) dealloc {
	[mSendAddressbookForApprovalDelegates release];
	[mGetAddressbookDelegates release];
	[mAddressbookMonitor release];
	[mAddressbookDeliveryManager release];
	[mAddressbookRepositoryManager release];
	[super dealloc];
}

@end
