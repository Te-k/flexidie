/*
 *  CommandDelegate.h
 *  CommandServiceManager
 *
 *  Created by Pichaya Srifar on 7/29/11.
 *  Copyright 2011 Vervata. All rights reserved.
 *
 */

@class ResponseData;

/**
 Callback method for Phoenix 
 */
@protocol CommandDelegate <NSObject>

- (void)onConstructError:(uint32_t)CSID withError:(NSError *)error;
- (void)onServerError:(ResponseData *)response;
- (void)onSuccess:(ResponseData *)response;
- (void)onTransportError:(uint32_t)CSID withError:(NSError *)error;

@end
