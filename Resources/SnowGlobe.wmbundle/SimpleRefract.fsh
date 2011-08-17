//
//  Shader.fsh
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 9/27/10.
//  Copyright Darknoon 2010. All rights reserved.
//

uniform sampler2D texture;

varying mediump vec2 v_tc;

void main()
{
    gl_FragColor = 0.8 * texture2D(texture, v_tc);
}
