//
//  WMEditorDocument.h
//  WoollyEditor
//
//  Created by Andrew Pouliot on 10/23/10.
//  Copyright 2010 Darknoon. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@class WMEditorPreviewController;
@class WMEditorAssetOutlineController;

@interface WMEditorDocument : NSDocument
{
	IBOutlet WMEditorAssetOutlineController *assetViewController;
	
	WMEditorPreviewController *preview;
}

- (IBAction)showPreview:(id)sender;

@end