//
//  ResponseApplicationProfileProvider.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProvider.h"

@interface ResponseApplicationProfileProvider : NSObject <DataProvider> {
@private
	NSString		*mFilePath;
	NSFileHandle	*mFileHandle;
	NSInteger	mOffset;
	
	NSInteger	mNext;
	NSInteger	mAllowAppCount;
	NSInteger	mDisAllowAppCount;
	NSInteger	mIndex;
}

- (id) initWithFilePath: (NSString *) aFilePath offset: (NSInteger) aOffset;

@end
