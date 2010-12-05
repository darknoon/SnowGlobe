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
	
@public
	VECTOR4 startColor;
	float deltaAlpha;
	
	float turbulence;
	
	double t;
	
	//Potentially slower. Try turning off for performance
	BOOL zSortParticles;
	
	//ignores model
}

@end
