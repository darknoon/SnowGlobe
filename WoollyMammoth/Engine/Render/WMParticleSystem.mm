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
#import "WMEngine.h"
#import "WMAssetManager.h"

extern "C" {
#import "SimplexNoise.h"
}
CTrivialRandomGenerator rng;

#define USE_INDEX_BUFFER 1

struct WMParticle {
	float life;
	Vec3 position;
	Vec3 velocity;
	Vec3 noiseVec;
	unsigned char color[4];
	void update(double dt, double t, int i, Vec3 gravity, WMParticleSystem *sys);
	void init();
	void updateNoise(double t);
};

struct WMParticleVertex {
	Vec3 position;
	unsigned char color[4];
	unsigned char texCoord0[2];
};

void WMParticle::updateNoise(double t) {
	const float noiseScale = 5.f;
	//Disturb randomly
	Vec3 noisePosX = noiseScale * position + Vec3(0.000000f, 12.252f, 1230.2685f) + t * Vec3(0.2f, 0.0f, 1.2f);
	Vec3 noisePosY = noiseScale * position + Vec3(7833.632f, 10.002f, 1242.8365f) + t * Vec3(0.0f, 1.0f, 0.2f);
	Vec3 noisePosZ = noiseScale * position + Vec3(2673.262f, 12.252f, 1582.1523f) + t * Vec3(-1.f, 0.0f, 0.0f);
	
	noiseVec = Vec3(simplexNoise3(noisePosX.x, noisePosX.y, noisePosX.z),
					simplexNoise3(noisePosY.x, noisePosY.y, noisePosY.z),
					simplexNoise3(noisePosZ.x, noisePosZ.y, noisePosZ.z));
	
}

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
		
	//	Vec3 randomVec = Vec3(rng.randF(-1.0f, 1.0f), rng.randF(-1.0f, 1.0f), rng.randF(-1.0f, 1.0f));
		force += turbulenceForce * sys->turbulence * noiseVec;
		
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
		
		const float sphereRadius = 0.58f;
;
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
	
	noiseVec = Vec3(0.0f);
	
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
}

int particleZCompare(const void *a, const void *b) {
	return (((WMParticle *)a)->position.z >  ((WMParticle *)b)->position.z) ? 1 : - 1;
}

@implementation WMParticleSystem

- (id)initWithEngine:(WMEngine *)inEngine properties:(NSDictionary *)renderableRepresentation;
{
	[super initWithEngine:inEngine properties:renderableRepresentation];
	if (self == nil) return self; 
	
	maxParticles = 1000;
	particles = new WMParticle[maxParticles];
#if USE_INDEX_BUFFER
	particleVertices = new WMParticleVertex[maxParticles * 4];
#else
	particleVertices = new WMParticleVertex[maxParticles * 6];
#endif
	for (int i=0; i<maxParticles; i++) {
		particles[i].init();
	}
	
	particleUpdateSkip = 6;
	particleUpdateIndex = 0;
	
	zSortParticles = YES;
	
	glGenBuffers(2, particleVBOs);
	glGenBuffers(1, &particleEBO);
	
	//Create our index buffer. 2 triangles = 6 indices per particle
	size_t indexBufferLength = maxParticles * 6;
	//TODO: maybe use map buffer here (better memory allocation?)
	unsigned short *indexBuffer = new unsigned short[indexBufferLength];
	
	//Fill up the index buffer lols no sharts only shorts here
	for (int i=0; i<maxParticles; i++) {
		//TODO: is this the correct winding???
		indexBuffer[6 * i + 0] = 4 * i + 0;
		indexBuffer[6 * i + 1] = 4 * i + 1;
		indexBuffer[6 * i + 2] = 4 * i + 2;
		indexBuffer[6 * i + 3] = 4 * i + 1;
		indexBuffer[6 * i + 4] = 4 * i + 2;
		indexBuffer[6 * i + 5] = 4 * i + 3;
	}
	
	GL_CHECK_ERROR;
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, particleEBO);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexBufferLength * sizeof(unsigned short), indexBuffer, GL_STATIC_DRAW);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	GL_CHECK_ERROR;

	delete indexBuffer;
	
	return self;
}

