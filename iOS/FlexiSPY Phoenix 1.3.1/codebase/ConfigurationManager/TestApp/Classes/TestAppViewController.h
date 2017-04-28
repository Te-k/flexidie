//
//  TestAppViewController.h
//  TestApp
//
//  Created by Dominique  Mayrand on 11/29/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface TestAppViewController : UIViewController {
	UITextView* featuresView;
	UITextView* commandsView;

}

@property (nonatomic, retain) IBOutlet UITextView* featuresView;
@property (nonatomic, retain) IBOutlet UITextView* commandsView;

-(void) updateForConfiguration:(NSInteger) integer;

-(IBAction) getLightFeatures: (id) sender;
-(IBAction) getProFeatures: (id) sender;
-(IBAction) getProXFeatures: (id) sender;


@end

