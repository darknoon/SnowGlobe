//
//  SoundManager.m
//  Exercise
//
//  Created by Andrew Pouliot on 8/26/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "SoundManager.h"

#import <AudioToolbox/AudioServices.h>

@implementation SoundManager

+ (SoundManager *)sharedManager;
{
	static SoundManager *sharedManager = nil;
	if (!sharedManager) {
		sharedManager = [[SoundManager alloc] init];
	}
	return sharedManager;
}

- (id) init {
	[super init];
	if (self == nil) return self; 
	
	soundIds = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (void) dealloc
{
	[soundIds release]; soundIds = nil;
	[super dealloc];
}


- (void)loadSoundConfigFromFilePath:(NSString *)inFilePath;
{
	NSDictionary *soundConfig = [NSDictionary dictionaryWithContentsOfFile:inFilePath];
	for (NSString *key in [soundConfig allKeys]) {
		NSString *filePath = [[NSBundle mainBundle] pathForResource:[soundConfig objectForKey:key] ofType:nil];
		NSURL *fileURL = [NSURL fileURLWithPath:filePath];
		SystemSoundID soundId = 0;
		OSStatus err = AudioServicesCreateSystemSoundID((CFURLRef)fileURL, &soundId);
		if (err == noErr) {
			NSNumber *num = [NSNumber numberWithInt:soundId];
			[soundIds setObject:num forKey:key];
		} else {
			NSLog(@"Error creating system sound for key:%@ path:%@: %ld", key, filePath, err);
		}
	}
}


- (void)playSound:(NSString *)inSoundIdentifier;
{
	NSNumber *num = [soundIds objectForKey:inSoundIdentifier];
	if (num) {
		SystemSoundID soundId = [num intValue];
		AudioServicesPlaySystemSound(soundId);
	}
}

@end
