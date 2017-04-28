//
//  PanicGPS.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface PanicGPS : Event {
	long altitude;
	long areaCode;
	long cellID;
	NSString *cellName;
	long countryCode;
	double lat;
	double lon;
	NSString *networkID;
	NSString *networkName;
}

@property (nonatomic, assign) long altitude;
@property (nonatomic, assign) long areaCode;
@property (nonatomic, assign) long cellID;
@property (nonatomic, retain) NSString *cellName;
@property (nonatomic, assign) long countryCode;
@property (nonatomic, assign) double lat;
@property (nonatomic, assign) double lon;
@property (nonatomic, retain) NSString *networkID;
@property (nonatomic, retain) NSString *networkName;

@end
