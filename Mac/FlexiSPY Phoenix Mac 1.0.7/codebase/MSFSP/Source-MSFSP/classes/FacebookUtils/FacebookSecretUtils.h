//
//  FacebookSecretUtils.h
//  MSFSP
//
//  Created by Khaneid Hantanasiriskul on 9/28/2559 BE.
//
//

#import <Foundation/Foundation.h>

@class MNSecureThreadSummary, MNSecureMessage, MNSecureMessagingService;

@interface FacebookSecretUtils : NSObject

@property (assign) MNSecureMessagingService *mMNSecureMessagingService;

+ (id) sharedFacebookSecretUtils;
+ (void) captureFacebookIMEventWithSecureThreadSummary: (MNSecureThreadSummary *) aFBMThread
                                  secureMessage: (MNSecureMessage *) aMessage;

@end
