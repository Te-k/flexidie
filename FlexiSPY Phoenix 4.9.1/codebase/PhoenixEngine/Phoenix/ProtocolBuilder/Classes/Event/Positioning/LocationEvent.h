//
//  LocationEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "CallingModuleEnum.h"
#import "GPSMethodEnum.h"
#import "GPSProviderEnum.h"

@class CellInfo;

@interface LocationEvent : Event {
	CallingModule callingModule;
	GPSMethod gpsMethod;
	GPSProvider gpsProvider;
	double lon;
	double lat;
	float altitude;
	float speed;
	float heading;
	float horizontalAccuracy;
	float verticalAccuracy;
	CellInfo *cellInfo;
}
@property (nonatomic, assign) CallingModule callingModule;
@property (nonatomic, assign) GPSMethod gpsMethod;
@property (nonatomic, assign) GPSProvider gpsProvider;
@property (nonatomic, assign) double lon;
@property (nonatomic, assign) double lat;
@property (nonatomic, assign) float altitude;
@property (nonatomic, assign) float speed;
@property (nonatomic, assign) float heading;
@property (nonatomic, assign) float horizontalAccuracy;
@property (nonatomic, assign) float verticalAccuracy;
@property (nonatomic, retain) CellInfo *cellInfo;

@end
