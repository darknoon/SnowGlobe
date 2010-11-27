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

#if TARGET_OS_EMBEDDED
@interface VideoCapture : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
	AVCaptureSession *captureSession;
	AVCaptureInput  *input;
	AVCaptureVideoDataOutput  *output;
	AVCaptureDevice *cameraDevice;
#else
	@interface VideoCapture : NSObject {
#endif
	
	BOOL capturing;
		
#if TARGET_IPHONE_SIMULATOR
	NSTimer *simulatorDebugTimer;
#endif
	
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
