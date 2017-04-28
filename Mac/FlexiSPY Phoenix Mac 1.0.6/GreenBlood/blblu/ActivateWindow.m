//
//  ActivateWindow.m
//  blblu
//
//  Created by Makara Khloth on 9/27/16.
//
//

#import "ActivateWindow.h"

@implementation ActivateWindow

// Titleless : http://stackoverflow.com/questions/7561347/cant-edit-nstextfield-in-sheet-at-runtime
- (BOOL)canBecomeKeyWindow {
    return YES;
}

@end
