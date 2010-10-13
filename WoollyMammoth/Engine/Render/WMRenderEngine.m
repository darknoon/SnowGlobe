//
//  WMRenderEngine.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/12/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMRenderEngine.h"

#import "WMShader.h"

@interface WMRenderEngine ()
@end


@implementation WMRenderEngine

@synthesize context;

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

- (id)init;
{
	self = [super init];
	if (!self) return nil;
	
	context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context) {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    }
    if (!context) {
        NSLog(@"Failed to create ES context");
	}	else if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"Failed to set ES context current");
	}
	
	tempShader = [[WMShader alloc] init];
	if (context.API == kEAGLRenderingAPIOpenGLES2) {
		tempShader.attributeNames = [NSArray arrayWithObjects:@"position", @"color", nil];
		tempShader.uniformNames = [NSArray arrayWithObjects:@"translate", nil];
		tempShader.vertexShader = [self stringFromResource:@"Shader" ofType:@"vsh"];
		tempShader.pixelShader  = [self stringFromResource:@"Shader" ofType:@"fsh"];
		[tempShader loadShaders];
	}
	
	return self;
}

- (void) dealloc
{
	// Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	[context release];
	context = nil;

	[super dealloc];
}




- (void)drawFrame;
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
    
    static float transY = 0.0f;
    
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    if (context.API == kEAGLRenderingAPIOpenGLES2)
    {
        // Use shader program.
        glUseProgram(tempShader.program);
        
        // Update uniform value.
        glUniform1f([tempShader uniformLocationForName:@"translate"], (GLfloat)transY);
        transY += 0.075f;	
        
        // Update attribute values.
		GLuint vertexAttribute = [tempShader attribIndexForName:@"position"];
        glVertexAttribPointer(vertexAttribute, 2, GL_FLOAT, 0, 0, squareVertices);
        glEnableVertexAttribArray(vertexAttribute);

		GLuint colorAttribute = [tempShader attribIndexForName:@"color"];
        glVertexAttribPointer(colorAttribute, 4, GL_UNSIGNED_BYTE, 1, 0, squareColors);
        glEnableVertexAttribArray(colorAttribute);
        
        // Validate program before drawing. This is a good check, but only really necessary in a debug build.
        // DEBUG macro must be defined in your debug configurations if that's not already the case.
#if defined(DEBUG)
        if (![tempShader validateProgram])
        {
            NSLog(@"Failed to validate program in shader: %@", tempShader);
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
        glTranslatef(0.0f, (GLfloat)(sinf(transY)/2.0f), 0.0f);
        transY += 0.075f;
        
        glVertexPointer(2, GL_FLOAT, 0, squareVertices);
        glEnableClientState(GL_VERTEX_ARRAY);
        glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
        glEnableClientState(GL_COLOR_ARRAY);
    }
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
}

@end
