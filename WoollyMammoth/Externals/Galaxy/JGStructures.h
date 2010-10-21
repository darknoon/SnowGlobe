/*
 Copyright (c) 2010, JAM Studios
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the name of the JAM Studios nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
 IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


/// @file JGStructures.h This file defines the main structures used in Galaxy.


#ifdef __APPLE__
#include "TargetConditionals.h"
#endif


#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define IPHONE true
#define MAC false
#else

#import <Cocoa/Cocoa.h>
#define MAC true
#define IPHONE false
#endif


#if MAC || DOXYGEN
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <AGL/agl.h>
#import <Cocoa/Cocoa.h>
#endif

#if IPHONE

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <UIKit/UIKit.h>

#endif


// Some color4f defaults
#define JGBlackFull createColor4f(0.0, 0.0, 0.0, 1.0)
#define JGWhiteFull createColor4f(1.0, 1.0, 1.0, 1.0)
#define JGRedFull createColor4f(1.0, 0.0, 0.0, 1.0)
#define JGBlueFull createColor4f(0.0, 0.0, 1.0, 1.0)
#define JGYellowFull createColor4f(1.0, 1.0, 0.0, 1.0)
#define JGPurpleFull createColor4f(1.0, 0.0, 1.0, 1.0)
#define JGOrangeFull createColor4f(1.0, 0.5, 0.0, 1.0)
#define JGTealFull createColor4f(0.0, 1.0, 1.0, 1.0)
#define JGBrownFull createColor4f(0.48, 0.24, 0.11, 1.0)
#define JGGrayFull createColor4f(0.5, 0.5, 0.5, 1.0)
#define JGPinkFull createColor4f(1.0, 0.5, 0.5, 1.0)
#define JGLimeFull createColor4f(0.5, 1.0, 0.0, 1.0)
#define JGGreenFull createColor4f(0.0, 1.0, 0.0, 1.0)
#define JGDkGrayFull createColor4f(.25, .25, .25, 1.0)

#define MAX_DEPTH 250


// Some position defaults
#define JGOrigin3D createPoint3D(0,0,0)
#define JGOrigin2D createPoint2D(0,0)
// Some rotation defaults
#define JGStartRotation createRotation3D(0, 0, 0)

//Vertex buffer stuff
#define BUFFER_OFFSET(i) ((char*)NULL + (i))
#define CHECKTHIS(i) if (!i){NSException* e = [NSException exceptionWithName:@"Bad Access" reason:@"nil pointer" userInfo:nil]; [e raise];}
#define JGHANDLEERROR(i) if (i){[NSApp presentError:i];}
#define MAX_DISTANCE 10000000 // if you are using a world bigger than this you better change it!

typedef enum {
	kJGOGL3GraphicsAPI = 0,
	kJGOGL4GraphicsAPI,
	kJGOGLES1GraphicsAPI,
	kJGOGLES2GraphicsAPI
} JGGraphicsAPI;

typedef enum {
	kJGMacPlatform = 0,
	kJGIPhonePlatform,
} JGPlatform;


#if MAC || DOXYGEN
/// The target platform.
static const JGPlatform systemPlatform = kJGMacPlatform;

/// The current graphics API change this to whatever you want to use.
static const JGGraphicsAPI graphicsAPI = kJGOGL3GraphicsAPI;
#elif IPHONE

/// iDevice pi definition
static const float pi = 3.14159265358979323846;

/// The target platform.
static const JGPlatform systemPlatform = kJGIPhonePlatform;

/// The current graphics API change this to whatever you want to use.
static const JGGraphicsAPI graphicsAPI = kJGOGLES1GraphicsAPI;
#endif

static const float pi2 = 6.28318530717;
static const float pi180 = 0.017453292519943;

/// A 4D point or vector
typedef struct {
	GLfloat	x;
	GLfloat y;
	GLfloat z;
	GLfloat w;
} point4D;


/// A 3D point or vector
typedef struct {
	GLfloat	x;
	GLfloat y;
	GLfloat z;
} point3D;

/// A 3D line or ray
typedef struct {
	point3D	firstPoint;
	point3D	secondPoint;
} line3D;

/// A 3D axis aligned rectangle.
typedef struct {
	point3D	firstPoint;
	point3D	secondPoint;
} rect3D;


/// A Euler angle 3D rotation
typedef struct{
	GLfloat yaw; // Z axis
	GLfloat pitch; // Y axis
	GLfloat roll; // X axis
} rotation3D;

/// A 3D plane represented by three points
typedef struct {
	point3D firstPoint;
	point3D secondPoint;
	point3D thirdPoint;
} plane3D;

/// A 2D point or vector.
typedef struct {
	GLfloat x;
	GLfloat y;
} point2D;

/// A 2D line or ray.
typedef struct {
	point2D firstPoint;
	point2D secondPoint;
} line2D;

/// A 2D axis aligned rectangle.
typedef struct {
	point2D firstPoint;
	point2D secondPoint;
} rect2D;

/// A 2D triangle
typedef struct{
	point2D firstPoint;
	point2D secondPoint;
	point2D thirdPoint;
} triangle2D;

/// An RGBA color4f struct
typedef struct {
	GLfloat	red;
	GLfloat green;
	GLfloat blue;
	GLfloat alpha;
} color4f;

/// A vertex element
typedef struct{
	point3D vertex;
	point3D normal;
	point2D textureCoord;
} element3D;

#if IPHONE
/// Framebuffer object
typedef struct{
	GLuint frameBuffer;
	GLuint renderBuffer;
	GLuint depthBuffer;
	
} JGScreenBuffer;

#endif


