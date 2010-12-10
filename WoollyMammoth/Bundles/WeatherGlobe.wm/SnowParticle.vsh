//
//  Shader.vsh
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 9/27/10.
//  Copyright Darknoon 2010. All rights reserved.
//

attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord0;

uniform mat4 modelViewProjectionMatrix;

varying lowp vec4 v_color;
varying mediump vec2 v_tc;

void main()
{
    gl_Position = modelViewProjectionMatrix * position;
	v_color	= color;
	v_tc = texCoord0;
}
