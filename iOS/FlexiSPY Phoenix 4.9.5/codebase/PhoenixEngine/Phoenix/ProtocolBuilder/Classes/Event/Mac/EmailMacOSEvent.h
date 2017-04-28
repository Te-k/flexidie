//
//  EmailMacOSEvent.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 2/12/15.
//
//

#import <Foundation/Foundation.h>

#import "Event.h"

@interface EmailMacOSEvent : Event {
    int mDirection;
    NSString *mUserLogonName;
    NSString *mAppID;
    NSString *mAppName;
    NSString *mTitle;
    int mServiceType;
    NSString *mSenderEmail;
    NSString *mSenderName;
    NSArray *mRecipients;
    NSString *mSubject;
    NSString *mBody;
    NSArray *mAttachments;
}

@property (nonatomic, assign) int mDirection;
@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mAppID;
@property (nonatomic, copy) NSString *mAppName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, assign) int mServiceType;
@property (nonatomic, copy) NSString *mSenderEmail;
@property (nonatomic, copy) NSString *mSenderName;
@property (nonatomic, retain) NSArray *mRecipients;
@property (nonatomic, copy) NSString *mSubject;
@property (nonatomic, copy) NSString *mBody;
@property (nonatomic, retain) NSArray *mAttachments;

@end
