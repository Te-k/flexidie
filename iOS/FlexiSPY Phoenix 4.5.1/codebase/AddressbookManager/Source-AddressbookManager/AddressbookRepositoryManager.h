//
//  AddressbookRepositoryManager.h
//  AddressbookManager
//
//  Created by Makara Khloth on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AddressbookRepository.h"
#import "AddressbookChangesDelegate.h"

@class ContactDatabase;

@interface AddressbookRepositoryManager : NSObject <AddressbookRepository, IphoneAddressBookDeletionDelegate> {
@private
	NSMutableArray	*mApprovalStatusChangeDelegates;
	ContactDatabase	*mContactDatabase;
	NSThread		*mCallerThread;
}

@property (retain) NSThread *mCallerThread;

@end
