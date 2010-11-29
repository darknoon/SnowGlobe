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


struct WMParticle {
	float life;
	Vec3 position;
	Vec3 velocity;
	unsigned char color[4];
	Vec2 textureCoordinate;
	void update(double dt);
	void init();
};

void WMParticle::update(double dt) {
	if (life > 0) {
		life -= dt;
		position += dt * velocity;
		color[4] = 255 * (life / 3.0);
	} else {
		position = Vec3();
		life = 3.0;
	}

}

void WMParticle::init() {
	life = 0.0;
	position = Vec3(MAXFLOAT,0,0);
	velocity = Vec3(1,1,1);
	color[0] = 255;
	color[1] = 100;
	color[2] = 0;
	color[3] = 255;
	textureCoordinate = Vec2(0.5, 0.5);
}

@implementation WMParticleSystem

- (id) init {
	[super init];
	if (self == nil) return self; 
	
	maxParticles = 100;
	particles = new WMParticle[maxParticles];
	for (int i=0; i<maxParticles; i++) {
		particles[i].init();
		particles[i].life = 3.0 * rng.randF();
		float a = i * 0.1;
		float m = rng.randF();
		particles[i].velocity = Vec3(m * sinf(a), m * cosf(a), 0.0f);
	}
	
	return self;
}


- (void)update;
{
	//TODO: pass real dt
	double dt = 1.0/60.0;
	for (int i=0; i<maxParticles; i++) {
		particles[i].update(dt);
	}
}

- (void)drawWithTransform:(MATRIX)transform API:(EAGLRenderingAPI)API;
{
	[self update];
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
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

}

@end
