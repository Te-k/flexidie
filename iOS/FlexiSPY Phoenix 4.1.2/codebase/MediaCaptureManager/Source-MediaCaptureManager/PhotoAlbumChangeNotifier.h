//
//  PhotoAlbumChangeNotifier.h
//  MediaCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 1/28/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class PLPhotoLibrary;


@interface PhotoAlbumChangeNotifier : NSObject {
@private
	PLPhotoLibrary	*mPlPhotoLibrary;
	SEL				mPhotoAlbumDidChangeSelector;
	id				mDelegate;
}


@property (nonatomic, assign) SEL mPhotoAlbumDidChangeSelector;
@property (nonatomic, assign) id mDelegate;

- (void) start;
- (void) stop;

@end
