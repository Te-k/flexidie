//
//  ImageUtils.m
//  FxStd
//
//  Created by Makara Khloth on 2/13/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "ImageUtils.h"

#import <AppKit/AppKit.h>

@implementation ImageUtils

+ (NSImage*) imageFromCGImageRef:(CGImageRef)image
{
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    CGContextRef imageContext = nil;
    NSImage* newImage = nil; // Get the image dimensions.
    imageRect.size.height = CGImageGetHeight(image);
    imageRect.size.width = CGImageGetWidth(image);
    
    // Create a new image to receive the Quartz image data.
    newImage = [[NSImage alloc] initWithSize:imageRect.size];
    [newImage lockFocus];
    
    // Get the Quartz context and draw.
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image);
    [newImage unlockFocus];
    
    return [newImage autorelease];
}

+ (CGImageRef)nsImageCopyCGImageRef:(NSImage*)image;
{
    NSData * imageData = [image TIFFRepresentation];
    CGImageRef imageRef;
    if(!imageData) return nil;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    CFRelease(imageSource);
    return imageRef;
}

+ (NSImage *)imageToGreyImage:(NSImage *)image {

    // Create image rectangle with current image width/height
    CGFloat actualWidth = image.size.width;
    CGFloat actualHeight = image.size.height;
    
    CGRect imageRect = CGRectMake(0, 0, actualWidth, actualHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context = CGBitmapContextCreate(nil, actualWidth, actualHeight, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    CGImageRef cgImage = [self nsImageCopyCGImageRef:image];
    CGContextDrawImage(context, imageRect, cgImage);

    CGImageRef grayImage = CGBitmapContextCreateImage(context);
    
    CGImageRelease(cgImage);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    context = CGBitmapContextCreate(nil, actualWidth, actualHeight, 8, 0, nil, (CGBitmapInfo)kCGImageAlphaOnly);
    cgImage = [self nsImageCopyCGImageRef:image];
    CGContextDrawImage(context, imageRect, cgImage);
    CGImageRef mask = CGBitmapContextCreateImage(context);

    CGImageRef finalImage = CGImageCreateWithMask(grayImage, mask);
    NSRect rect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    rect.size.height = CGImageGetHeight(finalImage);
    rect.size.width = CGImageGetWidth(finalImage);
    
    NSImage * grayScaleImage = [[[NSImage alloc]initWithCGImage:finalImage size:rect.size] autorelease];
    
//    NSImage *grayScaleImage = [self imageFromCGImageRef:CGImageCreateWithMask(grayImage, mask)];
    
    CGImageRelease(mask);
    CGImageRelease(cgImage);
    CGContextRelease(context);
    CGImageRelease(grayImage);
    CGImageRelease(finalImage);
    
    return grayScaleImage;
}

+ (NSImage *)scaleImage:(NSImage *)image toSize:(NSSize)targetSize {
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
            }
            else{
                scaleFactor = heightFactor;
            }
            
            scaledWidth  = width  * scaleFactor;
            scaledHeight = height * scaleFactor;
            
            if (widthFactor < heightFactor){
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            }
            
            else if (widthFactor > heightFactor){
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
            
            NSImage *newImage = [[NSImage alloc] initWithSize:targetSize];
            
            [newImage lockFocus];
            
            NSRect thumbnailRect;
            thumbnailRect.origin = thumbnailPoint;
            thumbnailRect.size.width = scaledWidth;
            thumbnailRect.size.height = scaledHeight;
            
            [image drawInRect:thumbnailRect
                     fromRect:NSZeroRect
                    operation:NSCompositeSourceOver
                     fraction:1.0];
            
            [newImage unlockFocus];
            return [newImage autorelease];
        }
    }
    return nil;
}

@end
