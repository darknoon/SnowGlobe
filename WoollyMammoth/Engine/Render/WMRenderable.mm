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

@implementation WMRenderable

@synthesize shader;
@synthesize model;

- (void)dealloc
{
	[shader release];
	shader = nil;
	[model release];
	model = nil;

	[super dealloc];
}

//TODO: refactor out!
- (NSString *)stringFromResource:(NSString *)inResourceName ofType:(NSString *)inExt;
{
	NSString *filePath = [[NSBundle mainBundle] pathForResource:inResourceName ofType:inExt];
	if (filePath) {
		return [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	} else {
		NSLog(@"Couldn't find resource %@ of type %@ .", inResourceName, inExt);
		return nil;
	}
}

- (id) init {
	[super init];
	if (self == nil) return self; 
	
	shader = [[WMShader alloc] init];
	
	if ([EAGLContext currentContext].API == kEAGLRenderingAPIOpenGLES2) {
		shader.attributeNames = [NSArray arrayWithObjects:@"position", nil];
		shader.uniformNames = [NSArray arrayWithObjects:@"modelViewProjectionMatrix", nil];
		shader.vertexShader = [self stringFromResource:@"Shader" ofType:@"vsh"];
		shader.pixelShader  = [self stringFromResource:@"Shader" ofType:@"fsh"];
		[shader loadShaders];
	}
		
	return self;
}


- (void)drawWithTransform:(MATRIX)transform API:(EAGLRenderingAPI)API;
{
	// Replace the implementation of this method to do your own custom drawing.
	static const GLfloat squareVertices[] = {
		-0.5f, -0.33f,
		0.5f, -0.33f,
		-0.5f,  0.33f,
		0.5f,  0.33f,
	};
	
	static const GLubyte squareColors[] = {
		255, 255,   0, 255,
		0,   255, 255, 255,
		0,     0,   0,   0,
		255,   0, 255, 255,
	};
	
	if (API == kEAGLRenderingAPIOpenGLES2)
    {
        // Use shader program.
        glUseProgram(shader.program);
			
		NSUInteger stride = [model interleavedDataStride];
		
        // Update attribute values.
		GLuint vertexAttribute = [shader attribIndexForName:@"position"];
        glVertexAttribPointer(vertexAttribute, 3, GL_FLOAT, 0, stride, [model vertexDataPointer]);
        glEnableVertexAttribArray(vertexAttribute);
		
		// GLuint colorAttribute = [shader attribIndexForName:@"color"];
        // glVertexAttribPointer(colorAttribute, 4, GL_UNSIGNED_BYTE, 1, 0, squareColors);
        // glEnableVertexAttribArray(colorAttribute);
		
		int matrixUniform = [shader uniformLocationForName:@"modelViewProjectionMatrix"];
		glUniformMatrix4fv(matrixUniform, 1, NO, transform.f);
        
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
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        //glTranslatef(0.0f, (GLfloat)(sinf(transY)/2.0f), 0.0f);
        //transY += 0.075f;
        
        glVertexPointer(2, GL_FLOAT, 0, squareVertices);
        glEnableClientState(GL_VERTEX_ARRAY);
        glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
        glEnableClientState(GL_COLOR_ARRAY);
    }
    
	//Just a test...
	//glPointSize(4.f);
	//glDrawArrays(GL_POINTS, 0, [model numberOfVertices]);
	
	glDrawElements(GL_TRIANGLES, [model numberOfTriangles] * 3, [model triangleIndexType], [model triangleIndexPointer]);
	

}
@end
