//
//  PrefMonitorFacetimeID.m
//  Preferences
//
//  Created by Benjawan Tanarattanakorn on 7/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "PrefMonitorFacetimeID.h"

@interface PrefMonitorFacetimeID (private)
- (void) transferDataToVariables: (NSData *) aData;
@end



@implementation PrefMonitorFacetimeID

@synthesize mEnableMonitorFacetimeID;
@synthesize mMonitorFacetimeIDs;


- (id) initFromData: (NSData *) aData {
	self = [super init];
	if (self != nil) {
		[self transferDataToVariables:aData];
	}
	return self;
}

- (id) initFromFile: (NSString *) aFilePath {
	self = [super init];
	if (self != nil) {
		NSData *data = [NSData dataWithContentsOfFile:aFilePath];
		[self transferDataToVariables:data];
	}
	return self;
}


- (NSData *) toData {
	NSMutableData* data = [[NSMutableData alloc] init];
	[data appendBytes:&mEnableMonitorFacetimeID length:sizeof(BOOL)];			
	
	// append a number of array elements, size of each element and each element to the data
	NSInteger numberOfElements = [mMonitorFacetimeIDs count];
	[data appendBytes:&numberOfElements length:sizeof(NSInteger)];			
	for (NSString *anElement in mMonitorFacetimeIDs) {
		NSInteger sizeOfAnElement = [anElement lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[data appendBytes:&sizeOfAnElement length:sizeof(NSInteger)];			
		
		NSData *elementData = [anElement dataUsingEncoding:NSUTF8StringEncoding];
		[data appendData:elementData];											
	}
	[data autorelease];
	return data;
}


- (void) transferDataToVariables: (NSData *) aData {
	[aData getBytes:&mEnableMonitorFacetimeID length:sizeof(BOOL)];
	
	// keep the position of the current byte to read
	NSInteger location = sizeof(BOOL); 
	
	// get a number of element in array
	NSRange range = NSMakeRange(location, sizeof(NSInteger));	
	NSInteger numberOfElements = 0;
	[aData getBytes:&numberOfElements range:range];						
	location += sizeof(NSInteger);	
	
	NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < numberOfElements; i++) {
		range = NSMakeRange(location, sizeof(NSInteger));		
		NSInteger sizeOfAnElement;
		[aData getBytes:&sizeOfAnElement range:range];				
		location += sizeof(NSInteger);
		
		range = NSMakeRange(location, sizeOfAnElement);
		NSData *elementData = [aData subdataWithRange:range];		
		NSString *elementString = [[NSString alloc] initWithData:elementData encoding:NSUTF8StringEncoding];
        
		location += sizeOfAnElement;
		
		[array addObject:elementString];
		[elementString release];
	}
    [self setMMonitorFacetimeIDs:array];
}

- (PreferenceType) type {
	return kFacetimeID;
}

- (void) reset {
	[self setMMonitorFacetimeIDs:[NSArray array]];
}

- (void) dealloc {
	[mMonitorFacetimeIDs release];
	mMonitorFacetimeIDs = nil;
	[super dealloc];
}

@end
