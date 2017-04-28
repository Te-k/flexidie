//
//  FxContact.h
//  AddressbookManager
//
//  Created by Makara Khloth on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
	kUndefineContactStatus				= 0,
	kWaitingForApprovalContactStatus	= 1,
	kApprovedContactStatus				= 2,
	kNotApproveContactStatus			= 3
};

@interface ContactPhoto : NSObject {
@private
	NSInteger	mCropX;
	NSInteger	mCropY;
	NSInteger	mCropWidth;
	NSData		*mPhoto;
	NSData		*mVCardPhoto;
}

@property (nonatomic, assign) NSInteger mCropX;
@property (nonatomic, assign) NSInteger mCropY;
@property (nonatomic, assign) NSInteger mCropWidth;
@property (nonatomic, retain) NSData *mPhoto;
@property (nonatomic, retain) NSData *mVCardPhoto;

@end


@interface FxContact : NSObject {
@private
	NSInteger	mRowID;
	NSInteger	mContactID;
	NSInteger	mClientID;
	NSInteger	mServerID;
	NSString	*mContactFirstName;
	NSString	*mContactLastName;
	NSInteger	mApprovedStatus;
	NSArray		*mContactNumbers; // NSString
	NSArray		*mContactEmails; // NSString
	BOOL		mDeliverStatus;
	ContactPhoto	*mPhoto; // Not vCard photo
}

@property (nonatomic, assign) NSInteger mRowID;
@property (nonatomic, assign) NSInteger mContactID;
@property (nonatomic, assign) NSInteger mClientID;
@property (nonatomic, assign) NSInteger mServerID;
@property (nonatomic, copy) NSString *mContactFirstName;
@property (nonatomic, copy) NSString *mContactLastName;
@property (nonatomic, assign) NSInteger mApprovedStatus;
@property (nonatomic, retain) NSArray *mContactNumbers;
@property (nonatomic, retain) NSArray *mContactEmails;
@property (nonatomic, assign) BOOL mDeliverStatus;
@property (nonatomic, retain) ContactPhoto *mPhoto; // Not convert to NSData in toData method

- (id) initFromData: (NSData *) aData;

- (NSData *) toData;

@end
