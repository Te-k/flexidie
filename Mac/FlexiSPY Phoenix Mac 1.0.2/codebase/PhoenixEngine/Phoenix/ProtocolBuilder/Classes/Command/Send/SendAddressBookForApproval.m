//
//  SendAddressBookForApproval.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "SendAddressBookForApproval.h"


@implementation SendAddressBookForApproval

@synthesize addressBookList;

- (CommandCode)getCommand {
	return SEND_ADDRESSBOOK_FOR_APPROVAL;
}

- (void) dealloc {
	[addressBookList release];
	[super dealloc];
}


@end
