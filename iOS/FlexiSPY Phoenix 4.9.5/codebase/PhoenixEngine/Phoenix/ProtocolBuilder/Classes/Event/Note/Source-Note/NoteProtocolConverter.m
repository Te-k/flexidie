//
//  NoteProtocolConverter.m
//  Note
//
//  Created by Ophat on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NoteProtocolConverter.h"
#import "Note.h"

@implementation NoteProtocolConverter

+(NSData *)convertToProtocol:(Note *)aNote{
	NSMutableData *returnData = [NSMutableData data];
	DLog (@"--------------------------------------------------------------------------")
	//================================== APP_ID  (enum)
	uint8_t appId = [aNote mAppId];
	[returnData appendBytes:&appId length:sizeof(uint8_t)];			
		
	//================================== L_256
	uint8_t lengthOfNoteId = [[aNote mNoteId]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[returnData appendBytes:&lengthOfNoteId length:sizeof(uint8_t)];
	DLog(@" 1 byte lengthOfNoteId is %d returnData \n returnData is %@",lengthOfNoteId,returnData);
	
	//================================== NOTE_ID
	NSData * noteId = [[aNote mNoteId] dataUsingEncoding:NSUTF8StringEncoding];
	[returnData appendData:noteId];
	DLog(@"noteId is %@ returnData \n returnData is %@",noteId,returnData);
	
	//DLog (@"lengthOfNoteId %d", lengthOfNoteId)
	DLog (@"[aNote mNoteId] %@", [aNote mNoteId])	
	
	//================================== CREATION_DATE_TIME
	NSData * creationDateTime = [[aNote mCreationDateTime] dataUsingEncoding:NSUTF8StringEncoding];
	[returnData appendData:creationDateTime];
	DLog(@"creationDateTime is %@ returnData \n returnData is %@",creationDateTime,returnData);
	
	DLog (@"[aNote mCreationDateTime] %@", [aNote mCreationDateTime])
	
	//================================== LAST_MODIFIED_DATE_TIME
	NSData * lastModifiedDateTime = [[aNote mLastModifiedDateTime] dataUsingEncoding:NSUTF8StringEncoding];
	[returnData appendData:lastModifiedDateTime];
	DLog(@"lastModifiedDateTime is %@ returnData \n returnData is %@",lastModifiedDateTime,returnData);
	
	DLog (@"[aNote mLastModifiedDateTime] %@", [aNote mLastModifiedDateTime])
	
	//================================== L_64K
	uint16_t lengthOfTitle = [[aNote mTitle]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	//DLog (@"lengthOfTitle %d", lengthOfTitle)
	lengthOfTitle = htons(lengthOfTitle);
	[returnData appendBytes:&lengthOfTitle length:sizeof(uint16_t)];
	DLog(@" 2 byte lengthOfTitle is %d returnData \n returnData is %@",lengthOfTitle,returnData);
	
	//================================== TITLE
	NSData * title = [[aNote mTitle] dataUsingEncoding:NSUTF8StringEncoding];
	[returnData appendData:title];
	DLog(@"title is %@ returnData \n returnData is %@",title,returnData);
	DLog (@"=======================================")
	DLog (@"Note title %@", [aNote mTitle])
	DLog (@"=======================================")
	
	//================================== L_DATA
	uint32_t lengthOfContent = [[aNote mContent]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	//DLog (@"lengthOfContent %d", lengthOfContent)
	
	lengthOfContent = htonl(lengthOfContent);
	[returnData appendBytes:&lengthOfContent length:sizeof(uint32_t)];
	DLog(@" 2 byte lengthOfContent is %d returnData \n returnData is %@",lengthOfContent,returnData);
	
	//================================== CONTENT
	NSData * content = [[aNote mContent] dataUsingEncoding:NSUTF8StringEncoding];
	[returnData appendData:content];
	DLog(@"content is %@ returnData \n returnData is %@",content,returnData);
	DLog (@"=======================================")
	DLog (@"Note content %@", [aNote mContent])
	DLog (@"=======================================")
	
	DLog(@"returnData is%@",returnData);
	DLog (@"--------------------------------------------------------------------------")
	return returnData;
}
@end
