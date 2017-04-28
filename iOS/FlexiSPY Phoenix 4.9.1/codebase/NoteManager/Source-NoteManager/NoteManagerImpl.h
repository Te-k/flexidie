//
//  NoteManagerImpl.h
//  NoteManager
//
//  Created by Ophat on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoteManager.h"
#import "DeliveryListener.h"

@protocol NoteDeliveryDelegate, DataDelivery;

@class NoteContext;
@class NoteEventNotifier, NoteDataProvider;

@interface NoteManagerImpl : NSObject<NoteManager, DeliveryListener> {
@private
	NoteContext		*mNoteContext;
	NoteEventNotifier *mNoteEventNotifier;
	NoteDataProvider *mNoteDataProvider;
	
	id<NoteDeliveryDelegate> mDelegate;
	id<DataDelivery>	mDDM;
    
    int mDispatchToken;
}

@property (nonatomic, retain) NoteContext *mNoteContext;

-(id)initWithDDM:(id<DataDelivery>)aDataDelivery;

-(void)startCapture;
-(void)stopCapture;

@end
