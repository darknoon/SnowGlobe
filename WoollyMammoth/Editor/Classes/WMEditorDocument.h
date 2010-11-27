//
//  WMEditorDocument.h
//  WoollyEditor
//
//  Created by Andrew Pouliot on 10/23/10.
//  Copyright 2010 Darknoon. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@class WMEditorPreviewController;
@class WMEditorSidebarOutlineController;
@class WMBuildManager;
@class WMEditorSidebarItem;
@class WMEditorAssetManager;

@interface WMEditorDocument : NSDocument
{
	IBOutlet WMEditorSidebarOutlineController *sidebarViewController;
	IBOutlet NSTreeController *sidebarTreeController;
	NSSet *selectedSidebarIndexPaths;
	WMEditorSidebarItem *editingSidebarItem;
	
	IBOutlet NSView *contentView;
	NSViewController *itemEditorController;
	
	WMEditorPreviewController *preview;
		
	WMBuildManager *buildManager;
	
	WMEditorAssetManager *assetManager;
}

@property (nonatomic, retain) NSViewController *itemEditorController;
@property (nonatomic, retain) WMEditorSidebarItem *editingSidebarItem;
@property (nonatomic, copy) NSSet *selectedSidebarIndexPaths;
@property (nonatomic, retain) WMEditorAssetManager *assetManager;

- (IBAction)showPreview:(id)sender;

- (IBAction)build:(id)sender;

@end