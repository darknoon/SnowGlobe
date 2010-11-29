//
//  Shader.fsh
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 9/27/10.
//  Copyright Darknoon 2010. All rights reserved.
//

uniform sampler2D texture;

varying lowp vec4 v_color;

void main()
{
	gl_FragColor = texture2D(texture, gl_PointCoord) * v_color;
	//gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
