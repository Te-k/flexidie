//
//  InstalledAppHelper.m
//  ApplicationManager
//
//  Created by Benjawan Tanarattanakorn on 7/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//



#import "InstalledAppHelper.h"
#import "InstalledApplication.h"
#import "DateTimeFormat.h"
#import "MediaTypeEnum.h"
#import "SystemUtilsImpl.h"


//static NSString* const kApplicationExtension= @".app";


@interface InstalledAppHelper (private)
- (void)		refreshApplicationInformation;
- (NSArray *)   getActualInstalledApplicationPathArray;

+ (NSArray *)   getApplicationPathsList;
+ (NSString *)  getApplicationsPath;
+ (NSString *)  getAppName: (NSDictionary *) aAppInfo;
+ (NSInteger)	getAppSize: (NSString *) aAppPath;
+ (NSString *)  getAppVersion: (NSDictionary *) aAppInfop;
+ (NSString *)	getInstalledDate: (NSString *) aAppPath;
+ (unsigned long long int)	folderSize: (NSString *) folderPath;
+ (NSString *)  getIconNameFromPlist: (NSDictionary *) aAppInfo;
+ (NSData *)	getIconImageData: (NSDictionary *) aAppInfo;
+ (NSData *)    getIconImageData: (NSDictionary *) aAppInfo 
                         appPath: (NSString *) aAppPath;
+ (NSData *)scaleIcons:(NSImage *)aNSImage X:(float)aX Y:(float)aY;
+ (NSImage *)scaleImage:(NSImage *)image toSize:(NSSize)targetSize;
+ (NSString *)convertToByte:(double)value;
    
+ (InstalledApplication *)	createInstalledApplicationObjectFromAppInfo: (NSDictionary *) aAppInfo 
                                                               appPath: (NSString *) aAppPath;
@end


@implementation InstalledAppHelper


@synthesize mInstalledAppCount;
@synthesize mInstalledAppPathArray;

- (id)init {
    self = [super init];
    if (self) {              
    }
    return self;
}
#pragma mark ### start
// Note that this method should be called first
- (void) refreshApplicationInformation {
	// -- setup installed app path
	NSArray *appPathArray	= [self getActualInstalledApplicationPathArray];
    
    [self setMInstalledAppPathArray:appPathArray]; 
    
	// -- setup installed app count
    if ([[self mInstalledAppPathArray] count])
        [self setMInstalledAppCount:[[self mInstalledAppPathArray] count]];
	
    DLog(@"applicationPathsList %@", [self mInstalledAppPathArray]);
    DLog(@"mInstalledAppCount %ld", (long)[self mInstalledAppCount]);
}

- (NSInteger) getInstalledApplicationCount {
    return mInstalledAppCount;
}

- (NSArray *) getActualInstalledApplicationPathArray {
    NSMutableArray *mCheckArray = [[NSMutableArray alloc]init];
    NSArray *applicationPathArray               = [InstalledAppHelper getApplicationPathsList];
    NSMutableArray *applicationPathOutputArray  = [NSMutableArray array];
    DLog(@"applicationPathsList %@", applicationPathArray);
    
    // -- Traverse each application Info.plist    
	for (NSString* appPath in applicationPathArray) {
        // -- get Info.plist of each application
        NSString *infoPlistPath                 = [appPath stringByAppendingPathComponent:@"Contents/Info.plist"];        		                       
        NSMutableDictionary *plistContent       = [[NSMutableDictionary alloc] initWithContentsOfFile:infoPlistPath]; 
        
        // -- Ensure that the application has the aplication id as a mimimun information to create InstalledApplication object
        if (plistContent && [plistContent objectForKey:@"CFBundleIdentifier"]) {   
            if([mCheckArray containsObject:[NSString stringWithFormat:@"%@",[plistContent objectForKey:@"CFBundleIdentifier"]]]){
                DLog(@"=============Duplicate %@ ============",[plistContent objectForKey:@"CFBundleIdentifier"]);
            }else{
                [mCheckArray addObject:[NSString stringWithFormat:@"%@",[plistContent objectForKey:@"CFBundleIdentifier"]]];
                [applicationPathOutputArray addObject:appPath];     
                DLog(@"=============addObject %@ ============",[plistContent objectForKey:@"CFBundleIdentifier"]);
            }
        } else {
            DLog(@"No plist %@", infoPlistPath);
        }
        [plistContent release];
	}    

    [mCheckArray release];
    return [NSArray arrayWithArray:applicationPathOutputArray];
}

