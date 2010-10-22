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
	NSDictionary *manifest;
	NSMutableDictionary *models;
	NSMutableDictionary *shaders;
	NSMutableDictionary *textures;
	NSMutableDictionary *scripts;
}

@property (nonatomic, readonly, retain) NSBundle *assetBundle;

- (id)initWithBundlePath:(NSString *)inBundlePath;

- (id)objectForManifestKey:(NSString *)inManifestKey;

- (id)modelWithName:(NSString *)inName;
- (id)shaderWithName:(NSString *)inName;
- (id)textureWithName:(NSString *)inName;
//- (id)scriptWithName:(NSString *)inName;

//Must be called with a context set
- (void)loadAllAssetsSynchronous;


@end
