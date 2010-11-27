//
//  WMEditorAssetOutlineController.m
//  WoollyEditor
//
//  Created by Andrew Pouliot on 10/28/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMEditorSidebarOutlineController.h"

#import "WMEditorSidebarItem.h"
#import "WMEditorAsset.h"
#import "WMEditorSidebarAssetItem.h"

@interface WMEditorSidebarOutlineController ()
@property (nonatomic, copy) NSArray *items;
@end


@implementation WMEditorSidebarOutlineController

@synthesize assets;
@synthesize items;

- (void)dealloc
{
	[items release];
	[assets release];

	[super dealloc];
}

- (void)refreshItems;
{
	NSMutableArray *mutableItems = [NSMutableArray array];
	
	WMEditorSidebarItem *assetsItem = [[[WMEditorSidebarItem alloc] init] autorelease];
	assetsItem.name = @"Assets";
	
	// [assetItem insertChildWithName:@"foo"];
	// [assetItem insertChildWithName:@"bar"];
	// [assetItem insertChildWithName:@"bash"];
	
	for (WMEditorAsset *asset in assets) {
		WMEditorSidebarAssetItem *assetItem = [[[WMEditorSidebarAssetItem alloc] init] autorelease];
		assetItem.asset = asset;
		[assetsItem insertChild: assetItem];
	}
	
	[mutableItems addObject:assetsItem];
	
	self.items = mutableItems;
}

- (void)setAssets:(NSArray *)value {
	if (assets == value) return;
	[assets release];
	assets = [value copy];
	
	[self refreshItems];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (!self) return nil;
		
	[self refreshItems];
	
	return self;
}

@end
