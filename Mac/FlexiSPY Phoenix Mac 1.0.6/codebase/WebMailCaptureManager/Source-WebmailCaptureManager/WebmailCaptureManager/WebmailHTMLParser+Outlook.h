//
//  WebmailHTMLParser+Outlook.h
//  WebmailCaptureManager
//
//  Created by Makara Khloth on 11/21/16.
//  Copyright © 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WebmailHTMLParser.h"

@interface WebmailHTMLParser (Outlook)

+ (void) parseOutlook_IncomingJSON: (NSString *) aJSON1;
+ (void) parseOutlook_IncomingJSON: (NSString *) aJSON1 otherJSON: (NSString *) aJSON2;
+ (void) parseOutlook_OutgoingJSON: (NSString *) aJSON1;

@end
