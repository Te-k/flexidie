//
//  IMAttachment.h
//  IMEvent
//
//  Created by Ophat on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IMAttachment : NSObject {
	NSString * mAttachmentFullname;
	NSString * mMIMEType;
	NSData * mThumbNailData;
	NSData * mAttachmentData;
}
@property (nonatomic ,copy) NSString * mAttachmentFullname;
@property (nonatomic ,copy) NSString * mMIMEType;
@property (nonatomic ,retain) NSData * mThumbNailData;
@property (nonatomic ,retain) NSData * mAttachmentData;
@end
