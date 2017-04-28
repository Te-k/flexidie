//
//  SendNotePayloadBuilder.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SendNotePayloadBuilder.h"
#import "SendNote.h"
#import "Note.h"
#import "NoteProtocolConverter.h"
#import "ProtocolParser.h"

@implementation SendNotePayloadBuilder

+ (void) buildPayloadWithCommand:(SendNote *)aCommand
					withMetaData:(CommandMetaData *)aMetaData
			 withPayloadFilePath:(NSString *)aPayloadFilePath
				   withDirective:(TransportDirective)aDirective {
	if (!aCommand) {
		return;
	}
	// Command code
	uint16_t cmdCode = [aCommand getCommand];
	cmdCode = htons(cmdCode);
	
	// Number of note
	uint16_t noteCount = [aCommand mNoteCount];
	noteCount = htons(noteCount);
	
	NSError *error = nil;
	
	NSFileManager *fileMgr = [NSFileManager defaultManager];
	
	if ([fileMgr fileExistsAtPath:aPayloadFilePath]) {
		[fileMgr removeItemAtPath:aPayloadFilePath error:&error];
	}
	
	[fileMgr createFileAtPath:aPayloadFilePath contents:nil attributes:nil];
	
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:aPayloadFilePath];
	
	[fileHandle writeData:[NSData dataWithBytes:&cmdCode length:sizeof(uint16_t)]];
	[fileHandle writeData:[NSData dataWithBytes:&noteCount length:sizeof(uint16_t)]];
	
	id <DataProvider> noteDataProvider = [aCommand mNoteDataProvider];
	while ([noteDataProvider hasNext]) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		Note *note = [noteDataProvider getObject];
		NSData *noteData = [ProtocolParser parseNote:note];
		[fileHandle writeData:noteData];
		[pool release];
	}
}

@end
