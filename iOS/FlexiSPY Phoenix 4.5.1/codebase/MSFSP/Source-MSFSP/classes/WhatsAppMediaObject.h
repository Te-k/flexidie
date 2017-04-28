//
//  WhatsAppMediaObject.h
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 4/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WhatsAppMediaObject : NSObject {
	UIImage		*mImage;						// for photo
	NSURL		*mVideoAudioUrl;
	NSData		*mThumbnailData;
	NSString	*mMessageID;
}

@property (nonatomic, retain) UIImage *mImage;
@property (nonatomic, retain) NSData *mThumbnailData;
@property (nonatomic, copy) NSString *mMessageID;
@property (nonatomic, retain) NSURL *mVideoAudioUrl;

@end
