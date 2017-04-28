//
//  HistoricalEventMediaOP.m
//  HistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 12/30/2557 BE.
//
//

#import <MobileCoreServices/MobileCoreServices.h>

#import "HistoricalEventMediaOP.h"
#import "NSString+Path.h"


@interface HistoricalEventMediaOP (private)

// -- Searching
- (void) searchType: (NSArray *) aTypes
           inFolder: (NSString *) aFolder
             result: (NSMutableArray *) aResult;
- (BOOL) isMediaFile: (NSString *) aFilePath findEntries: (NSArray *) aFindEntries;

// -- Customize result array
- (NSMutableArray *) filterOutFiles: (NSArray *) aInputFiles bySize: (NSInteger) aSize;
- (NSArray *) filesOrderedByCreationDate: (NSArray *) aInputFiles;
- (NSRange) getRangeOfCountFromLast: (NSInteger) aCount array: (NSArray *) aArray;
- (NSArray *) getLatestFilesWithCount: (NSInteger) aCount files: (NSArray *) aFiles;

@end


@implementation HistoricalEventMediaOP


#pragma mark - Public Method

// Get all
- (NSArray *) getAllFilePathsWithSize: (NSInteger) aSizeInByte
                                 type: (NSArray *) aTypes
                             rootPath: (NSString *) aRootPath {
    
    return [self getAllFilePathsWithSize:aSizeInByte
                                    type:aTypes
                                rootPath:aRootPath
                                   count:-1];
}

// Get some
- (NSArray *) getAllFilePathsWithSize: (NSInteger) aSizeInByte
                                 type: (NSArray *) aTypes
                             rootPath: (NSString *) aRootPath
                                count: (NSInteger) aCount {
    DLog(@"TYPES %@", aTypes)
    
    // -- STEP 1: Get all files in directory ------------------------
    
    NSMutableArray *allFilesInPath   = [NSMutableArray array];
    
    [self searchType:aTypes
            inFolder:aRootPath
              result:allFilesInPath];
    
    DLog(@"All files in path %@ are %@", aRootPath, allFilesInPath)

    
    // -- STEP 2: Filter out too big size of file ------------------------
    
    if (aSizeInByte > 0) {
        allFilesInPath = [self filterOutFiles:allFilesInPath bySize:aSizeInByte];
        DLog(@"All files after filter out by size %@", allFilesInPath)
    }
    
    
    // -- STEP 3: Order by creation date ------------------------
    
    allFilesInPath = [NSMutableArray arrayWithArray:[self filesOrderedByCreationDate:allFilesInPath]];
    
    
    // -- STEP 4: Get element accounding to the count ------------------------
    
    allFilesInPath = [NSMutableArray arrayWithArray:[self getLatestFilesWithCount:aCount files:allFilesInPath]];
    
    return allFilesInPath;
}


#pragma mark - Searching


- (void) searchType: (NSArray *) aTypes
           inFolder: (NSString *) aFolder
             result: (NSMutableArray *) aResult {
    
    NSError *error          = nil;
    NSFileManager *fm       = [NSFileManager defaultManager];
	NSArray *subFolderList  = [fm contentsOfDirectoryAtPath:aFolder error:&error];
    //DLog(@"Searching in subfolder: %@ %@", aFolder, subFolderList)
    if (!error) {
        for (NSString *subFolder in subFolderList) {
            
			BOOL isDirectory        = FALSE;
			NSString *subFolderPath = [NSString stringWithFormat:@"%@/%@", aFolder, subFolder];
            [fm fileExistsAtPath:subFolderPath isDirectory:&isDirectory];
            
			if (isDirectory) {
                [self searchType:aTypes inFolder:subFolderPath result:aResult]; // Recursion
            } else {
                //DLog(@"sub folder path %@", subFolderPath)
                
                if ([self isMediaFile:subFolderPath findEntries:aTypes]) {
                    [aResult addObject:subFolderPath];
                }
            }
		}
    }
}

- (BOOL) isMediaFile: (NSString *) aFilePath findEntries: (NSArray *) aFindEntries {
	BOOL isMediaFile        = FALSE;
    
	NSString *extLowercase  = [[aFilePath pathExtension] lowercaseString];
    
	for (NSString *findEntry in aFindEntries) {
		NSString *entryExtMimeLowercase     = [findEntry lowercaseString];
        
		if ([entryExtMimeLowercase isEqualToString:extLowercase])   {       // extension match
            //DLog(@">> %@ match Extension %@", aFilePath, findEntry)
			isMediaFile     = TRUE;
			break;
		}
        //DLog(@">> %@ Don't match Extension %@", aFilePath, findEntry)
	}
	return (isMediaFile);
}


#pragma mark - Customize result array


- (NSMutableArray *) filterOutFiles: (NSArray *) aInputFiles bySize: (NSInteger) aSize {
    NSMutableArray *validFiles  = [NSMutableArray array];
    NSFileManager *fm           = [NSFileManager defaultManager];
    
    for (NSString *path in aInputFiles) {
        
        unsigned long long filesize = [[fm attributesOfItemAtPath:path error:nil] fileSize];
        
        if (filesize < aSize) {
            [validFiles addObject:path];
            //DLog(@"path is VALID for size %llu", filesize)
        } else {
            DLog(@"path %@ is INVALID for size %llu", path, filesize)
        }
    }
    return validFiles;
}

- (NSArray *) filesOrderedByCreationDate: (NSArray *) aInputFiles {
    NSArray *sortedArray = [aInputFiles sortedArrayUsingSelector:@selector(compareCreationDate:)];
    DLog(@"AFTER compare %@", sortedArray)
    return sortedArray;
}

// return (0,0) if aCount < 1
// This function expects aCount as positive integer
- (NSRange) getRangeOfCountFromLast: (NSInteger) aCount array: (NSArray *) aArray {
    NSRange range   = NSMakeRange(0, 0);
    
    if (aCount >= 1) {
        NSInteger arraySize = [aArray count];
        if (arraySize >= aCount) {
            range   = NSMakeRange(arraySize - aCount, aCount);
        } else {
            range   = NSMakeRange(0, [aArray count]);
        }
    }
    return range;
}

- (NSArray *) getLatestFilesWithCount: (NSInteger) aCount files: (NSArray *) aFiles {
    NSArray *latestFiles = [NSArray array];
    
    if (aCount == -1) {                 // Get all
        latestFiles     = aFiles;
    } else if (aCount >= 1) {
        NSRange range   = [self getRangeOfCountFromLast:aCount array:aFiles];
        DLog(@"range location %lu length %lu", (unsigned long)range.location, (unsigned long)range.length)
        latestFiles     = [aFiles subarrayWithRange:range];
    }
    return latestFiles;
}


#pragma mark - Specify the type to be searched


- (NSArray *) imageTypes {
    NSArray *types = [NSArray arrayWithObjects:@"jpg", @"jpeg", @"png", @"gif", @"bmp", @"tiff", @"tif", @"ico", @"cur", @"xbm", nil];
    return types;
}

- (NSArray *) videoTypes {
    NSArray *types = [NSArray arrayWithObjects:@"mov", @"m4v", @"mp4", @"3gp", nil];
    return types;
}

- (NSArray *) audioTypes {
    NSArray *types = [NSArray arrayWithObjects:@"m4a", @"wav", @"mp3", @"m4r", nil];
    return types;
}

@end
