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

#import "JGModel.h"

@implementation JGModel

- (id)init{
	if (self = [super init]){
		cachedVertices = nil;
		cachedTextureCoord = nil;
		cachedNormals = nil;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder{
	if (self = [super init]){
		elementCount = [coder decodeIntForKey:@"elementCount"];
		faceCount = [coder decodeIntForKey:@"faceCount"];
		vertexCount = [coder decodeIntForKey:@"vertexCount"];
		textureCount = [coder decodeIntForKey:@"textureCount"];
		normalCount = [coder decodeIntForKey:@"normalCount"];
		
		
		vertices = malloc(sizeof(point3D) * vertexCount);
		textureCoords = malloc(sizeof(point2D) * textureCount);
		normals = malloc(sizeof(point3D) * normalCount);
		faces = malloc(sizeof(GLuint) * faceCount);
		
		
		NSData *vertexData = [[NSData alloc] initWithData:[coder decodeObjectForKey:@"vertices"]];
		NSData *textureData = [[NSData alloc] initWithData:[coder decodeObjectForKey:@"textureCoords"]];
		NSData *normalData = [[NSData alloc] initWithData:[coder decodeObjectForKey:@"normals"]];
		NSData *faceData = [[NSData alloc] initWithData:[coder decodeObjectForKey:@"faces"]];
		
		
		memcpy(vertices, [vertexData bytes],  sizeof(point3D) * vertexCount);
		memcpy(textureCoords, [textureData bytes], sizeof(point2D) * textureCount);
		memcpy(normals, [normalData bytes], sizeof(point3D) * normalCount);
		memcpy(faces, [faceData bytes], sizeof(GLuint) * faceCount);
		
		[vertexData release];
		[textureData release];
		[normalData release];
		[faceData release];		
	}
	return self;	
}
- (void)encodeWithCoder:(NSCoder *)coder{
	NSData *vertexData = [NSData dataWithBytes:vertices length:sizeof(point3D) * vertexCount];  
	NSData *textureData = [NSData dataWithBytes:textureCoords length:sizeof(point2D) * textureCount];  
	NSData *normalData = [NSData dataWithBytes:normals length:sizeof(point3D) * normalCount];
	NSData *faceData = [NSData dataWithBytes:faces length:sizeof(GLuint) * faceCount];  
	
	
	[coder encodeObject:vertexData forKey:@"vertices"];
	[coder encodeObject:textureData forKey:@"textureCoords"];
	[coder encodeObject:normalData forKey:@"normals"];
	[coder encodeObject:faceData forKey:@"faces"];
	
	[coder encodeInt:elementCount forKey:@"elementCount"];
	[coder encodeInt:faceCount forKey:@"faceCount"];
	[coder encodeInt:vertexCount forKey:@"vertexCount"];
	[coder encodeInt:normalCount forKey:@"normalCount"];
	[coder encodeInt:textureCount forKey:@"textureCount"];
	
}

+ (id)modelFromPath:(NSString*)filePath{
	JGModel* model = [[JGModel alloc] init];
	[model loadFromPath:filePath];
	return [model autorelease];
	
}
+ (id)modelFromFile:(NSString*)name extension:(NSString*)extension{
	JGModel* model = [[JGModel alloc] init];
	[model loadFromFile:name extension:extension];
	return [model autorelease];
	
}


- (void)loadFromData:(NSData*)data{
	[super loadFromData:data];
	
	if (format == kJGOBJModelFormat){
		
		NSString* string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		
		if (string == nil){
			NSException* e = [NSException exceptionWithName:@"Error loading model!" reason:@"Data is corrupted or nonexistant" userInfo:nil];
			[e raise];
		}
		
		[self countValues:string];
		
		if (vertices)
			free(vertices);
		
		if (textureCoords)
			free(textureCoords);
		
		if (normals)
			free(normals);
		
		if (faces)
			free(faces);
		
		vertices = malloc(sizeof(point3D) * vertexCount);
		textureCoords = malloc(sizeof(point2D) * textureCount);
		normals = malloc(sizeof(point3D) * normalCount);
		faces = malloc(sizeof(uint) * faceCount);
		
		
		tempVertexCount = 0;
		
		tempNormalCount = 0;
		
		tempTextureCount = 0;
		
		tempFaceCount = 0;
		
		
		NSScanner *scanner = [[NSScanner alloc] initWithString:string];
		
		
		
		while (![scanner isAtEnd]){
			
			
			NSString* firstString = [[NSString alloc] init];
			[scanner scanUpToString:@"\n" intoString:&firstString];
			NSString* value = [firstString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
			value = [value stringByReplacingOccurrencesOfString:@"/" withString:@" "];
			value = [value stringByReplacingOccurrencesOfString:@"\r" withString:@""];
			NSArray* strings = [value componentsSeparatedByString:@" "];
			
			
			
			if ([[strings objectAtIndex:0] isEqualToString:@"v"]){
				
				vertices[tempVertexCount].x = [[strings objectAtIndex:1] floatValue];
				vertices[tempVertexCount].y = [[strings objectAtIndex:2] floatValue];
				vertices[tempVertexCount].z = [[strings objectAtIndex:3] floatValue];
				
				tempVertexCount +=1;
				
			}else if ([[strings objectAtIndex:0] isEqualToString:@"vn"]){
				
				normals[tempNormalCount].x = [[strings objectAtIndex:1] floatValue];
				normals[tempNormalCount].y = [[strings objectAtIndex:2] floatValue];
				normals[tempNormalCount].z = [[strings objectAtIndex:3] floatValue];
				
				
				tempNormalCount += 1;
				
			}else if ([[strings objectAtIndex:0] isEqualToString:@"vt"]){
				textureCoords[tempTextureCount].x = [[strings objectAtIndex:1] floatValue];
				textureCoords[tempTextureCount].y = [[strings objectAtIndex:2] floatValue];
				
				tempTextureCount += 1;
				
			}else if ([[strings objectAtIndex:0] isEqualToString:@"f"]){
				faces[tempFaceCount + 0] = [[strings objectAtIndex:1] intValue] - 1;
				faces[tempFaceCount + 1] = [[strings objectAtIndex:2] intValue] - 1;
				faces[tempFaceCount + 2] = [[strings objectAtIndex:3] intValue] - 1;
				
				
				faces[tempFaceCount + 3] = [[strings objectAtIndex:4] intValue] - 1;
				faces[tempFaceCount + 4] = [[strings objectAtIndex:5] intValue] - 1;
				faces[tempFaceCount + 5] = [[strings objectAtIndex:6] intValue] - 1;
				
				
				faces[tempFaceCount + 6] = [[strings objectAtIndex:7] intValue] - 1;
				faces[tempFaceCount + 7] = [[strings objectAtIndex:8] intValue] - 1;
				faces[tempFaceCount + 8] = [[strings objectAtIndex:9] intValue] - 1;
				
				
				
				tempFaceCount += 9;
			}
			[scanner setScanLocation:[scanner scanLocation]+ 1];
		}
		[scanner release];
		scanner = nil;
		
		string = nil;		
	}else if (format == kJGGSModelFormat){
		uint offset = 0;
		[data getBytes:&elementCount range:NSMakeRange(offset, sizeof(uint))];
		offset += sizeof(uint);
		[data getBytes:&faceCount range:NSMakeRange(offset, sizeof(uint))];
		offset += sizeof(uint);
		[data getBytes:&vertexCount range:NSMakeRange(offset, sizeof(uint))];
		offset += sizeof(uint);
		[data getBytes:&normalCount range:NSMakeRange(offset, sizeof(uint))];
		offset += sizeof(uint);
		[data getBytes:&textureCount range:NSMakeRange(offset, sizeof(uint))];
		offset += sizeof(uint);
		
		
		vertices = malloc(sizeof(point3D) * vertexCount);
		textureCoords = malloc(sizeof(point2D) * textureCount);
		normals = malloc(sizeof(point3D) * normalCount);
		faces = malloc(sizeof(GLuint) * faceCount);
		
		uint size = sizeof(point3D) * vertexCount;
		[data getBytes:vertices range:NSMakeRange(offset, size)];
		offset += size;
		
		size = sizeof(point2D) * textureCount;
		[data getBytes:textureCoords range:NSMakeRange(offset, size)];
		offset += size;
		
		size = sizeof(point3D) * normalCount;
		[data getBytes:normals range:NSMakeRange(offset, size)];
		offset += size;
		
		size = sizeof(uint) * faceCount;
		[data getBytes:faces range:NSMakeRange(offset, size)];		
		
	}
	[self recalculateCache];
	
	loaded = YES;
}

- (void)countValues:(NSString*)string{
	NSScanner *scanner = [[NSScanner alloc] initWithString:string];
	
	vertexCount = 0;
	normalCount = 0;
	textureCount = 0;
	faceCount = 0;
	
	while (![scanner isAtEnd]){
		NSString* firstString = [[NSString alloc] init];
		[scanner scanUpToString:@"\n" intoString:&firstString];
		NSString* value = [firstString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
		value = [value stringByReplacingOccurrencesOfString:@"/" withString:@" "];
		NSArray* strings = [value componentsSeparatedByString:@" "];
		
		if ([[strings objectAtIndex:0] isEqualToString:@"v"]){
			vertexCount += 1;
			
		}else if ([[strings objectAtIndex:0] isEqualToString:@"vn"]){
			normalCount += 1;
			
		}else if ([[strings objectAtIndex:0] isEqualToString:@"vt"]){
			textureCount += 1;
			
		}else if ([[strings objectAtIndex:0] isEqualToString:@"f"]){
			faceCount += 9;
		}
		[scanner setScanLocation:[scanner scanLocation] + 1];
	}
	[scanner release];
	
	
	elementCount = faceCount / 3;
	
}

	
- (void)recalculateCache{
	if (cachedVertices)
		free(cachedVertices);
	
	if (cachedTextureCoord)
		free(cachedTextureCoord);
	
	if (cachedNormals)
		free(cachedNormals);
	
	cachedVertices = malloc(sizeof(point3D) * elementCount);
	cachedTextureCoord = malloc(sizeof(point2D) * elementCount);
	cachedNormals = malloc(sizeof(point3D) * elementCount);
	
	int a = 0;
	for (int i = 0; i < faceCount; i += 3){
		cachedVertices[a] = vertices[faces[i]];
		cachedTextureCoord[a] = textureCoords[faces[i + 1]];
		cachedNormals[a] = normals[faces[i + 2]];
		a += 1;
	}
	
}

#if 0
- (void)drawModel{
	// if (material){
		// [material bindMaterial];
	// }

	// ES2.0
	if (graphicsAPI == kJGOGLES2GraphicsAPI){ 
		glEnableVertexAttribArray(GRAPHICS_ATTRIB_VERTEX);
		glEnableVertexAttribArray(GRAPHICS_ATTRIB_NORMAL); 
		glEnableVertexAttribArray(GRAPHICS_ATTRIB_TEXTURE); 

		glVertexAttribPointer(GRAPHICS_ATTRIB_VERTEX, sizeof(point3D) * elementCount, GL_FLOAT, GL_FALSE, sizeof(point3D), cachedVertices);
		glVertexAttribPointer(GRAPHICS_ATTRIB_NORMAL, sizeof(point3D) * elementCount, GL_FLOAT, GL_FALSE, sizeof(point3D), cachedNormals);
		glVertexAttribPointer(GRAPHICS_ATTRIB_TEXTURE, sizeof(point2D) * elementCount, GL_FLOAT, GL_FALSE, sizeof(point2D), cachedTextureCoord);
		
		glDrawArrays(GL_TRIANGLES, 0, elementCount);

		glDisableVertexAttribArray(GRAPHICS_ATTRIB_VERTEX);
		glDisableVertexAttribArray(GRAPHICS_ATTRIB_NORMAL); 
		glDisableVertexAttribArray(GRAPHICS_ATTRIB_TEXTURE); 
		

	}else{
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_NORMAL_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		
		glVertexPointer(3, GL_FLOAT, sizeof(point3D), cachedVertices);
		glNormalPointer(GL_FLOAT, sizeof(point3D) , cachedNormals);
		glTexCoordPointer(2, GL_FLOAT, sizeof(point2D), cachedTextureCoord);
		
		glDrawArrays(GL_TRIANGLES, 0, elementCount);
		
		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_NORMAL_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}
	
	
	if (material){
		[material unBindMaterial];
	}
}

#endif

- (void)unload{
	if (loaded){
		[super unload];
		
		free(cachedVertices);
		free(cachedTextureCoord);
		free(cachedNormals);
	}
}




@end

