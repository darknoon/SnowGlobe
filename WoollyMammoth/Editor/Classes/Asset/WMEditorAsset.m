//
//  WMEditorAsset.m
//  WoollyEditor
//
//  Created by Andrew Pouliot on 11/22/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMEditorAsset.h"

NSString *WMEditorAssetTypeShader = @"shader";
NSString *WMEditorAssetTypeModel = @"model";
NSString *WMEditorAssetTypeScene = @"scene";
NSString *WMEditorAssetTypeTexture = @"texture";
NSString *WMEditorAssetTypeScript = @"script";


@implementation WMEditorAsset

@synthesize assetType;
@synthesize resourceName;
@synthesize properties;

- (NSArray *)absolutePathsForCopyingWithRoot:(NSString *)inResourceRoot;
{
	if ([self.assetType isEqualToString:WMEditorAssetTypeShader]) {
		return [NSArray arrayWithObjects:
				[[inResourceRoot stringByAppendingPathComponent:[self.resourceName stringByAppendingPathExtension:@"fsh"]] stringByStandardizingPath],
				[[inResourceRoot stringByAppendingPathComponent:[self.resourceName stringByAppendingPathExtension:@"vsh"]] stringByStandardizingPath], nil];
	} else {
		NSString *pathExtension = nil;
		if ([self.assetType isEqualToString:WMEditorAssetTypeModel]) {
			pathExtension = @"pod";
		} else if ([self.assetType isEqualToString:WMEditorAssetTypeScene]) {
			pathExtension = @"plist";
		} else if ([self.assetType isEqualToString:WMEditorAssetTypeTexture]) {
			pathExtension = nil;
		} else if ([self.assetType isEqualToString:WMEditorAssetTypeScript]) {
			pathExtension = @"lua";
		}
		
		if (pathExtension) {
			return [NSArray arrayWithObject:[[inResourceRoot stringByAppendingPathComponent:[self.resourceName stringByAppendingPathExtension:pathExtension]] stringByStandardizingPath]];
		} else {
			return [NSArray arrayWithObject:[[inResourceRoot stringByAppendingPathComponent:self.resourceName] stringByStandardizingPath]];
		}

	}
}

- (NSString *)resourceTypeSection;
{
	//TODO: use constants from WollyMammoth proper
	if ([self.assetType isEqualToString:WMEditorAssetTypeShader]) {
		return @"shaders";
	} else if ([self.assetType isEqualToString:WMEditorAssetTypeModel]) {
		return @"models";
	} else if ([self.assetType isEqualToString:WMEditorAssetTypeScene]) {
		return @"scenes";
	} else if ([self.assetType isEqualToString:WMEditorAssetTypeTexture]) {
		return @"textures";
	} else if ([self.assetType isEqualToString:WMEditorAssetTypeScript]) {
		return @"scripts";
	}
	return nil;
}

- (void)dealloc
{
	[resourceName release];
	[properties release];
	[assetType release];
	[super dealloc];
}

@end
