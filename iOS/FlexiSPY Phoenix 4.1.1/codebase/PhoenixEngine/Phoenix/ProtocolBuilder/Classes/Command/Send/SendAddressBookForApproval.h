//
//  SendAddressBookForApproval.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandData.h"

@interface SendAddressBookForApproval : NSObject <CommandData>{
	NSArray *addressBookList;
}

@property (nonatomic, retain) NSArray *addressBookList;

@end
