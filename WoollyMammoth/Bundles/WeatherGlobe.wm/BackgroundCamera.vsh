//
//  Shader.vsh
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 9/27/10.
//  Copyright Darknoon 2010. All rights reserved.
//

attribute vec4 position;
attribute vec2 texCoord0;

uniform mat4 modelViewProjectionMatrix;

varying highp vec2 v_textureCoordinate;

void main()
{
    gl_Position = modelViewProjectionMatrix * position;
	v_textureCoordinate = vec2(1.0) - texCoord0.yx;
}
