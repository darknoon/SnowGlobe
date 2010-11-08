//
//  WMAsset.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/15/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMAsset.h"


@implementation WMAsset

@synthesize isLoaded;

- (id)initWithResourceName:(NSString *)inResourceName properties:(NSDictionary *)inProperties;
{
	self = [super init];
	if (!self) return nil;
	
	resourceName = [inResourceName retain];
	properties = [inProperties retain];
	
	return self;
}


- (void) dealloc
{
	[resourceName release];
	[properties release];
	
	[super dealloc];
}

//TODO: thread safety

- (BOOL)loadWithBundle:(NSBundle *)inBundle error:(NSError **)outError;
{
	NSAssert(0, @"Must overload this");
	return NO;
}

- (NSString *)description;
{
	return [NSString stringWithFormat:@"%@{%@}", [super description], resourceName];
}

@end
