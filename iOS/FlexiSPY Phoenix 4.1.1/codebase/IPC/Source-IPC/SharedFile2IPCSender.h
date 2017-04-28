//
//  SharedFile2IPCSender.h
//  IPC
//
//  Created by Makara Khloth on 1/3/14.
//  Copyright 2014 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxDatabase;

@interface SharedFile2IPCSender : NSObject {
@private
	NSString	*mSharedFileName;
	FxDatabase	*mDatabase;
	FxDatabase	*mCacheDatabase;
}

- (id) initWithSharedFileName: (NSString*) aSharedFileName;
- (BOOL) writeDataToSharedFile: (NSData*) aRawData;

@end
