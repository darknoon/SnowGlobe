//
//  SGAboutViewController.h
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 12/16/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SGAboutViewController : UIViewController {
	IBOutlet UIImageView *imageView;
	IBOutlet UIView *containerView;
}

@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) UIImageView *imageView;

- (void)showWithAnimation;
- (void)hideWithAnimation;

- (IBAction)twitterAndrew;
- (IBAction)twitterOllie;

@end
