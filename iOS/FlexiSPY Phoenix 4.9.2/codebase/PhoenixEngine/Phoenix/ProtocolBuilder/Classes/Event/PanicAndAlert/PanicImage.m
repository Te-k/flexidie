//
//  PanicImage.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "PanicImage.h"
#import "EventTypeEnum.h"

@implementation PanicImage

@synthesize lat;
@synthesize lon;
@synthesize altitude;
@synthesize coordinateAccuracy;
@synthesize networkName;
@synthesize networkID;
@synthesize cellName;
@synthesize cellID;
@synthesize countryCode;
@synthesize areaCode;
@synthesize mediaType;
@synthesize mediaData;

-(EventType)getEventType {
	return PANIC_IMAGE;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [networkName release];
    [networkID release];
    [cellName release];
    [mediaData release];
	
    [super dealloc];
}


@end
