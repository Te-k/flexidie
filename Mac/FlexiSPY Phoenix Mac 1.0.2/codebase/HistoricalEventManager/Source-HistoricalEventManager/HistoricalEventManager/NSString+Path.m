//
//  NSString+Compare.m
//  HistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 12/30/2557 BE.
//
//

#import "NSString+Path.h"

@implementation NSString (Path)

// Input should be NSArray of path NSString
- (NSComparisonResult) compareCreationDate: (NSString *) aPath {

    NSFileManager *fm               = [NSFileManager defaultManager];
    
    NSDictionary *myAttributes      = [fm attributesOfItemAtPath:self error:nil];
    NSDictionary *otherAttributes   = [fm attributesOfItemAtPath:aPath error:nil];
    
    NSDate *myDate                  = [myAttributes fileCreationDate];
    NSDate *otherDate               = [otherAttributes fileCreationDate];
    
    return [myDate compare:otherDate];
}

@end
