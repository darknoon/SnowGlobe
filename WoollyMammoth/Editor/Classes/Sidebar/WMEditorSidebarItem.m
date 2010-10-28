//
//  WMEditorSidebarItem.m
//  WoollyEditor
//
//  Created by Andrew Pouliot on 10/28/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMEditorSidebarItem.h"


@implementation WMEditorSidebarItem

@synthesize children;
@synthesize name;

- (id) init {
	[super init];
	if (self == nil) return self; 
	
	children = [[NSMutableArray alloc] init];
	
	return self;
}


- (void)dealloc
{
	[name release];
	name = nil;

	[children release];
	children = nil;

	[super dealloc];
}

- (void)insertChildWithName:(NSString *)inName;
{
	WMEditorSidebarItem *child = [[[WMEditorSidebarItem alloc] init] autorelease];
	
	[self willChangeValueForKey:@"children"];
	child.name = inName;
	[children addObject:child];
	
	[self didChangeValueForKey:@"children"];
}

@end
