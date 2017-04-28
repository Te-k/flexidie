//
//  NoteEventNotifier.h
//  NoteManager
//
//  Created by Ophat on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoteEventNotifier : NSObject {
	id mNoteChangeDelegate;
	SEL mNoteChangeSelector;
}

@property (nonatomic,assign) id mNoteChangeDelegate;
@property (nonatomic,assign) SEL mNoteChangeSelector;

-(void)start;
-(void)stop;

@end
