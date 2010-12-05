//
//  WMEditorShaderViewController.m
//  WoollyEditor
//
//  Created by Andrew Pouliot on 11/30/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMEditorShaderViewController.h"

#import "WMEditorDocument.h"
#import "WMEditorAssetManager.h"

@interface WMEditorShaderViewController ()
- (NSString *)vertexShaderPath;
- (NSString *)fragmentShaderPath;
@end


@implementation WMEditorShaderViewController

- (void)setItem:(WMEditorAsset *)inItem;
{
	[super setItem:inItem];
	
	//Set the text fields
	NSError *error = nil;
	NSString *vertexText = [NSString stringWithContentsOfFile:[self vertexShaderPath] encoding:NSUTF8StringEncoding error:&error];
	if (!vertexText) {
		[[NSAlert alertWithError:error] runModal];
	}
	[vertexShaderTextView setString:vertexText];
	error = nil;
	
	NSString *fragmentText = [NSString stringWithContentsOfFile:[self fragmentShaderPath] encoding:NSUTF8StringEncoding error:&error];
	if (!fragmentText) {
		[[NSAlert alertWithError:error] runModal];
	}
	error = nil;
}

- (NSString *)vertexShaderPath;
{
	WMEditorAssetManager *assetManager = document.assetManager;
	return [assetManager.assetBasePath stringByAppendingPathComponent:[item.resourceName stringByAppendingPathExtension:@"fsh"]];
}

- (NSString *)fragmentShaderPath;
{
	WMEditorAssetManager *assetManager = document.assetManager;
	return [assetManager.assetBasePath stringByAppendingPathComponent:[item.resourceName stringByAppendingPathExtension:@"vsh"]];
}

- (IBAction)editVertexShader:(id)sender;
{
	NSURL *vertexShaderURL = [NSURL fileURLWithPath:[self vertexShaderPath]];
	LSOpenCFURLRef((CFURLRef)vertexShaderURL, NULL);
}

- (IBAction)editFragmentShader:(id)sender;
{
	NSURL *vertexShaderURL = [NSURL fileURLWithPath:[self vertexShaderPath]];
	LSOpenCFURLRef((CFURLRef)vertexShaderURL, NULL);
}


@end
