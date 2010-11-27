//
//  WMEditorAssetOutlineController.h
//  WoollyEditor
//
//  Created by Andrew Pouliot on 10/28/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WMEditorSidebarOutlineController : NSViewController {
	NSArray *items;
	
	NSArray *assets;
}

@property (nonatomic, copy) NSArray *assets;
@property (nonatomic, copy, readonly) NSArray *items;

@end
