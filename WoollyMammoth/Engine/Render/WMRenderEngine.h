//
//  WMRenderEngine.h
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/12/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


@interface WMRenderEngine : NSObject {
	EAGLContext *context;

	//If rendering with GLES2
	GLuint program;
}

@property (nonatomic, retain) EAGLContext *context;

- (id)init;

- (void)drawFrame;

@end
