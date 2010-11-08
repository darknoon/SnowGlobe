//
//  WMSceneDescription.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/28/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMSceneDescription.h"

#import "WMGameObject.h"
#import "WMAssetManager.h"
#import "WMRenderable.h"
#import "WMEngine.h"

@implementation WMSceneDescription

- (BOOL)loadWithBundle:(NSBundle *)inBundle error:(NSError **)outError;
{
	if (!isLoaded) {
		NSString *filePath = [inBundle pathForResource:resourceName ofType:@"plist"];
		if (filePath) {
			sceneDescription = [NSDictionary dictionaryWithContentsOfFile:filePath];
		}
		
		isLoaded = sceneDescription != nil;

	}
	return isLoaded;
}

- (WMRenderable *)deserializeRenderable:(NSDictionary *)renderableRepresentation withEngine:(WMEngine *)inEngine error:(NSError **)outError;
{
	//TODO: can we simplify this? How can we make the renderable dynamic
	WMRenderable *renderable = [[[WMRenderable alloc] init] autorelease];
	
	NSString *modelName = [renderableRepresentation objectForKey:@"model"];
	if (modelName) {
		renderable.model = [inEngine.assetManager modelWithName:modelName];
		if (!renderable.model) {
			NSLog(@"Couldn't find model %@", modelName);
			return nil;
		}
	}
	
	NSString *shaderName = [renderableRepresentation objectForKey:@"shader"];
	if (shaderName) {
		renderable.shader = [inEngine.assetManager shaderWithName:shaderName];
		if (!renderable.shader) {
			NSLog(@"Couldn't find shader %@", shaderName);
			return nil;
		}
	}
	
	NSString *textureName = [renderableRepresentation objectForKey:@"texture"];
	if (textureName) {
		renderable.texture = [inEngine.assetManager textureWithName:textureName];
		if (!renderable.texture) {
			NSLog(@"Couldn't find texture: %@", textureName);
			return nil;
		}
	}

	return renderable;
}

- (VECTOR3)vectorFromArray:(NSArray *)inArray;
{
	VECTOR3 v;
	if (inArray.count == 3) {
		v.x = [[inArray objectAtIndex:0] floatValue];
		v.y = [[inArray objectAtIndex:1] floatValue];
		v.z = [[inArray objectAtIndex:2] floatValue];
	}
	return v;
}

- (WMGameObject *)deserializeObject:(NSDictionary *)objectRepresentation withEngine:(WMEngine *)inEngine error:(NSError **)outError;
{
	NSNumber *objectId = [objectRepresentation objectForKey:@"objectId"];
	if (![objectId isKindOfClass:[NSNumber class]]) {
		NSLog(@"Object %@ doesn't have an objectId field!", objectRepresentation);
		return nil;
	} 
	
	WMGameObject *gameObject = [[[WMGameObject alloc] initWithObjectId:[objectId unsignedLongLongValue] inEngine:inEngine] autorelease];
	gameObject.notes = [objectRepresentation objectForKey:@"notes"];

	NSDictionary *renderableDefinition = [objectRepresentation objectForKey:@"renderable"];
	if (renderableDefinition) {
		gameObject.renderable = [self deserializeRenderable:renderableDefinition withEngine:inEngine error:outError];
		if (!gameObject.renderable) {
			NSLog(@"Renderable could not be created for object %d", objectId);
			return nil;
		}
	}
	
	gameObject.script = [inEngine.assetManager scriptWithName:[objectRepresentation objectForKey:@"script"]];
	
	//scale
	MATRIX transform;
	if ([objectRepresentation objectForKey:@"scale"]) {
		VECTOR3 sv = [self vectorFromArray:[objectRepresentation objectForKey:@"scale"]];
		MatrixScaling(transform, sv.x, sv.y, sv.z);
	} else {
		MatrixIdentity(transform);
	}
	gameObject.transform = transform;

	
	for (NSDictionary *childDefinition in [objectRepresentation objectForKey:@"children"]) {
		WMGameObject *child = [self deserializeObject:childDefinition withEngine:inEngine error:outError];
		if (!child) return nil; //Fail case: return error
		[gameObject addChild:child];
	}
	return gameObject;
}

- (WMGameObject *)deserializeObjectGraphWithEngine:(WMEngine *)inEngine error:(NSError **)outError;
{
	if (isLoaded) {
		return [self deserializeObject:[sceneDescription objectForKey:@"root"] withEngine:inEngine error:outError];
	} else {
		//TODO: return appropriate error
		NSLog(@"Could not deserialize scene because it is not loaded.");
		return nil;
	}

}


@end