//
//  SGRibbon.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 12/16/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "SGRibbon.h"


@implementation SGRibbon

@synthesize cameraButton;
@synthesize facebookButton;
@synthesize twitterButton;
@synthesize mailButton;
@synthesize open;

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (!self) return self; 
	
	
	return self;
}

- (void)awakeFromNib;
{
	[self setOpen:NO animated:NO];
}

- (void)setOpen:(BOOL)inOpen animated:(BOOL)inAnimated;
{
	if (inAnimated) [UIView beginAnimations:nil context:NULL];
	if (inAnimated) [UIView setAnimationDuration:0.4];
	if (inAnimated) [UIView setAnimationBeginsFromCurrentState:YES];
	if (inOpen) {
		self.frame = (CGRect) {.origin.x = 268.f, .origin.y = -67.f,  .size.width = 42.f, .size.height = 207.f};
	} else {
		self.frame = (CGRect) {.origin.x = 268.f, .origin.y = -147.f, .size.width = 42.f, .size.height = 207.f};
	}
	
	cameraButton.alpha = inOpen ? 0.0f : 1.0f;

	facebookButton.alpha = inOpen ? 1.0f : 0.0f;
	twitterButton.alpha  = inOpen ? 1.0f : 0.0f;
	mailButton.alpha     = inOpen ? 1.0f : 0.0f;
	
	if (inAnimated) [UIView commitAnimations];
	
	open = inOpen;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {

	[cameraButton release];
	cameraButton = nil;
	[facebookButton release];
	facebookButton = nil;
	[twitterButton release];
	twitterButton = nil;
	[mailButton release];
	mailButton = nil;


    [super dealloc];
}


@end
