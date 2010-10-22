//
//  WMEngine.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/12/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMEngine.h"

#import "WMDebugChannel.h"
#import "WMGameObject.h"
#import "WMScriptingContext.h"
#import "WMRenderable.h"
#import "WMAssetManager.h"

@interface WMEngine ()
@property (nonatomic, retain, readwrite) WMGameObject *rootObject;

@end


@implementation WMEngine

@synthesize assetManager;
@synthesize renderEngine;
@synthesize rootObject;
@synthesize scriptingContext;
@synthesize debugChannel;

- (id) init {
	self = [super init];
	if (self == nil) return self; 
	
	objectsById = [[NSMutableDictionary alloc] initWithCapacity:256];
	
	return self;
}


- (void)dealloc
{
	[assetManager release];
	[rootObject release];
	[objectsById release];
	[scriptingContext release];
	[debugChannel release];
	[renderEngine release];

	[super dealloc];
}

- (void)debugMakeObjectGraph;
{
	WMModelPOD *model = [assetManager modelWithName:@"GeodesicSphere02"];
	WMShader *shader = [assetManager shaderWithName:@"DebugPositionOnly"];
	for (int i=0; i<1; i++) {
		WMGameObject *child = [self createObject];
		child.renderable = [[[WMRenderable alloc] init] autorelease];
		child.renderable.model = model;
		child.renderable.shader = shader;
		
		child.transform = c_mIdentity;
		
		[self.rootObject addChild:child];
	}	
}


- (void)start;
{
	if (!debugChannel) {
		debugChannel = [[WMDebugChannel alloc] initWithEngine:self onPort:8080];
		[debugChannel start];
	}
	if (!scriptingContext) {
		scriptingContext = [[WMScriptingContext alloc] initWithEngine:self];
	}
	if (!assetManager) {
		assetManager = [[WMAssetManager alloc] initWithBundlePath:[[NSBundle mainBundle] pathForResource:@"Test" ofType:@"wm"]];
		[assetManager loadAllAssetsSynchronous];
	}
	
	//Create root object
	self.rootObject = [self createObject];
	rootObject.notes = @"Root";
	
	[self debugMakeObjectGraph];
}

- (void)updateRecursive:(WMGameObject *)inGameObject;
{
	[inGameObject update];
	for (WMGameObject *object in inGameObject.children) {
		[self updateRecursive:object];
	}
}

- (void)update;
{
	[self updateRecursive:rootObject];
}

- (WMGameObject *)createObject;
{
	WMGameObject *object = [[WMGameObject alloc] initWithObjectId:++maxObjectId inEngine:self];
	[objectsById setObject:object forKey:[NSNumber numberWithUnsignedLongLong:object.objectId]];
	return [object autorelease];
}

- (void)deleteObject:(WMGameObject *)inObject;
{
	for (WMGameObject *child in inObject.children) {
		[self deleteObject:child];
	}
	[inObject removeFromParent];
}

- (WMGameObject *)objectWithId:(UInt64)gameObjectId;
{
	return [objectsById objectForKey:[NSNumber numberWithUnsignedLongLong:gameObjectId]];
}

- (NSString *)title;
{
	return [assetManager objectForManifestKey:@"title"];
}

@end