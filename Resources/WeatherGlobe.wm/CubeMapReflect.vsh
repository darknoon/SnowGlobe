//
//  Shader.vsh
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 9/27/10.
//  Copyright Darknoon 2010. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;

uniform mat4 modelViewProjectionMatrix;

varying mediump vec3 v_tc;
varying mediump float v_factor;

void main()
{
	gl_Position = modelViewProjectionMatrix * position;
	v_tc = normal;
	v_factor = 0.8 * (1.0 - abs(normal.z));
}
