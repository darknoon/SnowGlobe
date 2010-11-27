//
//  WMBuild.m
//  WoollyEditor
//
//  Created by Andrew Pouliot on 11/22/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMBuild.h"

#import "WMEditorAsset.h"

@implementation WMBuild

@synthesize outputPath;
@synthesize inputResourceRoot;
@synthesize assets;

- (void)dealloc
{
	[assets release];
	assets = nil;

	[inputResourceRoot release];
	inputResourceRoot = nil;

	[outputPath release];
	outputPath = nil;

	[super dealloc];
}

- (void)buildAsset:(WMEditorAsset *)inAsset;
{
	//Just copy to output dir for now
	
}

- (void)buildWithCompletionBlock:(void (^)(NSError *error))completionBlock;
{
	building = YES;
	
	NSError *error = nil;
	//Clear out build directory
	for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:outputPath error:&error]) {
		NSError *error = nil;
		[[NSFileManager defaultManager] removeItemAtPath:[outputPath stringByAppendingPathComponent:file] error:&error];
		if (error) {
			NSLog(@"Couldn't clear output directory!");
			completionBlock(error);
			return;
		}
		
	}
	
	//Make sure the output directory exists
	NSError *buildDirErr = nil;
	[[NSFileManager defaultManager] createDirectoryAtPath:outputPath withIntermediateDirectories:YES attributes:nil error:&buildDirErr];

	NSMutableDictionary *manifestDictionary = [NSMutableDictionary dictionary];
	[manifestDictionary setObject:[NSNumber numberWithInt:1] forKey:@"version"];
	
	//Build assets
	for (WMEditorAsset *asset in assets) {
		//TODO: actually convert files or whatever
		for (NSString *inPath in [asset absolutePathsForCopyingWithRoot:inputResourceRoot]) {
			NSString *outPath = [outputPath stringByAppendingPathComponent:[inPath lastPathComponent]];

			[[NSFileManager defaultManager] copyItemAtPath:inPath toPath:outPath error:&error];
			if (error) {
				NSLog(@"Error processing file: %@ (%@ \n=> %@)", asset.resourceName, inPath, outPath);
				completionBlock(error);
				return;
			}
		}
		NSMutableDictionary *outputDictionary = [manifestDictionary objectForKey:[asset resourceTypeSection]];
		if (!outputDictionary) {
			outputDictionary = [NSMutableDictionary dictionary];
			[manifestDictionary setObject:outputDictionary forKey:[asset resourceTypeSection]];
		}
		[outputDictionary setObject:asset.properties forKey:asset.resourceName];
	}
	
	//Write manifest
	[manifestDictionary writeToFile:[outputPath stringByAppendingPathComponent:@"manifest.plist"] atomically:YES];
	
	//Call completion right away
	completionBlock(error);
}

@end
