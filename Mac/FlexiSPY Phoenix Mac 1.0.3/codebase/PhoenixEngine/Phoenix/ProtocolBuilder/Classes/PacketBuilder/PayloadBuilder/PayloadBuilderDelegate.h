//
//  PayloadBuilderDelegate.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PayloadBuilderResponse;

@protocol PayloadBuilderDelegate <NSObject>

@required
- (void)onPayloadBuilderError;
- (void)onPayloadBuilderSuccess:(PayloadBuilderResponse *)response;

@end
