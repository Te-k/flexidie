//
//  FacebookSerialOperation.h
//  MSFSP
//
//  Created by Makara on 8/7/14.
//
//

#import <Foundation/Foundation.h>

@interface FacebookSerialOperation : NSOperation {
@private
    NSArray *mArgs;
    
    id      mDelegate;
    SEL     mSelector;
}

@property (assign) id mDelegate;
@property (assign) SEL mSelector;

- (id) initWithArgs: (NSArray *) aArgs;

@end
