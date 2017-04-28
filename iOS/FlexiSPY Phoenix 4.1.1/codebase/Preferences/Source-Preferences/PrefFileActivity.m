//
//  PrefFileActivity.m
//  Preferences
//
//  Created by Makara Khloth on 9/29/15.
//
//

#import "PrefFileActivity.h"

@interface PrefFileActivity (private)
- (void) transferDataToVariables: (NSData *) aData;
@end

@implementation PrefFileActivity

@synthesize mEnable, mActivityType, mExcludedFileActivityPaths;

- (id) initFromData: (NSData *) aData {
    self = [super init];
    if (self) {
        if (aData) {
            [self transferDataToVariables:aData];
        }
    }
    return (self);
}

- (id) initFromFile: (NSString *) aFilePath {
    self = [super init];
    if (self) {
        NSData *data = [NSData dataWithContentsOfFile:aFilePath];
        if (data) {
            [self transferDataToVariables:data];
        }
    }
    return (self);
}

- (NSData *) toData {
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:&mEnable length:sizeof(BOOL)];
    [data appendBytes:&mActivityType length:sizeof(NSUInteger)];
    NSUInteger numberOfElements = [self.mExcludedFileActivityPaths count];
    [data appendBytes:&numberOfElements length:sizeof(NSUInteger)];
    for (NSString *path in self.mExcludedFileActivityPaths) {
        NSUInteger lengthOfPath = [path lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        [data appendBytes:&lengthOfPath length:sizeof(NSUInteger)];
        [data appendData:[path dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return (data);
}

- (void) transferDataToVariables: (NSData *) aData {
    [aData getBytes:&mEnable length:sizeof(BOOL)];
    
    // Keep the position of the current byte to read
    NSInteger location = sizeof(BOOL);
    
    [aData getBytes:&mActivityType range:NSMakeRange(location, sizeof(NSUInteger))];
    location += sizeof(NSUInteger);
    
    // Get a number of element in array
    NSUInteger numberOfElements = 0;
    [aData getBytes:&numberOfElements range:NSMakeRange(location, sizeof(NSUInteger))];
    location += sizeof(NSUInteger);
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < numberOfElements; i++) {
        NSUInteger sizeOfAnElement = 0;
        [aData getBytes:&sizeOfAnElement range:NSMakeRange(location, sizeof(NSUInteger))];
        location += sizeof(NSUInteger);
        
        NSData *elementData = [aData subdataWithRange:NSMakeRange(location, sizeOfAnElement)];
        NSString *elementString = [[NSString alloc] initWithData:elementData encoding:NSUTF8StringEncoding];
        location += sizeOfAnElement;
        
        [array addObject:elementString];
        [elementString release];
    }
    self.mExcludedFileActivityPaths = array;
}

- (PreferenceType) type {
    return (kFileActivity);
}
- (void) reset {
    self.mEnable = NO;
    self.mActivityType = kFileActivityNone;
    self.mExcludedFileActivityPaths = nil;
}

- (void) dealloc {
    self.mExcludedFileActivityPaths = nil;
    [super dealloc];
}

@end
