//
//  AddressbookRepository.h
//  AddressbookManager
//
//  Created by Makara Khloth on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxContact, ContactPhoto;

@protocol ApprovalStatusChangeDelegate;

@protocol AddressbookRepository <NSObject>

- (void) insert: (NSArray *) aContacts;
- (void) insertOldContact: (NSArray *) aContacts;
- (void) update: (FxContact *) aContact;
- (NSInteger) count;
- (NSArray *) select;
- (NSArray *) selectPendingForApproval; // contact_status = Waiting_For_Approval && deliver_status = 0
- (FxContact *) selectAddressbookContactID: (NSInteger) aIphoneAddressbookContactID;
- (FxContact *) selectFromClientID: (NSInteger) aClientID;
- (FxContact *) selectFromServerID: (NSInteger) aServerID;
- (void) remove: (NSArray *) aClientIDs;
- (void) clear;

- (ContactPhoto *) photo: (NSInteger) aClientID;
- (void) deletePhoto: (NSInteger) aClientID;

- (void) addApprovalStatusChangeDelegate: (id <ApprovalStatusChangeDelegate>) aDelegate;
- (void) removeApprovalStatusChangeDelegate: (id <ApprovalStatusChangeDelegate>) aDelegate;

- (void) openRepository;
- (void) closeRepository;

@end