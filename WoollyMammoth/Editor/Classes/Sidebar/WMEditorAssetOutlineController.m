//
//  WMEditorAssetOutlineController.m
//  WoollyEditor
//
//  Created by Andrew Pouliot on 10/28/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMEditorAssetOutlineController.h"

#import "WMEditorSidebarItem.h"

@implementation WMEditorAssetOutlineController

@synthesize items;

- (void)dealloc
{
	[items release];
	items = nil;

	[super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (!self) return nil;
	
	WMEditorSidebarItem *item = [[[WMEditorSidebarItem alloc] init] autorelease];
	item.name = @"root";

	[item insertChildWithName:@"foo"];
	[item insertChildWithName:@"bar"];
	[item insertChildWithName:@"bash"];
	
	self.items = [NSArray arrayWithObject:item];
	
	return self;
}

@end
