//
//  WMGameObject.h
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/12/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

//TODO: copying
//TODO: equality, hash

@class WMEngine;

@interface WMGameObject : NSObject {
@protected
	UInt64 objectId;
	
	//Weak
	WMGameObject *parent;
	WMEngine *engine;
	
	//Strong
	NSMutableArray *mutableChildren;
	//For debugging purposes
	NSString *notes;
}

@property (nonatomic, copy) NSString *notes;
@property (nonatomic, assign) WMGameObject *parent;
@property (nonatomic, readonly) UInt64 objectId;
@property (nonatomic, readonly) NSArray *children;

- (id)initWithObjectId:(UInt64)inObjectId inEngine:(WMEngine *)inEngine;

- (NSString *)descriptionRecursive;

- (void)removeFromParent;
- (void)addChild:(WMGameObject *)inChild;
- (void)removeChild:(WMGameObject *)inChild;

@end
