//
//  WMAssetManager.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/15/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMAssetManager.h"

//Asset classes
#import "WMModelPOD.h"
#import "WMShader.h"

NSString *const WMAssetManagerManifestModelsKey = @"models";
NSString *const WMAssetManagerManifestTexturesKey = @"textures";
NSString *const WMAssetManagerManifestShadersKey = @"shaders";
NSString *const WMAssetManagerManifestScriptsKey = @"scripts";

const NSUInteger WMAssetManagerManifestVersion = 1;
const NSUInteger WMAssetManagerManifestMinimumVersionReadable = 1;

@interface WMAssetManager ()
- (void)createAssetsFromManifest:(NSDictionary *)inManifest;
@end


@implementation WMAssetManager

@synthesize assetBundle;

- (id)initWithBundlePath:(NSString *)inBundlePath;
{
	self = [super init];
	if (!self) return nil;
	
	assetBundle = [[NSBundle alloc] initWithPath:inBundlePath];

	NSString *manifestPath = [assetBundle pathForResource:@"manifest" ofType:@"plist"];
	manifest = [[NSDictionary dictionaryWithContentsOfFile:manifestPath] retain];
	if (!manifest) {
		NSLog(@"No manifest.plist found for bundle %@, or manifest could not be read", inBundlePath);
		[self release];
		return nil;
	}
	
	models = [[NSMutableDictionary alloc] init];
	shaders = [[NSMutableDictionary alloc] init];
	textures = [[NSMutableDictionary alloc] init];
	scripts = [[NSMutableDictionary alloc] init];
	[self createAssetsFromManifest:manifest];
	
	return self;
}

- (void) dealloc
{
	[models release];
	[shaders release];
	[textures release];
	[scripts release];
	
	[assetBundle release];
	assetBundle = nil;

	[super dealloc];
}


- (void)createAssetsFromManifest:(NSDictionary *)inManifest;
{
	NSDictionary *modelDefinitions = [inManifest objectForKey:WMAssetManagerManifestModelsKey];
	for (NSString *modelKey in modelDefinitions) {
		WMAsset *asset = [[WMModelPOD alloc] initWithResourceName:modelKey properties:[modelDefinitions objectForKey:modelKey]];
		[models setObject:asset forKey:modelKey];
	}
	
	NSDictionary *shaderDefinitions = [inManifest objectForKey:WMAssetManagerManifestShadersKey];
	for (NSString *shaderKey in shaderDefinitions) {
		WMAsset *asset = [[WMShader alloc] initWithResourceName:shaderKey properties:[shaderDefinitions objectForKey:shaderKey]];
		[shaders setObject:asset forKey:shaderKey];
	}
	
}

- (void)loadAllAssetsSynchronous;
{
	//Load models
	for (WMModelPOD *model in [models allValues]) {
		NSError *loadError = nil;
		if (![model loadWithBundle:assetBundle error:&loadError]) {
			NSLog(@"Error loading model : %@", model);
		}		
	}
	//Load shaders
	for (WMShader *shader in [shaders allValues]) {
		NSError *loadError = nil;
		if (![shader loadWithBundle:assetBundle error:&loadError]) {
			NSLog(@"Error loading shader : %@", shader);
		}		
	}
}

- (id)objectForManifestKey:(NSString *)inManifestKey;
{
	return [manifest objectForKey:inManifestKey];
}

- (id)modelWithName:(NSString *)inName;
{
	return [models objectForKey:inName];
}

- (id)shaderWithName:(NSString *)inName;
{
	return [shaders objectForKey:inName];
}


@end
