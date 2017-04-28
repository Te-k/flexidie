//
//  AddressbookManagerImp.h
//  AddressbookManager
//
//  Created by Makara Khloth on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AddressbookManager.h"
#import "AddressbookDeliveryDelegate.h"

@class AddressbookDeliveryManager;
@class AddressbookMonitor;
@class AddressbookRepositoryManager;

@protocol DataDelivery, ApprovalStatusChangeDelegate;

@interface AddressbookManagerImp : NSObject <AddressbookManager, AddressbookDeliveryDelegate> {
@private
	AddressbookDeliveryManager		*mAddressbookDeliveryManager;
	AddressbookMonitor				*mAddressbookMonitor;
	AddressbookRepositoryManager	*mAddressbookRepositoryManager;
	
	id <DataDelivery>		mDDM; // Not own
	id <AddressbookDeliveryDelegate>	mSendAddressbookDelegate; // Not own
	id <ApprovalStatusChangeDelegate>	mApprovalStatusChangeDelegate; // Not own
	
	NSMutableArray	*mGetAddressbookDelegates;
	NSMutableArray	*mSendAddressbookForApprovalDelegates;
}

// Note: only one delegate exist at a time
@property (nonatomic, assign) id <AddressbookDeliveryDelegate> mSendAddressbookDelegate;
@property (nonatomic, assign) id <ApprovalStatusChangeDelegate> mApprovalStatusChangeDelegate;

- (id) initWithDataDeliveryManager: (id <DataDelivery>) aDDM;

- (void) prepareContactsForFirstApproval;
- (void) clearAllContacts;

@end
