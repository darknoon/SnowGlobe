//
//  WMEditorShaderViewController.h
//  WoollyEditor
//
//  Created by Andrew Pouliot on 11/30/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "WMEditorAssetViewController.h"

@interface WMEditorShaderViewController : WMEditorAssetViewController {
	IBOutlet NSTextView *vertexShaderTextView;
	IBOutlet NSTextView *fragmentShaderTextView;
}

- (IBAction)editVertexShader:(id)sender;
- (IBAction)editFragmentShader:(id)sender;


@end
