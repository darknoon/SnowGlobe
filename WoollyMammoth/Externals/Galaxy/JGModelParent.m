/*
 Copyright (c) 2010, JAM Studios
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the name of the JAM Studios nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
 IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "JGModelParent.h"


#define min fminf
#define max fmaxf


@implementation JGModelParent
@synthesize vertices, normals, textureCoords, faces, vertexCount, textureCount, normalCount, faceCount, elementCount, format;
- (id)init{
	if (self = [super init]){
//		material = [[JGMaterial alloc] init];
		format = kJGOBJModelFormat;
		vertices = nil;
		normals = nil;
		textureCoords = nil;
		faces = nil;
		
	}
	return self;
}


+ (id)modelFromFile:(NSString*)name extension:(NSString*)extension{
	return nil;
}
+ (id)modelFromPath:(NSString*)filePath{
	return nil;
}
- (void)drawModel{
	
}

- (NSData*)writeToData{
	NSMutableData* data = [[NSMutableData alloc] init];
	[data appendBytes:&elementCount length:sizeof(uint)];
	[data appendBytes:&faceCount length:sizeof(uint)];
	[data appendBytes:&vertexCount length:sizeof(uint)];
	[data appendBytes:&normalCount length:sizeof(uint)];
	[data appendBytes:&textureCount length:sizeof(uint)];
	[data appendBytes:vertices length:sizeof(point3D) * vertexCount];
	[data appendBytes:textureCoords length:sizeof(point2D) * textureCount];
	[data appendBytes:normals length:sizeof(point3D) * normalCount];
	[data appendBytes:faces length:sizeof(uint) * faceCount];


	return [NSData dataWithData:[data autorelease]];
	
}



- (point3D)getMinPosition{
	point3D minPoint;
	minPoint.x = 0;
	minPoint.y = 0;
	minPoint.z = 0;
	for (int i = 0; i < vertexCount; i++){
		point3D newVert = vertices[i];
		
		minPoint.x = min(minPoint.x, newVert.x);
		minPoint.y = min(minPoint.y, newVert.y);
		minPoint.z = min(minPoint.z, newVert.z);
	}
	return minPoint;
}
- (point3D)getMaxPosition{
	point3D maxPoint;
	maxPoint.x = 0;
	maxPoint.y = 0;
	maxPoint.z = 0;
	for (int i = 0; i < vertexCount; i++){
		point3D newVert = vertices[i];
		maxPoint.x = max(maxPoint.x, newVert.x);
		maxPoint.y = max(maxPoint.y, newVert.y);
		maxPoint.z = max(maxPoint.z, newVert.z);
	}
	return maxPoint;
}
- (point3D*)copyVertices{
	point3D* returned = malloc(sizeof(point3D) * vertexCount);
	for (int i = 0; i < vertexCount; i ++){
		returned[i] = vertices[i];
		
	}
	return returned;
}
- (void)unload{
	if (loaded){
		[super unload];
		free(vertices);
		free(textureCoords);
		free(normals);
		free(faces);
	}
}
- (void)dealloc{
	//[material release];	
	[super dealloc];
}
@end
