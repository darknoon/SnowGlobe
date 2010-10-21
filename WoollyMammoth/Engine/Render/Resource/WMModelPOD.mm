//
//  WMModelPOD.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/15/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMModelPOD.h"

#import "WMRenderCommon.h"


@implementation WMModelPOD

- (id) init {
	[super init];
	if (self == nil) return self; 
	
	podmodel = new CPVRTModelPOD();
	
	NSString *podPath = [[NSBundle mainBundle] pathForResource:@"GeodesicSphere02" ofType:@"pod"];
	
	podmodel->ReadFromFile([podPath UTF8String], NULL, 1);
	
	mesh = podmodel->pMesh[0];
	
	//Make sure mesh is interleaved
	if (!mesh.pInterleaved) {
		NSLog(@"Mesh not interleaved!");
		[self release];
		return nil;
	}
	
	return self;
}

- (void) dealloc
{
	delete podmodel;
	//TODO: delete mesh…
	
	[super dealloc];
}


- (size_t)interleavedDataStride;
{
	return mesh.sVertex.nStride;
}

- (void *)vertexDataPointer;
{
	//Yay, pointer arithmatic
	return (void *)((int)mesh.pInterleaved + (int)mesh.sVertex.pData);
}

- (void *)textureCoordDataPointer;
{
	//TODO: support this
	return NULL;
}

- (void *)normalCoordDataPointer;
{
	//Yay, pointer arithmatic
	return (void *)((int)mesh.pInterleaved + (int)mesh.sNormals.pData);
}

- (void *)interleavedDataPointer;
{
	return mesh.pInterleaved;
}

- (size_t)numberOfTriangles;
{
	return mesh.nNumFaces;
}

- (size_t)numberOfVertices;
{
	return mesh.nNumVertex;
}

- (GLenum)triangleIndexType;
{
	switch (mesh.sFaces.eType) {
		case EPODDataInt:
			return GL_INT;
		case EPODDataUnsignedShort:
			return GL_UNSIGNED_SHORT;
		case EPODDataUnsignedByte:
			return GL_UNSIGNED_BYTE;
		default:
			NSLog(@"Unknown triangle index type: %d", mesh.sFaces.eType);
			return GL_UNSIGNED_SHORT;
	}
}

- (unsigned short *)triangleIndexPointer;
{
	return (unsigned short *)mesh.sFaces.pData;
}

@end