- (void) dealloc
{
	glDeleteBuffers(2, particleVBOs);
	delete particles;
	delete particleVertices;

	[super dealloc];
}


- (void)update;
{
	Vec3 gravity = [WMAccelerometer sharedAccelerometer].gravity;
	Vec3 rotationRate = [WMAccelerometer sharedAccelerometer].rotationRate;

	//NSLog(@"g(%f, %f, %f) rot(%f, %f, %f)", gravity.x, gravity.y, gravity.z, rotationRate.x, rotationRate.y, rotationRate.z);
	
	//TODO: pass real dt
#if 0
	double t_prev = t;
	t = CFAbsoluteTimeGetCurrent();
	double dt = t - t_prev;
	dt = fmax(1.0/30.0, fmin(dt, 1.0/60.0));
#else
	double dt = 1.0/60.0;
	t += dt;
#endif

	
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

	for (int i=particleUpdateIndex; i<maxParticles; i+=particleUpdateSkip) {
		particles[i].updateNoise(t);
	}
	//Update particles
	for (int i=0; i<maxParticles; i++) {
		particles[i].update(dt, t, i, gravity, self);

		//Rotate with torque! (try to anyway!)
		MatrixVec3Multiply(particles[i].position, particles[i].position, rotation);
	}
	
	
	//Sort particles
	if (zSortParticles)
		qsort(particles, maxParticles, sizeof(WMParticle), particleZCompare);
	
	//Swap buffers and write particles to VBO
	currentParticleVBOIndex = !currentParticleVBOIndex;
	glBindBuffer(GL_ARRAY_BUFFER, particleVBOs[currentParticleVBOIndex]);
	
	Vec3 spherePosition = Vec3(0.0f, 0.145f, 0.0f);
	float sz = 0.01f;
	
#if	USE_INDEX_BUFFER
	const Vec3 offsets[4] = {
		Vec3(-sz, -sz, 0),
		Vec3( sz, -sz, 0),
		Vec3(-sz,  sz, 0),
		Vec3( sz,  sz, 0),
	};
	const unsigned char textureCoords[4][2] = {
		{0,0},
		{1,0},
		{0,1},
		{1,1},
	};
	
	for (int i=0; i<maxParticles; i++) {
		for (int v=0; v<4; v++) {
			//Calculate the particle position
			particleVertices[4 * i + v].position = particles[i].position + spherePosition + offsets[v];
			
			//copy color as int
			*((int *)particleVertices[4 * i + v].color) = *((int *)particles[i].color);
			
			//copy tex coord as short
			particleVertices[4 * i + v].texCoord0[0] = textureCoords[v][0];
			particleVertices[4 * i + v].texCoord0[1] = textureCoords[v][1];
		}
	}
	glBufferData(GL_ARRAY_BUFFER, maxParticles * 4 * sizeof(WMParticleVertex), particleVertices, GL_STREAM_DRAW);
	GL_CHECK_ERROR;
#else
	const Vec3 offsets[6] = {
		Vec3(-sz, -sz, 0),
		Vec3( sz, -sz, 0),
		Vec3(-sz,  sz, 0),
		Vec3( sz, -sz, 0),
		Vec3(-sz,  sz, 0),
		Vec3( sz,  sz, 0),
	};
	const unsigned char textureCoords[6][2] = {
		{0,0},
		{1,0},
		{0,1},
		{1,0},
		{0,1},
		{1,1},
	};
	
	for (int i=0; i<maxParticles; i++) {
		for (int v=0; v<6; v++) {
			//Calculate the particle position
			particleVertices[6 * i + v].position = particles[i].position + spherePosition + offsets[v];
			
			//copy color as int
			*((int *)particleVertices[4 * i + v].color) = *((int *)particles[i].color);
			
			//copy tex coord as short
			particleVertices[6 * i + v].texCoord0[0] = textureCoords[v][0];
			particleVertices[6 * i + v].texCoord0[1] = textureCoords[v][1];
		}
	}
	glBufferData(GL_ARRAY_BUFFER, maxParticles * 6 * sizeof(WMParticleVertex), particleVertices, GL_STREAM_DRAW);
	GL_CHECK_ERROR;
#endif

	glBindBuffer(GL_ARRAY_BUFFER, 0);
	particleDataAvailable++;

}

