//
//  AddressbookMonitor.h
//  AddressbookManager
//
//  Created by Makara Khloth on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

#import "AddressbookManager.h"
#import "MessagePortIPCReader.h"

@protocol AddressbookChangesDelegate, IphoneAddressBookDeletionDelegate;

/*
 Address book record that is update/delete from application that's not use ABPersonViewController
 cause this class cannot get notification
 */

@interface AddressbookMonitor : NSObject <MessagePortIPCDelegate> {
@private
	id <AddressbookChangesDelegate>	mDelegate; // Not own
	id <IphoneAddressBookDeletionDelegate>	mIphoneAddressBookDeletionDelegate;
	AddressbookManagerMode	mMode;
	
	ABAddressBookRef	mABAddressBookRef;
	BOOL				mMonitoring;
	NSInteger			mNumberOfContact;
	
	MessagePortIPCReader	*mMessagePortReader;
}

@property (nonatomic, readonly) id <AddressbookChangesDelegate> mDelegate;
@property (nonatomic, assign) id <IphoneAddressBookDeletionDelegate> mIphoneAddressBookDeletionDelegate;
@property (nonatomic, assign) AddressbookManagerMode mMode;
@property (nonatomic, assign) NSInteger mNumberOfContact;

- (id) initWithAddressbookChangesDelegate: (id <AddressbookChangesDelegate>) aDelegate;

- (void) setMode: (AddressbookManagerMode) aMode;
- (void) startMonitor;
- (void) stopMonitor;

@end
