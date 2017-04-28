//
//  RCParser.m
//  blbld
//
//  Created by Makara Khloth on 10/13/16.
//
//

#import "RCParser.h"
#import "RCCommand.h"

@implementation RCParser

+ (RCCommand *) parse: (NSString *) cmd {
    // <1><2><3>
    NSString *cmdCode = nil;
    NSArray *args = nil;
    NSArray *elements = [cmd componentsSeparatedByString:@"><"];
    if ([elements count] > 1) {
        NSString *firstElement = [elements firstObject];
        firstElement = [firstElement stringByReplacingOccurrencesOfString:@"<" withString:@""];
        NSString *lastElement = [elements lastObject];
        lastElement = [lastElement stringByReplacingOccurrencesOfString:@">" withString:@""];
        
        NSMutableArray *params = [NSMutableArray arrayWithArray:elements];
        [params replaceObjectAtIndex:[params indexOfObject:[params firstObject]] withObject:firstElement];
        [params replaceObjectAtIndex:[params indexOfObject:[params lastObject]] withObject:lastElement];
        
        cmdCode = firstElement;
        args = params;
    }
    else if ([elements count] == 1) {
        NSString *firstElement = [elements firstObject];
        firstElement = [firstElement stringByReplacingOccurrencesOfString:@"<" withString:@""];
        firstElement = [firstElement stringByReplacingOccurrencesOfString:@">" withString:@""];
        
        cmdCode = firstElement;
        args = [NSArray arrayWithObject:firstElement];
    }
    DLog(@"cmdCode: %@", cmdCode);
    DLog(@"args: %@", args);
    
    RCCommand *rcCommand = [[RCCommand alloc] init];
    rcCommand.cmdCode = cmdCode;
    rcCommand.cmdArgs = args;
    return rcCommand;
}

@end
