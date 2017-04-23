//
//  ContactInfo.h
//  MSFSP
//
//  Created by Makara Khloth on 6/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>

@interface ContactInfo : NSObject {
@private
	NSData				*mDisplayedPersonVcardData;
	NSData				*mPicture;
	NSString			*mNote;
	ABRecordID			mDisplayedPresonRecordID;
	ABAddressBookRef	mAddressBook;
	
	BOOL	mIsMonitoring;
	BOOL	mIsDaemonUpdating;
}

@property (nonatomic, copy) NSData *mDisplayedPersonVcardData;
@property (nonatomic, copy) NSData *mPicture;
@property (nonatomic, copy) NSString *mNote;
@property (nonatomic, assign) ABRecordID mDisplayedPersonRecordID;
@property (nonatomic, assign) ABAddressBookRef mAddressBook;
@property (nonatomic, readonly) BOOL mIsDaemonUpdating;

+ (id) sharedContactInfo;

+ (BOOL) contactDidChanges: (ABRecordID) aRecordID;

- (BOOL) isDisplayPersonChanges: (NSData *) aDisplayedPersonVardData;

- (void) startMonitor;
- (void) stopMonitor;

@end
