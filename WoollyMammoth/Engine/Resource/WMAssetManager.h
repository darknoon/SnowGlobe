//
//  WMAssetManager.h
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/15/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WMAssetManager : NSObject {
	NSBundle *assetBundle;
	NSMutableDictionary *models;
	NSMutableDictionary *shaders;
	NSMutableDictionary *textures;
	NSMutableDictionary *scripts;
}

- (id)initWithBundlePath:(NSString *)inBundlePath;

- (id)modelWithName:(NSString *)inName;
- (id)shaderWithName:(NSString *)inName;

//Must be called with a context set
- (void)loadAllAssetsSynchronous;

//- (id)textureWithName:(NSString *)inName;
//- (id)scriptWithName:(NSString *)inName;

@end
