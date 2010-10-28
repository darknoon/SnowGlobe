//
//  WMRenderableDataSource.h
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/21/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WMRenderCommon.h"

@protocol WMRenderableDataSource

- (void *)vertexDataPointer;
- (void *)textureCoordDataPointer;
- (void *)normalCoordDataPointer;

- (size_t)interleavedDataStride;
- (size_t)numberOfTriangles;
- (size_t)numberOfVertices;

- (GLenum)triangleIndexType;
- (unsigned short *)triangleIndexPointer;


@end
