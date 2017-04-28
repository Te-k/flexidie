//
//  SendAddressBook.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/25/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "SendAddressBook.h"

@implementation SendAddressBook

@synthesize addressBookList;

- (CommandCode)getCommand {
	return SEND_ADDRESSBOOK;
}

- (void) dealloc {
	[addressBookList release];
	[super dealloc];
}

@end