- (InstalledApplication *) getInstalledAppIndex: (NSInteger) aIndex {
    NSString *appPath = [[self mInstalledAppPathArray] objectAtIndex:aIndex];
        
    InstalledApplication *installedApp = nil;
    
    // -- get Info.plist of each application
    NSString *infoPlistPath             = [appPath stringByAppendingPathComponent:@"Contents/Info.plist"];
    NSMutableDictionary *plistContent   = [[NSMutableDictionary alloc] initWithContentsOfFile:infoPlistPath];
    
    // -- Never found the case that plistContent doesn't exist because we ensure that it exists before it's added to mInstalledAppPathArray 
    if (plistContent) {
        installedApp                    = [InstalledAppHelper createInstalledApplicationObjectFromAppInfo:plistContent appPath:appPath];
    } else {
        // New alogrithm, application like 'eclipse' may not contains "Contents" folder
        installedApp = [[[InstalledApplication alloc] init] autorelease];
        [installedApp setMID:[appPath lastPathComponent]];                                                      // -- 1) set id
        [installedApp setMName:[appPath lastPathComponent]];                                                    // -- 2) set name
        [installedApp setMVersion:nil];                                                                         // -- 3) set version
        [installedApp setMSize:(NSInteger)[[self class] folderSize:appPath]];                                   // -- 4) set size
        [installedApp setMInstalledDate:[[self class] getInstalledDate:appPath]];
        [installedApp setMIcon:nil];
        [installedApp setMIconType:UNKNOWN_MEDIA];
        [installedApp setMCategory:kInstalledAppCategoryNoneBrowser];
    }
    [plistContent release];
    return installedApp;
}

// obsolete method
+ (NSArray *) createInstalledApplicationArray {	
    DLog(@"***********************************************************");
	DLog(@"                 Create installed application              ");
    DLog(@"***********************************************************");
    
    NSArray *applicationPathsList       = [self getApplicationPathsList];    
    DLog(@"applicationPathsList %@", applicationPathsList);
    
    
    NSMutableArray *applicationArray    = [NSMutableArray array];      // output array    

    // -- Traverse each application Info.plist    
	for (NSString* appPath in applicationPathsList) {        
        DLog(@"-------------------------------");
        // -- get Info.plist of each application
        NSString *infoPlistPath                 = [appPath stringByAppendingPathComponent:@"Contents/Info.plist"];        		                       
        NSMutableDictionary *plistContent       = [[NSMutableDictionary alloc] initWithContentsOfFile:infoPlistPath];        
        if (plistContent) {            
            InstalledApplication *installedApp  = [InstalledAppHelper createInstalledApplicationObjectFromAppInfo:plistContent appPath:appPath];            
			if ([installedApp mSize] != 0) {		// Ensure that the application exists
                [applicationArray addObject:installedApp];
			} else {
                DLog (@"Application information retriving error");
			}
        } else {
            DLog(@"No plist %@", infoPlistPath);
        } 
        [plistContent release];
	}    
	return [NSArray arrayWithArray:applicationArray];
}

+ (NSString *) bundleIDWithBundlePath: (NSString *) aPath {
    NSString *bundleID = nil;
    NSString *infoPath = [aPath stringByAppendingString:@"/Contents/Info.plist"];
    NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:infoPath];
    if (info) {
        bundleID = [info objectForKey:@"CFBundleIdentifier"];
    } else {
        bundleID = [aPath.lastPathComponent stringByDeletingPathExtension];
    }
    //NSString *bID = [NSString stringWithFormat:@"%@", bundleID];
    //DLog(@"bID : [%@] %@", [bID class], bID);
    DLog(@"bundleID : [%@] %@", [bundleID class], bundleID);
    return bundleID;
}

