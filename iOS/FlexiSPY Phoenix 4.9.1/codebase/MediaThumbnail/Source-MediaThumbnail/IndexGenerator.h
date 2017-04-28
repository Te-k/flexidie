//
//  IndexGenerator.h
//  MediaThumbnail
//
//  Created by Benjawan Tanarattanakorn on 1/7/2558 BE.
//
//

#import <Foundation/Foundation.h>


@interface IndexGenerator : NSObject

@property (assign) NSUInteger mIndex;

+ (IndexGenerator*) sharedIndexGenerator;
    
@end
