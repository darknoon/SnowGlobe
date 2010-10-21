//
//  WMShader.h
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 10/13/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WMRenderCommon.h"

#import "WMAsset.h"
//ASSUME: This must be used in only one GL context.

@interface WMShader : WMAsset {
	//TODO: Add ES1 Pipeline features?
	
	//If rendering with ES2
	NSArray *attributeNames;
	NSArray *uniformNames;
	NSString *vertexShader;
	NSString *pixelShader;

	GLuint program;
	NSMutableDictionary *uniformLocations;
}

//Set these
@property (nonatomic, copy) NSArray *uniformNames;
@property (nonatomic, copy) NSArray *attributeNames;
@property (nonatomic, copy) NSString *vertexShader;
@property (nonatomic, copy) NSString *pixelShader;

//Then load the shaders, compile and link into a program in the current context
- (BOOL)loadShaders;

//Is this program configured correctly for drawing?
- (BOOL)validateProgram;


//Use this to draw
@property (nonatomic, readonly) GLuint program;
- (GLuint)attribIndexForName:(NSString *)inName;
- (int)uniformLocationForName:(NSString *)inName;

@end