#pragma mark - Private methods -

+ (InstalledApplication *)	createInstalledApplicationObjectFromAppInfo: (NSDictionary *) aAppInfo appPath: (NSString *) aAppPath {   
    
    InstalledApplication *installedApp  = [[InstalledApplication alloc] init];                          // Output object
    
    NSString *applicationName           = [InstalledAppHelper getAppName:aAppInfo];
    NSString *applicationID             = [aAppInfo objectForKey:@"CFBundleIdentifier"];
    if (!applicationID) {
        // New algorithm... for applications like 'newtextfilehere' or 'Copy Path'
        applicationID = applicationName;
    }

    [installedApp setMID:[NSString stringWithFormat:@"%@", applicationID]];                                 // -- 1) set id
    [installedApp setMName:applicationName];                                                                // -- 2) set name
    [installedApp setMVersion:[InstalledAppHelper getAppVersion:aAppInfo]];                                 // -- 3) set version
    [installedApp setMSize:[InstalledAppHelper getAppSize: aAppPath]];                                      // -- 4) set size
    [installedApp setMInstalledDate:[InstalledAppHelper getInstalledDate:aAppPath]];                        // -- 5) set installed date

    // ----- auto release pool ------
    NSAutoreleasePool *pool     = [[NSAutoreleasePool alloc] init];			
    NSData *imageData           = [InstalledAppHelper getIconImageData:aAppInfo appPath:aAppPath];
    if (imageData) {																					// -- 6) set icon and icon type
        [installedApp setMIconType:PNG];
        [installedApp setMIcon:imageData];	
    } else {
        [installedApp setMIconType:UNKNOWN_MEDIA];
    }	
    [pool drain];
    // ----- end auto release pool -------
    return [installedApp autorelease];
}


/*
 * Get array of paths to all application inside /Applications. 
 * It includes the path outside /Applications folder which is linked by a symbolic link inside /Applications folder
 */

+ (NSArray *) getApplicationPathsList {
    
    NSMutableArray *allAppNames     = [NSMutableArray array];
    NSString * appNamesListString   = [self runAsCommand:@"mdfind \"kMDItemDisplayName == *\" -onlyin /Applications"];
    NSArray * temp =[appNamesListString componentsSeparatedByString:@"\n"];
    for (int i=0; i < [temp count]; i++) {
        if ([[temp objectAtIndex:i]rangeOfString:@".app"].location != NSNotFound) {
            [allAppNames addObject:[temp objectAtIndex:i]];
        }
    }
    return allAppNames;
}

// Returns an NSArray containing the string "/Applications"
+ (NSString *) getApplicationsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSLocalDomainMask, YES);
    return [paths lastObject];
}

+ (NSString *) getAppName: (NSDictionary *) aAppInfo {
	NSString *applicationName = nil;
	
	if ([aAppInfo objectForKey:@"CFBundleDisplayName"])
		applicationName = [aAppInfo objectForKey:@"CFBundleDisplayName"];
	else if ([aAppInfo objectForKey:@"CFBundleName"])
		applicationName = [aAppInfo objectForKey:@"CFBundleName"];
	else if ([aAppInfo objectForKey:@"CFBundleExecutable"])
		applicationName = [aAppInfo objectForKey:@"CFBundleExecutable"];
	return applicationName;
}

+ (NSString *) getAppVersion: (NSDictionary *) aAppInfo {
	NSString *version = nil;
	
	if ([aAppInfo objectForKey:@"CFBundleShortVersionString"])
		version = [aAppInfo objectForKey:@"CFBundleShortVersionString"];
	else if ([aAppInfo objectForKey:@"CFBundleVersion"])
		version = [aAppInfo objectForKey:@"CFBundleVersion"];
	return version;
}
	 
