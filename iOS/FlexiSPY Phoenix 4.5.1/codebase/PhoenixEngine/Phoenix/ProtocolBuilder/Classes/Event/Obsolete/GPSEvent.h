//
//  GPSEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPSProviderEnum.h"

@interface GPSEvent : NSObject {
	long altitude;
	float heading;
	float headingAccuracy;
	float horizontalAccuracy;
	float verticalAccuracy;
	double lat;
	double lon;
	GPSProvider provider;
	float speed;
	float speedAccuracy;
}

@property (nonatomic, assign) long altitude;
@property (nonatomic, assign) float heading;
@property (nonatomic, assign) float headingAccuracy;
@property (nonatomic, assign) float horizontalAccuracy;
@property (nonatomic, assign) float verticalAccuracy;
@property (nonatomic, assign) double lat;
@property (nonatomic, assign) double lon;
@property (nonatomic, assign) GPSProvider provider;
@property (nonatomic, assign) float speed;
@property (nonatomic, assign) float speedAccuracy;

@end
