//
//  SendAddressBook.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/25/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandData.h"

@interface SendAddressBook : NSObject <CommandData>{
	NSArray *addressBookList;
}

@property (nonatomic, retain) NSArray *addressBookList;
@end
