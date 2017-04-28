//
//  NetworkTrafficEvent.h
//  ProtocolBuilder
//
//  Created by ophat on 10/21/15.
//
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface NetworkTrafficEvent : Event{
    NSString    *mUserLogonName;
    NSString    *mApplicationID;
    NSString    *mApplicationName;
    NSString    *mTitle;
    NSString    *mStartTime;
    NSString    *mEndTime;
    NSArray     *mNetworkInterfaces; // FxNetworkInterface
}
@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mApplicationName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, copy) NSString *mStartTime;
@property (nonatomic, copy) NSString *mEndTime;
@property (nonatomic, retain) NSArray  *mNetworkInterfaces;

@end
