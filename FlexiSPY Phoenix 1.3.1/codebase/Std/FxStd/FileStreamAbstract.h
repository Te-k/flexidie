//
//  FileStreamAbstract.h
//  FxStd
//
//  Created by Makara Khloth on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileStreamAbstract : NSObject {
@protected
	NSString*	mFileFullName;
	NSMutableData*	mExternalizedData; // Not own
}

@property (nonatomic, copy) NSString* mFileFullName;

- (void) save;
- (void) read;

@end
