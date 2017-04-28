//
//  UsbEvent.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 2/3/15.
//
//

#import <Foundation/Foundation.h>

#import "Event.h"

@interface UsbEvent : Event {
    NSString *mUserLogonName;
    NSString *mAppID;
    NSString *mAppName;
    NSString *mTitle;
    int mAction;
    int mType;
    NSString *mName;
}

@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mAppID;
@property (nonatomic, copy) NSString *mAppName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, assign) int mAction;
@property (nonatomic, assign) int mType;
@property (nonatomic, copy) NSString *mName;

@end
