//
//  DNGLState.m
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 12/8/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "DNGLState.h"
#import "WMShader.h"

@implementation DNGLState

- (void)setVertexAttributeEnableState:(unsigned int)inVertexAttributeEnableState;
{
	if (vertexAttributeEnableState == inVertexAttributeEnableState) return;
	
	for (int attribute=WMShaderAttributePosition; attribute<WMShaderAttributeCount; attribute++) {
		BOOL shouldBeEnabled = inVertexAttributeEnableState & (WMRenderableDataAvailablePosition << attribute);
		BOOL isEnabled = vertexAttributeEnableState & (WMRenderableDataAvailablePosition << attribute);
		if (shouldBeEnabled && !isEnabled) {
			glEnableVertexAttribArray(attribute);
		} else if (!shouldBeEnabled && isEnabled) {
			glDisableVertexAttribArray(attribute);
		}
	}
	vertexAttributeEnableState = inVertexAttributeEnableState;
}

- (void)setBlendState:(DNGLStateBlendMask)inBlendState;
{

}

- (NSString *)description;
{
	NSMutableString *stateDesc = [NSMutableString string];
	for (int attribute=WMShaderAttributePosition; attribute<WMShaderAttributeCount; attribute++) {
		BOOL isEnabled = vertexAttributeEnableState & (WMRenderableDataAvailablePosition << attribute);
		NSString *attributeName = [WMShader nameForShaderAttribute:attribute];
		[stateDesc appendFormat:@"\t%@ %@\n", attributeName, isEnabled ? @"enabled" : @"disabled"];
	}
	
	[stateDesc appendFormat:@"\tblending %@\n", blendState & DNGLStateBlendEnabled ?  @"enabled" : @"disabled"];
	[stateDesc appendFormat:@"\tadd mode %@\n", blendState & DNGLStateBlendModeAdd ?  @"enabled" : @"disabled"];
	
	return [[super description] stringByAppendingFormat:@"{\n%@\n}", stateDesc];
}

@end
