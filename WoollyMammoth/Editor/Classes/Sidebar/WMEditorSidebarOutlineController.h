//
//  WMEditorAssetOutlineController.h
//  WoollyEditor
//
//  Created by Andrew Pouliot on 10/28/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WMEditorDocument;

@interface WMEditorSidebarOutlineController : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource> {
	NSArray *items;
	
	NSOutlineView *outlineView;
	
	WMEditorDocument *document;
}

@property (nonatomic, assign) IBOutlet WMEditorDocument *document;
@property (nonatomic, retain) IBOutlet NSOutlineView *outlineView;

@property (nonatomic, copy, readonly) NSArray *items;

@end
