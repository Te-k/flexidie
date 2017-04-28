//
//  ContactDAO.h
//  AddressbookManager
//
//  Created by Makara Khloth on 6/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxDatabase, FxContact;

@interface ContactDAO : NSObject {
@private
	FxDatabase	*mDatabase;
}

- (id) initWithDatabase: (FxDatabase *) aDatabase;

- (void) insert: (FxContact *) aContact;
- (NSArray *) select;
- (NSArray *) selectPendingForApproval;
- (FxContact *) selectWithContactID: (NSInteger) aContactID;
- (FxContact *) selectWithClientID: (NSInteger) aClientID;
- (FxContact *) selectWithServerID: (NSInteger) aServerID;
- (void) update: (FxContact *) aContact; // Using client id as criteria
- (void) deleteContact: (NSInteger) aClientID;
- (void) deleteAll;
- (NSInteger) count;

@end
