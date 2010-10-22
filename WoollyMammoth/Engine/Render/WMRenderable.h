//
//  WMRenderable.h
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/13/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WMRenderCommon.h"

#import "Matrix.h"

@class WMShader;

@class WMModelPOD;

@interface WMRenderable : NSObject {
	WMShader *shader;
	WMModelPOD *model;
}

@property (nonatomic, retain) WMShader *shader;
@property (nonatomic, retain) WMModelPOD *model;

- (void)drawWithTransform:(MATRIX)transform API:(EAGLRenderingAPI)API;

@end