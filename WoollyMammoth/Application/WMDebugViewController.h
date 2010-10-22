//
//  WMDebugViewController.h
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/21/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMViewController;

@interface WMDebugViewController : UIViewController {
	WMViewController *parent;
}

@property (nonatomic, assign) IBOutlet WMViewController *parent;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UILabel *gameTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *gamePathLabel;

- (IBAction)close;
- (IBAction)reloadGame;

@end
