//
//  WMEditorAssetManager.m
//  WoollyEditor
//
//  Created by Andrew Pouliot on 11/22/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMEditorAssetManager.h"
#import "WMEditorAsset.h"

#import "WMAssetManifest.h"

NSString *const WMEditorAssetManagerAssetsChangedNotification = @"WMEditorAssetManagerAssetsChanged";

@interface WMEditorAssetManager ()
- (void)loadAssetsFromDictionary:(NSDictionary *)inAssetDictionary asAssetsOfType:(NSString *)inAssetType;
@end


@implementation WMEditorAssetManager

@synthesize assetBasePath;
@synthesize assets;

- (id) init {
	[super init];
	if (self == nil) return self; 
		
	self.assets = [NSArray array];
	
	return self;
}


- (void)dealloc
{
	[assets release];
	assets = nil;

	[assetBasePath release];
	assetBasePath = nil;

	[super dealloc];
}


- (BOOL)loadManifestFromData:(NSData *)inData error:(NSError **)outError;
{
	NSDictionary *manifest = [NSPropertyListSerialization propertyListWithData:inData options:0 format:NULL error:outError];
	if (!manifest) return NO;
	
	[self loadAssetsFromDictionary:[manifest objectForKey:WMAssetManagerManifestModelsKey] asAssetsOfType:WMEditorAssetTypeModel];
	[self loadAssetsFromDictionary:[manifest objectForKey:WMAssetManagerManifestShadersKey] asAssetsOfType:WMEditorAssetTypeShader];
	[self loadAssetsFromDictionary:[manifest objectForKey:WMAssetManagerManifestTexturesKey] asAssetsOfType:WMEditorAssetTypeTexture];
	[self loadAssetsFromDictionary:[manifest objectForKey:WMAssetManagerManifestScriptsKey] asAssetsOfType:WMEditorAssetTypeScript];
	[self loadAssetsFromDictionary:[manifest objectForKey:WMAssetManagerManifestScenesKey] asAssetsOfType:WMEditorAssetTypeScene];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:WMEditorAssetManagerAssetsChangedNotification object:self];
	
	return YES;
}

- (void)loadAssetsFromDictionary:(NSDictionary *)inAssetDictionary asAssetsOfType:(NSString *)inAssetType;
{
	NSMutableArray *mutableAssets = [NSMutableArray array];
	for (NSString *resourceName in inAssetDictionary) {
		NSDictionary *assetDictionary = [inAssetDictionary objectForKey:resourceName];
		WMEditorAsset *asset = [[[WMEditorAsset alloc] init] autorelease];
		asset.assetType = inAssetType;
		asset.properties = assetDictionary;
		asset.resourceName = resourceName;
		[mutableAssets addObject:asset];
	}
	self.assets = [assets arrayByAddingObjectsFromArray:mutableAssets];
}

- (NSDictionary *)manifestDictionaryForType:(NSString *)inType;
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	for (WMEditorAsset *asset in assets) {
		if ([asset.assetType isEqualToString:inType]) {
			if (asset.properties) {
				[dictionary setObject:asset.properties forKey:asset.resourceName];
			} else {
				[dictionary setObject:[NSDictionary dictionary] forKey:asset.resourceName];
			}

		}
	}
	return dictionary;
}

- (NSData *)manifestDataWithDocumentTitle:(NSString *)inTitle;
{
	NSMutableDictionary *manifestDictionary = [NSMutableDictionary dictionary];
	[manifestDictionary setObject:[NSNumber numberWithInt:WMAssetManagerManifestVersion] forKey:WMAssetManagerManifestVersionKey];
	[manifestDictionary setObject:inTitle forKey:@"title"];
	
	[manifestDictionary setObject:[self manifestDictionaryForType:WMEditorAssetTypeModel] forKey:WMAssetManagerManifestModelsKey];
	[manifestDictionary setObject:[self manifestDictionaryForType:WMEditorAssetTypeShader] forKey:WMAssetManagerManifestShadersKey];
	[manifestDictionary setObject:[self manifestDictionaryForType:WMEditorAssetTypeTexture] forKey:WMAssetManagerManifestTexturesKey ];
	[manifestDictionary setObject:[self manifestDictionaryForType:WMEditorAssetTypeScript] forKey:WMAssetManagerManifestScriptsKey];
	[manifestDictionary setObject:[self manifestDictionaryForType:WMEditorAssetTypeScene] forKey:WMAssetManagerManifestScenesKey];
	
	NSError *error = nil;
	NSData *data =  [NSPropertyListSerialization dataWithPropertyList:manifestDictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
	return data;
}

@end
