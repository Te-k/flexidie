//
//  FxAttachment.h
//  FxEvents
//
//  Created by Makara Khloth on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FxAttachment : NSObject <NSCopying> {
@protected
	NSData		*mThumbnail;
	NSString*	fullPath;
	NSUInteger	dbId;
}

@property (nonatomic, retain) NSData *mThumbnail;
@property (nonatomic, copy) NSString* fullPath;
@property (nonatomic, assign) NSUInteger dbId;

@end
