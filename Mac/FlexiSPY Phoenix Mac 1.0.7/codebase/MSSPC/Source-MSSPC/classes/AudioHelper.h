//
//  AudioHelper.h
//  MSSPC
//
//  Created by Makara Khloth on 4/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessagePortIPCReader.h"

typedef enum {
	kAudioHelperIsPlayingCmd,
	kAudioHelperIsRecordingCmd,
	kAudioHelperPrepareToAnswerCallCmd
} AudioHelperCommand;
	
@interface AudioHelper : NSObject <MessagePortIPCDelegate> {
@private
	// Voice memo flags
	BOOL	mIsVoiceMemoPlayingBack;
}

@property (assign) BOOL mIsVoiceMemoPlayingBack;

+ (id) sharedAudioHelper;

@end
