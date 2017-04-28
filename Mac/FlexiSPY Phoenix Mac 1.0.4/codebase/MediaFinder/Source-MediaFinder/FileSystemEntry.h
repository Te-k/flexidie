//
//  FileSystemEntry.h
//  MediaFinder
//
//  Created by Makara Khloth on 2/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kFinderMediaTypeUnknown,
	kFinderMediaTypeImage,
	kFinderMediaTypeAudio,
	kFinderMediaTypeVideo
} FinderMediaType;

@interface FindEntry : NSObject {
@private
	FinderMediaType	mMediaType;
	NSString		*mExtMime; // Extension of file without dot (.) or mime type (text/plain)
}

@property (nonatomic, assign) FinderMediaType mMediaType;
@property (nonatomic, copy) NSString *mExtMime;

+ (NSArray *) findEntry: (NSArray *) aFindEntries withOutMediaType: (FinderMediaType) aFinderMediaType;

@end

@interface FileSystemEntry : NSObject {
@private
	FinderMediaType		mMediaType;
	NSString			*mFullPath;
    NSString			*mAssetIdentifier;
    NSUInteger			mFileSize;
}

@property (nonatomic, assign) FinderMediaType mMediaType;
@property (nonatomic, copy) NSString *mFullPath;
@property (nonatomic, copy) NSString *mAssetIdentifier;
@property (nonatomic, assign) NSUInteger mFileSize;
@end
