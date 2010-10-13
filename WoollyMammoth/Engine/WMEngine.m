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

@implementation WMEngine

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
	[rootObject release];
	[objectsById release];

	[super dealloc];
}

- (void)debugMakeObjectGraph;
{
	WMGameObject *child = [self createObject];
	[self.rootObject addChild:child];
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
	
	//Create root object
	self.rootObject = [self createObject];
	rootObject.notes = @"Root";
	
	[self debugMakeObjectGraph];
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

@end
