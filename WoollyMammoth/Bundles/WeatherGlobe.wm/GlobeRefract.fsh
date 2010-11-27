/*
A Core Image kernel routine that computes a multiply effect.
The code looks up the source pixel in the sampler and then multiplies it by the value passed to the routine.
*/

uniform sampler2D texture;

varying highp vec2 v_textureCoordinate;


highp float intersectRaySphere(const highp vec3 rayOrigin, highp vec3 rayDirection, highp vec3 sphereOrigin, highp float sphereRadiusSquared, out bool intersects) {
	highp vec3 dst = rayOrigin - sphereOrigin;
	highp float B = dot(dst, rayDirection);
	highp float C = dot(dst, dst) - sphereRadiusSquared;
	highp float D = B*B - C;
	intersects = D > 0.0;
	return D > 0.0 ? -B - sqrt(D) : 0.0;
}

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

/*
Uniforms:
sampler image, 

TODO:
float r;
float sphereDistance,
float mat_index;

*/

void main()
{

	const highp float r = 3.0;
	const highp float sphereDistance = 7.0;
	const highp float mat_index = 2.0;

	highp vec3 inc = normalize( vec3(v_textureCoordinate, 1.0) );
	
	const highp vec3 sphereOrigin = vec3(0, 0, 0);
	const highp vec3 cameraPosition = vec3(0, 0, -sphereDistance);
			
	bool intersects;
	highp float t = intersectRaySphere(cameraPosition, inc, sphereOrigin, r*r, intersects);
	highp vec3 sphereEnterPoint = cameraPosition + t * inc;
	highp vec3 enterNormal = normalize(sphereEnterPoint - sphereOrigin);
	
	//return intersects ? vec4(normal.x, normal.y, normal.z, 1.0) : vec4(0.0);
	
	highp vec3 reflected;
	highp vec3 refracted;
	highp float transmittance;
	highp float reflectance;
	myRefract(inc, enterNormal, 1.0, mat_index, reflected, refracted, reflectance, transmittance);
	
	//Intersect backside
	
	bool alwaysTrue;
	highp float t2 = intersectRaySphere(sphereEnterPoint, refracted, sphereOrigin, r*r, alwaysTrue);
	highp vec3 sphereExitPoint = sphereEnterPoint + t2 * refracted;
	highp vec3 exitNormal = normalize(sphereExitPoint - sphereOrigin);
	
	highp vec3 final;
	myRefract(refracted, exitNormal, 1.0, mat_index, reflected, final, reflectance, transmittance);
	
	
	//return intersects ? vec4(sphereExitPoint.x, sphereExitPoint.y, -sphereExitPoint.z, 1.0) : vec4(0.0);
	//return intersects ? vec4(refracted.x, refracted.y, refracted.z, 1.0) : vec4(0.0);
		
	gl_FragColor = intersects ? texture2D(texture, final.xy + vec2(0.5)) : vec4(0.0, 0.0, 0.0, 1.0);
}
