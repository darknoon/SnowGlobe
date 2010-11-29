//
//  WMParticleSystem.h
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 11/27/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WMRenderable.h"
#import "Random.h"

struct WMParticle;

@interface WMParticleSystem : WMRenderable {
	NSUInteger maxParticles;
	NSUInteger liveParticles;
	WMParticle *particles;
	
	VECTOR4 startColor;
	float deltaAlpha;
	
	CTrivialRandomGenerator rng;
	
	//ignores model
}

@end
