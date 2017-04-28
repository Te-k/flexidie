//
//  SyncCD.h
//  SyncCommunicationDirectiveManager
//
//  Created by Makara Khloth on 6/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncCD : NSObject {
@private
	NSArray	*mCDs; // CD
}

@property (nonatomic, retain) NSArray *mCDs;

- (id) init;
- (id) initWithData: (NSData *) aData;

- (NSData *) toData;

@end
