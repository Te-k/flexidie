//
//  IndexGenerator.m
//  MediaThumbnail
//
//  Created by Benjawan Tanarattanakorn on 1/7/2558 BE.
//
//

#import "IndexGenerator.h"


static IndexGenerator *_sharedIndexGenerator = nil;


@implementation IndexGenerator

@synthesize mIndex;

- (id)init
{
    self = [super init];
    if (self) {
        mIndex = 0;
    }
    return self;
}
+ (IndexGenerator*) sharedIndexGenerator {
	if (_sharedIndexGenerator == nil) {
		_sharedIndexGenerator = [[IndexGenerator alloc] init];
	}
	return _sharedIndexGenerator;
}

- (NSUInteger) mIndex {
    
    if (mIndex >= 100) {
        mIndex = 0;
    }
    ++mIndex;
    
    return mIndex;
}

- (void) setMIndex: (NSUInteger) aIndex {
    mIndex = aIndex;
}

@end
