//
//  SendTemporalControl.h
//  ProtocolBuilder
//
//  Created by Makara on 1/12/15.
//
//

#import <Foundation/Foundation.h>
#import "CommandData.h"

@interface SendTemporalControl : NSObject <CommandData> {
    NSArray *mTemporalControls;  // TemporalControl
}

@property (nonatomic, retain) NSArray *mTemporalControls;

@end
