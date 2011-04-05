//
//  Shader.fsh
//  CaptureTest
//
//  Created by Andrew Pouliot on 8/12/10.
//  Copyright Darknoon 2010. All rights reserved.
//

uniform sampler2D texture;

varying highp vec2 v_textureCoordinate;

void main()
{
	highp float h = v_textureCoordinate.y;
	h = 6.0 *h*h*h*h*h - 15.0*h*h*h*h + 10.0*h*h*h;
    gl_FragColor = texture2D(texture, vec2(v_textureCoordinate.x, h));
}