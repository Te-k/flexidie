//
//  FileSystemSearcherDelegate.h
//  MediaFinder
//
//  Created by Makara Khloth on 2/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FileSystemSearcherDelegate <NSObject>

- (void) fileSystemSearchFinished: (NSArray *) aFileSystemEntries;

@end

