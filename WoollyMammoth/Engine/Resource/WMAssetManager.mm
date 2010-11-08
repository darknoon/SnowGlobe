//
//  WMAssetManager.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/15/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMAssetManager.h"

#import "WMEngine.h"

//Asset classes
#import "WMModelPOD.h"
#import "WMShader.h"
#import "WMTextureAsset.h"
#import "WMSceneDescription.h"
#import "WMLuaScript.h"

//Fixed assets
#import "WMQuad.h"

NSString *const WMAssetManagerManifestModelsKey = @"models";
NSString *const WMAssetManagerManifestTexturesKey = @"textures";
NSString *const WMAssetManagerManifestShadersKey = @"shaders";
NSString *const WMAssetManagerManifestScenesKey = @"scenes";
NSString *const WMAssetManagerManifestScriptsKey = @"scripts";

const NSUInteger WMAssetManagerManifestVersion = 1;
const NSUInteger WMAssetManagerManifestMinimumVersionReadable = 1;

@interface WMAssetManager ()
- (void)createAssetsFromManifest:(NSDictionary *)inManifest;
- (void)addFixedAssets;
@end


@implementation WMAssetManager

@synthesize assetBundle;

- (id)initWithBundlePath:(NSString *)inBundlePath engine:(WMEngine *)inEngine;
{
	self = [super init];
	if (!self) return nil;
	
	engine = inEngine;
	
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
	scenes = [[NSMutableDictionary alloc] init];
	
	[self addFixedAssets];
	[self createAssetsFromManifest:manifest];

	return self;
}

- (void) dealloc
{
	[assetBundle release];

	[models release];
	[shaders release];
	[textures release];
	[scripts release];
	[scenes release];
	
	[super dealloc];
}

- (void)addFixedAssets;
{
	[models setObject:[[[WMQuad alloc] init] autorelease] forKey:@"WMQuad"];
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
	
	NSDictionary *textureDefinitions = [inManifest objectForKey:WMAssetManagerManifestTexturesKey];
	for (NSString *textureKey in textureDefinitions) {
		WMAsset *asset = [[WMTextureAsset alloc] initWithResourceName:textureKey properties:[textureDefinitions objectForKey:textureKey]];
		[textures setObject:asset forKey:textureKey];
	}
	
	NSDictionary *sceneDefinitions = [inManifest objectForKey:WMAssetManagerManifestScenesKey];
	for (NSString *sceneKey in sceneDefinitions) {
		WMAsset *asset = [[WMSceneDescription alloc] initWithResourceName:sceneKey properties:[sceneDefinitions objectForKey:sceneKey]];
		[scenes setObject:asset forKey:sceneKey];
	}
	
	NSDictionary *scriptDefinitions = [inManifest objectForKey:WMAssetManagerManifestScriptsKey];
	for (NSString *scriptKey in scriptDefinitions) {
		WMAsset *asset = [[WMLuaScript alloc] initWithResourceName:scriptKey properties:[scriptDefinitions objectForKey:scriptKey]];
		[scripts setObject:asset forKey:scriptKey];
	}
	
	
}

- (void)loadAllAssetsSynchronous;
{
	//Load models
	for (WMModelPOD *model in [models allValues]) {
		if ([model isKindOfClass:[WMAsset class]]) {
			NSError *loadError = nil;
			if (![model loadWithBundle:assetBundle error:&loadError]) {
				NSLog(@"Error loading model : %@", model);
			}
		}
	}
	//Load shaders
	for (WMShader *shader in [shaders allValues]) {
		NSError *loadError = nil;
		if (![shader loadWithBundle:assetBundle error:&loadError]) {
			NSLog(@"Error loading shader : %@", shader);
		}		
	}
	//Load textures
	for (WMShader *texture in [textures allValues]) {
		NSError *loadError = nil;
		if (![texture loadWithBundle:assetBundle error:&loadError]) {
			NSLog(@"Error loading texture : %@", texture);
		}
	}
	//Load scenes
	for (WMSceneDescription *scene in [scenes allValues]) {
		NSError *loadError = nil;
		if (![scene loadWithBundle:assetBundle error:&loadError]) {
			NSLog(@"Error loading scene : %@", scene);
		}
	}
	
	//Load scripts
	for (WMLuaScript *script in [scripts allValues]) {
		NSError *loadError = nil;
		if (![script loadWithBundle:assetBundle inScriptingContext:engine.scriptingContext error:&loadError]) {
			NSLog(@"Error loading script : %@", script);
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

- (id)textureWithName:(NSString *)inName;
{
	return [textures objectForKey:inName];
}

- (id)sceneWithName:(NSString *)inName;
{
	return [scenes objectForKey:inName];
}

- (id)scriptWithName:(NSString *)inName;
{
	return [scripts objectForKey:inName];
}

@end
