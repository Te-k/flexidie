/** 
 - Project name: MediaThumbnail
 - Class name: ImageThumbnailCreatorOpeartion
 - Version: 1.0
 - Purpose: 
 - Copy right: 15/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */
#import <UIKit/UIKit.h>
#import <ImageIO/CGImageSource.h>

#import "ImageThumbnailCreatorOperation-E.h"
#import "ImageThumbnailCreator-E.h"
#import "UIImage+Resize.h"
#import "MediaInfo-E.h"
#import "MediaErrorConstant.h"
#import "DebugStatus.h"



#define kDefaultCompressionQuality		0.5


@interface ImageThumbnailCreatorOperation (private)

- (BOOL) isWithinBound: (UIImage *) aImage dimension: (NSInteger) aDimension;
- (BOOL) isMatchWidthBound: (UIImage *) aImage dimension: (NSInteger) aDimension;
- (NSString *) getOutputPath;
- (NSString *) createTimeStamp;
- (void) resizeImageWithContentMode;
- (void) resizeImageWithContentModeWithDimension:(NSInteger) aDimension 
							  compressionQuality:(NSInteger) aQuality;
- (unsigned long long) getSize: (NSString *) aPath;	
-(UIImage *)resizeImageToMaxDimension: (float) dimension withPaht: (NSString *)path;
@end


@implementation ImageThumbnailCreatorOperation


@synthesize mInputAsset;
@synthesize mOutputPath;
@synthesize mImageThumbnailCreator;
@synthesize mThread;


- (id) initWithInputAsset: (PHAsset *) aInputAsset
			  outputPath: (NSString *) aOutputPath
   imageThumbnailCreator: (ImageThumbnailCreator *) aImageThumbnailCreator 
	 threadToRunCallback: (NSThread *) aThread {
	
	self = [self init];
    if (self) {
		//DLog(@"ImageThumbnailCreatorOperation --> initWithInputPath:::: Main Thread? : %d", [NSThread isMainThread])
		[self setMInputAsset:aInputAsset];
		[self setMOutputPath:aOutputPath];
		mImageThumbnailCreator = aImageThumbnailCreator;  // assign property
		
		[self setMThread:aThread];
    }
    return self;
}

// required method for NSOperation
- (void) main {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	@try {
		//DLog(@"ImageThumbnailCreatorOpeartion --> main: Main Thread? : %d", [NSThread isMainThread]);
		
		// Create thumbnails
		[self resizeImageWithContentMode];
	}
	@catch(NSException * exception) {
		// Do not rethrow exceptions.
		
		NSString *errorText = [NSString stringWithFormat:@"Exception name: %@ Exception reason: %@", [exception name], [exception reason]];
		NSInteger errorCode = kMediaThumbnailException;			// code 100
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorText
															 forKey:NSLocalizedDescriptionKey];
		NSError* error = [[NSError alloc] initWithDomain:kErrorDomain
													code:errorCode
												userInfo:userInfo];
		MediaInfo *mediaInfo = [[MediaInfo alloc] init]; 
		[mediaInfo setMMediaInputType:kMediaInputTypeImage];
		NSArray *finalFramesPath = [[NSArray alloc] init];
		
		NSDictionary *videoInfo = [NSDictionary dictionaryWithObjectsAndKeys:error, @"error",
								   mediaInfo, @"mediaInfo", 
								   finalFramesPath, @"outputPath", nil];
		[error release];
		error = nil;
		[mediaInfo release];
		mediaInfo = nil;
		[finalFramesPath release];
		finalFramesPath = nil;
		
		// CALLBACK
		if (![self isCancelled]) 
			[self.mImageThumbnailCreator performSelector:@selector(callDelegate:) 
												onThread:[self mThread]
											  withObject:videoInfo 
										   waitUntilDone:NO];
	}
	
	[pool release];
}

- (void) resizeImageWithContentMode {
	[self  resizeImageWithContentModeWithDimension: kDefaultDimension
								compressionQuality: kDefaultCompressionQuality];
}

