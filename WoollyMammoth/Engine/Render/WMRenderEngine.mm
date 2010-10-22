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

#define DEBUG_LOG_RENDER_MATRICES 0

void LogMatrix(MATRIX mat) {
	for (int i=0; i<4; i++) {
		NSLog(@"|%f \t%f \t%f \t%f|", mat[i][0], mat[i][1], mat[i][2], mat[i][3]);
	}
}

@interface WMRenderEngine ()
- (void)setCameraMatrixWithRect:(CGRect)inBounds;
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
		NSLog(@"Falling back to ES 1 context because we could not create ES 2 context.");
    }
    if (!context) {
        NSLog(@"Failed to create ES context");
	}	else if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"Failed to set ES context current");
	}
	
	glEnable(GL_TEXTURE_2D);
	
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


- (void)setCameraMatrixWithRect:(CGRect)inBounds;
{
	glCullFace(GL_BACK);
	
	MATRIX projectionMatrix;
	GLfloat viewAngle = 45.f * M_PI / 180.0f;
	
	const float near = 0.1;
	const float far = 1000.0;
	
	const float aspectRatio = inBounds.size.width / inBounds.size.height;
	
	MatrixPerspectiveFovRH(projectionMatrix, viewAngle, aspectRatio, near, far, NO);
	
	//glDepthRangef(near, far);
	
	MATRIX viewMatrix;
	Vec3 cameraPosition(0, 0, 100);
	Vec3 cameraTarget(0, 0, 0);
	Vec3 upVec(0, 1, 0);
	MatrixLookAtRH(viewMatrix, cameraPosition, cameraTarget, upVec);
	
	MatrixMultiply(cameraMatrix, viewMatrix, projectionMatrix);

#if DEBUG_LOG_RENDER_MATRICES
	
	NSLog(@"Perspective: ");
	LogMatrix(projectionMatrix);
	
	NSLog(@"Look At: ");
	LogMatrix(viewMatrix);

	NSLog(@"Final: ");
	LogMatrix(cameraMatrix);
	
	Vec3 position(0,0,0);
	MatrixVec3Multiply(position, position, cameraMatrix);
	NSLog(@"Position of 0,0,0 in screen space: %f %f %f", position.x, position.y, position.z);
	
	position = Vec3(1,1,0);
	MatrixVec3Multiply(position, position, cameraMatrix);
	NSLog(@"Position of 1,1,0 in screen space: %f %f %f", position.x, position.y, position.z);
#endif
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

- (void)drawFrameInRect:(CGRect)inBounds;
{
	[self setCameraMatrixWithRect:inBounds];

	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);
	
    glClearColor(0.5f, 0.6f, 0.6f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		
	[self drawFrameRecursive:engine.rootObject transform:cameraMatrix];
		
}
@end
