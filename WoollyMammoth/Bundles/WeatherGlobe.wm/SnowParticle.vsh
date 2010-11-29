//
//  Shader.vsh
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 9/27/10.
//  Copyright Darknoon 2010. All rights reserved.
//

attribute vec4 position;
attribute vec4 color;

uniform mat4 modelViewProjectionMatrix;

varying lowp vec4 v_color;

void main()
{
	gl_PointSize = 8.0;
    gl_Position = modelViewProjectionMatrix * position;
	v_color	= color;
}
