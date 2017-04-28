//
//  AddressbookDataProvider.h
//  AddressbookManager
//
//  Created by Makara Khloth on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

#import "DataProvider.h"

@protocol AddressbookRepository;

@interface AddressbookDataProvider : NSObject <DataProvider> {
@private
	NSInteger	mNumberOfContact;
	NSInteger	mVCardIndex;
	
	BOOL		mSendAddressbookForApproval;
	id <AddressbookRepository> mAddressbookRepository; // Not own
	
	NSMutableArray	*mDeliverClientIDs;
}

@property (assign) BOOL mSendAddressbookForApproval;
@property (assign) id <AddressbookRepository> mAddressbookRepository;

@property (retain) NSMutableArray *mDeliverClientIDs;

- (id) commandDataAllForApproval: (BOOL) aSendAddressbookForApproval;

@end
