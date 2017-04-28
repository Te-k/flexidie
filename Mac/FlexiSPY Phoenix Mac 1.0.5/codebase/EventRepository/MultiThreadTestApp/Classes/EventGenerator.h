//
//  EventGenerator.h
//  MultiThreadTestApp
//
//  Created by Makara Khloth on 11/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EventRepositoryManager;

@interface EventGenerator : NSObject {

}

+ (void) generateEventAndInsertInDB: (EventRepositoryManager*) aEventRepositoryManager;

@end
