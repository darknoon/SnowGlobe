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

#import "JGResource.h"


@implementation JGResource
@synthesize loaded, path;
- (id)init{
	if (self = [super init]){
		path = @"";
		loaded = NO;
	}
	return self;
}
- (void)loadFromFile:(NSString*)name extension:(NSString*)extension{
	[self loadFromPath:[[NSBundle mainBundle] pathForResource:name ofType:extension]];
}
- (void)loadFromPath:(NSString*)filePath{
	path = filePath;
	NSData* data = [NSData dataWithContentsOfFile:path];
	[self loadFromData:data];
}
- (void)loadFromData:(NSData*)data{
	if (!data){
		NSException* e = [NSException exceptionWithName:@"Error loading resource form data!" reason:@"Data is corrupted or nonexistant" userInfo:nil];
		[e raise];
	}
	if (loaded){
		[self unload];
	}
}
- (void)reload{
	if (loaded){
		[self unload];
		[self loadFromPath:path];
	}else{
		NSException* e = [NSException exceptionWithName:@"Error reloading resource!" reason:@"Resource has not been loaded yet or was loaded from data." userInfo:nil];
		[e raise];
	}
}
- (void)unload{
	if (loaded){
		loaded = NO;
	}
}
- (void)dealloc{
	if (loaded){
		[self unload];
	}
	[super dealloc];
}
@end
