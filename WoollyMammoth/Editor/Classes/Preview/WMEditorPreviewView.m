//
//  WMEditorPreviewView.m
//  WoollyEditor
//
//  Created by Andrew Pouliot on 10/23/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMEditorPreviewView.h"

#import <OpenGL/glu.h>

@implementation WMEditorPreviewView

- (id)initWithCoder:(NSCoder *)aDecoder;
{
	self = [super initWithCoder:aDecoder];
	if (!self) return nil;
	
	updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(heartbeat) userInfo:nil repeats:YES];
	
	return self;
}

- (void) prepareOpenGL
{
	GLint swapInt = 1;
	[[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval]; // set to vbl sync
}

- (void) dealloc
{
	[updateTimer invalidate];
	[super dealloc];
}


- (void)heartbeat;
{
	[self setNeedsDisplay:YES];
}

- (void)drawRect: (NSRect) theRect
{
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluOrtho2D(0., 2., 0., 1.);
	
	glClearColor(0.0, 0.0, 0.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT);
	
	
	glFlush();
}

@end
