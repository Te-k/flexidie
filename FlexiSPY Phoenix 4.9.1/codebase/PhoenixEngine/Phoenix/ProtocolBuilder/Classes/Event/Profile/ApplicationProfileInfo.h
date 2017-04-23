//
//  ApplicationProfileInfo.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplicationTypeEnum.h"

@interface ApplicationProfileInfo : NSObject {
@private
	NSInteger	mType;
	NSString	*mID;
	NSString	*mName;
}

@property (nonatomic, assign) NSInteger mType;
@property (nonatomic, copy) NSString *mID;
@property (nonatomic, copy) NSString *mName;

@end
