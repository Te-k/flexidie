//
//  TestPanicViewController.h
//  TestPanic
//
//  Created by Dominique  Mayrand on 11/16/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PanicButton.h"

@interface TestPanicViewController : UIViewController <PanicButtonDelegate> {
	PanicButton *panicButton;;
}

@property (retain, nonatomic) PanicButton* panicButton;

@end

