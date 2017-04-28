/*
 *  DataProvider.h
 *  ProtocolBuilder
 *
 *  Created by Pichaya Srifar on 8/26/11.
 *  Copyright 2011 Vervata. All rights reserved.
 *
 */

@protocol DataProvider <NSObject>

- (id)getObject;
- (BOOL)hasNext;

@end
