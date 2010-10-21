//
//  WMRenderEngine.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/12/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMRenderEngine.h"

#import "WMShader.h"
#import "WMRenderEngine.h"
#import "WMEngine.h"
#import "WMRenderable.h"
#import "WMGameObject.h"

void LogMatrix(MATRIX mat) {
	for (int i=0; i<4; i++) {
		NSLog(@"|%f \t%f \t%f \t%f|", mat[i][0], mat[i][1], mat[i][2], mat[i][3]);
	}
}

@interface WMRenderEngine ()
- (void)setCameraMatrix;
@end


@implementation WMRenderEngine

@synthesize context;


- (id)initWithEngine:(WMEngine *)inEngine;
{
	self = [super init];
	if (!self) return nil;
	
	engine = inEngine;
	
	context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context) {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    }
    if (!context) {
        NSLog(@"Failed to create ES context");
	}	else if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"Failed to set ES context current");
	}
	
	[self setCameraMatrix];
		
	return self;
}

- (void)setCameraMatrix;
{
	const BOOL perspective = YES;
	
	if (perspective) {
		
		glCullFace(GL_BACK);
		
		MATRIX projectionMatrix;
		GLfloat viewAngle = 45.f * M_PI / 180.0f;
		
		const float near = 0.1;
		const float far = 1000.0;
		
		const float aspectRatio = 320.f / 480.f;
		
		MatrixPerspectiveFovRH(projectionMatrix, viewAngle, aspectRatio, near, far, NO);
		
		//glDepthRangef(near, far);
		
		NSLog(@"Perspective: ");
		LogMatrix(projectionMatrix);
		
		MATRIX viewMatrix;
		Vec3 cameraPosition(0, 0, 100);
		Vec3 cameraTarget(0, 0, 0);
		Vec3 upVec(0, 1, 0);
		MatrixLookAtRH(viewMatrix, cameraPosition, cameraTarget, upVec);
		
		NSLog(@"Look At: ");
		LogMatrix(viewMatrix);
		
		MatrixMultiply(cameraMatrix, viewMatrix, projectionMatrix);
		
		NSLog(@"Final: ");
		LogMatrix(cameraMatrix);
		
		Vec3 position(0,0,0);
		MatrixVec3Multiply(position, position, cameraMatrix);
		NSLog(@"Position of 0,0,0 in screen space: %f %f %f", position.x, position.y, position.z);
		
		position = Vec3(1,1,0);
		MatrixVec3Multiply(position, position, cameraMatrix);
		NSLog(@"Position of 1,1,0 in screen space: %f %f %f", position.x, position.y, position.z);
		
	} else {
		MatrixScaling(cameraMatrix, 1.0f, 320.0f / 480.f, 1.0f);
	}
	
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



- (void)drawFrameRecursive:(WMGameObject *)inObject transform:(MATRIX)parentTransform;
{
	MATRIX transform;
	MatrixMultiply(transform, inObject.transform, parentTransform);
	
	WMRenderable *renderable = inObject.renderable;
	[renderable drawWithTransform:transform API:context.API];

	for (WMGameObject *object in inObject.children) {
		[self drawFrameRecursive:object transform:transform];
	}
}

- (void)drawFrame;
{
	
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);
	
    glClearColor(0.5f, 0.6f, 0.6f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		
	[self drawFrameRecursive:engine.rootObject transform:cameraMatrix];
		
}
@end
