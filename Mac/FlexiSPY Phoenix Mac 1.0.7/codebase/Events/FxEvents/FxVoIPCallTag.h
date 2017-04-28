//
//  FxVoIPCallTag.h
//  FxEvents
//
//  Created by Makara Khloth on 10/10/16.
//
//

#import <Foundation/Foundation.h>
#import "FxVoIPEvent.h"

@interface FxVoIPCallTag : NSObject <NSCoding> {
@private
    NSUInteger          dbId;
    FxEventDirection	direction;
    NSInteger           duration;
    NSString            *ownerNumberAddr;
    NSString            *ownerName;
    NSArray             *recipients; // FxRecipient
    FxVoIPCategory      category;
    FxVoIPMonitor       isMonitor;
}

@property (nonatomic, assign) NSUInteger dbId;
@property (nonatomic, assign) FxEventDirection direction;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, copy) NSString *ownerNumberAddr;
@property (nonatomic, copy) NSString *ownerName;
@property (nonatomic, retain) NSArray *recipients;
@property (nonatomic, assign) FxVoIPCategory category;
@property (nonatomic, assign) FxVoIPMonitor isMonitor;

@end