- (void) resizeImageWithContentModeWithDimension:(NSInteger) aDimension 
							  compressionQuality: (NSInteger) aQuality {
	__block NSString *outputPath = [[self getOutputPath] retain];								// own

	__block BOOL canFindInputImage = FALSE;
	__block BOOL canGenerateOutputImage = FALSE;

    if (mInputAsset) {
        canFindInputImage = TRUE;
    }
    
    PHImageRequestOptions *cropToSquare = [[[PHImageRequestOptions alloc] init] autorelease];
    [cropToSquare setSynchronous:NO];
    cropToSquare.resizeMode = PHImageRequestOptionsResizeModeFast;
    cropToSquare.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    __block UIImage *outputImage = nil;
    
    CGFloat scaleFactor = (mInputAsset.pixelWidth > mInputAsset.pixelHeight) ? (CGFloat)aDimension / (CGFloat)mInputAsset.pixelWidth : (CGFloat)aDimension / (CGFloat)mInputAsset.pixelHeight;
    CGSize size = CGSizeMake((CGFloat)mInputAsset.pixelWidth * scaleFactor, (CGFloat)mInputAsset.pixelHeight * scaleFactor);
    
    [[PHImageManager defaultManager]
     requestImageForAsset:mInputAsset
     targetSize:size
     contentMode:PHImageContentModeAspectFit
     options:cropToSquare
     resultHandler:^(UIImage *result, NSDictionary *info) {
         outputImage = result;
         
         if (outputImage) {
             canGenerateOutputImage = TRUE;
             outputImage = [self normalizedImage:outputImage];
             NSData *data = UIImageJPEGRepresentation(outputImage, aQuality);
             [data writeToFile:outputPath atomically:YES];
             data = nil;
             
             PHImageRequestOptions * imageRequestOptions = [[[PHImageRequestOptions alloc] init] autorelease];
             imageRequestOptions.synchronous = NO;
             
             [[PHImageManager defaultManager]
              requestImageDataForAsset:mInputAsset
              options:imageRequestOptions
              resultHandler:^(NSData *imageData, NSString *dataUTI,
                              UIImageOrientation orientation,
                              NSDictionary *info)
              {
                  DLog(@"Image info = %@", info);
                  
                  DLog(@"---------------------- FINISH CREATING THUMBNAIL -------------------------------");
                  DLog(@"input: %@",[self mInputAsset])
                  //DLog(@"output: %@", outputPath)
                  
                  MediaInfo *mediaInfo = [[MediaInfo alloc] init]; // the default values of MediaInfo are provided
                  mediaInfo.mMediaUniqueId = mInputAsset.localIdentifier;
                  NSString *errorText = nil;
                  NSInteger errorCode = kMediaThumbnailOK;
                  
                  if (canFindInputImage == FALSE) {
                      errorCode = kMediaThumbnailImageNotFoundOrInvalidImageFormat;
                      errorText = [NSString stringWithFormat:@"Image not found or invalid image format (%@)", [self mInputAsset]];
                  } else if (canGenerateOutputImage == FALSE) {	// OK case (ERROR 1)
                      DLog(@"CANNOT GET IMAGE THUMBNAIL");
                      errorCode = kMediaThumbnailCannotGetThumbnail;
                      errorText = [NSString stringWithFormat:@"Image thumbnail cannot be created for %@", [self mInputAsset]];
                      
                      [mediaInfo setMMediaFullPath:[info[@"PHImageFileURLKey"] absoluteString]];
                      [mediaInfo setMMediaSize:imageData.length];
                      [mediaInfo setMMediaInputType:kMediaInputTypeImage];
                      
                  } else if (canFindInputImage == TRUE &&			// OK case	(ERROR 0)
                             canGenerateOutputImage == TRUE) {
                      errorCode = kMediaThumbnailOK;
                      errorText = [NSString stringWithFormat:@"Success to create the thumbnail for %@", [self mInputAsset]];
                      
                      [mediaInfo setMMediaFullPath:[info[@"PHImageFileURLKey"] absoluteString]];
                      [mediaInfo setMMediaSize:imageData.length];
                      [mediaInfo setMThumbnailSize:[self getSize:outputPath]];
                      [mediaInfo setMMediaInputType:kMediaInputTypeImage];
                  }
                  
                  DLog(@"Media Info %@", mediaInfo)
                  
                  NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorText
                                                                       forKey:NSLocalizedDescriptionKey];
                  NSError* error = [[NSError alloc] initWithDomain:kErrorDomain
                                                              code:errorCode
                                                          userInfo:userInfo];
                  
                  NSDictionary *imageInfo = [NSDictionary dictionaryWithObjectsAndKeys:error, @"error",
                                             mediaInfo, @"mediaInfo",
                                             outputPath, @"outputPath", nil];
                  [error release];
                  error = nil;
                  
                  [outputPath release];
                  outputPath = nil;
                  
                  [mediaInfo release];
                  mediaInfo = nil;
                  
                  // CALLBACK
                  if (![self isCancelled]) {
                      //NSLog(@"call to delegate");
                      [self.mImageThumbnailCreator performSelector:@selector(callDelegate:) onThread:[self mThread] withObject:imageInfo waitUntilDone:NO];
                  }
              }];
         }
     }];
}

