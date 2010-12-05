//
//  WMParticleSystem.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 11/27/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMParticleSystem.h"

#import "Vector.h"

#import "WMShader.h"
#import "WMTextureAsset.h"
#import "WMAccelerometer.h"

extern "C" {
#import "SimplexNoise.h"
}
CTrivialRandomGenerator rng;


struct WMParticle {
	float life;
	Vec3 position;
	Vec3 velocity;
	unsigned char color[4];
	Vec2 textureCoordinate;
	void update(double dt, double t, int i, Vec3 gravity, WMParticleSystem *sys);
	void init();
};

void WMParticle::update(double dt, double t, int i, Vec3 gravity, WMParticleSystem *sys) {
	if (life > 0) {
		life -= dt;
		position += dt * velocity;
		velocity *= 0.99;
		velocity += 0.1 * gravity * dt;
		
		
		//Disturb randomly
		Vec3 noisePos = 10.0 * position;
		velocity += 10.0f * sys->turbulence * dt * Vec3(simplexNoise3(noisePos.x, noisePos.y + 12.2512, noisePos.z + 120.2068365),
														simplexNoise3(noisePos.x + 78343.632, noisePos.y, noisePos.z + 1242.8365),
														simplexNoise3(noisePos.x + 267.262, noisePos.y + 12.2512, noisePos.z));
		
		const float sphereRadius = 0.6;
		//Constrain to be inside sphere
		float distanceFromOrigin2 = position.dot(position);
		if (distanceFromOrigin2 > sphereRadius * sphereRadius) {
			position = position.normalize() * sphereRadius;
		}
		
		float bright = 0.9 + 0.1 * position.z;
		
		color[0] = 255 * bright;
		color[1] = 255 * bright;
		color[2] = 255 * bright;
		color[3] = 255;
	} else {
		init();
	}
}

void WMParticle::init() {
	life = 1000.0;
	position = Vec3(0,0,0);
	const float vinitial = 1.0;
	velocity = Vec3(rng.randF(-vinitial,vinitial), rng.randF(-vinitial,vinitial), rng.randF(-vinitial,vinitial));
	color[0] = 255;
	color[1] = 255;
	color[2] = 255;
	color[3] = 255;
	textureCoordinate = Vec2(0.5, 0.5);
}

@implementation WMParticleSystem

- (id) init {
	[super init];
	if (self == nil) return self; 
	
	maxParticles = 300;
	particles = new WMParticle[maxParticles];
	for (int i=0; i<maxParticles; i++) {
		particles[i].init();
	}
	
	return self;
}


- (void)update;
{
	Vec3 gravity = [WMAccelerometer sharedAccelerometer].gravity;
	Vec3 rotationRate = [WMAccelerometer sharedAccelerometer].rotationRate;

	//NSLog(@"g(%f, %f, %f) rot(%f, %f, %f)", gravity.x, gravity.y, gravity.z, rotationRate.x, rotationRate.y, rotationRate.z);
	
	//TODO: pass real dt
	double dt = 1.0/60.0;
	t += dt;
	
	const float turbulenceDecay = 0.99f;
	const float turbulenceStrength = 0.1f;
	MATRIX rotation;
	if (t > 1.0) {
		turbulence = turbulence * turbulenceDecay + (1.0 - turbulenceDecay) * turbulenceStrength * (fabsf(rotationRate.x) + fabsf(rotationRate.y) + fabsf(rotationRate.z));
		turbulence = fmaxf(0.0, fminf(turbulence, 1.0));

		MATRIX rotX;
		MATRIX rotY;
		MATRIX rotZ;
		MatrixRotationX(rotX, dt * rotationRate.x);
		MatrixRotationY(rotY, dt * rotationRate.y);
		MatrixRotationZ(rotZ, dt * rotationRate.z);
		
		MatrixMultiply(rotation, rotX, rotY);
		MatrixMultiply(rotation, rotation, rotZ);
		
	} else {
		MatrixIdentity(rotation);
	}

	for (int i=0; i<maxParticles; i++) {
		particles[i].update(dt, t, i, gravity, self);

		//Rotate with torque! (try to anyway!)
		MatrixVec3Multiply(particles[i].position, particles[i].position, rotation);
	}
}

- (void)drawWithTransform:(MATRIX)transform API:(EAGLRenderingAPI)API;
{

	[self update];
	
	if (hidden) return;

	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glDepthMask(GL_FALSE);
	if (API == kEAGLRenderingAPIOpenGLES2)
    {
        // Use shader program.
        glUseProgram(shader.program);
		
		NSUInteger stride = sizeof(WMParticle);
		
        // Update attribute values.
		GLuint vertexAttribute = [shader attribIndexForName:@"position"];
        glVertexAttribPointer(vertexAttribute, 3, GL_FLOAT, GL_FALSE, stride, &particles[0].position);
        glEnableVertexAttribArray(vertexAttribute);
		
		
		if (texture) {
			glBindTexture(GL_TEXTURE_2D, [texture glTexture]);
			
			int textureUniformLocation = [shader uniformLocationForName:@"texture"];
			if (textureUniformLocation != -1) {
				glUniform1i(textureUniformLocation, 0); //texture = texture 0
			}
			
			GLuint textureCoordinateAttribute = [shader attribIndexForName:@"textureCoordinate"];
			glVertexAttribPointer(textureCoordinateAttribute, 2, GL_FLOAT, GL_FALSE, stride, &particles[0].textureCoordinate);
			glEnableVertexAttribArray(textureCoordinateAttribute);
			
		}
		
		
		GLuint colorAttribute = [shader attribIndexForName:@"color"];
		if (colorAttribute != NSNotFound) {
			glVertexAttribPointer(colorAttribute, 4, GL_UNSIGNED_BYTE, GL_TRUE, stride, &particles[0].color);
			glEnableVertexAttribArray(colorAttribute);
		}
		
		int matrixUniform = [shader uniformLocationForName:@"modelViewProjectionMatrix"];
		if (matrixUniform != -1) glUniformMatrix4fv(matrixUniform, 1, NO, transform.f);
        
        // Validate program before drawing. This is a good check, but only really necessary in a debug build.
        // DEBUG macro must be defined in your debug configurations if that's not already the case.
#if defined(DEBUG)
        if (![shader validateProgram])
        {
            NSLog(@"Failed to validate program in shader: %@", shader);
            return;
        }
#endif
    }
    else
    {        
		//TODO: es1 support
	}
	
	glDrawArrays(GL_POINTS, 0, maxParticles);
	glDisable(GL_BLEND);
	glDepthMask(GL_TRUE);
}

@end
