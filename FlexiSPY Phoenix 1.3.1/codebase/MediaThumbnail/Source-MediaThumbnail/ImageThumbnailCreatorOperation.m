/** 
 - Project name: MediaThumbnail
 - Class name: ImageThumbnailCreatorOpeartion
 - Version: 1.0
 - Purpose: 
 - Copy right: 15/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */
#import <UIKit/UIKit.h>
#import <ImageIO/CGImageSource.h>

#import "ImageThumbnailCreatorOperation.h"
#import "ImageThumbnailCreator.h"
#import "UIImage+Resize.h"
#import "MediaInfo.h"
#import "MediaErrorConstant.h"
#import "DebugStatus.h"


#define kDefaultDimension				200				// specified by the specification
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


@synthesize mInputPath;
@synthesize mOutputPath;
@synthesize mImageThumbnailCreator;
@synthesize mThread;


- (id) initWithInputPath: (NSString *) aInputPath 
			  outputPath: (NSString *) aOutputPath
   imageThumbnailCreator: (ImageThumbnailCreator *) aImageThumbnailCreator 
	 threadToRunCallback: (NSThread *) aThread {
	
	self = [self init];
    if (self) {
		//DLog(@"ImageThumbnailCreatorOperation --> initWithInputPath:::: Main Thread? : %d", [NSThread isMainThread])
		[self setMInputPath:aInputPath];
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
	// ******************************** POOL 1 ******************************************************
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];							// own, auto release pool 1 

	NSString *outputPath = [[self getOutputPath] retain];								// own
	DLog(@"output path %@", outputPath);
	
	BOOL canFindInputImage = FALSE;
	BOOL canGenerateOutputImage = FALSE;

    UIImage *inputImg = [[UIImage alloc] initWithContentsOfFile:[self mInputPath]];		// own
	DLog (@"Image to create thumbnail, inputImg = %@", inputImg);
	
	//NSLog(@"Image to create thumbnail, inputImg = %@", inputImg);
	
	// STEP 1: Ensure that input image exists
	if (inputImg) {
		canFindInputImage = TRUE;
		CGSize size = CGSizeMake(aDimension, aDimension);

		CGFloat imageWidth = inputImg.size.width;
		CGFloat imageHeight = inputImg.size.height;
		
		[inputImg release];																/// !!!: Release inputImag
		inputImg = nil;
		
		DLog(@"Original size: (%.f, %.f)", imageWidth, imageHeight);		
		//NSLog(@"Original size: (%.f, %.f)", imageWidth, imageHeight);		
		
		// ******************************** POOL 2 ******************************************************
		NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];					// auto release pool 2
			
		UIImage *outputImage = nil;
	
		// Reduce the size of only images whose bound exceed the specified dimension
		//if ([self isWithinBound:inputImg dimension:aDimension]) {
		if (0 /*&& [self isMatchWidthBound:inputImg dimension:aDimension]*/) { // Always scale up/down
			//DLog(@"Match width bound");
			canGenerateOutputImage = TRUE;
			outputImage = inputImg;
			[outputImage retain];														// own			
			DLog(@"Output size 1: (%.f, %.f)", [outputImage size].width,  [outputImage size].height);

			NSData *data = UIImageJPEGRepresentation(outputImage, aQuality);
			[data writeToFile:outputPath atomically:YES];
			data = nil;
		} else {
			DLog (@"---- Adjust the size ----- ")
			// Method below eat a lots memory
			/*
			outputImage = [inputImg resizedImageWithContentMode:UIViewContentModeScaleAspectFit
												   widthBounds:size 
										  interpolationQuality:kCGInterpolationLow];
			 */										
			// -- the height must be the fixed value for all the cases
			
			// calculate the max dimension
			CGFloat verticalRatio	= size.height / imageHeight;			 			
			CGSize newSize			= CGSizeMake(imageWidth * verticalRatio, imageHeight * verticalRatio);

			DLog (@"new size w:%f, h:%f", newSize.width, newSize.height)
			//NSLog (@"new size w:%f, h:%f", newSize.width, newSize.height);						
			CGFloat maxDimension = 0;
			if (newSize.width > newSize.height) 
				maxDimension = newSize.width;	
			else 
				maxDimension = newSize.height;		
							
			//outputImage = [self resizeImageToMaxDimension:size.width withPaht:[self mInputPath]];
			outputImage = [self resizeImageToMaxDimension:maxDimension withPaht:[self mInputPath]];		// autorelease image object
			//NSLog(@"outputImage %@", outputImage);

			if (outputImage) 
				[outputImage retain];													// own

			DLog(@"Output size 2: (%.f, %.f)", [outputImage size].width,  [outputImage size].height)
			// check whether the output image can be generated or not
			if (!outputImage || 
				([outputImage size].width == 0 && [outputImage size].height == 0) ) {	// cannot generate
				canGenerateOutputImage = FALSE;
				DLog(@"Cannot generate the output image");
				//NSLog(@"!!!Cannot generate the output image");
			} else {																	// can generate
				
				
				// ******************************** POOL 3 ******************************************************
				NSAutoreleasePool *pool3 = [[NSAutoreleasePool alloc] init];
				
				canGenerateOutputImage = TRUE;
				NSData *data = UIImageJPEGRepresentation(outputImage, aQuality);				
				
				// write the image thumbnail to a file
				[data writeToFile:outputPath atomically:YES];
				data = nil;
				
				
				//NSLog(@"Can generate image");
				[pool3 drain];
				// ******************************** END OF POOL 3 ******************************************************
			}			
		}
		
		if (outputImage) {
			[outputImage release];
			outputImage = nil;
		}
		
		[pool2 release];
		// ******************************** END OF POOL 2 ******************************************************
	} else {
		DLog(@"File not found or invalid format");
		canFindInputImage	= FALSE;
	}

	DLog(@"---------------------- FINISH CREATING THUMBNAIL -------------------------------");
	DLog(@"input: %@",[self mInputPath])
	//DLog(@"output: %@", outputPath)

	MediaInfo *mediaInfo = [[MediaInfo alloc] init]; // the default values of MediaInfo are provided
	NSString *errorText = nil;
	NSInteger errorCode = kMediaThumbnailOK;
	
	if (canFindInputImage == FALSE) {
		errorCode = kMediaThumbnailImageNotFoundOrInvalidImageFormat;
		errorText = [NSString stringWithFormat:@"Image not found or invalid image format (%@)", [self mInputPath]];
	} else if (canGenerateOutputImage == FALSE) {	// OK case (ERROR 1)
		DLog(@"CANNOT GET IMAGE THUMBNAIL");
		errorCode = kMediaThumbnailCannotGetThumbnail;
		errorText = [NSString stringWithFormat:@"Image thumbnail cannot be created for %@", [self mInputPath]];
			
		[mediaInfo setMMediaFullPath:[self mInputPath]];
		[mediaInfo setMMediaSize:[self getSize:[self mInputPath]]];
		[mediaInfo setMMediaInputType:kMediaInputTypeImage];
		
	} else if (canFindInputImage == TRUE &&			// OK case	(ERROR 0)
			   canGenerateOutputImage == TRUE) {
		errorCode = kMediaThumbnailOK;
		errorText = [NSString stringWithFormat:@"Success to create the thumbnail for %@", [self mInputPath]];
		
		[mediaInfo setMMediaFullPath:[self mInputPath]];	
		[mediaInfo setMMediaSize:[self getSize:[self mInputPath]]];
		[mediaInfo setMThumbnailSize:[self getSize:outputPath]];
		[mediaInfo setMMediaInputType:kMediaInputTypeImage];
	}
		
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
	[pool drain];
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

- (void) dealloc {
	[self setMInputPath:nil];
	[self setMOutputPath:nil];
	[self setMThread:nil];
	[super dealloc];
}

@end
