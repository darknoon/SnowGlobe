//
//  WMEditorPreviewController.h
//  WoollyEditor
//
//  Created by Andrew Pouliot on 10/23/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WMEditorPreviewView;

@interface WMEditorPreviewController : NSWindowController {
	IBOutlet WMEditorPreviewView *previewView;
	IBOutlet NSPopUpButton *outputPopUpButton;
	
	NSArray *devices;
	
	NSDictionary *currentDevice;
}

@property (nonatomic, copy) NSDictionary *currentDevice;

- (NSArray *)devices;
- (IBAction)selectOutput:(id)sender;

@end
