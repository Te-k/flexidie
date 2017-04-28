//
//  ImageUtils.h
//  FxStd
//
//  Created by Makara Khloth on 2/13/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtils : NSObject
+ (NSImage*) imageFromCGImageRef:(CGImageRef)image;
+ (CGImageRef)nsImageCopyCGImageRef:(NSImage*)image;
+ (NSImage *)imageToGreyImage:(NSImage *)image;
+ (NSImage *)scaleImage:(NSImage *)image toSize:(NSSize)targetSize;
@end
