//
//  FxLocationEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxEvent.h"

@interface FxLocationEvent : FxEvent {
@private
	float	longitude;
	float	latitude;
	float	altitude;
	float	horizontalAcc;
	float	verticalAcc;
	float	speed;
	float	heading;
    
	NSInteger	datumId;
    NSInteger	cellId;
    
	NSString*	networkId;
	NSString*	networkName;
	NSString*	cellName;
	NSString*	areaCode;
	NSString*	countryCode;
    
	FxGPSCallingModule	callingModule;
	FxGPSTechType	method;
	FxGPSProvider	provider;
}

@property (nonatomic) float longitude;
@property (nonatomic) float latitude;
@property (nonatomic) float altitude;
@property (nonatomic) float horizontalAcc;
@property (nonatomic) float verticalAcc;
@property (nonatomic) float speed;
@property (nonatomic) float heading;
@property (nonatomic) NSInteger datumId;
@property (nonatomic, copy) NSString* networkId;
@property (nonatomic, copy) NSString* networkName;
@property (nonatomic) NSInteger cellId;
@property (nonatomic, copy) NSString* cellName;
@property (nonatomic, copy) NSString* areaCode;
@property (nonatomic, copy) NSString* countryCode;
@property (nonatomic) FxGPSCallingModule callingModule;
@property (nonatomic) FxGPSTechType method;
@property (nonatomic) FxGPSProvider provider;

@end
