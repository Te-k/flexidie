//
//  AttendeeStructure.h
//  Calendar
//
//  Created by Ophat on 1/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AttendeeStructure : NSObject {
	NSString * mAttendeeName;
	NSString * mAttendeeUID;
}
@property (nonatomic,copy)NSString * mAttendeeName;
@property (nonatomic,copy)NSString * mAttendeeUID;

@end
