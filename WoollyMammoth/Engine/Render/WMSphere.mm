//
//  WMSphere.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 12/6/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMSphere.h"

#import "Vector.h"

//Position, Normal, Color, TexCoord0, TexCoord1, PointSize, Weight, MatrixIndex
struct WMSphereVertex {
	Vec3 v;
	Vec3 n;
	Vec3 tc;
	//TODO: Align to even 32-byte boundary?
};

@implementation WMSphere

- (id)init;
{
	self = [super init];
	if (!self) return nil;

	unum = 50;
	vnum = 50;
	
	radius = 0.8f;
	
	vertexData = new WMSphereVertex[unum * vnum];
	if (!vertexData) {
		[self release];
		return nil;
	}
	indexData = new unsigned short [unum * (vnum - 1) * 2 * 3]; 
	if (!indexData) {
		[self release];
		return nil;
	}
	
	//Add vertices
	for (int u=0, i=0, indexDataIndex=0; u<unum; u++) {
		for (int v=0; v<vnum; v++, i++) {
			float theta = u * 2.0f * M_PI / unum;
			float phi = v * M_PI / vnum;
			//Add the vertex
			vertexData[i].n = Vec3(sinf(phi)*cosf(theta),
								   sinf(phi)*sinf(theta), 
								   cosf(phi));
			vertexData[i].v = radius * vertexData[i].n;
			
			//Add the triangles in the quad {(u,v), (u+1,v), (u,v+1), (u+1,v+1)}
			unsigned short nextU = (u+1) % unum;
			unsigned short nextV = v+1;
			
			if (nextV < vnum) {	//Don't add last row
				indexData[indexDataIndex++] = u * vnum + v;
				indexData[indexDataIndex++] = nextU * vnum + v;
				indexData[indexDataIndex++] = u * vnum + nextV;

				indexData[indexDataIndex++] = nextU * vnum + v;
				indexData[indexDataIndex++] = u * vnum + nextV;
				indexData[indexDataIndex++] = nextU * vnum + nextV;
			}
		}
	}
	
	int maxRefI = 0;
	for (int i=0; i<[self numberOfTriangles]*3; i++) {
		maxRefI = MAX(maxRefI, indexData[i]);
	}
	
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
	return &(vertexData[0].v);
}
- (void *)textureCoordDataPointer;
{
	return &(vertexData[0].tc);
}
- (void *)normalCoordDataPointer;
{
	return &(vertexData[0].n);
}

- (size_t)interleavedDataStride;
{
	return sizeof(WMSphereVertex);
}
- (size_t)numberOfTriangles;
{
	return unum * (vnum - 1) * 2;
}
- (size_t)numberOfVertices;
{
	return unum * vnum;
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
