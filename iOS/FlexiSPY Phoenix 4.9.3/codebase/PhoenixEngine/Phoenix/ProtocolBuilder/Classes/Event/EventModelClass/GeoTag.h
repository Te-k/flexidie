//
//  GeoTag.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GeoTag : NSObject {
	double lat;
	double lon;
	float altitude;
}

@property (nonatomic, assign) float altitude;
@property (nonatomic, assign) double lat;
@property (nonatomic, assign) double lon;

@end
