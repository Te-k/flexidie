//
//  ResponseUrlProfileProvider.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProvider.h"

@interface ResponseUrlProfileProvider : NSObject <DataProvider> {
@private
	NSString		*mFilePath;
	NSFileHandle	*mFileHandle;
	NSInteger	mOffset;
	
	NSInteger	mStep;
	NSInteger	mAllowUrlCount;
	NSInteger	mDisAllowUrlCount;
	NSInteger	mIndex;
}

- (id) initWithFilePath: (NSString *) aFilePath offset: (NSInteger) aOffset;

@end
