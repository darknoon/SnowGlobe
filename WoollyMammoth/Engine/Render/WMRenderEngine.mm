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

@interface WMRenderEngine ()
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



- (void)drawFrameRecursive:(WMGameObject *)inObject transform:(MATRIX)parentTransform;
{
	MATRIX transform;
	//transform = parentTransform * object.transform
	MatrixMultiply(transform, parentTransform, inObject.transform);
	
	WMRenderable *renderable = inObject.renderable;
	[renderable drawWithTransform:transform API:context.API];

	for (WMGameObject *object in inObject.children) {
		[self drawFrameRecursive:object transform:transform];
	}
}

- (void)drawFrame;
{
    glClearColor(0.5f, 0.6f, 0.6f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
	MATRIX rootTransform;
	MatrixScaling(rootTransform, 1.0f, 320.0f / 480.f, 1.0f);
	
	[self drawFrameRecursive:engine.rootObject transform:rootTransform];
		
}
@end
