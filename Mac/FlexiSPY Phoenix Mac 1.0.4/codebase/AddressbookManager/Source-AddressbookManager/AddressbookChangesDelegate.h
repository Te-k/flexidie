//
//  AddressbookChangesDelegate.h
//  AddressbookManager
//
//  Created by Makara Khloth on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AddressbookChangesDelegate <NSObject>

- (void) addressbookChanged; // Mode monitor
- (void) addressbookChanged: (NSArray *) aChangedContacts; // Contact id in iphone address book, mode restriction

@end

@protocol IphoneAddressBookDeletionDelegate <NSObject>

@optional
- (void) nativeIphoneContactDeleted: (NSArray *) aContactIDs;

@end