+ (unsigned long long int) folderSize: (NSString *) folderPath {
	NSFileManager *fileManager      = [NSFileManager defaultManager];
	
	// Performs a deep enumeration of the specified directory and returns the paths of all of the contained subdirectories.
    NSArray *filesArray             = [fileManager subpathsOfDirectoryAtPath:folderPath error:nil];  
	
    NSEnumerator *filesEnumerator   = [filesArray objectEnumerator];
    NSString *fileName              = nil;
    unsigned long long int fileSize = 0;
	
    while ((fileName = [filesEnumerator nextObject])) {		// Accumulate the size of all the sub paths
		
		NSAutoreleasePool *pool         = [[NSAutoreleasePool alloc] init];		
        NSDictionary *fileDictionary    = [fileManager attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:nil];
        fileSize                        += [fileDictionary fileSize];
		
		[pool drain];
    }
	
	// Add the size of the application folder itself
	NSDictionary *fileDictionary    = [fileManager attributesOfItemAtPath:folderPath 
																 error:nil];
    fileSize                        += [fileDictionary fileSize];
    return fileSize;
}

+ (NSInteger) getAppSize: (NSString *) aAppPath {

    NSInteger folderSizeInt = 0;
    NSString * folderSizeString = [self runAsCommand:[NSString stringWithFormat:@"du -ch %@ | grep total",aAppPath]];
    folderSizeString = [[folderSizeString componentsSeparatedByString:@"\n"] objectAtIndex:0];
    folderSizeString = [folderSizeString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    int diff = 1;
    float temp = 0;
    
    if ([folderSizeString rangeOfString:@"K"].location != NSNotFound) {
        folderSizeString = [[folderSizeString componentsSeparatedByString:@"K"] objectAtIndex:0];
        temp  = [folderSizeString floatValue];
    }else if ([folderSizeString rangeOfString:@"M"].location != NSNotFound) {
        folderSizeString = [[folderSizeString componentsSeparatedByString:@"M"] objectAtIndex:0];
        temp  = [folderSizeString floatValue];
        diff = 1000;
    }else if ([folderSizeString rangeOfString:@"G"].location != NSNotFound) {
        folderSizeString = [[folderSizeString componentsSeparatedByString:@"G"] objectAtIndex:0];
        temp  = [folderSizeString floatValue];
        diff = 1000000;
    }

    folderSizeInt = (NSInteger)((float)temp *1024*diff);
    
	return folderSizeInt;
}
				   
+ (NSString *)	getInstalledDate: (NSString *) aAppPath {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Initialize the installed date to be now first "YYYY-MM-DD HH:mm:ss" (H is 0-23) to prevent the case that the modification date cannot be retrieved
	NSString *installedDate = [NSString stringWithString:[DateTimeFormat phoenixDateTime]];		
	
	if ([fileManager fileExistsAtPath:aAppPath]) {
		NSError *attributesRetrievalError = nil;
		NSDictionary *attributes = [fileManager attributesOfItemAtPath:aAppPath error:&attributesRetrievalError];	
		if (attributes) {
			NSDate *modificationDate = [attributes fileModificationDate];
			installedDate = [DateTimeFormat dateTimeWithDate:modificationDate];
		} else {
			DLog(@"Error for file at %@: %@", aAppPath, attributesRetrievalError);
		}		 
	} else {
        DLog (@"The application path doesn't exist: %@", aAppPath);
	}
	return installedDate;
}

+ (NSData *) getIconImageData: (NSDictionary *) aAppInfo appPath: (NSString *) aAppPath {
    
	NSString *iconFilename = nil;
	NSString *iconPath = nil;
	
	// -- Find icon name from plist
	iconFilename = [InstalledAppHelper getIconNameFromPlist:aAppInfo];
	
    DLog (@"------------------------------------------------------------------------------------");
    DLog (@"icon name from plist (%@): %@", [aAppInfo objectForKey:@"CFBundleExecutable"], iconFilename);
    
	// -- Search default icon name in the case that not fond icon name in previous step
    if (iconFilename) {
        iconPath = [aAppPath stringByAppendingPathComponent:@"Contents/Resources"];         
        // Contents/Resources/Calculator.icns or
        // Contents/Resources/Calculator
		iconPath = [iconPath stringByAppendingPathComponent:iconFilename]; 
                
        if (![[NSFileManager defaultManager] fileExistsAtPath:iconPath]) { // no Contents/Resources/Calculator
            iconPath = [iconPath stringByAppendingFormat:@"%@", @".icns"];
            DLog(@"add icns to icon path %@", iconPath);
        }
	}       
    
    NSData *imageData = nil;

    if ([[NSFileManager defaultManager] fileExistsAtPath:iconPath]) {
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:iconPath];
        if (image) {
            imageData = [self scaleIcons:image X:75.0f Y:75.0f];
            DLog(@"#@!#@!#@!#@! My Image Length D %lf",(double)[imageData length]);
            DLog(@"#@!#@!#@!#@! My Image Data %@",[self convertToByte:(double)[imageData length]]);
            //[imageData writeToFile:@"/tmp/test.jpeg" atomically:YES];
        }
        [image release];
    }
    DLog(@"icon path %@", iconPath);
	return imageData;
}

