//
//  SGMainViewController.h
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 4/5/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WMViewController.h"

@interface SGMainViewController : WMViewController {
	IBOutlet SGAboutViewController *aboutViewController;
	
	IBOutlet SGRibbon *ribbon;
}

- (IBAction)showAbout:(id)sender;

- (IBAction)showShare:(id)sender;

- (IBAction)shareFacebook:(id)sender;
- (IBAction)shareTwitter:(id)sender;
- (IBAction)shareEmail:(id)sender;


@end
