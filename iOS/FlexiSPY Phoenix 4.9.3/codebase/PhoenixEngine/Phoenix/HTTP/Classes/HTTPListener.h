//
//  HTTPListener.h
//  HTTP
//
//  Created by Pichaya Srifar on 7/22/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "ASIProgressDelegate.h"

@interface HTTPListener : NSObject <ASIHTTPRequestDelegate, ASIProgressDelegate> {

}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders;
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;
- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes;


@end
