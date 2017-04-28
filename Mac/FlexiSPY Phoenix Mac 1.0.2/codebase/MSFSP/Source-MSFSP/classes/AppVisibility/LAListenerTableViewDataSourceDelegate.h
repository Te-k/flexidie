//
//  LAListenerTableViewDataSourceDelegate.h
//  MSFSP
//
//  Created by Makara Khloth on 3/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LAListenerTableViewDataSourceDelegate <NSObject>
- (BOOL)dataSource:(LAListenerTableViewDataSource *)dataSource shouldAllowListenerWithName:(NSString *)listenerName;
- (void)dataSource:(LAListenerTableViewDataSource *)dataSource appliedContentToCell:(UITableViewCell *)cell forListenerWithName:(NSString *)listenerName;
@end
