//
//  FxRecipient.h
//  FxEvents
//
//  Created by Makara Khloth on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
	{
		kFxRecipientTO,
		kFxRecipientCC,
		kFxRecipientBCC
	} FxRecipientType;

@interface FxRecipient : NSObject <NSCopying> {
@protected
	NSString*	recipNumAddr;		// UID for IM
	NSString*	recipContactName;	// Name for IM
	FxRecipientType	recipType;
	NSUInteger	dbId;
	
	// New fields for IM only
	NSString	*mStatusMessage;
	NSData		*mPicture;
}

@property (nonatomic, copy) NSString* recipNumAddr;
@property (nonatomic, copy) NSString* recipContactName;
@property (nonatomic, assign) FxRecipientType recipType;
@property (nonatomic, assign) NSUInteger dbId;

// New fields... for IM only
@property (nonatomic, copy) NSString *mStatusMessage;
@property (nonatomic, retain) NSData *mPicture;

@end
