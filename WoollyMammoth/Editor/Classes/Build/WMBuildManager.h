//
//  WMBuildManager.h
//  WoollyEditor
//
//  Created by Andrew Pouliot on 11/22/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Cocoa/Cocoa.h>


//Advertises build via bonjour, handles build state, serves builds to clients

#import "HTTPServer.h"

@class WMEditorAssetManager;

@interface WMBuildManager : NSObject {
	HTTPServer *server;
	
	NSString *outputDirectory;
}

@property (nonatomic, copy) NSString *outputDirectory;

- (void)buildWithAssetManager:(WMEditorAssetManager *)inAssetManager;

- (void)startBuildServer;
- (void)stopBuildServer;


@end
