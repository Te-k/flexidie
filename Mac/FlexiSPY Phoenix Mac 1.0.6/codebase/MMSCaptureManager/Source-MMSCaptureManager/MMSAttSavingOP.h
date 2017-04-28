//
//  MMSAttSavingOP.h
//  MMSCaptureManager
//
//  Created by Makara Khloth on 2/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMSAttSavingOP : NSOperation {
@private
	NSString	*mAttFullPath;
	id			mAttSource;
}

@property (nonatomic, copy) NSString *mAttFullPath;
@property (nonatomic, retain) id mAttSource;

@end
