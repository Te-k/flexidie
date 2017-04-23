//
//  GetCSIDResponse.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseData.h"

@interface GetCSIDResponse : ResponseData {
	NSArray *CSIDList;
}
@property (nonatomic, retain) NSArray *CSIDList;

@end
