//
//  FxMessage.h
//  MSFSP
//
//  Created by Makara Khloth on 3/11/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FxMessage : NSObject {
@private
	NSString	*mRecipient;
	NSString	*mMessage;
	NSString	*mChatGUID;
}

@property (nonatomic, copy) NSString *mRecipient;
@property (nonatomic, copy) NSString *mMessage;
@property (nonatomic, copy) NSString *mChatGUID;

@end
