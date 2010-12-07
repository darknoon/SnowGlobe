//
//  Shader.fsh
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 9/27/10.
//  Copyright Darknoon 2010. All rights reserved.
//

uniform sampler2D texture;

varying mediump vec3 v_normal;
varying mediump vec2 v_tc;

void main()
{
	mediump vec2 outTC = 0.5 * v_tc.xy + vec2(0.5);

    gl_FragColor = texture2D(texture, outTC);
}
