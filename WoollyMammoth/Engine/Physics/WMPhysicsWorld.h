//
//  WMPhysicsWorld.h
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/13/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "btBulletDynamicsCommon.h"

@interface WMPhysicsWorld : NSObject {
	btDiscreteDynamicsWorld *world;
}

@end