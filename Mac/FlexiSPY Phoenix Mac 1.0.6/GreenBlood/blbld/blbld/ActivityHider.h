//
//  ActivityHider.h
//  blbld
//
//  Created by ophat on 3/9/16.
//
//

#import <Foundation/Foundation.h>

@interface ActivityHider : NSObject {
@private
    NSString *mActivityHiderPath;
}

@property (nonatomic, copy) NSString *mActivityHiderPath;

- (void) start;
- (void) stop;

@end
