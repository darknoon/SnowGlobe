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

@interface WMEngine : NSObject {
	UInt64 maxObjectId;
	WMScriptingContext *scriptingContext;
	WMDebugChannel *debugChannel;
	NSMutableDictionary *objectsById;
	WMGameObject *rootObject;
}

@property (nonatomic, retain) WMGameObject *rootObject;
@property (nonatomic, readonly) WMScriptingContext *scriptingContext;
@property (nonatomic, readonly) WMDebugChannel *debugChannel;

- (WMGameObject *)createObject;
- (void)deleteObject:(WMGameObject *)inObject;

- (WMGameObject *)objectWithId:(UInt64)gameObjectId;

- (void)start;

@end
