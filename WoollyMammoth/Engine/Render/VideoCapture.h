//
//  VideoCapture.h
//  CaptureTest
//
//  Created by Andrew Pouliot on 8/12/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface VideoCapture : NSObject
#if TARGET_OS_EMBEDDED
<AVCaptureVideoDataOutputSampleBufferDelegate> 
#endif
{
#if TARGET_OS_EMBEDDED
	AVCaptureSession *captureSession;
	AVCaptureInput  *input;
	AVCaptureVideoDataOutput  *output;
	AVCaptureDevice *cameraDevice;
#else			
	NSTimer *simulatorDebugTimer;
#endif
	BOOL capturing;
	
	//Swap between textures to reduce locking issues?
	GLuint textures[1];
}

@property (nonatomic, readonly) BOOL capturing;

+ (VideoCapture *)sharedCapture;

//Will block until AVFoundation is done processing
- (GLuint)getVideoTexture;

- (void)startCapture;
- (void)stopCapture;

@end
