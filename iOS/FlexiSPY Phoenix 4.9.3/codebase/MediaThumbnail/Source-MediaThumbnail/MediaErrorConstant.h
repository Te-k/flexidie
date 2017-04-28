/** 
 - Project name: MediaThumbnail
 - Class name: NONE (Filename: ErrorConstant)
 - Version: 1.0
 - Purpose: 
 - Copy right: 14/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>


#define kErrorDomain	@"com.ssmp.MediaThumbnailCreatorOperationDomain"


typedef enum {
	kMediaThumbnailOK = 0,									// can get duration and generate thumbnail
	kMediaThumbnailCannotGetThumbnail = 1,					// can get duration but CANNOT generate thumbnail

	kMediaThumbnailCannotGetDuration = 11,					// CANNOT get duration then not generate thumbnail
	kMediaThumbnailFileNotFound = 12,						// CANNOT find the input media, so we will not generate thumbnail
	kMediaThumbnailImageNotFoundOrInvalidImageFormat = 13,	// CANNOT find the input image, or the format of input image is invalid
	kMediaThumbnailException = 100,
} ThumbnailCreatorErrorCode;

