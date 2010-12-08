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

void main()
{
	gl_Position = modelViewProjectionMatrix * position;

	//Need to flip the tc for some reason
	v_tc = normal;
}
