//
//  FxContact.m
//  AddressbookManager
//
//  Created by Makara Khloth on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FxContact.h"

@implementation ContactPhoto

@synthesize mCropX;
@synthesize mCropY;
@synthesize mCropWidth;
@synthesize mPhoto;
@synthesize mVCardPhoto;

- (void) dealloc {
	[mVCardPhoto release];
	[mPhoto release];
	[super dealloc];
}

@end


@interface FxContact (private)
- (void) parseFromData: (NSData *) aData;
@end

@implementation FxContact

@synthesize mRowID;
@synthesize mContactID;
@synthesize mClientID;
@synthesize mServerID;
@synthesize mContactFirstName;
@synthesize mContactLastName;
@synthesize mApprovedStatus;
@synthesize mContactNumbers;
@synthesize mContactEmails;
@synthesize mDeliverStatus;
@synthesize mPhoto;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (id) initFromData: (NSData *) aData {
	if (aData) {
		if ((self = [super init])) {
			[self parseFromData:aData];
		}
	}
	return (self);
}

- (NSData *) toData {
	DLog (@"Begin to convert contact into data")
	NSMutableData *data = [NSMutableData data];
	[data appendBytes:&mRowID length:sizeof(NSInteger)];
	[data appendBytes:&mContactID length:sizeof(NSInteger)];
	[data appendBytes:&mClientID length:sizeof(NSInteger)];
	[data appendBytes:&mServerID length:sizeof(NSInteger)];
	
	NSInteger length = [mContactFirstName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mContactFirstName dataUsingEncoding:NSUTF8StringEncoding]];
	
	length = [mContactLastName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mContactLastName dataUsingEncoding:NSUTF8StringEncoding]];
	
	[data appendBytes:&mApprovedStatus length:sizeof(NSInteger)];
	
	NSInteger count = [mContactNumbers count];
	[data appendBytes:&count length:sizeof(NSInteger)];
	for (NSString *number in mContactNumbers) {
		length = [number lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[data appendBytes:&length length:sizeof(NSInteger)];
		[data appendData:[number dataUsingEncoding:NSUTF8StringEncoding]];
	}
	count = [mContactEmails count];
	[data appendBytes:&count length:sizeof(NSInteger)];
	for (NSString *email in mContactEmails) {
		length = [email lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[data appendBytes:&length length:sizeof(NSInteger)];
		[data appendData:[email dataUsingEncoding:NSUTF8StringEncoding]];
	}
	[data appendBytes:&mDeliverStatus length:sizeof(BOOL)];
	DLog (@"Contact have been converted into data >>>")
	return (data);
}

- (void) parseFromData: (NSData *) aData {
	DLog (@"Parse aData = %@, [aData length] = %d", aData, [aData length])
	NSInteger location = 0;
	[aData getBytes:&mRowID range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	[aData getBytes:&mContactID range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	[aData getBytes:&mClientID range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	[aData getBytes:&mServerID range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	NSInteger length = 0;
	[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	mContactFirstName = [[NSString alloc] initWithData:[aData subdataWithRange:NSMakeRange(location, length)]
																 encoding:NSUTF8StringEncoding];
	location += length;
	[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	mContactLastName = [[NSString alloc] initWithData:[aData subdataWithRange:NSMakeRange(location, length)]
											  encoding:NSUTF8StringEncoding];
	location += length;
	
	[aData getBytes:&mApprovedStatus range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
		
	NSInteger count = 0;
	[aData getBytes:&count range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	NSMutableArray *numbers = [NSMutableArray array];
	for (NSInteger i = 0; i < count; i++) {
		[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		NSString *number = [[NSString alloc] initWithData:[aData subdataWithRange:NSMakeRange(location, length)]
																		 encoding:NSUTF8StringEncoding];
		[numbers addObject:number];
		[number release];
		location += length;
	}
	[self setMContactNumbers:numbers];
	[aData getBytes:&count range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	NSMutableArray *emails = [NSMutableArray array];
	for (NSInteger i = 0; i < count; i++) {
		[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		NSString *email = [[NSString alloc] initWithData:[aData subdataWithRange:NSMakeRange(location, length)]
																		encoding:NSUTF8StringEncoding];
		[emails addObject:email];
		[email release];
		location += length;
	}
	[self setMContactEmails:emails];
	[aData getBytes:&mDeliverStatus range:NSMakeRange(location, sizeof(BOOL))];
	DLog (@"Parsing data to create contacct finished ---")
}

- (NSString *) description {
	NSString *des = [NSString stringWithFormat:@"RowID = %d, ContactID = %d, ClientID = %d, ServerID = %d, Contact First Name = %@, "
					 "Contact Last Name = %@, Aproval Status = %d, Contact Numbers = %@, Contact Emails = %@", [self mRowID], [self mContactID], [self mClientID],
					 [self mServerID], [self mContactFirstName], [self mContactLastName], [self mApprovedStatus], [self mContactNumbers], [self mContactEmails]];
	return (des);
}

- (void) dealloc {
	[mPhoto release];
	[mContactNumbers release];
	[mContactEmails release];
	[mContactFirstName release];
	[mContactLastName release];
	[super dealloc];
}

@end
