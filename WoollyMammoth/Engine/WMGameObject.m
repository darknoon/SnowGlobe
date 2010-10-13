//
//  WMGameObject.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/12/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMGameObject.h"


@implementation WMGameObject

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
	
	return self;
}

- (void)dealloc
{	
	[notes release];
	[mutableChildren release];	
	
	[super dealloc];
}

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
