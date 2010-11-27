//
//  WMBuild.h
//  WoollyEditor
//
//  Created by Andrew Pouliot on 11/22/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WMBuild : NSObject {
	NSString *inputResourceRoot;
	NSString *outputPath;
	
	NSArray *assets;
	
	BOOL building;
}

@property (nonatomic, copy) NSString *outputPath;
@property (nonatomic, copy) NSString *inputResourceRoot;
@property (nonatomic, copy) NSArray *assets;

- (void)buildWithCompletionBlock:(void (^)(NSError *error))completionBlock;

@end
