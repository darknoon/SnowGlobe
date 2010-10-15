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


varying vec4 colorVarying;

void main()
{
    gl_Position = position * modelViewProjectionMatrix;

    colorVarying = color;
}
