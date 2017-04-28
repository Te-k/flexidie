//
//  IMMacOSEvent.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 2/3/15.
//
//

#import <Foundation/Foundation.h>

#import "Event.h"

@interface IMMacOSEvent : Event {
    NSString *mUserLogonName;
    NSString *mAppID;
    NSString *mAppName;
    NSString *mTitle;
    int mIMServiceID;
    NSString *mConvName;
    NSString *mKeyData;
    int mSnapshotType;
    id mSnapshotData;
}

@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mAppID;
@property (nonatomic, copy) NSString *mAppName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, assign) int mIMServiceID;
@property (nonatomic, copy) NSString *mConvName;
@property (nonatomic, copy) NSString *mKeyData;
@property (nonatomic, assign) int mSnapshotType;
@property (nonatomic, retain) id mSnapshotData;

@end
