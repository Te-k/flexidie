//
//  FxSqlString.m
//  FxSqLite
//
//  Created by Makara Khloth on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxSqlString.h"
#import "DefStd.h"

@interface FxSqlString (private)

- (void) tokenize;

@end

@implementation FxSqlString

- (id) initWithSqlFormat: (const NSString*) sqlFormat
{
	if (self = [super init])
	{
		tokenArray = NULL;
		sqlStatement = [[NSString alloc] initWithString:(NSString*)sqlFormat];
		[self tokenize];
	}
	return (self);
}

- (void) dealloc
{
	[sqlStatement release];
	[tokenArray release];
	[super dealloc];
}

- (void) tokenize
{
	NSString* tempString = [NSString stringWithString:sqlStatement];
	NSArray* componentArray = [tempString componentsSeparatedByString:kFxStringQuestionMark];
	tokenArray = [[NSMutableArray alloc] initWithArray:componentArray];
}

- (void) formatInt: (NSInteger) intParam atIndex: (NSInteger) index
{
	NSString* tempString = [NSString stringWithFormat:@"%d", intParam];
	[self formatString:tempString atIndex:index];
}

- (void) formatFloat: (float) floatParam atIndex: (NSInteger) index
{
	NSString* tempString = [NSString stringWithFormat:@"%4.7f", floatParam];
	[self formatString:tempString atIndex:index];
}

- (void) formatString: (const NSString*) stringParam atIndex: (NSInteger) index
{
	NSString *makeUpString = (NSString *)stringParam;
	if (!makeUpString) {
		makeUpString = [NSString string];
	}
	
	NSRange range = NSMakeRange(0, [makeUpString length]);
	NSString* temp1String = [makeUpString stringByReplacingOccurrencesOfString:kFxStringOneSingleQuote withString:kFxStringTwoSingleQuote options:NSCaseInsensitiveSearch range:range];
	NSString* temp2String = [tokenArray objectAtIndex:index];
	NSString* temp3String = [temp2String stringByAppendingString:temp1String];
	[tokenArray replaceObjectAtIndex:index withObject:temp3String];
}

- (NSString*) finalizeSqlString
{
	NSString* tempString = [NSString string];
	if (tokenArray)
	{
		NSInteger i = 0;
		for (i = 0; i < [tokenArray count]; i++)
		{
            tempString = [tempString stringByAppendingString:[tokenArray objectAtIndex:i]];
		}
	}
	return (tempString);
}

@end
