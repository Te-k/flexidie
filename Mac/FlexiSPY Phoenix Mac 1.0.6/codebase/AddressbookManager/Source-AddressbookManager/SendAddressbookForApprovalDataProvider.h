//
//  SendAddressbookForApprovalDataProvider.h
//  AddressbookManager
//
//  Created by Makara Khloth on 6/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataProvider.h"

@protocol AddressbookRepository;

@interface SendAddressbookForApprovalDataProvider : NSObject <DataProvider> {
@private
	NSArray		*mContactsIDs;			// In order one to one mapping to mAssociateClientIDs
	NSArray		*mAssociateClientIDs;	// // In order one to one mapping to mContactsIDs
	NSInteger	mVCardIndex;
	
	id <AddressbookRepository> mAddressbookRepository; // Not own
	NSMutableArray	*mDeliverClientIDs;
}

@property (retain) NSArray *mContactIDs;
@property (retain) NSArray *mAssociateClientIDs;
@property (assign) NSInteger mVCardIndex;
@property (assign) id <AddressbookRepository> mAddressbookRepository;

@property (retain) NSMutableArray *mDeliverClientIDs;

- (id) commandDataSomeContactsForApproval;

@end
