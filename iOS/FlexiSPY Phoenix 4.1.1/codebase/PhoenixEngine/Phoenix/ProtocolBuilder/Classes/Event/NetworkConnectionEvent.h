//
//  NetworkConnectionEvent.h
//  ProtocolBuilder
//
//  Created by ophat on 11/25/15.
//
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface NetworkConnectionEvent : Event {
    NSString    *mUserLogonName;
    NSString    *mApplicationID;
    NSString    *mApplicationName;
    NSString    *mTitle;
    id           mAdapter;
    id           mAdapterStatus;

}
@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mApplicationName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, retain) id mAdapter;
@property (nonatomic, retain) id mAdapterStatus;

@end
