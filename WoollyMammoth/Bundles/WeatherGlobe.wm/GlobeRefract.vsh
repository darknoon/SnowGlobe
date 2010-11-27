//
//  Shader.vsh
//  CaptureTest
//
//  Created by Andrew Pouliot on 8/12/10.
//  Copyright Darknoon 2010. All rights reserved.
//

attribute vec4 position;
attribute vec2 textureCoordinate;

uniform mat4 modelViewProjectionMatrix;

varying highp vec2 v_textureCoordinate;

void main()
{
    gl_Position = modelViewProjectionMatrix * position;
	v_textureCoordinate = textureCoordinate - vec2(0.5);
}
