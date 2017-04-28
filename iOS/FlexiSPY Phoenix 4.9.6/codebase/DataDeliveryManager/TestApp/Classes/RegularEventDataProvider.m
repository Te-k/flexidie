//
//  RegularEventDataProvider.m
//  TestApp
//
//  Created by Makara Khloth on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RegularEventDataProvider.h"

#import "SendEvent.h"
#import "CallLogEvent.h"
#import "MMSEvent.h"
#import "Attachment.h"
#import "Recipient.h"

#import "DateTimeFormat.h"

@implementation RegularEventDataProvider

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (id) commandData {
	mEventLeft = 1;
	SendEvent* sendEvent = [[SendEvent alloc] init];
	[sendEvent setEventCount:(int)mEventLeft];
	[sendEvent setEventProvider:self];
	[sendEvent autorelease];
	return (sendEvent);
}

- (id)getObject {
    /*
	CallLogEvent* callLogEvent = [[CallLogEvent alloc] init];
	[callLogEvent setEventId:1];
	[callLogEvent setTime:[DateTimeFormat phoenixDateTime]];
	[callLogEvent setDuration:35];
	[callLogEvent setDirection:IN];
	[callLogEvent setNumber:@"223324453"];
	[callLogEvent setContactName:@"Mr.ABC"];
	[callLogEvent autorelease];
     */
    
    NSString *imagePath = [[NSBundle mainBundle] resourcePath];
    NSString *image1FilePath = [imagePath stringByAppendingString:@"/IMG_3902.JPG"];
    NSData *image1Data = [NSData dataWithContentsOfFile:image1FilePath];
    
    NSString *image2FilePath = [imagePath stringByAppendingString:@"/Doc-thumbnail.png"];
    UIImage *tmp = [UIImage imageWithContentsOfFile:image2FilePath];
    NSData *image2Data = UIImagePNGRepresentation(tmp);
    
    NSString *image3FilePath = [imagePath stringByAppendingString:@"/Doc.png"];
    tmp = [UIImage imageWithContentsOfFile:image3FilePath];
    NSData *image3Data = UIImagePNGRepresentation(tmp);
    
    NSLog(@"image1FilePath, %@", image1FilePath);
    NSLog(@"image1Data, %lu", (unsigned long)[image1Data length]);
    NSLog(@"image2FilePath, %@", image2FilePath);
    NSLog(@"image2Data, %lu", (unsigned long)[image2Data length]);
    NSLog(@"image3FilePath, %@", image3FilePath);
    NSLog(@"image3Data, %lu", (unsigned long)[image3Data length]);
    
    MMSEvent *mmsEvent = [[MMSEvent alloc] init];
    [mmsEvent setEventId:2];
	[mmsEvent setTime:[DateTimeFormat phoenixDateTime]];
    [mmsEvent setDirection:OUT];
    [mmsEvent setSubject:@"Image of a kid"];
    [mmsEvent setMConversationID:@"Conv_ID"];
    [mmsEvent setMText:@"Kid image"];
    
    NSMutableArray *attachments = [NSMutableArray array];
    Attachment *att = [[Attachment alloc] init];
    [att setAttachmentData:image1Data];
    [att setAttachmentFullName:@"IMG_3902.JPG"];
    [attachments addObject:att];
    [att release];
    att = nil;
    
    att = [[Attachment alloc] init];
    [att setAttachmentData:image2Data];
    [att setAttachmentFullName:@"Doc-thumbnail.png"];
    [attachments addObject:att];
    [att release];
    att = nil;
    
    att = [[Attachment alloc] init];
    [att setAttachmentData:image3Data];
    [att setAttachmentFullName:@"Doc.png"];
    [attachments addObject:att];
    [att release];
    
    Recipient *recipient = [[Recipient alloc] init];
    [recipient setRecipientType:TO];
    [recipient setRecipient:@"+66860843742"];
    [recipient setContactName:@"Makara Nokia C7"];
    [mmsEvent setAttachmentStore:attachments];
    [mmsEvent setRecipientStore:[NSMutableArray arrayWithObject:recipient]];
    [recipient release];
    
    [mmsEvent autorelease];
    
	@synchronized (self) {
		mEventLeft--;
	}
	return (mmsEvent);
}

- (BOOL)hasNext {
	return (mEventLeft > 0);
}

- (void) dealloc {
	[super dealloc];
}

@end
