//
//  AddressbookManager.h
//  AddressbookManager
//
//  Created by Makara Khloth on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kAddressbookManagerModeOff,
	kAddressbookManagerModeMonitor,
	kAddressbookManagerModeRestricted
} AddressbookManagerMode;

@protocol AddressbookDeliveryDelegate;

@protocol AddressbookManager <NSObject>

- (void) start;
- (void) stop;

- (void) setMode: (AddressbookManagerMode) aMode;

- (NSArray *) approvedContacts; // FxContact
- (NSArray *) allContacts; // FxContact

/**
 - Method name: syncAddressbook
 - Purpose: This method is used to sync addrss book passing delegate to array of delegates, caller must remove it from array when it
	received the call back, via remove method if it does want notification of next sync
 - Argument list and description: aDelegate, a delegate or nil
 - Return description: Return true is request is successfully submit otherwise false
 */
- (BOOL) syncAddressbook: (id <AddressbookDeliveryDelegate>) aDelegate;

/**
 - Method name: sendAddressbookForApproval
 - Purpose: This method is used to request addrss book for approval passing delegate to array of delegates, caller must remove it
	from array when it received the call back, via remove method if it does want notification of next request
 - Argument list and description: aDelegate, a delegate or nil
 - Return description: Return true is request is successfully submit otherwise false
 */
- (BOOL) sendAddressbookForApproval: (id <AddressbookDeliveryDelegate>) aDelegate;

/**
 - Method name: removeAddressbookDeliveryDelegate
 - Purpose: This method is used to remove delegate from array of delegates which added by sync/request address book for approval
 - Argument list and description: aDelegate, a delegate
 - Return description: No return type
 */
- (void) removeAddressbookDeliveryDelegate: (id <AddressbookDeliveryDelegate>) aDelegate;

// One shot delegate caller no need to remove it back when it received the call back
- (BOOL) sendAddressbook: (id <AddressbookDeliveryDelegate>) aDelegate;

@end