- (void)drawWithTransform:(MATRIX)transform API:(EAGLRenderingAPI)API glState:(DNGLState *)inGLState;
{	
	if (particleDataAvailable < 2) return;

	GL_CHECK_ERROR;
	if (API == kEAGLRenderingAPIOpenGLES2)
    {
 		unsigned int attributeMask = WMRenderableDataAvailablePosition | WMRenderableDataAvailableColor | WMRenderableDataAvailableTexCoord0;
		unsigned int enableMask = attributeMask & [shader attributeMask];
		[inGLState setVertexAttributeEnableState:enableMask];
		
		[inGLState setDepthState:0];
		[inGLState setBlendState:DNGLStateBlendEnabled];

		// Use shader program.
        glUseProgram(shader.program);
		
		NSUInteger stride = sizeof(WMParticleVertex);
		
		glBindBuffer(GL_ARRAY_BUFFER, particleVBOs[currentParticleVBOIndex]);
#if	USE_INDEX_BUFFER
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, particleEBO);
#endif
		GL_CHECK_ERROR;

        // Update attribute values.
        glVertexAttribPointer(WMShaderAttributePosition, 3, GL_FLOAT, GL_FALSE, stride, (GLvoid *)offsetof(WMParticleVertex, position));
		
		int textureUniformLocation = [shader uniformLocationForName:@"texture"];
		if (texture && textureUniformLocation != -1) {
			glBindTexture(GL_TEXTURE_2D, [texture glTexture]);			
			glUniform1i(textureUniformLocation, 0); //texture = texture 0
		}
		GL_CHECK_ERROR;

		if (enableMask & WMRenderableDataAvailableColor) {
			glVertexAttribPointer(WMShaderAttributeColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, stride, (GLvoid *)offsetof(WMParticleVertex, color[0]));
		}
		GL_CHECK_ERROR;
		
		if (enableMask & WMRenderableDataAvailableTexCoord0) {
			glVertexAttribPointer(WMShaderAttributeTexCoord0, 2, GL_UNSIGNED_BYTE, GL_FALSE, stride, (GLvoid *)offsetof(WMParticleVertex, texCoord0[0]) );
		}
		GL_CHECK_ERROR;
		
		int matrixUniform = [shader uniformLocationForName:@"modelViewProjectionMatrix"];
		if (matrixUniform != -1) {
			glUniformMatrix4fv(matrixUniform, 1, NO, transform.f);
		}
		GL_CHECK_ERROR;
        
        // Validate program before drawing. This is a good check, but only really necessary in a debug build.
        // DEBUG macro must be defined in your debug configurations if that's not already the case.
#if defined(DEBUG)
        if (![shader validateProgram])
        {
            NSLog(@"Failed to validate program in shader: %@", shader);
            return;
        }
		
#endif
		//glDrawArrays(GL_POINTS, 0, maxParticles);
		GL_CHECK_ERROR;
#if	USE_INDEX_BUFFER
		glDrawElements(GL_TRIANGLES, maxParticles * 6, GL_UNSIGNED_SHORT, 0); //use element array buffer ebo
#else
		glDrawArrays(GL_TRIANGLES, 0, maxParticles * 6);
#endif
		GL_CHECK_ERROR;
		
		glBindBuffer(GL_ARRAY_BUFFER, 0);
#if	USE_INDEX_BUFFER
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
#endif
	} else {        
		//TODO: es1 support
	}	
}

@end
