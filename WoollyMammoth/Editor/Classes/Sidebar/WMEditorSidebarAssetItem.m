//
//  WMEditorSidebarAssetItem.m
//  WoollyEditor
//
//  Created by Andrew Pouliot on 11/22/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMEditorSidebarAssetItem.h"

#import "WMEditorAsset.h"

@implementation WMEditorSidebarAssetItem

@synthesize asset;

- (void)dealloc
{
	[asset release];
	asset = nil;

	[super dealloc];
}

- (NSString *)name {
    return asset.resourceName;
}

- (void)setName:(NSString *)value {
	asset.resourceName = value;
}

@end
