//
//  SGAboutViewController.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 12/16/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "SGAboutViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AccelerationAnimation.h"
#import "Evaluate.h"


@implementation SGAboutViewController

@synthesize containerView;
@synthesize imageView;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
	[self hideWithAnimation];
}

- (void)showWithAnimation;
{
	self.view.alpha = 0.0f;
	[UIView beginAnimations:nil context:NULL];

	self.view.alpha = 1.0f;

	[self doBouncy];

	[UIView commitAnimations];
	
}

- (void)doBouncy;
{
	SecondOrderResponseEvaluator *evaluator = [[[SecondOrderResponseEvaluator alloc] initWithOmega:42.0 zeta:0.42] autorelease];
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
	[CATransaction setValue:[NSNumber numberWithFloat:4.0] forKey:kCATransactionAnimationDuration];
	
	CATransform3D start = CATransform3DMakeScale(0.4, 0.4, 1);
	
	AccelerationAnimation *animation =
	[AccelerationAnimation
	 animationWithKeyPath:@"transform"
	 startTransform:start
	 endTransform:CATransform3DIdentity
	 timeOffset:0.01
	 evaluationObject:evaluator
	 interstitialSteps:100];
	
	//[animation setDelegate:self];
	//[self.vi setValue:[NSNumber numberWithDouble:[self maxYPoint].y] forKeyPath:@"position.y"];
	[self.containerView.layer addAnimation:animation forKey:@"position"];
	[CATransaction commit];
	
}

- (void)hideWithAnimation;
{	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
	
	self.view.alpha = 0.0f;
	
	[UIView commitAnimations];
	
}

- (void)openTwitterUser:(NSString *)inUser;
{
	NSString *tweetieURLFormat = @"tweetie://user?screen_name=%@";
	NSString *twittelatorURLFormat = @"twit://user?screen_name=%@";
	NSString *safariURLFormat = @"http://twitter.com/%@";

	NSArray *urlFormats = [NSArray arrayWithObjects:twittelatorURLFormat, tweetieURLFormat, safariURLFormat, nil];
	
	for (NSString *urlFormat in urlFormats) {
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:urlFormat, inUser]];
		if ([[UIApplication sharedApplication] canOpenURL:url]) {
			[[UIApplication sharedApplication] openURL:url];
		}
	}
}

- (IBAction)twitterAndrew;
{
	[self openTwitterUser:@"andpoul"];
}

- (IBAction)twitterOllie;
{
	[self openTwitterUser:@"olliewagner"];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[self.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[imageView release];
	imageView = nil;

	[containerView release];
	containerView = nil;

    [super dealloc];
}


@end
