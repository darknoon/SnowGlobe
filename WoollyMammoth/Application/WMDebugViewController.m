//
//  WMDebugViewController.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/21/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMDebugViewController.h"

#import "WMEngine.h"
#import "WMAssetManager.h"
#import "WMViewController.h"

@implementation WMDebugViewController

@synthesize parent;
@synthesize activityIndicator;
@synthesize gameTitleLabel;
@synthesize gamePathLabel;


- (void)updateLabels;
{
	gameTitleLabel.text = [parent.engine title];
	gamePathLabel.text = [parent.engine.assetManager.assetBundle bundlePath];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self updateLabels];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.gamePathLabel = nil;
	self.gameTitleLabel = nil;
}

- (IBAction)close;
{
	[self.view removeFromSuperview];
}

- (IBAction)reloadGame;
{
	[activityIndicator startAnimating];
	[parent reloadGame];
	[activityIndicator stopAnimating];
}

- (void)dealloc {
	[gamePathLabel release];
	[gameTitleLabel release];
    [super dealloc];
}


@end
