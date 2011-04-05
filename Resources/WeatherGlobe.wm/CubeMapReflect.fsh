//
//  Shader.fsh
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 9/27/10.
//  Copyright Darknoon 2010. All rights reserved.
//

uniform samplerCube texture;

varying mediump vec3 v_tc;
varying mediump float v_factor;

void main()
{
    gl_FragColor = v_factor * textureCube(texture, v_tc);
}
