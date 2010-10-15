//
//  WMRenderEngine.h
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/12/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WMRenderCommon.h"

@class WMShader;
@class WMEngine;

@interface WMRenderEngine : NSObject {
	EAGLContext *context;

	//Weak
	WMEngine *engine;
}

@property (nonatomic, retain) EAGLContext *context;

- (id)initWithEngine:(WMEngine *)inEngine;

- (void)drawFrame;

@end
