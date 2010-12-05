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
	WMEditorSidebarOutlineController *sidebarViewController;
	
	IBOutlet NSView *contentView;
	NSViewController *itemEditorController;
	
	WMEditorPreviewController *preview;
		
	WMBuildManager *buildManager;
	
	WMEditorAssetManager *assetManager;
}

@property (nonatomic, retain) IBOutlet WMEditorSidebarOutlineController *sidebarViewController;
@property (nonatomic, retain) NSViewController *itemEditorController;
@property (nonatomic, retain) WMEditorAssetManager *assetManager;

- (IBAction)showPreview:(id)sender;

- (IBAction)build:(id)sender;

- (void)inspectSidebarItem:(WMEditorSidebarItem *)editingSidebarItem;


@end