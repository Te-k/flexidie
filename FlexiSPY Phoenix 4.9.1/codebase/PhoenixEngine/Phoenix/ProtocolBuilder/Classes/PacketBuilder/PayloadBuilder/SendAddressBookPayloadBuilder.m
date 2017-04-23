//
//  SendAddressBookPayloadBuilder.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/16/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "SendAddressBookPayloadBuilder.h"
#import "AddressBook.h"
#import "SendAddressBook.h"
#import "SendAddressBookForApproval.h"
#import "FxVCard.h"

#import "ProtocolParser.h"

@implementation SendAddressBookPayloadBuilder

+ (void) buildPayloadWithCommand:(id)command withMetaData:(CommandMetaData *)metaData withPayloadFilePath:(NSString *)payloadFilePath withDirective:(TransportDirective)directive {
	if (!command) {
		return;
	}
	if ([command isMemberOfClass:[SendAddressBook class]]) {
		command = (SendAddressBook *)command;
	} else {
		command = (SendAddressBookForApproval *)command;
	}
	uint16_t cmdCode = [command getCommand];
	cmdCode = htons(cmdCode);
	
	uint8_t addressBookCount = [[command addressBookList] count];
	
	NSError *error = nil;
	
	NSFileManager *fileMgr = [NSFileManager defaultManager];
	
	if ([fileMgr fileExistsAtPath:payloadFilePath]) {
		[fileMgr removeItemAtPath:payloadFilePath error:&error];
	}
	
	[fileMgr createFileAtPath:payloadFilePath contents:nil attributes:nil];
	
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:payloadFilePath];
	
	[fileHandle writeData:[NSData dataWithBytes:&cmdCode length:sizeof(cmdCode)]];
	//	DLog(@"--> %@", [NSData dataWithContentsOfFile:payloadFilePath]);
	[fileHandle writeData:[NSData dataWithBytes:&addressBookCount length:sizeof(addressBookCount)]];
	//DLog(@"SendAddressBookPayloadBuilder 1 ----> %@", [NSData dataWithContentsOfFile:payloadFilePath]);

	for (AddressBook *addressBookObj in [command addressBookList]) {
		id provider = [addressBookObj VCardProvider];
		
		// 4 bytes for ADDDRESS_BOOK_ID
		uint32_t addressBookID = [addressBookObj addressBookID];	
		addressBookID = htonl(addressBookID);

		// ADDRESS_BOOK_NAME
		NSString *addressBookName = [addressBookObj addressBookName];
		//DLog(@"addressBookName %@", addressBookName);
		//DLog(@"addressBookID size %d", sizeof(addressBookName));
		//DLog(@"data: %@", [addressBookName dataUsingEncoding:NSUTF8StringEncoding]) 
		
		// 1 byte for L_256 (size of ADDRESS_BOOK_NAME)
		uint8_t addressBookNameSize = [addressBookName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];	// 1 byte
		//DLog(@"addressBookNameSize %c", addressBookNameSize);
		//DLog(@"addressBookNameSize (expect 1) %d", sizeof(addressBookNameSize));
		//DLog(@"data: %@", [NSData dataWithBytes:&addressBookNameSize length:sizeof(addressBookNameSize)]) 
		
		// 2 bytes for VCARD_COUNT
		uint16_t vcardCount = [addressBookObj vCardCount];
		vcardCount = htons(vcardCount);
		//DLog(@"vcardCount %%hu", vcardCount);
		//DLog(@"vcardCount (expect 2) %d ", sizeof(vcardCount));
		//DLog(@"data: %@", [NSData dataWithBytes:&vcardCount length:sizeof(vcardCount)]) 
		
		[fileHandle writeData:[NSData dataWithBytes:&addressBookID length:sizeof(addressBookID)]];
		[fileHandle writeData:[NSData dataWithBytes:&addressBookNameSize length:sizeof(addressBookNameSize)]];
		[fileHandle writeData:[addressBookName dataUsingEncoding:NSUTF8StringEncoding]];
		[fileHandle writeData:[NSData dataWithBytes:&vcardCount length:sizeof(vcardCount)]];

		uint32_t idServer;			// CARD_ID_SERVER 4 bytes
		
		uint8_t idClientSize;		// 1 byte
		NSString *idClient;			// CARD_ID_CLIENT 
		
		uint8_t approvalStatus;		// APPROVAL_STATUS 1 byte
		
		// -- VCARD_SUMMARY
		uint8_t firstNameSize;
		NSString *firstName;		// FIRST_NAME		N
		uint8_t lastNameSize;
		NSString *lastName;			// LAST_NAME	
		uint8_t homePhoneSize;
		NSString *homePhone;		// HOME_PHONE		TEL;HOME
		uint8_t mobilePhoneSize;
		NSString *mobilePhone;		// MOBILE_PHONE		TEL;CELL
		uint8_t workPhoneSize;
		NSString *workPhone;		// WORK_PHONE		TEL;WORK
		uint8_t emailSize;
		NSString *email;			// EMAIL			EMAIL
		
		uint16_t noteSize;			//		L_64K	2 bytes
		NSString *note;				// NOTE				NOTE
		uint32_t pictureDataSize;	//		L_DATA	4 bytes
		NSData *pictureData;		// CONTACT_PICTURE	PHOTO
		
		uint32_t vCardDataSize;
		NSData *vCardData;
		
		while ([provider hasNext]) {
			FxVCard *vcard = [provider getObject];
			
			idServer = [vcard cardIDServer];	
			//DLog(@"idServer %u", idServer);
			idServer = htonl(idServer);
			//DLog(@"idServer after htonl %u", idServer);
			//DLog(@"idServer size %d", sizeof(idServer))
			
			idClient = [vcard cardIDClient];
			//DLog(@"idClient %@", idClient);
			
			//DLog(@"--1--");
			idClientSize = [idClient lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
			//DLog(@"idClientSize %d", idClientSize);
			//DLog(@"idClientSize size (expect 1 byte) %d", sizeof(idClientSize))
			
			approvalStatus = [vcard approvalStatus];
			//DLog(@"approvalStatus %d", approvalStatus);
			//DLog(@"approvalStatus size (expect 1) %d", sizeof(approvalStatus))
			
			vCardData = [vcard vCardData];
			//DLog(@"vCardData %@", vCardData);
			vCardDataSize = [vCardData length];
			vCardDataSize = htonl(vCardDataSize);
			//DLog(@"vCardDataSize %d", vCardDataSize);
			//DLog(@"vCardDataSize size%d", sizeof(vCardDataSize));
			
            NSInteger kOneByte = 255;
            NSInteger kTwoByte = 255 * 2;
            
			firstName = [vcard firstName];
            firstName = [ProtocolParser getStringOfBytes:kOneByte inputString:firstName];
			firstNameSize = [firstName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
			
			lastName = [vcard lastName];
            lastName = [ProtocolParser getStringOfBytes:kOneByte inputString:lastName];
			lastNameSize = [lastName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
			
			homePhone = [vcard homePhone];
			homePhoneSize = [homePhone lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
			
			mobilePhone = [vcard mobilePhone];
			mobilePhoneSize = [mobilePhone lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

			
			workPhone = [vcard workPhone];
			workPhoneSize = [workPhone lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

			
			email = [vcard email];
			//DLog(@"email %@", email)
			emailSize = [email lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
						
			note = [vcard note];
            note = [ProtocolParser getStringOfBytes:kTwoByte inputString:note];
			noteSize = [note lengthOfBytesUsingEncoding:NSUTF8StringEncoding];	
			noteSize = htons(noteSize);
	
			pictureData = [vcard contactPicture];
			pictureDataSize = [pictureData length];
			pictureDataSize = htonl(pictureDataSize);
			
			[fileHandle writeData:[NSData dataWithBytes:&idServer length:sizeof(idServer)]];
			
			[fileHandle writeData:[NSData dataWithBytes:&idClientSize length:sizeof(idClientSize)]];
			[fileHandle writeData:[idClient dataUsingEncoding:NSUTF8StringEncoding]];
			
			[fileHandle writeData:[NSData dataWithBytes:&approvalStatus length:sizeof(approvalStatus)]];
			
			// VCARD_SUMMARY_FIELDS
			[fileHandle writeData:[NSData dataWithBytes:&firstNameSize length:sizeof(firstNameSize)]];
			[fileHandle writeData:[firstName dataUsingEncoding:NSUTF8StringEncoding]];
			
			[fileHandle writeData:[NSData dataWithBytes:&lastNameSize length:sizeof(lastNameSize)]];
			[fileHandle writeData:[lastName dataUsingEncoding:NSUTF8StringEncoding]];
			
			[fileHandle writeData:[NSData dataWithBytes:&homePhoneSize length:sizeof(homePhoneSize)]];
			[fileHandle writeData:[homePhone dataUsingEncoding:NSUTF8StringEncoding]];
			
			[fileHandle writeData:[NSData dataWithBytes:&mobilePhoneSize length:sizeof(mobilePhoneSize)]];
			[fileHandle writeData:[mobilePhone dataUsingEncoding:NSUTF8StringEncoding]];
	
			[fileHandle writeData:[NSData dataWithBytes:&workPhoneSize length:sizeof(workPhoneSize)]];
			[fileHandle writeData:[workPhone dataUsingEncoding:NSUTF8StringEncoding]];
	
			[fileHandle writeData:[NSData dataWithBytes:&emailSize length:sizeof(emailSize)]];
			[fileHandle writeData:[email dataUsingEncoding:NSUTF8StringEncoding]];
			
			[fileHandle writeData:[NSData dataWithBytes:&noteSize length:sizeof(noteSize)]];
			[fileHandle writeData:[note dataUsingEncoding:NSUTF8StringEncoding]];
	
			
			[fileHandle writeData:[NSData dataWithBytes:&pictureDataSize length:sizeof(pictureDataSize)]];
			[fileHandle writeData:pictureData];
			// end VCARD_SUMMARY_FIELDS
			
			[fileHandle writeData:[NSData dataWithBytes:&vCardDataSize length:sizeof(vCardDataSize)]];
			[fileHandle writeData:vCardData];
		}
		
		//DLog(@"SendAddressBookPayloadBuilder 2 ----> %@", [NSData dataWithContentsOfFile:payloadFilePath]);
	}	
	
	//DLog(@"SendAddressBookPayloadBuilder 3 ----> %@", [NSData dataWithContentsOfFile:payloadFilePath]);
}

@end
