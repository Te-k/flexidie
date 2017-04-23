//
//  CallInfoEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CallInfoEvent : NSObject {
	long areaCode;
	long cellID;
	NSString *cellName;
	long countryCode;
	NSString *networkID;
	NSString *networkName;
}

@property (nonatomic, assign) long areaCode;
@property (nonatomic, assign) long cellID;
@property (nonatomic, retain) NSString *cellName;
@property (nonatomic, assign) long countryCode;
@property (nonatomic, retain) NSString *networkID;
@property (nonatomic, retain) NSString *networkName;

@end
