//
//  WMEditorAsset.h
//  WoollyEditor
//
//  Created by Andrew Pouliot on 11/22/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *WMEditorAssetTypeShader;
extern NSString *WMEditorAssetTypeModel;
extern NSString *WMEditorAssetTypeScene;
extern NSString *WMEditorAssetTypeTexture;
extern NSString *WMEditorAssetTypeScript;

@interface WMEditorAsset : NSObject {
	NSString *resourceName;
	NSDictionary *properties;
	NSString *assetType;
}

@property (nonatomic, copy) NSString *assetType;
@property (nonatomic, copy) NSString *resourceName;
@property (nonatomic, copy) NSDictionary *properties;

- (NSArray *)absolutePathsForCopyingWithRoot:(NSString *)inResourceRoot;

//Corresponds to one of the sections in the manifest
- (NSString *)resourceTypeSection;

@end
