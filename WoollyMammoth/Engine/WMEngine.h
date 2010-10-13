//
//  WMEngine.h
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/12/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WMDebugChannel;
@class WMGameObject;
@class WMScriptingContext;
@class WMRenderEngine;

@interface WMEngine : NSObject {
	UInt64 maxObjectId;
	WMScriptingContext *scriptingContext;
	WMDebugChannel *debugChannel;
	NSMutableDictionary *objectsById;
	WMGameObject *rootObject;
	WMRenderEngine *renderEngine;
}

//This is set up by the view and set on us. If nil, renderer not ready
@property (nonatomic, retain) WMRenderEngine *renderEngine;

@property (nonatomic, retain, readonly) WMGameObject *rootObject;
@property (nonatomic, retain, readonly) WMScriptingContext *scriptingContext;
@property (nonatomic, retain, readonly) WMDebugChannel *debugChannel;

- (WMGameObject *)createObject;
- (void)deleteObject:(WMGameObject *)inObject;

- (WMGameObject *)objectWithId:(UInt64)gameObjectId;

- (void)start;

@end
