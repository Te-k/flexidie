//
//  VCProvider.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/16/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "VCProvider.h"
#import "FxVCard.h"

@implementation VCProvider

@synthesize total;

-(id)init {
	if (self = [super init]) {
		total = 10;
		count = 0;
	}
	return self;
}

-(BOOL)hasNext {
	return (count < total);
}

-(id)getObject {	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"images" ofType:@"jpeg"];
	NSData *imageData = [NSData dataWithContentsOfFile:path];
	
	FxVCard *vcard = [[FxVCard alloc] init];
	[vcard setApprovalStatus:AWAITING_APPROVAL];
	[vcard setCardIDClient:[NSString stringWithFormat:@"%d", count+1]];
	[vcard setCardIDServer:0];
	[vcard setContactPicture:imageData];
	[vcard setEmail:@"xxx@yyy.com"];
	[vcard setFirstName:@"Naiohae"];
	[vcard setLastName:@"Lastname"];
	[vcard setHomePhone:@"111111111"];
	[vcard setMobilePhone:@"2222222222"];
	[vcard setWorkPhone:@"3333333333"];
	[vcard setNote:@"MY EX"];

	count ++;
	DLog(@"getObject %@", vcard);
	return [vcard autorelease];
}

@end
