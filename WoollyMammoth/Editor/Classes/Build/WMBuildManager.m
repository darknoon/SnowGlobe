//
//  WMBuildManager.m
//  WoollyEditor
//
//  Created by Andrew Pouliot on 11/22/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMBuildManager.h"

#import "WMBuild.h"
#import "WMEditorAssetManager.h"

@implementation WMBuildManager

@synthesize outputDirectory;

- (void) dealloc
{
	[server release];
	[outputDirectory release];
	outputDirectory = nil;

	[super dealloc];
}


- (void)setOutputDirectory:(NSString *)value {
	if (outputDirectory == value) return;
	[outputDirectory release];
	outputDirectory = [value copy];
	
	[self stopBuildServer];
	[self startBuildServer];
}



- (void)startBuildServer;
{
	if (!outputDirectory) return;
	
	if (!server) {
		server = [[HTTPServer alloc] init];
		[server setType:@"_wmremote._tcp."];
	}
	[server setDocumentRoot:[NSURL fileURLWithPath:outputDirectory]];
	NSError *error = nil;
	if (![server start:&error]) {
		NSLog(@"Error starting server! %@", error);
	}
	
}

- (void)stopBuildServer;
{
	[server stop];
}

- (void)buildWithAssetManager:(WMEditorAssetManager *)inAssetManager;
{
	WMBuild *build = [[WMBuild alloc] init];
	build.inputResourceRoot = inAssetManager.assetBasePath;
	build.outputPath = outputDirectory;
	build.assets = inAssetManager.assets;
	[build buildWithCompletionBlock:^ (NSError *error){
		if (error) {
			NSLog(@"Build failed! %@", error);
		} else {
			NSLog(@"Build complete!");
		}
		[build release];
	}];
	
}

@end
