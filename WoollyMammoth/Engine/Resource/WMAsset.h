//
//  WMAsset.h
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/15/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMAsset : NSObject {
	NSString *resourceName;
	NSDictionary *properties;
	BOOL isLoaded;
}

@property BOOL isLoaded;

- (id)initWithResourceName:(NSString *)inResourceName properties:(NSDictionary *)inProperties;

- (BOOL)isLoaded;
- (BOOL)loadWithError:(NSError **)outError;

@end
