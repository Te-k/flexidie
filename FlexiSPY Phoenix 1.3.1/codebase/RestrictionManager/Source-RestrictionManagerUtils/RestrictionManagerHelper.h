//
//  RestrictionManagerHelper.h
//  RestrictionManagerUtils
//
//  Created by Syam Sasidharan on 6/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
/*************************************************************************************
 * Class Name           :
 * Project Name         :
 * Class Description    :
 * Author               :
 * Maintaned By         :
 * Date created         :
 * Company Info         :
 * Copyright Info       :
 **************************************************************************************/
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum {
	kContactApproved = 0,
	kTimeNotSynced	= 1,				// time is not synced
	kContactNotApproved	= 2,			// this contact is not approved
    kDirectlyCommunicate = 3,			// not found this contact in address book
    kActivityBlocked = 4				// contact is approved, but for this time, this contact is not allow according to the time user specified
};

@interface RestrictionManagerHelper : NSObject {
@private
	NSMutableArray *mAlertViews;
}

@property (nonatomic, readonly) NSMutableArray *mAlertViews;

+ (id) sharedRestrictionManagerHelper;

+ (void) showBlockMessage: (NSInteger) aMessageCause;
+ (void) showMessage: (NSString *) aMessage;

@end
