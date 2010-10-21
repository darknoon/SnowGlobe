//
//  WMGameObject.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/12/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMGameObject.h"

//Temporary, move this out to a smarter place
#import "WMRenderable.h"

@implementation WMGameObject

@synthesize transform;
@synthesize renderable;
@synthesize notes;
@synthesize objectId;
@synthesize parent;

- (id)initWithObjectId:(UInt64)inObjectId inEngine:(WMEngine *)inEngine;
{
	self = [self init];
	if (self == nil) return self; 
	
	engine = inEngine;
	
	objectId = inObjectId;
	mutableChildren = [[NSMutableArray alloc] init];
	notes = @"";
	
	MatrixIdentity(transform);
		
	return self;
}

- (void)dealloc
{	
	[notes release];
	[mutableChildren release];	
	
	[renderable release];

	[super dealloc];
}

#pragma mark -
#pragma mark Hierarchy Managment

- (void)removeFromParent;
{
	[parent removeChild:self];
}

- (void)addChild:(WMGameObject *)inChild;
{
	[inChild retain];
	[inChild removeFromParent];
	[mutableChildren addObject:inChild];
	[inChild release];
}

- (void)removeChild:(WMGameObject *)inChild;
{
	[mutableChildren removeObject:inChild];
}

- (NSArray *)children;
{
	return [[mutableChildren copy] autorelease];
}

#pragma mark -
#pragma mark Update

- (void)update;
{
	if (renderable) {
		//Rotate by 1.0 rads each second
		MATRIX rotation;
		MatrixRotationZ(rotation, 1.0f / 60.0f);
		MatrixMultiply(transform, transform, rotation);
		MatrixRotationY(rotation, 0.5f / 60.0f);
		MatrixMultiply(transform, transform, rotation);
	}
	
}

#pragma mark -

- (NSString *)description;
{
	return [[super description] stringByAppendingFormat:@"{\"%@\", %d childen}", notes, mutableChildren.count];
}

- (NSString *)descriptionRecursive;
{
	NSMutableString *descriptionRecursive = [NSMutableString stringWithString:[self description]];
	for (WMGameObject *child in mutableChildren) {
		[descriptionRecursive appendFormat:@"\n\t%@", [child descriptionRecursive]];
	}
	[descriptionRecursive appendString:@"\n"];
	return descriptionRecursive;
}

@end
