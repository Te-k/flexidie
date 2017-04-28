//
//  CSMDeviceManager.h
//  CommandServiceManager
//
//  Created by Makara Khloth on 11/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CSMDeviceManager : NSObject {
@private
	NSString	*mIMEI;
}

@property (nonatomic, copy) NSString *mIMEI;

+ (id) sharedCSMDeviceManager;

@end
