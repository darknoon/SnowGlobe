//
//  SGMainViewController.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 4/5/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import "SGMainViewController.h"

#import "SoundManager.h"

#import "SGRibbon.h"
#import "SGAboutViewController.h"

#import "SHK.h"
#import "SHKItem.h"
#import "SHKTwitter.h"
#import "SHKMail.h"
#import "SHKFacebook.h"


@implementation SGMainViewController
@synthesize aboutViewController;
@synthesize ribbon;

- (id)initWithCoder:(NSCoder *)aDecoder;
{
	self = [super initWithCoder:aDecoder];
	if (!self) return nil;

	self.compositionURL = [[NSBundle mainBundle] URLForResource:@"SnowGlobe" withExtension:@"wmbundle"];
	
	return self;
}

- (void)dealloc
{
	[ribbon release];
	ribbon = nil;
	
	[aboutViewController release];
	aboutViewController = nil;

    [super dealloc];
}


#pragma mark - View lifecycle

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
	if (ribbon.open) {
		[ribbon setOpen:NO animated:YES];
		[self startAnimation];
	}
}

- (IBAction)showShare:(id)sender;
{
	[[SoundManager sharedManager] playSound:@"shutter"];
	[self stopAnimation];
	ribbon.mailButton.enabled = [SHKMail canShare];
	
	[ribbon setOpen:YES animated:YES];
}

- (IBAction)showAbout:(id)sender;
{
	[self.view addSubview:aboutViewController.view];
	aboutViewController.view.frame = self.view.bounds;
	[aboutViewController showWithAnimation];	
	[[SoundManager sharedManager] playSound:@"about"];
}


- (SHKItem *)shareItemWithScreenshot;
{
	return [SHKItem image:[self screenshotImage] title:@"It's Snowing!"];
}

- (IBAction)shareFacebook:(id)sender;
{
	SHKItem *item = [self shareItemWithScreenshot];
	item.title = @"Made with Snow Globe, by poptical – for iPhone and iPod touch.";
	[SHKFacebook shareItem:item];
	[ribbon setOpen:NO animated:YES];
	[self startAnimation];
}

- (IBAction)shareTwitter:(id)sender;
{
	SHKItem *item = [self shareItemWithScreenshot];
	item.title = @"Made with poptical's Snow Globe App for iPhone and iPod touch\n http://itunes.com/app/snowglobebypoptical";
	[SHKTwitter shareItem:item];
	[ribbon setOpen:NO animated:YES];
}

- (IBAction)shareEmail:(id)sender;
{
	SHKItem *item = [self shareItemWithScreenshot];
	[item setCustomValue:@"Made with poptical's <a href='http://itunes.com/app/snowglobebypoptical'>Snow Globe</a> App for iPhone and iPod touch" forKey:@"body"];
	[SHKMail shareItem:item];
	[ribbon setOpen:NO animated:YES];
}


@end
