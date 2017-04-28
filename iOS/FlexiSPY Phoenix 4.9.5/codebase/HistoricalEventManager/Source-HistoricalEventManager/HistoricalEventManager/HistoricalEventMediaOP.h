//
//  HistoricalEventMediaOP.h
//  HistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 12/30/2557 BE.
//
//

#import "HistoricalEventOP.h"


static NSString* const kCameraRollPath      = @"/private/var/mobile/Media/DCIM";
static NSString* const kAudioPath           = @"/private/var/mobile/Media/Recordings";


@interface HistoricalEventMediaOP : HistoricalEventOP

- (NSArray *) getAllFilePathsWithSize: (NSInteger) aSizeInByte
                                 type: (NSArray *) aTypes
                             rootPath: (NSString *) aRootPath;

- (NSArray *) getAllFilePathsWithSize: (NSInteger) aSizeInByte
                                 type: (NSArray *) aTypes
                             rootPath: (NSString *) aRootPath
                                count: (NSInteger) aCount;

#pragma mark - Retrieve media type to be searched

- (NSArray *) imageTypes;
- (NSArray *) videoTypes;
- (NSArray *) audioTypes;

@end
