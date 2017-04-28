//
//  FxIMGeoTag.h
//  FxEvents
//
//  Created by Makara Khloth on 1/18/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FxIMGeoTag : NSObject <NSCoding, NSCopying> {
@private
	float	mLongitude; // double would cause unit test fail ???
	float	mLatitude;  // double would cause unit test fail ???
	float	mAltitued;
	float	mHorAccuracy;
	
	NSString *mPlaceName;
}

@property (nonatomic, assign) float mLongitude;
@property (nonatomic, assign) float mLatitude;
@property (nonatomic, assign) float mAltitude;
@property (nonatomic, assign) float mHorAccuracy;
@property (nonatomic, copy) NSString *mPlaceName;

@end
