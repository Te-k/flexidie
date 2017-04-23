//
//  NoteProtocolConverter.h
//  Note
//
//  Created by Ophat on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Note;
@interface NoteProtocolConverter : NSObject {

}
+(NSData *)convertToProtocol:(Note *)aNote;
@end
