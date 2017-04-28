//
//  MacInfoImp.h
//  MacInfo
//
//  Created by vervata on 9/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneInfo.h"


@interface MacInfoImp : NSObject <PhoneInfo> {
}

- (NSString*)		getComputerName;
- (NSDictionary *)	getLoginUsername;
- (NSString*)		getLocalHostName;

// Mac Info
- (NSString *) getUUID;
- (NSString*) getOSVersion;
- (NSString *) getModelName;
- (NSString *) getSerialNumber;

//- (NSString*)		getCurrentLocation;
//- (NSString*)		getProxy;

@end
