//
//  Shader.vsh
//  WoollyMammoth
//
//  Created by Andrew Pouliot on 9/27/10.
//  Copyright Darknoon 2010. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;

uniform mat4 modelViewProjectionMatrix;

varying mediump vec3 v_normal;
varying mediump vec2 v_tc;

void myRefract(in highp vec3 incom, in highp vec3 normal, 
               in highp float index_external, 
               in highp float index_internal,
               out highp vec3 reflection,
               out highp vec3 refraction,
               out highp float reflectance, 
               out highp float transmittance) {
				
  highp float eta = index_external/index_internal;
  highp float cos_theta1 = dot(-incom, normal);
  highp float cos_theta2 = sqrt(1.0 - ((eta * eta) * ( 1.0 - (cos_theta1 * cos_theta1))));
  reflection = incom - 2.0 * cos_theta1 * normal;
  refraction = (eta * incom) + (cos_theta2 - eta * cos_theta1) * normal;

  highp float fresnel_rs = (index_external * cos_theta1 
                        - index_internal * cos_theta2 ) /
                     (index_external * cos_theta1 
                        + index_internal * cos_theta2);

  highp float fresnel_rp = (index_internal * cos_theta1 
                        - index_external * cos_theta2 ) /
                     (index_internal * cos_theta1 
                        + index_external * cos_theta2);

  reflectance = (fresnel_rs * fresnel_rs 
               + fresnel_rp * fresnel_rp) / 2.0;
  transmittance = ((1.0-fresnel_rs) * (1.0-fresnel_rs) 
                 + (1.0-fresnel_rp) * (1.0-fresnel_rp)) / 2.0;
}


void main()
{
	gl_Position = modelViewProjectionMatrix * position;

	mediump vec3 incoming = normalize(position.xyz - vec3(0.0, 0.0, 3.0));	
	mediump vec3 reflectionVector;
	mediump vec3 refractionVector;
	mediump float reflectance;
	mediump float transmittance;
	
	myRefract(incoming, normal,
	          1.0, 1.3,
			  reflectionVector,
			  refractionVector,
			  reflectance,
			  transmittance);
	
	v_normal = normal;
	//Need to flip the tc for some reason
	v_tc = reflectionVector.yx;
}
