//
//  SoundManager.h
//  Exercise
//
//  Created by Andrew Pouliot on 8/26/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SoundManager : NSObject {
	NSMutableDictionary *soundIds;
}

//Not thread safe. Call on main thread
+ (SoundManager *)sharedManager;

- (void)loadSoundConfigFromFilePath:(NSString *)inFilePath;

//- (void)vibrate;
- (void)playSound:(NSString *)inSoundIdentifier;

@end
