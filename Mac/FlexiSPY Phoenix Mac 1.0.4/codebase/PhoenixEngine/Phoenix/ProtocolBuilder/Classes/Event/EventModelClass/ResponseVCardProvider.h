//
//  AddressBookResponseProvider.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/5/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProvider.h"

@interface ResponseVCardProvider : NSObject <DataProvider> {
	NSString *filePath;
	unsigned long offset;
	int totalVCard;
	int readCount;
}

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) unsigned long offset;
@property (nonatomic, assign) int totalVCard;
@property (nonatomic, assign) int readCount;

- (id)initWithPath:(NSString *)afilePath offset:(int)offset totalVCard:(int)vCardCount;

@end
