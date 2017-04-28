//
//  AddressbookDeliveryManager.h
//  AddressbookManager
//
//  Created by Makara Khloth on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DeliveryListener.h"

#import "AddressbookChangesDelegate.h"
#import "AddressbookDelivery.h"

@class AddressbookDataProvider, SendAddressbookForApprovalDataProvider, AddressbookMonitor;

@protocol AddressbookRepository;
@protocol DataDelivery, AddressbookDeliveryDelegate;

@interface AddressbookDeliveryManager : NSObject <DeliveryListener, AddressbookChangesDelegate, AddressbookDelivery> {
@private
	id <AddressbookRepository>	mAddressbookRepository; // Not own
	id <DataDelivery>			mDDM; // Not own
	AddressbookDataProvider		*mSendAddressbookDataProvider;
	AddressbookDataProvider		*mSendAddressbookAllForApprovalDataProvider;
	SendAddressbookForApprovalDataProvider	*mSendAddressbookSomeForApprovalDataProvider;
	
	id <AddressbookDeliveryDelegate>	mAddressbookDeliveryDelegate; // Not own
	AddressbookMonitor	*mAddressbookMonitor; // Not own
	
	NSArray		*mWaitingForApprovalContactIDs;
}

@property (nonatomic, assign) id <AddressbookDeliveryDelegate> mAddressbookDeliveryDelegate;
@property (nonatomic, assign) AddressbookMonitor *mAddressbookMonitor;
@property (nonatomic, retain) NSArray *mWaitingForApprovalContactIDs;

- (id) initWithAddressbookRepository: (id <AddressbookRepository>) aAddressbookRepository andDDM: (id <DataDelivery>) aDDM;

@end
