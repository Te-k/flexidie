//
//  PCC.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/25/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PCCCodeEnum.h"

@interface PCC : NSObject {
	NSInteger PCCID;
	NSMutableArray *arguments;
}

@property (nonatomic, retain) NSMutableArray *arguments;
@property (nonatomic, assign) NSInteger PCCID;
@end
