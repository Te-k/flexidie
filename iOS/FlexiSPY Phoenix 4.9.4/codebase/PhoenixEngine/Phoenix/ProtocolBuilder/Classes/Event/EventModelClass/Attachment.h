//
//  Attachment.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Attachment : NSObject {
	NSData *attachmentData;
	NSString *attachmentFullName;
}

@property (nonatomic, retain) NSData *attachmentData;
@property (nonatomic, retain) NSString *attachmentFullName;

@end
