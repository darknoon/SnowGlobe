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


#import "JGStructures.h"

#import "JGResource.h"

/// Model formats
typedef enum {
	kJGOBJModelFormat = 0,
	kJGGSModelFormat,
} JGModelFormat;


@interface JGModelParent : JGResource {
	//JGMaterial* material;
	/// Model vertices.
	point3D* vertices;
	/// Model texture coordinates.
	point2D* textureCoords;
	/// Model normals.
	point3D* normals;
	/// Model face indices.
	GLuint* faces;
	/// The format of file the model is loaded from.
	JGModelFormat format;
	
	uint vertexCount;
	uint textureCount;
	uint normalCount;
	uint faceCount;	
	uint elementCount;
}
//@property(retain)JGMaterial* material;

@property(assign)point3D* vertices;
@property(assign)point2D* textureCoords;
@property(assign)point3D* normals;
@property(assign)GLuint* faces;

@property(readonly)uint vertexCount;
@property(readonly)uint textureCount;
@property(readonly)uint normalCount;
@property(readonly)uint faceCount;
@property(readonly)uint elementCount;

@property(assign)JGModelFormat format;


- (void)drawModel;
- (point3D)getMinPosition;
- (point3D)getMaxPosition;

+ (id)modelFromFile:(NSString*)name extension:(NSString*)extension;
+ (id)modelFromPath:(NSString*)filePath;
- (NSData*)writeToData;
- (point3D*)copyVertices;
@end
