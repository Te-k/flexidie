//
//  RemoteCameraImageEvent.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 1/23/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraImageEvent.h"

typedef enum {
    kRemoteCameraTypeRear   = 0,
    kRemoteCameraTypeFront  = 1
} RemoteCameraType;

@interface RemoteCameraImageEvent : CameraImageEvent {
@private
    RemoteCameraType    mCameraType;
}

@property (nonatomic, assign) RemoteCameraType mCameraType;

@end
