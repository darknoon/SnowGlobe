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
#import "WMGameObject.h"


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

static int WMScriptingContextErrorHandler(lua_State *lua) {
	if (!lua_isstring(lua, 1))  /* 'message' not a string? */
		return 1;  /* keep it intact */
	lua_getfield(lua, LUA_GLOBALSINDEX, "debug");
	if (!lua_istable(lua, -1)) {
		lua_pop(lua, 1);
		return 1;
	}
	lua_getfield(lua, -1, "traceback");
	if (!lua_isfunction(lua, -1)) {
		lua_pop(lua, 2);
		return 1;
	}
	lua_pushvalue(lua, 1);  /* pass error message */
	lua_pushinteger(lua, 2);  /* skip this function and traceback */
	lua_call(lua, 2, 1);  /* call debug.traceback */
	return 1;
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
	//TODO: convert this to use the registry instead!!
	lua_pushnumber(lua, (int)self);
	lua_setglobal(lua, "WMScriptingContext");	
	
	//Bring in our scripts
	[self importBuiltinScript:@"WMGameObject"];
	
	return self;
}

- (void)importBuiltinScript:(NSString *)resourceName;
{
	NSString *path = [[NSBundle mainBundle] pathForResource:resourceName ofType:@"lua"];
	if (!path) {
		NSLog(@"Couldn't import script %@", resourceName);
	} else {
		[self doScript:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL]];
	}
}

- (void) dealloc
{
	lua_close(lua);
	[super dealloc];
}

- (void)setObjectToGameObject:(WMGameObject *)inObject;
{
	//Table
	// gameObject = {_meta:WMGameObject, id = 123, notes = "foo bar bash"}
	
	//no array elements, 10 associative
	lua_createtable(lua, 0, 10); //This will become index -3 for the settable commands

	//Get the metatable we'll be setting from the global
	lua_getglobal(lua, "WMGameObject");
	lua_setmetatable(lua, -2);
	
	lua_pushstring(lua, "id");
	lua_pushnumber(lua, inObject.objectId);
	lua_settable(lua, -3); //set new table value to
	
	lua_pushstring(lua, "notes");
	lua_pushstring(lua, [[inObject notes] UTF8String]);
	lua_settable(lua, -3);
	
	lua_setglobal(lua, "gameObject");
}

- (NSString *)errorTypeDescription:(int)inErrType;
{
	switch (inErrType) {
		case LUA_ERRRUN:
			return @"runtime error";
		case LUA_ERRMEM:
			return @"memory error";
		case LUA_ERRSYNTAX:
			return @"syntax error";
		default:
			return @"unknown error";
			break;
	}
}

- (void)doScript:(NSString *)inScript;
{
	//Add error handler to caputure stack BT
	lua_pushcfunction(lua, WMScriptingContextErrorHandler);
	
	//Load in the script to execute
	int status = luaL_loadstring(lua, [inScript UTF8String]);
	if (status != 0) {
		const char *errString = lua_tostring(lua, -1);
		NSLog(@"lua %@: %s", [self errorTypeDescription:status], errString);
	}
	
	status = lua_pcall(lua, 0, LUA_MULTRET, -2);
	if (status != 0) {
		const char *errString = lua_tostring(lua, -1);
		NSLog(@"lua %@: %s", [self errorTypeDescription:status], errString);
	}
}

- (void)printFromScript:(NSString *)inString;
{
	NSLog(@"lua: %@", inString);
	[engine.debugChannel broadcastMessageToSockets:[inString stringByAppendingString:@"\r\n"]];
}

@end
