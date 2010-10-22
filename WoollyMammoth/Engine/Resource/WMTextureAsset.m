//
//  WMTextureAsset.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/15/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMTextureAsset.h"

#import "Texture2D.h"


@implementation WMTextureAsset

- (BOOL)loadWithBundle:(NSBundle *)inBundle error:(NSError **)outError;
{
	if (isLoaded) return NO;
	
	//File comes with extension
	NSString *imagePath = [[inBundle bundlePath] stringByAppendingPathComponent:resourceName];
	
	NSString *extension = [imagePath pathExtension];
	if ([extension isEqualToString:@"png"]) {
		UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
		texture = [[Texture2D alloc] initWithImage:image];
		return YES;
	}

	return NO;
}

- (GLuint)glTexture;
{
	return texture.name;
}


- (void) dealloc
{	
	[texture release];
	[super dealloc];
}

@end
