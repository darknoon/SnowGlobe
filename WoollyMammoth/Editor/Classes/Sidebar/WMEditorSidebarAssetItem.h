//
//  WMEditorSidebarAssetItem.h
//  WoollyEditor
//
//  Created by Andrew Pouliot on 11/22/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "WMEditorSidebarItem.h"

@class WMEditorAsset;

@interface WMEditorSidebarAssetItem : WMEditorSidebarItem {
	WMEditorAsset *asset;
}

@property (nonatomic, retain) WMEditorAsset *asset;

@end
