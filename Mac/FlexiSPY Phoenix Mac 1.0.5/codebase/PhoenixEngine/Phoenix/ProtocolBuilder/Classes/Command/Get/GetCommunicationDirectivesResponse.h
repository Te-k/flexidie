//
//  GetCommunicationDirectivesResponse.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseData.h"

@interface GetCommunicationDirectivesResponse : ResponseData {
	NSArray *communicationDirectiveList;
}
@property (nonatomic, retain) NSArray *communicationDirectiveList;

@end
