//
//  WMEditorAssetViewController.m
//  WoollyEditor
//
//  Created by Andrew Pouliot on 11/22/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMEditorAssetViewController.h"


@implementation WMEditorAssetViewController

@synthesize document;
@synthesize assetController;
@synthesize item;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (!self) return nil;
	
	
	return self;
}

- (void)loadView;
{
	[super loadView];
	
	[assetController setContent:item];
}

- (void)setItem:(WMEditorAsset *)inItem;
{
	[item autorelease];
	item = [inItem retain];
	[assetController setContent:inItem];
}

- (void)dealloc
{
	[item release];
	[assetController release];
	
	[super dealloc];
}

@end
