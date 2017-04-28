//
//  UseCaseFailureSender.h
//  TestApp
//
//  Created by Makara on 3/13/15.
//
//

#import <Foundation/Foundation.h>

@interface UseCaseFailureSender : NSObject {
    
}

+ (id) sharedUseCaseFailureSender;

- (void) postFailedUseCase: (NSDictionary *) aUseCase to: (NSString *) aEmail;

@end
