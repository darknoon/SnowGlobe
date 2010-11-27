//
//  WMEditorAssetViewController.h
//  WoollyEditor
//
//  Created by Andrew Pouliot on 11/22/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "WMEditorAsset.h"

@interface WMEditorAssetViewController : NSViewController {
	WMEditorAsset *item;
	NSObjectController *assetController;
}

@property (nonatomic, retain) IBOutlet NSObjectController *assetController;
@property (nonatomic, retain) WMEditorAsset *item;

@end
