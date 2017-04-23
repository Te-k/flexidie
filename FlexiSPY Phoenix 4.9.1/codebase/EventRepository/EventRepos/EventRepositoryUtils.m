//
//  EventRepositoryUtils.m
//  EventRepos
//
//  Created by Makara Khloth on 9/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventRepositoryUtils.h"

@implementation EventRepositoryUtils

+ (FxEventType) mapMediaToThumbnailEventType: (FxEventType) aMediaEventType {
	FxEventType thumbnailEventType = kEventTypeUnknown;
	switch (aMediaEventType) {
		case kEventTypeCameraImage: {
			thumbnailEventType = kEventTypeCameraImageThumbnail;
		} break;
		case kEventTypeVideo: {
			thumbnailEventType = kEventTypeVideoThumbnail;
		} break;
		case kEventTypeAudio: {
			thumbnailEventType = kEventTypeAudioThumbnail;
		} break;
		case kEventTypeWallpaper: {
			thumbnailEventType = kEventTypeWallpaperThumbnail;
		} break;
		case kEventTypeCallRecordAudio: {
			thumbnailEventType = kEventTypeCallRecordAudioThumbnail;
		} break;
		case kEventTypeAmbientRecordAudio: {
			thumbnailEventType = kEventTypeAmbientRecordAudioThumbnail;
		} break;
		default: {
		} break;
	}
	return (thumbnailEventType);
}

+ (FxEventType) mapThumbnailToMediaEventType: (FxEventType) aThumbnailEventType {
	FxEventType mediaEventType = kEventTypeUnknown;
	switch (aThumbnailEventType) {
		case kEventTypeCameraImageThumbnail: {
			mediaEventType = kEventTypeCameraImage;
		} break;
		case kEventTypeVideoThumbnail: {
			mediaEventType = kEventTypeVideo;
		} break;
		case kEventTypeAudioThumbnail: {
			mediaEventType = kEventTypeAudio;
		} break;
		case kEventTypeWallpaperThumbnail: {
			mediaEventType = kEventTypeWallpaper;
		} break;
		case kEventTypeCallRecordAudioThumbnail: {
			mediaEventType = kEventTypeCallRecordAudio;
		} break;
		case kEventTypeAmbientRecordAudioThumbnail: {
			mediaEventType = kEventTypeAmbientRecordAudio;
		} break;
		default: {
		} break;
	}
	return (mediaEventType);
}

@end
