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
#import "stdlib.h"
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

		const float mass = 0.01f;
		//Elasticity of collision with sphere
		const float elasticity = 0.70f;
		const float coefficientOfDrag = 0.05f;

		Vec3 force = Vec3(0.0f, 0.0f, 0.0f);
		force += mass * 0.1 * gravity; // add gravitational force, cheat
		
		float v2 = velocity.dot(velocity);
		float vl = sqrtf(v2);
		if (v2 > 10.f) {
			v2 = 10.f;
		}
		Vec3 drag = -coefficientOfDrag * v2 * (1.0f/vl) * velocity;
		force += drag;
		
		// TODO: do using force for v^2 drag
		// velocity *= 0.99;
		
		
		
		MATRIX ts;
		MatrixIdentity(ts);
		
		
		float turbulenceForce = 0.1f;
		const float noiseScale = 5.f;
		
		//Disturb randomly
		Vec3 noisePosX = noiseScale * position + Vec3(0.000000f, 12.252f, 1230.2685f) + t * Vec3(0.2f, 0.0f, 1.2f);
		Vec3 noisePosY = noiseScale * position + Vec3(7833.632f, 10.002f, 1242.8365f) + t * Vec3(0.0f, 1.0f, 0.2f);
		Vec3 noisePosZ = noiseScale * position + Vec3(2673.262f, 12.252f, 1582.1523f) + t * Vec3(-1.f, 0.0f, 0.0f);
		
		force += turbulenceForce * sys->turbulence * Vec3(simplexNoise3(noisePosX.x, noisePosX.y, noisePosX.z),
														  simplexNoise3(noisePosY.x, noisePosY.y, noisePosY.z),
														  simplexNoise3(noisePosZ.x, noisePosZ.y, noisePosZ.z));
		
		const float particleOppositionForce = 200.0f;
		const int particlesToConsider = 10;
		//Move away from other particles
		for (int j=MAX(0, i - particlesToConsider/2); j<MIN(i+particlesToConsider/2,sys->maxParticles); j++) {
			if (i != j) {
				Vec3 d = (sys->particles[j].position - position);
				float dist2 = d.dot(d);
				const float collisionDistance = 0.03f;
				if (dist2 < collisionDistance * collisionDistance) {
					//Add a force away from the other particle
					force += particleOppositionForce * (dist2 - collisionDistance * collisionDistance) * d;
				}
			}
		}
		
		const float sphereRadius = 0.6;
		//Constrain to be inside sphere
		float distanceFromOrigin2 = position.dot(position);
		if (distanceFromOrigin2 > sphereRadius * sphereRadius) {
			//Normalize vector to constrain to unit sphere
			position.normalize();
			
			//Invert for normal
			Vec3 normal = -position;
			
			//If velocity is heading out of bounds (should always be true)
			if (velocity.dot(normal) < 0.0f) {
				velocity = elasticity * (velocity - 2.0f * velocity.dot(normal) * normal);
			}
			
			//Add in normal force
			if (force.dot(normal) < 0.0f) {
				force += force.dot(normal) * normal;
			}
			
			//Scale back to sphere size
			position *= sphereRadius;
		}
		
		const float mass_inv = 1.0f/mass;
		velocity += force * mass_inv * dt;
		
		float bright = 0.85 + 0.1 * position.z;
		
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
	
	
	const float pinitial = 0.6f;
	int misses = 0;
	do {
		position = Vec3(rng.randF(-pinitial,pinitial), rng.randF(-pinitial,pinitial), rng.randF(-pinitial,pinitial));
		misses++;
	} while (position.dot(position) > 0.4f * 0.4f);
	
	
	color[0] = 255;
	color[1] = 255;
	color[2] = 255;
	color[3] = 255;
	textureCoordinate = Vec2(0.5, 0.5);
}

int particleZCompare(const void *a, const void *b) {
	return (((WMParticle *)a)->position.z >  ((WMParticle *)b)->position.z) ? 1 : - 1;
}

@implementation WMParticleSystem

- (id) init {
	[super init];
	if (self == nil) return self; 
	
	maxParticles = 400;
	particles = new WMParticle[maxParticles];
	for (int i=0; i<maxParticles; i++) {
		particles[i].init();
	}
	
	zSortParticles = YES;
	
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
	if (t > 0.5) {
		turbulence = turbulence * turbulenceDecay + (1.0 - turbulenceDecay) * turbulenceStrength * (fabsf(rotationRate.x) + fabsf(rotationRate.y) + fabsf(rotationRate.z));
		turbulence = fmaxf(0.0, fminf(turbulence, 1.0));
		
#if TARGET_IPHONE_SIMULATOR
		turbulence = 0.5;
#endif

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
	
	//Sort particles
	if (zSortParticles)
		qsort(particles, maxParticles, sizeof(WMParticle), particleZCompare);
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
			if (textureCoordinateAttribute != NSNotFound) {
				glVertexAttribPointer(textureCoordinateAttribute, 2, GL_FLOAT, GL_FALSE, stride, &particles[0].textureCoordinate);
				glEnableVertexAttribArray(textureCoordinateAttribute);
			}
			
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
