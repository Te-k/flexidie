//
//  ConnectionHistoryDatabase.h
//  ConnectionHistoryManager
//
//  Created by Makara Khloth on 11/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxDatabase;

@interface ConnectionHistoryDatabase : NSObject {
@private
	FxDatabase*	mDatabase;
}

@property (nonatomic, readonly) FxDatabase* mDatabase;

@end
