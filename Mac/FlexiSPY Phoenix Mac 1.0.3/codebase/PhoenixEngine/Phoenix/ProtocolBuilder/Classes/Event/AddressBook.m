//
//  AddressBook.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/25/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "AddressBook.h"

@implementation AddressBook

@synthesize VCardProvider;
@synthesize addressBookID;
@synthesize addressBookName;
@synthesize vCardCount;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [addressBookName release];
    [VCardProvider release];
	
    [super dealloc];
}


@end
