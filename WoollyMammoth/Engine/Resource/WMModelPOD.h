//
//  WMModelPOD.h
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/15/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ModelPOD.h"
#import "WMAsset.h"

@interface WMModelPOD : WMAsset {
	CPVRTModelPOD *podmodel;
	SPODMesh mesh;
	float scale;
}

/**
 Properties supported:
 scale: scale the model by this factor when loading
 */

- (id)initWithResourceName:(NSString *)inResourceName properties:(NSDictionary *)inProperties;

@property (nonatomic, assign) float scale;

//Apply scale, etc
- (BOOL)loadWithError:(NSError **)outError;

- (void *)interleavedDataPointer;

- (void *)vertexDataPointer;
- (void *)textureCoordDataPointer;
- (void *)normalCoordDataPointer;

- (size_t)interleavedDataStride;
- (size_t)numberOfTriangles;
- (size_t)numberOfVertices;

- (GLenum)triangleIndexType;
- (unsigned short *)triangleIndexPointer;

@end
