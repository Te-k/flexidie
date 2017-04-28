/*
 *  DebugEventProtocol.h
 *  ProtocolBuilder
 *
 *  Created by Pichaya Srifar on 8/29/11.
 *  Copyright 2011 Vervata. All rights reserved.
 *
 */

#import "DebugModeEnum.h"

@protocol DebugEventProtocol <NSObject>

- (int)getFieldCount;
- (DebugMode)getMode;

@end
