//
//  VideoCapture.m
//  CaptureTest
//
//  Created by Andrew Pouliot on 8/12/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "VideoCapture.h"

#import <CoreVideo/CoreVideo.h>

#define USE_LOW_RES_CAMERA 0

@implementation VideoCapture

@synthesize capturing;

- (id) init {
	[super init];
	if (self == nil) return self; 
	
	//Try to keep the write texture ahead of the read texture
	// currentReadTexture = 0;
	// currentWriteTexture = 1;
	
	return self;
}


- (void)dealloc
{
	[super dealloc];
}

+ (VideoCapture *)sharedCapture;
{
	static VideoCapture *sharedCapture = nil;
	@synchronized (self) {
		if (!sharedCapture) {
			sharedCapture = [[VideoCapture alloc] init];
		}
	}
	return sharedCapture;
}


- (void)startOGL;
{	
	GL_CHECK_ERROR;
	
	//TODO: why does this fail on ES2?
	if ([EAGLContext currentContext].API == kEAGLRenderingAPIOpenGLES1) {
		glEnable(GL_TEXTURE_2D);
	}

	GL_CHECK_ERROR;
	
	glGenTextures(VideoCapture_NumTextures, textures);	
	
	//TODO: get these from the camera session somehow
#if USE_LOW_RES_CAMERA
	unsigned width = 192;
	unsigned height = 144;
#else
	unsigned width = 640;
	unsigned height = 480;
#endif
	
	//Initialize the buffer
	unsigned char *buffer = malloc(4 * width * height);
	for (int y=0, i=0; y<height; y++) {
		for (int x=0; x<width; x++, i++) {
			buffer[4*i + 0] = 255;
			buffer[4*i + 1] = 0;
			buffer[4*i + 2] = 255;
			buffer[4*i + 3] = 255;
		}
	}

	//glTexParameterf(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_FALSE);

	for (int texture = 0; texture < VideoCapture_NumTextures; texture++) {
		 glBindTexture(GL_TEXTURE_2D, textures[texture]);
		
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA_EXT, GL_UNSIGNED_BYTE, buffer);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		GL_CHECK_ERROR;
	}
	glBindTexture(GL_TEXTURE_2D, 0);	
	
	
	free(buffer);
}


- (void)startCapture;
{
	//TODO: make this hack less hacky
	if (capturing) return;
	
	[self startOGL];
	
#if TARGET_OS_EMBEDDED
	captureSession = [[AVCaptureSession alloc] init];

#if USE_LOW_RES_CAMERA
	[captureSession setSessionPreset:AVCaptureSessionPresetLow];
#else
	[captureSession setSessionPreset:AVCaptureSessionPreset640x480];
#endif	
	NSError *error = nil;
	
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	NSLog(@"Devices: %@", devices);
	
	//Look for back camera
	for (AVCaptureDevice *device in devices) {
		if (device.position == AVCaptureDevicePositionBack) {
			NSLog(@"Picked device: %@", device);
			cameraDevice = [device retain];
		}
	}
	
	input = [[AVCaptureDeviceInput alloc] initWithDevice:cameraDevice error:&error];
	
	if (!input) {
		NSLog(@"Error making an input from device. %@", error);
		return;
	}
	
	output = [[AVCaptureVideoDataOutput alloc] init];
	if (!output) {
		NSLog(@"Error making output.");
		return;
	}
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey,
								   [NSNumber numberWithBool:YES], (id)kCVPixelBufferOpenGLCompatibilityKey, nil];
	
	[output setVideoSettings:videoSettings];	
	
	[output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	
	[captureSession addInput:input];
	[captureSession addOutput:output];
	[captureSession startRunning];
#endif	
	capturing = YES;
}

- (void)stopCapture;
{
#if TARGET_OS_EMBEDDED
	[captureSession stopRunning];
	[captureSession release]; captureSession = nil;
	[input release]; input = nil;
#endif
	
	capturing = NO;

	glDeleteTextures(VideoCapture_NumTextures, textures);
}

#if TARGET_OS_EMBEDDED

//On main thread, for texture upload :(
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
	   fromConnection:(AVCaptureConnection *)connection;
{

	if (!textureWasRead) {
		//NSLog(@"Texture was not read before swap!");
		return;
	}
	//Advance the current texture
	currentTexture = !currentTexture;
	textureWasRead = NO;
	//Get the texture ready
	glBindTexture(GL_TEXTURE_2D, textures[currentTexture]);
	
	//Get buffer info
	CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CVPixelBufferLockBaseAddress(imageBuffer,0);
	uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
	//size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
	size_t width = CVPixelBufferGetWidth(imageBuffer);
	size_t height = CVPixelBufferGetHeight(imageBuffer);
	
	//NSLog(@"Is ready: %@ samples:%uld sampleSize:%d width:%d height:%d bytes/row:%d baseAddr:%x", ready ? @"Y" : @"N", numsamples, sampleSize, width, height, bytesPerRow, baseAddress);

	//Copy buffer contents into vram
	GL_CHECK_ERROR;
	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_BGRA_EXT, GL_UNSIGNED_BYTE, baseAddress);
	GL_CHECK_ERROR;
	
	//Now release the lock
	CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}
#else

- (void)simulatorUploadTexture;
{
	//Advance the current texture
	currentTexture = !currentTexture;
	//Get the texture ready
	glBindTexture(GL_TEXTURE_2D, textures[currentTexture]);
	
	unsigned width = 640;
	unsigned height = 480;
	
	static unsigned char ppp;
	
	//Initialize the buffer
	unsigned char *buffer = malloc(4 * width * height);
	for (int y=0, i=0; y<height; y++) {
		for (int x=0; x<width; x++, i++) {
			buffer[4*i + 0] = 255 - ppp;
			buffer[4*i + 1] = ppp + x;
			buffer[4*i + 2] = y;
			buffer[4*i + 3] = 255;
		}
	}
	ppp++;
	
	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_BGRA_EXT, GL_UNSIGNED_BYTE, buffer);
	
	free(buffer);
	
	glBindTexture(GL_TEXTURE_2D, 0);

}

#endif


- (GLuint)getVideoTexture;
{	
	textureWasRead = YES;
#if TARGET_IPHONE_SIMULATOR
	[self simulatorUploadTexture];
#endif
	return textures[currentTexture];
}


@end
