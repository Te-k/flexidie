//
//  AddressBookResponseProvider.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/5/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "ResponseVCardProvider.h"
#import "FxVCard.h"
#import "Util.h"

@interface ResponseVCardProvider (private)

- (void) removeVcardFile;

@end


@implementation ResponseVCardProvider

@synthesize filePath;
@synthesize offset;
@synthesize totalVCard;
@synthesize readCount;

- (id)initWithPath:(NSString *)aFilePath offset:(int)aOffset totalVCard:(int)vCardCount {
	if(self = [super init]) {
		[self setFilePath:aFilePath];
		offset = aOffset;
		totalVCard = vCardCount;
	}
	return self;
}

-(id) getObject {
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
	[fileHandle seekToFileOffset:offset];
	
	FxVCard *vc = [[FxVCard alloc] init];
	uint32_t cardIDServer;
	uint8_t cardIDClientSize;
	NSString *cardIDClient;
	uint8_t approvalStatus;
	
	uint8_t firstNameSize;
	NSString *firstName;
	uint8_t lastNameSize;
	NSString *lastName;
	uint8_t homePhoneSize;
	NSString *homePhone;
	uint8_t mobilePhoneSize;
	NSString *mobilePhone;
	uint8_t workPhoneSize;
	NSString *workPhone;
	uint8_t emailSize;
	NSString *email;
	uint16_t noteSize;
	NSString *note;
	uint32_t pictureDataSize;
	NSData *pictureData;
	
	uint32_t vCardDataSize;
	NSData *vCardData;
	
	offset = [Util getValueFromFile:fileHandle toBuffer:&cardIDServer withBufferSize:sizeof(cardIDServer) atOffset:offset];
	cardIDServer = ntohl(cardIDServer);
	offset = [Util getValueFromFile:fileHandle toBuffer:&cardIDClientSize withBufferSize:sizeof(cardIDClientSize) atOffset:offset];
	cardIDClient = [Util getStringFromFile:fileHandle length:cardIDClientSize atOffset:&offset];
	offset = [Util getValueFromFile:fileHandle toBuffer:&approvalStatus withBufferSize:sizeof(approvalStatus) atOffset:offset];

	//DLog (@"cardIDServer %d", cardIDServer)
	//DLog (@"cardIDClient %@", cardIDClient)
		
	offset = [Util getValueFromFile:fileHandle toBuffer:&firstNameSize withBufferSize:sizeof(firstNameSize) atOffset:offset];
	firstName = [Util getStringFromFile:fileHandle length:firstNameSize atOffset:&offset];
	offset = [Util getValueFromFile:fileHandle toBuffer:&lastNameSize withBufferSize:sizeof(lastNameSize) atOffset:offset];
	lastName = [Util getStringFromFile:fileHandle length:lastNameSize atOffset:&offset];
	offset = [Util getValueFromFile:fileHandle toBuffer:&homePhoneSize withBufferSize:sizeof(homePhoneSize) atOffset:offset];
	homePhone = [Util getStringFromFile:fileHandle length:homePhoneSize atOffset:&offset];
	offset = [Util getValueFromFile:fileHandle toBuffer:&mobilePhoneSize withBufferSize:sizeof(mobilePhoneSize) atOffset:offset];
	mobilePhone = [Util getStringFromFile:fileHandle length:mobilePhoneSize atOffset:&offset];
	offset = [Util getValueFromFile:fileHandle toBuffer:&workPhoneSize withBufferSize:sizeof(workPhoneSize) atOffset:offset];
	workPhone = [Util getStringFromFile:fileHandle length:workPhoneSize atOffset:&offset];
	offset = [Util getValueFromFile:fileHandle toBuffer:&emailSize withBufferSize:sizeof(emailSize) atOffset:offset];
	email = [Util getStringFromFile:fileHandle length:emailSize atOffset:&offset];
	offset = [Util getValueFromFile:fileHandle toBuffer:&noteSize withBufferSize:sizeof(noteSize) atOffset:offset];
	noteSize = ntohs(noteSize);
	note = [Util getStringFromFile:fileHandle length:noteSize atOffset:&offset];
	offset = [Util getValueFromFile:fileHandle toBuffer:&pictureDataSize withBufferSize:sizeof(pictureDataSize) atOffset:offset];
	pictureDataSize = ntohl(pictureDataSize);
	pictureData = [Util getDataFromFile:fileHandle length:pictureDataSize atOffset:&offset];
	
	offset = [Util getValueFromFile:fileHandle toBuffer:&vCardDataSize withBufferSize:sizeof(vCardDataSize) atOffset:offset];
	vCardDataSize = ntohl(vCardDataSize);
	vCardData = [Util getDataFromFile:fileHandle length:vCardDataSize atOffset:&offset];

	[vc setCardIDServer:cardIDServer];
	[vc setCardIDClient:cardIDClient];
	[vc setApprovalStatus:approvalStatus];
	[vc setFirstName:firstName];
	[vc setLastName:lastName];
	[vc setHomePhone:homePhone];
	[vc setMobilePhone:mobilePhone];
	[vc setWorkPhone:workPhone];
	[vc setEmail:email];
	[vc setNote:note];
	[vc setContactPicture:pictureData];
	[vc setVCardData:vCardData];
	//DLog(@"vCardData %@", vCardData);
	readCount++;
	return [vc autorelease];
}

-(BOOL)hasNext {
	if (readCount == totalVCard) {
		NSFileManager *fileMgr = [NSFileManager defaultManager];
		NSError *error = nil;
		[fileMgr removeItemAtPath:filePath error:&error];
		if (error) {
			DLog(@"Error removing file, %@", [error domain]);
		}
		DLog(@"FILE %@ REMOVED", filePath);
	}
	return (readCount < totalVCard);
}

- (void) removeVcardFile {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:[self filePath] error:nil];
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc {
	[self removeVcardFile];
	[filePath release];
	[super dealloc];
}

@end
