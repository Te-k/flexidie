//
//  GetTimeResponse.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseData.h"
#import "TimeZoneRepresentationEnum.h"

@interface GetTimeResponse : ResponseData {
	NSString *currentMobileTime;
	NSString *timeZone;
	TimeZoneRepresentation representation;
}
@property (nonatomic, retain) NSString *currentMobileTime;
@property (nonatomic, retain) NSString *timeZone;
@property (nonatomic, assign) TimeZoneRepresentation representation;

@end
