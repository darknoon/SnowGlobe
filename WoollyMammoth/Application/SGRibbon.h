//
//  SGRibbon.h
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 12/16/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SGRibbon : UIView {
	BOOL open;
		
	UIButton *cameraButton;

	UIButton *facebookButton;
	UIButton *twitterButton;
	UIButton *mailButton;
}

@property (nonatomic, retain) IBOutlet UIButton *cameraButton;
@property (nonatomic, retain) IBOutlet UIButton *facebookButton;
@property (nonatomic, retain) IBOutlet UIButton *twitterButton;
@property (nonatomic, retain) IBOutlet UIButton *mailButton;
@property (nonatomic, assign) BOOL open;

- (void)setOpen:(BOOL)inOpen animated:(BOOL)inAnimated;

@end
