//
//  GetAddressBookResponse.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "GetAddressBookResponse.h"

@implementation GetAddressBookResponse

@synthesize addressBookList;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [addressBookList release];
	
    [super dealloc];
}


@end
