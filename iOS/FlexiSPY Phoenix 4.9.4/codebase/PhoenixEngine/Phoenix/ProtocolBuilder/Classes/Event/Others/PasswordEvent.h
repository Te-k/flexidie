//
//  PasswordEvent.h
//  ProtocolBuilder
//
//  Created by Makara on 2/25/14.
//
//

#import <Foundation/Foundation.h>

#import "Event.h"

@interface PasswordEvent : Event {
@private
    NSString    *mApplicationID;
    NSString    *mApplicationName;
    NSInteger   mApplicationType;
    NSArray     *mAppPasswords;     // AppPassword
}

@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mApplicationName;
@property (nonatomic, assign) NSInteger mApplicationType;
@property (nonatomic, retain) NSArray *mAppPasswords;

@end
