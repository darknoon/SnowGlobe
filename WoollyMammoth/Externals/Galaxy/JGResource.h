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


/// An abstract class for handling resource managment for all resource types in the engine.
@interface JGResource : NSObject {
	/// The path the resource was loaded from.
	NSString* path;
	BOOL loaded;
}
@property(readonly)NSString* path;
@property(readonly)BOOL loaded;
/// Load from the current project bundle.
- (void)loadFromFile:(NSString*)name extension:(NSString*)extension;
/// Load from a file path.
- (void)loadFromPath:(NSString*)filePath;
/// Load from an NSData object.
- (void)loadFromData:(NSData*)data;
/// Reloads the current resource. Resource must have been loaded from either a file or path and must have been previously loaded.
- (void)reload;
/// Unloads the current resource. Resource must have been loaded. This method is called automaticly on release.
- (void)unload;
@end
