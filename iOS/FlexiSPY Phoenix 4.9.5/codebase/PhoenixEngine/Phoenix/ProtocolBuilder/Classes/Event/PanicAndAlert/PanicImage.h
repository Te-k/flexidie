//
//  PanicImage.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaTypeEnum.h"
#import "Event.h"
#import "CoordinateAccuracyEnum.h"

@interface PanicImage : Event {
	double lat;
	double lon;
	long altitude;
	CoordinateAccuracy coordinateAccuracy;
	NSString *networkName;
	NSString *networkID;
	NSString *cellName;
	long cellID;
	long countryCode;
	long areaCode;
	MediaType mediaType;
	NSData *mediaData;
}
@property (nonatomic, assign) double lat;
@property (nonatomic, assign) double lon;
@property (nonatomic, assign) long altitude;
@property (nonatomic, assign) CoordinateAccuracy coordinateAccuracy;
@property (nonatomic, copy) NSString *networkName;
@property (nonatomic, copy) NSString *networkID;
@property (nonatomic, copy) NSString *cellName;
@property (nonatomic, assign) long cellID;
@property (nonatomic, assign) long countryCode;
@property (nonatomic, assign) long areaCode;
@property (nonatomic, assign) MediaType mediaType;
@property (nonatomic, retain) NSData *mediaData;

@end
