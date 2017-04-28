//
//  FxGPSTag.h
//  FxEvents
//
//  Created by Makara Khloth on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kFxCoordinateAccUnknown,
	kFxCoordinateAccCoarse,
	kFxCoordinateAccFine
} FxCoordinateAcc;

@interface FxGPSTag : NSObject <NSCoding> {
@private
	NSUInteger	dbId;
	float	longitude;
	float	latitude;
	float	altitude;
	FxCoordinateAcc	mCoordinateAcc;
	NSInteger	cellId;
	NSString*	mCellName;
	NSString*	areaCode;
	NSString*	networkId;
	NSString*	countryCode;
	NSString*	mNetworkName;
}

@property (nonatomic) NSUInteger dbId;
@property (nonatomic) float longitude;
@property (nonatomic) float latitude;
@property (nonatomic) float altitude;
@property (nonatomic) FxCoordinateAcc mCoordinateAcc;
@property (nonatomic) NSInteger cellId;
@property (nonatomic, copy) NSString* mCellName;
@property (nonatomic, copy) NSString* areaCode;
@property (nonatomic, copy) NSString* networkId;
@property (nonatomic, copy) NSString* countryCode;
@property (nonatomic, copy) NSString* mNetworkName;

@end
