//
//  Shader.fsh
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 9/27/10.
//  Copyright Darknoon 2010. All rights reserved.
//

uniform samplerCube texture;

varying mediump vec3 v_tc;

void main()
{
	mediump float factor = 0.8 * (1.0 - abs(v_tc.z));
    gl_FragColor = factor * textureCube(texture, v_tc);
}
