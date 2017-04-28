//
//  StringTestClass.h
//  TestApp
//
//  Created by Makara Khloth on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StringTestClass : NSObject {
@private
	NSString* hello;
	NSString* world;
}

@property (nonatomic, copy) NSString* hello;
@property (nonatomic, retain) NSString* world;

@end
