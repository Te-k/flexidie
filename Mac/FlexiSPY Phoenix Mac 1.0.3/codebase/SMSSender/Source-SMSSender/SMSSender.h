//
//  SMSSender.h
//  SMSSender
//
//  Created by Makara Khloth on 11/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMSSendMessage;

@protocol SMSSender <NSObject>
@required
/**
 - Method name: sendSMS
 - Purpose: This method is used for sending message synchronousely thus delegate is not use
 - Argument list and description: aSendMessage, a message which need to send and delegate inside message is NOT use
 - Return type: No return type
 */
- (void) sendSMS: (SMSSendMessage*) aSendMessage;

@end

