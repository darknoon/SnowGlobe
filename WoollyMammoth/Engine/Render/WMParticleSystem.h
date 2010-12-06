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

struct WMParticleVertex;

@interface WMParticleSystem : WMRenderable {
@public
	NSUInteger maxParticles;
	WMParticle *particles;
	WMParticleVertex *particleVertices;
	
	NSUInteger currentParticleVBOIndex;
	GLuint particleVBOs[2];
	
	VECTOR4 startColor;
	float deltaAlpha;
	
	float turbulence;
	
	double t;
	
	//Potentially slower. Try turning off for performance
	BOOL zSortParticles;
	
	//ignores model
}

@end
