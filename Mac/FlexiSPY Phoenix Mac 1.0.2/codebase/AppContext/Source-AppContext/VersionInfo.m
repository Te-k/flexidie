/** 
 - Project name: AppContext
 - Class name: VersionInfo
 - Version: 1.0
 - Purpose: Read version file
 - Copy right: 14/12/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#define kVersion @"version.xml"

#import "VersionInfo.h"
#import "DebugStatus.h"

@interface VersionInfo (private) 
- (NSString *) path;
- (BOOL) readDataFromFile;
- (void) printVersionInfo;
@end

@implementation VersionInfo

@synthesize mMajor;
@synthesize mMinor;
@synthesize mBuild;
@synthesize mBuildDate;
@synthesize mBuildDescription;
@synthesize mCurrentElementValue;

- (NSString *) path {
	NSBundle *bundle = [NSBundle mainBundle];
	if (bundle) {
		NSString *resourcePath = [bundle resourcePath];
		NSString *path = [[resourcePath stringByAppendingFormat:@"/%@", kVersion] retain];
		return [path autorelease];
	}
	return nil;
}

- (BOOL) readDataFromFile {
	if ([self path]) {
		NSData *versionData = [NSData dataWithContentsOfFile:[self path]];
		NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:versionData];
		if (xmlParser) {
			[xmlParser setDelegate:self];
			[xmlParser parse];
			[xmlParser setDelegate:nil]; 
			[xmlParser release];
			return TRUE;
		} else {
			[xmlParser release];
			return FALSE;
		}
	} else {
		return FALSE;
	}
}

- (void) printVersionInfo {
	DLog(@"major %@", [self mMajor]);
	DLog(@"minor %@", [self mMinor]);
	DLog(@"build %@", [self mBuild]);
	DLog(@"build date %@", [self mBuildDate]);
	DLog(@"build description %@", [self mBuildDescription]);
}

- (NSString *) version {
	[self readDataFromFile];
	//[self printVersionInfo];
	
	NSMutableString *version = [[NSMutableString alloc] initWithFormat:@"%@", [self mMajor]];
	[version appendString:@"."];
	[version appendFormat:@"%@", [self mMinor]];
	return [version autorelease];
}

- (NSString *) versionWithBuild {
	[self readDataFromFile];
	[self printVersionInfo];
	
	NSMutableString *version = [[NSMutableString alloc] initWithFormat:@"%@", [self mMajor]];
	[version appendString:@"."];
	[version appendFormat:@"%@", [self mMinor]];
	[version appendFormat:@".%@", [self mBuild]];
	return [version autorelease];
}

- (NSString *) versionDescription {
	[self readDataFromFile];
	//[self printVersionInfo];
	
	// first line: major.minor.build
	NSMutableString *version = [[NSMutableString alloc] initWithFormat:@"%@", [self mMajor]];
	[version appendString:@"."];
	[version appendFormat:@"%@", [self mMinor]];
	[version appendFormat:@".%@", [self mBuild]];
	
	// second line: build_date
	[version appendFormat:@" %@", [self mBuildDate]];
	
	// third line: build_description
	[version appendFormat:@" %@", [self mBuildDescription]];
	return [version autorelease];
}

- (void) parser: (NSXMLParser *) parser 
didStartElement: (NSString * ) elementName 
   namespaceURI: (NSString *) namespaceURI 
  qualifiedName: (NSString *) qName 
	 attributes: (NSDictionary *) attributeDict {
	
	DLog(@"---------- didStartElement");
	
    if ([elementName isEqualToString:@"product"]){
		DLog(@"----- product element");
    } else if ([elementName isEqualToString:@"major"] ||
			   [elementName isEqualToString:@"minor"] || 
			   [elementName isEqualToString:@"build"] ||
			   [elementName isEqualToString:@"build_date"] ||
			   [elementName isEqualToString:@"build_description"]) {
		isInElement = TRUE;
    } else {
		DLog(@"----- other element");
		isInElement = FALSE;
	}
}
		 
- (void) parser: (NSXMLParser *) parser foundCharacters: (NSString *) string {
	// ensure that we get only the charactors in the element 
	// e.g., <my_element>get only this string<my_element>
	if (isInElement) {
		if(![self mCurrentElementValue]) {
			[self setMCurrentElementValue:[NSMutableString stringWithString:string]];
			DLog(@"element %@", string);
		} else {
			[[self mCurrentElementValue] appendString:string];
			DLog(@"In element: %@", [self mCurrentElementValue]);
		}
	} else {
		DLog(@"Not in element: %@", string);
	}
}

- (void) parser: (NSXMLParser *) parser 
  didEndElement: (NSString *) elementName
   namespaceURI: (NSString *) namespaceURI 
  qualifiedName: (NSString *) qName {	
	if ([elementName isEqualToString:@"product"] ) {
		DLog(@"---------- END product element -------------");
	} else if ([elementName isEqualToString:@"major"] ) {
		[self setMMajor:[self mCurrentElementValue]];
		DLog(@"---------- END major");
	} else if ([elementName isEqualToString:@"minor"]) {
		[self setMMinor:[self mCurrentElementValue]];
		DLog(@"----------  END minor");
	} else if ([elementName isEqualToString:@"build"]) {
		[self setMBuild:[self mCurrentElementValue]];
		DLog(@"----------  END build");
	} else if ([elementName isEqualToString:@"build_date"]) {
		[self setMBuildDate:[self mCurrentElementValue]];	
		DLog(@"----------  END build_date");
	} else if ([elementName isEqualToString:@"build_description"]) {
		[self setMBuildDescription:[self mCurrentElementValue]];
		DLog(@"---------- END build_description");
	} 
    else {
		DLog(@"---------- END other element");
	}
	isInElement = FALSE;
	[self setMCurrentElementValue:nil];
}
		 
- (void) dealloc {
	[mMajor release];
	[mMinor release];
	[mBuild release];
	[mBuildDate release];
    [mBuildDescription release];
	[mCurrentElementValue release];
	[super dealloc];
}

@end
