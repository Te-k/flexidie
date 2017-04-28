//
//  AddressBook.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/25/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProvider.h"

@interface AddressBook : NSObject {
	int addressBookID;
	NSString *addressBookName;
	int vCardCount;
	id<DataProvider> VCardProvider;
}

@property (nonatomic,assign) int addressBookID;
@property (nonatomic, retain) NSString *addressBookName;
@property (nonatomic, assign) int vCardCount;
@property (nonatomic, retain) id<DataProvider> VCardProvider;

@end
