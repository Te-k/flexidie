/*
 *  CommandData.h
 *  ProtocolBuilder
 *
 *  Created by Pichaya Srifar on 7/26/11.
 *  Copyright 2011 Vervata. All rights reserved.
 *
 */
#import "CommandCodeEnum.h"

@protocol CommandData <NSObject>

@required
- (CommandCode)getCommand;

@end
