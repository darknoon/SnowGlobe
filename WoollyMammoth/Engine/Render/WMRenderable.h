//
//  WMRenderable.h
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/13/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WMRenderCommon.h"
#import "WMRenderableDataSource.h"

#import "Matrix.h"

@class WMShader;
@class WMTextureAsset;
@class WMModelPOD;

@interface WMRenderable : NSObject {
	WMShader *shader;
	//TODO: how should we handle multi-texturing?
	//Move into shader?
	WMTextureAsset *texture;
	BOOL hidden;
	NSObject<WMRenderableDataSource> *model;
}

@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, retain) WMTextureAsset *texture;
@property (nonatomic, retain) WMShader *shader;
@property (nonatomic, retain) NSObject<WMRenderableDataSource> *model;

//Gets called after every frame. do computation here
- (void)update;

- (void)drawWithTransform:(MATRIX)transform API:(EAGLRenderingAPI)API;

@end
