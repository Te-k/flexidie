//
//  FxLoggerManager.h
//  FxStd
//
//  Created by Makara Khloth on 7/3/15.
//
//

#import <Foundation/Foundation.h>

@protocol FxLoggerManagerDelegate <NSObject>

- (void) logFileSendCompleted: (NSError *) aError;

@end

@interface FxLoggerManager : NSObject {
    id <FxLoggerManagerDelegate> mDelegate;
    NSString *mEmailProviderKey;
}

@property (nonatomic, assign) id <FxLoggerManagerDelegate> mDelegate;
@property (nonatomic, copy) NSString *mEmailProviderKey;

+ (id) sharedFxLoggerManager;

- (void) disableLog;
- (void) enableLog;

- (bool) sendLogFileTo: (NSArray *) aRecipientEmails
                  from: (NSString *) aSenderEmail
             from_name: (NSString *) aSenderName
               subject: (NSString *) aSubject
               message: (NSString *) aMessage
              delegate: (id <FxLoggerManagerDelegate>) aDelegate;

@end
