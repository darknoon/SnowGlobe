//
//  WMShader.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/13/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMShader.h"


@implementation WMShader

@synthesize uniformNames;
@synthesize attributeNames;
@synthesize vertexShader;
@synthesize pixelShader;
@synthesize program;

- (id)initWithResourceName:(NSString *)inResourceName properties:(NSDictionary *)inProperties;
{
	self = [super initWithResourceName:inResourceName properties:inProperties];
	if (self == nil) return self; 
	
	uniformLocations = [[NSMutableDictionary alloc] init];

	self.attributeNames = [inProperties objectForKey:@"attributeNames"];
	self.uniformNames = [inProperties objectForKey:@"uniformNames"];
	
	return self;
}


- (void)dealloc
{
	[vertexShader release];
	[pixelShader release];
	[uniformNames release];
	[uniformLocations release];
	[attributeNames release];

	if (program)
    {
        glDeleteProgram(program);
        program = 0;
    }

	[super dealloc];
}

- (BOOL)loadWithBundle:(NSBundle *)inBundle error:(NSError **)outError;
{
	if ([EAGLContext currentContext].API == kEAGLRenderingAPIOpenGLES2) {		
		NSString *vertexShaderPath = [[[inBundle bundlePath] stringByAppendingPathComponent:resourceName] stringByAppendingPathExtension:@"vsh"];
		NSString *fragmentShaderPath = [[[inBundle bundlePath] stringByAppendingPathComponent:resourceName] stringByAppendingPathExtension:@"fsh"];
		
		self.vertexShader = [NSString stringWithContentsOfFile:vertexShaderPath encoding:NSUTF8StringEncoding error:outError];
		if (!vertexShader) return NO;
		self.pixelShader = [NSString stringWithContentsOfFile:fragmentShaderPath encoding:NSUTF8StringEncoding error:outError];
		if (!pixelShader) return NO;
		
		isLoaded = [self loadShaders];
		return isLoaded;
	} else {
		//TODO: OpenGL ES 1.0 support?
		return YES;
	}

}

- (void)setVertexShader:(NSString *)inVertexShader;
{
	if (vertexShader == inVertexShader) return;
	[vertexShader release];
	
	vertexShader = [inVertexShader copy];
}


- (void)setPixelShader:(NSString *)inPixelShader;
{
	if (pixelShader == inPixelShader) return;
	[pixelShader release];
	
	pixelShader = [inPixelShader copy];
}

- (int)uniformLocationForName:(NSString *)inName;
{
	NSNumber *unifiormLocationValue = [uniformLocations objectForKey:inName];
	if (!unifiormLocationValue) {
		NSLog(@"Attempt to get uniform location for \"%@\", which was not specified in the shader.", inName);
		//TODO: is this a good error value?
		return -1;
	}
	return [unifiormLocationValue intValue];
}


- (GLuint)attribIndexForName:(NSString *)inName;
{
	GLuint attribIndex = [attributeNames indexOfObject:inName];
	if (attribIndex == NSNotFound) {
		NSLog(@"Attempt to get attribute index for \"%@\", which was not specified in the shader.", inName);
	}
	return attribIndex;
}

- (BOOL)compileShaderSource:(NSString *)inSourceString toShader:(GLuint *)shader type:(GLenum)type;
{
    GLint status;
    const GLchar *source = [inSourceString UTF8String];
        
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    
    glLinkProgram(prog);

    //TODO: use unified DEBUG macro
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

- (BOOL)validateProgram;
{
    GLint logLength, status;
    
    glValidateProgram(program);
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(program, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

- (BOOL)loadShaders;
{
	GLuint vertShader, fragShader;
	
	// Create shader program.
	program = glCreateProgram();
	
	// Create and compile vertex shader.
	if (![self compileShaderSource:vertexShader toShader:&vertShader type:GL_VERTEX_SHADER])
	{
		NSLog(@"Failed to compile vertex shader");
		return NO;
	}	
	// Create and compile fragment shader.
	if (![self compileShaderSource:pixelShader toShader:&fragShader type:GL_FRAGMENT_SHADER]) {
		NSLog(@"Failed to compile fragment shader");
		return NO;
	}
	
	// Attach vertex shader to program.
	glAttachShader(program, vertShader);
	
	// Attach fragment shader to program.
	glAttachShader(program, fragShader);
	
	// Bind attribute locations.
	// This needs to be done prior to linking.
	GLuint attribIndex = 0;
	for (NSString *attribName in attributeNames) {
		glBindAttribLocation(program, attribIndex, [attribName UTF8String]);
		attribIndex++;
	}
		
	// Link program.
	if (![self linkProgram:program])
	{
		NSLog(@"Failed to link program: %d", program);
		
		if (vertShader) {
			glDeleteShader(vertShader);
			vertShader = 0;
		}
		if (fragShader) {
			glDeleteShader(fragShader);
			fragShader = 0;
		}
		if (program) {
			glDeleteProgram(program);
			program = 0;
		}
		
		return NO;
	}
	
	//Get uniform locations
	for (NSString *uniformName in uniformNames) {
		int uniformLocation = glGetUniformLocation(program, [uniformName UTF8String]);
		[uniformLocations setObject:[NSNumber numberWithInt:uniformLocation] forKey:uniformName];
	}	
		
	// Release vertex and fragment shaders.
	if (vertShader)
		glDeleteShader(vertShader);
	if (fragShader)
		glDeleteShader(fragShader);
	
	return YES;
}


@end
