//
//  WMQuad.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/21/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMQuad.h"

typedef struct WMQuadVertex {
	float v[3];
	float tc[2];
	//TODO: Align to even power boundary?
};

@implementation WMQuad

- (id)init;
{
	self = [super init];
	if (!self) return nil;
	
	vertexData = malloc(sizeof(WMQuadVertex) * 4);
	if (!vertexData) {
		[self release];
		return nil;
	}
	
	const float scale = 1;
	
	//Add vertices
	WMQuadVertex *vertexDataPtr = (WMQuadVertex *)vertexData;
	for (int y=0, i=0; y<2; y++) {
		for (int x=0; x<2; x++, i++) {
			
			vertexDataPtr[i].v[0] = ((float)x - 0.5f) * 2.0f * scale;
			vertexDataPtr[i].v[1] = ((float)y - 0.5f) * 2.0f * scale;
			vertexDataPtr[i].v[2] = 0.0f;
			
			vertexDataPtr[i].tc[0] = (float)x;
			vertexDataPtr[i].tc[1] = (float)y;
		}
	}
		
	indexData = (unsigned short *)malloc(sizeof(indexData[0]) * 2 * 3); 
	if (!indexData) {
		[self release];
		return nil;
	}
	//Add triangles
	indexData[0] = 0;
	indexData[1] = 1;
	indexData[2] = 2;

	indexData[3] = 1;
	indexData[4] = 2;
	indexData[5] = 3;
	
	return self;
}

- (void) dealloc
{
	if (vertexData) free(vertexData);
	if (indexData) free(indexData);
	
	[super dealloc];
}


- (void *)vertexDataPointer;
{
	return vertexData;
}
- (void *)textureCoordDataPointer;
{
	return (void *)&(((WMQuadVertex *)vertexData)[0].tc);
}
- (void *)normalCoordDataPointer;
{
	return NULL;
}

- (size_t)interleavedDataStride;
{
	return sizeof(WMQuadVertex);
}
- (size_t)numberOfTriangles;
{
	return 2;
}
- (size_t)numberOfVertices;
{
	return 4;
}

- (GLenum)triangleIndexType;
{
	return GL_UNSIGNED_SHORT;
}

- (unsigned short *)triangleIndexPointer;
{
	return indexData;
}

@end
