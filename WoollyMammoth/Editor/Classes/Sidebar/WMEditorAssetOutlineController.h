//
//  WMEditorAssetOutlineController.h
//  WoollyEditor
//
//  Created by Andrew Pouliot on 10/28/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WMEditorAssetOutlineController : NSViewController {
	NSArray *items;
}

@property (nonatomic, copy) NSArray *items;

@end
