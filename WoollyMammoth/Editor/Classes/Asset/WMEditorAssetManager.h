//
//  WMEditorAssetManager.h
//  WoollyEditor
//
//  Created by Andrew Pouliot on 11/22/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const WMEditorAssetManagerAssetsChangedNotification;

@interface WMEditorAssetManager : NSObject {
	NSArray *assets;
	NSString *assetBasePath;
}

@property (nonatomic, copy) NSString *assetBasePath;
@property (nonatomic, copy) NSArray *assets;

- (BOOL)loadManifestFromData:(NSData *)inData error:(NSError **)outError;

- (NSData *)manifestDataWithDocumentTitle:(NSString *)inTitle;

@end