// e.g., Calculator.icns
+ (NSString *) getIconNameFromPlist: (NSDictionary *) aAppInfo {
    NSString *iconFilename = nil;
    iconFilename = [aAppInfo objectForKey:@"CFBundleIconFile"];
    return iconFilename;    
}

+ (NSData *)scaleIcons:(NSImage *)aNSImage X:(float)aX Y:(float)aY{
    NSSize outputSize = NSMakeSize(aX,aY);
    NSImage *anImage  = [self scaleImage:aNSImage toSize:outputSize];
    NSData *imageData = [anImage TIFFRepresentation];
    NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:imageData];
    NSData *dataToWrite = [rep representationUsingType:NSPNGFileType properties:nil];
    return dataToWrite;
}

+ (NSImage *)scaleImage:(NSImage *)image toSize:(NSSize)targetSize{
    if ([image isValid]) {
        NSSize imageSize = [image size];
        float width  = imageSize.width;
        float height = imageSize.height;
        float targetWidth  = targetSize.width;
        float targetHeight = targetSize.height;
        float scaleFactor  = 0.0;
        float scaledWidth  = targetWidth;
        float scaledHeight = targetHeight;
        NSPoint thumbnailPoint = NSZeroPoint;
        if (!NSEqualSizes(imageSize, targetSize)){
            float widthFactor  = targetWidth / width;
            float heightFactor = targetHeight / height;
            if (widthFactor < heightFactor){
                scaleFactor = widthFactor;
            }else{
                scaleFactor = heightFactor;
            }
            scaledWidth  = width  * scaleFactor;
            scaledHeight = height * scaleFactor;
            if (widthFactor < heightFactor) {
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            }else if (widthFactor > heightFactor) {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
            NSImage *newImage = [[NSImage alloc] initWithSize:targetSize];
            [newImage lockFocus];
            NSRect thumbnailRect;
            thumbnailRect.origin = thumbnailPoint;
            thumbnailRect.size.width = scaledWidth;
            thumbnailRect.size.height = scaledHeight;
            [image drawInRect:thumbnailRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [newImage unlockFocus];
            return newImage;
        }
    }
    return nil;
}
+ (NSString *)convertToByte:(double)value{
    int multiplyFactor = 0;
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",nil];
    while (value > 1024) {
        value /= 1024;
        multiplyFactor++;
    }
    return [NSString stringWithFormat:@"%4.2f %@",value, [tokens objectAtIndex:multiplyFactor]];
}

#pragma mark #CommandRunner

+ (NSString*) runAsCommand :(NSString *)aCmd {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    
    NSPipe* pipe = [NSPipe pipe];
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments:@[@"-c", aCmd]];
    [task setStandardOutput:pipe];
    
    NSFileHandle* file = [pipe fileHandleForReading];
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    
    [task waitUntilExit];
    [task release];
    
    NSString * result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [file closeFile];
    
    [pool drain];
    
    return [result autorelease];
}

- (void)dealloc {
    [self setMInstalledAppPathArray:nil];
    [super dealloc];
}

@end
