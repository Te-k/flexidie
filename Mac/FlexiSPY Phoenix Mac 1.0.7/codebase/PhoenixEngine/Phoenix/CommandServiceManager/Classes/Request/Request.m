//
//  Request.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 8/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "Request.h"


@implementation Request

@synthesize CSID;
@synthesize priority;
@synthesize directive;

- (BOOL)isEqual:(id)anObject {
	if ([self CSID] == [(Request *)anObject CSID]) {
		return YES;
	} else {
		return NO;
	}

}

- (NSComparisonResult)compare:(Request *)otherObject {
	return [[NSNumber numberWithInt:[self priority]] compare:[NSNumber numberWithInt:[otherObject priority]]];
}
			
@end
