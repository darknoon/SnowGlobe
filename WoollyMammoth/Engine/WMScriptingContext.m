//
//  WMScriptingContext.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/12/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMScriptingContext.h"

#import "WMEngine.h"
#import "WMDebugChannel.h"

#import "lualib.h"
#import "lauxlib.h"

@interface WMScriptingContext ()
- (void)printFromScript:(NSString *)inString;
@end


static int WMScriptingContextPrint(lua_State *lua) {
	//Get a pointer back to our object
	lua_getglobal(lua, "WMScriptingContext");
	int contextPtr = 0;
	lua_number2int(contextPtr, lua_tonumber(lua, -1));
	lua_pop(lua, 1);
	
	id self = (id)contextPtr;
	NSMutableString *printString = [NSMutableString string];
	
	int n = lua_gettop(lua);  /* number of arguments */
	int i;
	lua_getglobal(lua, "tostring");
	for (i=1; i<=n; i++) {
		const char *s;
		lua_pushvalue(lua, -1);  /* function to be called */
		lua_pushvalue(lua, i);   /* value to print */
		lua_call(lua, 1, 1);
		s = lua_tostring(lua, -1);  /* get result */
		if (s == NULL)
			return luaL_error(lua, LUA_QL("tostring") " must return a string to "
							  LUA_QL("print"));
		[printString appendFormat: i > 1 ? @"\t%s" : @"%s", s];
		lua_pop(lua, 1);  /* pop result */
	}
	[self printFromScript:printString];
	return 0;
}

@implementation WMScriptingContext

- (id)initWithEngine:(WMEngine *)inEngine;
{
	self = [self init];
	if (self == nil) return self; 
	
	engine = inEngine;
	
	lua = lua_open();	
	luaL_openlibs(lua);
	
	//Set up our callback functions
	lua_register(lua, "print", WMScriptingContextPrint);

	//Set ourselves as a global
	lua_pushnumber(lua, (int)self);
	lua_setglobal(lua, "WMScriptingContext");	
		
	return self;
}

- (void) dealloc
{
	lua_close(lua);
	[super dealloc];
}


- (void)doScript:(NSString *)inScript;
{
	luaL_loadstring(lua, [inScript UTF8String]);
	lua_pcall(lua, 0, 0, 0);
}

- (void)printFromScript:(NSString *)inString;
{
	NSLog(@"lua: %@", inString);
	[engine.debugChannel broadcastMessageToSockets:[inString stringByAppendingString:@"\r\n"]];
}

@end
