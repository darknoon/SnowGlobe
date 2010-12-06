//
//  WMRenderable.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/13/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMRenderable.h"

#import "WMShader.h"

#import "WMModelPOD.h"
#import "WMTextureAsset.h"

#import "WMEngine.h"
#import "WMAssetManager.h"

@implementation WMRenderable

@synthesize hidden;
@synthesize texture;
@synthesize shader;
@synthesize model;

- (void)dealloc
{
	[shader release];
	shader = nil;
	[model release];
	model = nil;

	[texture release];
	texture = nil;


	[super dealloc];
}

- (id) init {
	[super init];
	if (self == nil) return self; 
			
	return self;
}

- (id)initWithEngine:(WMEngine *)inEngine properties:(NSDictionary *)renderableRepresentation;
{
	self = [self init];
	if (!self) return nil;
	
	NSString *modelName = [renderableRepresentation objectForKey:@"model"];
	if (modelName) {
		self.model = [inEngine.assetManager modelWithName:modelName];
		if (!self.model) {
			NSLog(@"Couldn't find model %@", modelName);
			return nil;
		}
	}
	
	NSString *shaderName = [renderableRepresentation objectForKey:@"shader"];
	if (shaderName) {
		self.shader = [inEngine.assetManager shaderWithName:shaderName];
		if (!self.shader) {
			NSLog(@"Couldn't find shader %@", shaderName);
			return nil;
		}
	}
	
	NSString *textureName = [renderableRepresentation objectForKey:@"texture"];
	if (textureName) {
		self.texture = [inEngine.assetManager textureWithName:textureName];
		if (!self.texture) {
			NSLog(@"Couldn't find texture: %@", textureName);
			return nil;
		}
	}
	
	//Default = NO
	self.hidden = [[renderableRepresentation objectForKey:@"hidden"] boolValue];
	
	
	return self;
}

- (void)update;
{
	//Override this
}

- (void)drawWithTransform:(MATRIX)transform API:(EAGLRenderingAPI)API;
{
	if (!model || hidden) return;
	
	if (API == kEAGLRenderingAPIOpenGLES2)
    {
        // Use shader program.
        glUseProgram(shader.program);

		NSUInteger stride = [model interleavedDataStride];
		
        // Update attribute values.
		GLuint vertexAttribute = [shader attribIndexForName:@"position"];
        glVertexAttribPointer(vertexAttribute, 3, GL_FLOAT, GL_FALSE, stride, [model vertexDataPointer]);
        glEnableVertexAttribArray(vertexAttribute);

		
		if (texture) {
			glBindTexture(GL_TEXTURE_2D, [texture glTexture]);
			
			int textureUniformLocation = [shader uniformLocationForName:@"texture"];
			if (textureUniformLocation != -1) {
				glUniform1i(textureUniformLocation, 0); //texture = texture 0
			}

			GLuint textureCoordinateAttribute = [shader attribIndexForName:@"textureCoordinate"];
			glVertexAttribPointer(textureCoordinateAttribute, 2, GL_FLOAT, GL_FALSE, stride, [model textureCoordDataPointer]);
			glEnableVertexAttribArray(textureCoordinateAttribute);

		}

		
		// GLuint colorAttribute = [shader attribIndexForName:@"color"];
        // glVertexAttribPointer(colorAttribute, 4, GL_UNSIGNED_BYTE, 1, 0, squareColors);
        // glEnableVertexAttribArray(colorAttribute);
		
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

    	//Just a test...
		glPointSize(4.f);
		glDrawArrays(GL_POINTS, 0, [model numberOfVertices]);
	}
    	
	glDrawElements(GL_TRIANGLES, [model numberOfTriangles] * 3, [model triangleIndexType], [model triangleIndexPointer]);

}
@end