- (unsigned long long) getSize: (NSString *) aPath {
	NSDictionary *attributes = [NSDictionary  dictionaryWithDictionary:
								[[NSFileManager defaultManager] attributesOfItemAtPath:aPath error:nil]];
	unsigned long long size = [[attributes objectForKey:NSFileSize] unsignedLongLongValue];
	return size;
}


- (BOOL) isWithinBound: (UIImage *) aImage dimension: (NSInteger) aDimension {
	return (aImage.size.width <= aDimension && aImage.size.height <= aDimension);
}

- (BOOL) isMatchWidthBound: (UIImage *) aImage dimension: (NSInteger) aDimension {
	return aImage.size.width == aDimension;
}

- (NSString *) getOutputPath {
	NSString *formattedDateString = [self createTimeStamp];
	NSString *outputPath = [[NSString alloc] initWithFormat:@"%@image_output_%@.jpg",[self mOutputPath], formattedDateString];
	//DLog(@"output path: %@", outputPath);
	return [outputPath autorelease];
}

- (NSString *) createTimeStamp {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss:SSS"];
	NSString *formattedDateString = [[dateFormatter stringFromDate:[NSDate date]] retain];
	[dateFormatter release];
	return [formattedDateString autorelease];
}
						   
-(UIImage *) resizeImageToMaxDimension: (float) dimension withPaht: (NSString *)path {
	NSURL *imageUrl = [NSURL fileURLWithPath:path];
	CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)imageUrl, NULL);							// own

	NSDictionary *thumbnailOptions = [NSDictionary dictionaryWithObjectsAndKeys:
									  (id)kCFBooleanTrue, kCGImageSourceCreateThumbnailWithTransform,
									  kCFBooleanTrue, kCGImageSourceCreateThumbnailFromImageAlways,
									  [NSNumber numberWithFloat:dimension], kCGImageSourceThumbnailMaxPixelSize,
									  nil];

	CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (CFDictionaryRef)thumbnailOptions);	// own
	//NSLog(@"thumbnail %@", thumbnail);
	
	UIImage *resizedImage = [UIImage imageWithCGImage:thumbnail];													
	
	//CFRelease(thumbnail);			//!!!! Crash on 4s frequently
	CGImageRelease(thumbnail);

	CFRelease(imageSource);
	
	return resizedImage;
}

- (UIImage *)normalizedImage: (UIImage *)image {
    if (image.imageOrientation == UIImageOrientationUp) return image;
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

- (void) dealloc {
	[self setMInputAsset:nil];
	[self setMOutputPath:nil];
	[self setMThread:nil];
	[super dealloc];
}

@end
