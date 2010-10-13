//
//  WMScriptingContext.h
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/12/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "lua.h"

@class WMEngine;

@interface WMScriptingContext : NSObject {
	WMEngine *engine;

	lua_State *lua;
}

- (id)initWithEngine:(WMEngine *)inEngine;

- (void)doScript:(NSString *)inScript;

@end
