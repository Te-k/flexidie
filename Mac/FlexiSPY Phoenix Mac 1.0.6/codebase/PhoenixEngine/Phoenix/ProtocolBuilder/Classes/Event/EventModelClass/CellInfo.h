//
//  CellInfo.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/31/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CellInfo : NSObject {
	NSString *networkName;
	NSString *networkID;
	NSString *cellName;
	uint32_t cellID;
	NSString *MCC;
	uint32_t areaCode;
}

@property (nonatomic, retain) NSString *networkName;
@property (nonatomic, retain) NSString *networkID;
@property (nonatomic, retain) NSString *cellName;
@property (nonatomic, assign) uint32_t cellID;
@property (nonatomic, retain) NSString *MCC;
@property (nonatomic, assign) uint32_t areaCode;

@end
