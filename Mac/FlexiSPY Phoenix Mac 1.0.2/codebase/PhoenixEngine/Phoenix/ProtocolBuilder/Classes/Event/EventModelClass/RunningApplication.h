//
//  RunningApplication.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplicationTypeEnum.h"

@interface RunningApplication : NSObject {
@private
	NSInteger	mType;
	NSString	*mName;
	NSString	*mID;
}

@property (nonatomic, assign) NSInteger mType;
@property (nonatomic, copy) NSString *mName;
@property (nonatomic, copy) NSString *mID;

@end
