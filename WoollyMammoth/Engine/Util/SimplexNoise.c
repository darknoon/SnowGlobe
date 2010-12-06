/*
 *  SimplexNoise.c
 *  ImageBlur
 *
 *  Created by Andrew Pouliot on 12/20/08.
 *  Copyright 2008 Darknoon. All rights reserved.
 *
 */

#include "SimplexNoise.h"
#include "math.h"
#include "unistd.h"

#include "stdio.h"

int p[] = {151,160,137,91,90,15, 
131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23, 
190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33, 
88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166, 
77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244, 
102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196, 
135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123, 
5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42, 
223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9, 
129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228, 
251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107, 
49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254, 
138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180}; 

int grad3[][3] = {{1,1,0},{-1,1,0},{1,-1,0},{-1,-1,0}, 
{1,0,1},{-1,0,1},{1,0,-1},{-1,0,-1}, 
{0,1,1},{0,-1,1},{0,1,-1},{0,-1,-1}}; 

// To remove the need for index wrapping, double the permutation table length 
int perm[512]; 

int fastfloor(SNFloat x) { 
    return x>0 ? (int)x : (int)x-1; 
} 

SNFloat dot2(int g[], SNFloat x, SNFloat y) { 
    return g[0]*x + g[1]*y; 
} 

SNFloat dot3(int g[], SNFloat x, SNFloat y, SNFloat z) { 
    return g[0]*x + g[1]*y + g[2]*z;
} 

void _initNoiseIfNecessary() {
	static int noiseInitted;
	if (noiseInitted == 0) {
		noiseInitted = 2;
		for(int i=0; i<512; i++) perm[i]=p[i & 255];
		noiseInitted = 1;
	} else if (noiseInitted == 2) {//Spinlock
		while (noiseInitted != 1) {
			usleep(1000);
		}
	}
}

// 2D simplex noise 
SNFloat simplexNoise2(SNFloat xin, SNFloat yin) { 
	_initNoiseIfNecessary();
    
	SNFloat n0, n1, n2; // Noise contributions from the three corners 
    // Skew the input space to determine which simplex cell we're in 
    const SNFloat F2 = 0.5*(sqrt(3.0)-1.0); 
    SNFloat s = (xin+yin)*F2; // Hairy factor for 2D 
    int i = fastfloor(xin+s); 
    int j = fastfloor(yin+s); 
    const SNFloat G2 = (3.0-sqrt(3.0))/6.0; 
    SNFloat t = (i+j)*G2; 
    SNFloat X0 = i-t; // Unskew the cell origin back to (x,y) space 
    SNFloat Y0 = j-t; 
    SNFloat x0 = xin-X0; // The x,y distances from the cell origin 
    SNFloat y0 = yin-Y0; 
    // For the 2D case, the simplex shape is an equilateral triangle. 
    // Determine which simplex we are in. 
    int i1, j1; // Offsets for second (middle) corner of simplex in (i,j) coords 
    if(x0>y0) {i1=1; j1=0;} // lower triangle, XY order: (0,0)->(1,0)->(1,1) 
    else {i1=0; j1=1;}      // upper triangle, YX order: (0,0)->(0,1)->(1,1) 
    // A step of (1,0) in (i,j) means a step of (1-c,-c) in (x,y), and 
    // a step of (0,1) in (i,j) means a step of (-c,1-c) in (x,y), where 
    // c = (3-sqrt(3))/6 
    SNFloat x1 = x0 - i1 + G2; // Offsets for middle corner in (x,y) unskewed coords 
    SNFloat y1 = y0 - j1 + G2; 
    SNFloat x2 = x0 - 1.0 + 2.0 * G2; // Offsets for last corner in (x,y) unskewed coords 
    SNFloat y2 = y0 - 1.0 + 2.0 * G2; 
    // Work out the hashed gradient indices of the three simplex corners 
    int ii = i & 255; 
    int jj = j & 255; 
    int gi0 = perm[ii+perm[jj]] % 12; 
    int gi1 = perm[ii+i1+perm[jj+j1]] % 12; 
    int gi2 = perm[ii+1+perm[jj+1]] % 12; 
    // Calculate the contribution from the three corners 
    SNFloat t0 = 0.5 - x0*x0-y0*y0; 
    if(t0<0) n0 = 0.0; 
    else { 
		t0 *= t0; 
		n0 = t0 * t0 * dot2(grad3[gi0], x0, y0);  // (x,y) of grad3 used for 2D gradient 
    } 
    SNFloat t1 = 0.5 - x1*x1-y1*y1; 
    if(t1<0) n1 = 0.0; 
    else { 
		t1 *= t1; 
		n1 = t1 * t1 * dot2(grad3[gi1], x1, y1); 
    }
    SNFloat t2 = 0.5 - x2*x2-y2*y2; 
    if(t2<0) n2 = 0.0; 
    else { 
		t2 *= t2; 
		n2 = t2 * t2 * dot2(grad3[gi2], x2, y2); 
    } 
    // Add contributions from each corner to get the final noise value. 
    // The result is scaled to return values in the interval [-1,1]. 
    return 70.0 * (n0 + n1 + n2); 
} 


// 3D simplex noise 
SNFloat simplexNoise3(SNFloat xin, SNFloat yin, SNFloat zin) { 
	_initNoiseIfNecessary();
	
    SNFloat n0, n1, n2, n3; // Noise contributions from the four corners 
    // Skew the input space to determine which simplex cell we're in 
    const SNFloat F3 = 1.0/3.0; 
    SNFloat s = (xin+yin+zin)*F3; // Very nice and simple skew factor for 3D 
    int i = fastfloor(xin+s); 
    int j = fastfloor(yin+s); 
    int k = fastfloor(zin+s); 
    const SNFloat G3 = 1.0/6.0; // Very nice and simple unskew factor, too 
    SNFloat t = (i+j+k)*G3; 
    SNFloat X0 = i-t; // Unskew the cell origin back to (x,y,z) space 
    SNFloat Y0 = j-t; 
    SNFloat Z0 = k-t; 
    SNFloat x0 = xin-X0; // The x,y,z distances from the cell origin 
    SNFloat y0 = yin-Y0; 
    SNFloat z0 = zin-Z0; 
    // For the 3D case, the simplex shape is a slightly irregular tetrahedron. 
    // Determine which simplex we are in. 
    int i1, j1, k1; // Offsets for second corner of simplex in (i,j,k) coords 
    int i2, j2, k2; // Offsets for third corner of simplex in (i,j,k) coords 
    if(x0>=y0) { 
		if(y0>=z0) 
        { i1=1; j1=0; k1=0; i2=1; j2=1; k2=0; } // X Y Z order 
        else if(x0>=z0) { i1=1; j1=0; k1=0; i2=1; j2=0; k2=1; } // X Z Y order 
        else { i1=0; j1=0; k1=1; i2=1; j2=0; k2=1; } // Z X Y order 
	} 
    else { // x0<y0 
		if(y0<z0) { i1=0; j1=0; k1=1; i2=0; j2=1; k2=1; } // Z Y X order 
		else if(x0<z0) { i1=0; j1=1; k1=0; i2=0; j2=1; k2=1; } // Y Z X order 
		else { i1=0; j1=1; k1=0; i2=1; j2=1; k2=0; } // Y X Z order 
    } 
    // A step of (1,0,0) in (i,j,k) means a step of (1-c,-c,-c) in (x,y,z), 
    // a step of (0,1,0) in (i,j,k) means a step of (-c,1-c,-c) in (x,y,z), and 
    // a step of (0,0,1) in (i,j,k) means a step of (-c,-c,1-c) in (x,y,z), where 
    // c = 1/6.
    SNFloat x1 = x0 - i1 + G3; // Offsets for second corner in (x,y,z) coords 
    SNFloat y1 = y0 - j1 + G3; 
    SNFloat z1 = z0 - k1 + G3; 
    SNFloat x2 = x0 - i2 + 2.0*G3; // Offsets for third corner in (x,y,z) coords 
    SNFloat y2 = y0 - j2 + 2.0*G3; 
    SNFloat z2 = z0 - k2 + 2.0*G3; 
    SNFloat x3 = x0 - 1.0 + 3.0*G3; // Offsets for last corner in (x,y,z) coords 
    SNFloat y3 = y0 - 1.0 + 3.0*G3; 
    SNFloat z3 = z0 - 1.0 + 3.0*G3; 
    // Work out the hashed gradient indices of the four simplex corners 
    int ii = i & 255; 
    int jj = j & 255; 
    int kk = k & 255; 
    int gi0 = perm[ii+perm[jj+perm[kk]]] % 12; 
    int gi1 = perm[ii+i1+perm[jj+j1+perm[kk+k1]]] % 12; 
    int gi2 = perm[ii+i2+perm[jj+j2+perm[kk+k2]]] % 12; 
    int gi3 = perm[ii+1+perm[jj+1+perm[kk+1]]] % 12; 
    // Calculate the contribution from the four corners 
    SNFloat t0 = 0.6 - x0*x0 - y0*y0 - z0*z0; 
    if(t0<0) n0 = 0.0; 
    else { 
		t0 *= t0; 
		n0 = t0 * t0 * dot3(grad3[gi0], x0, y0, z0); 
    } 
    SNFloat t1 = 0.6 - x1*x1 - y1*y1 - z1*z1; 
    if(t1<0) n1 = 0.0; 
    else { 
		t1 *= t1; 
		n1 = t1 * t1 * dot3(grad3[gi1], x1, y1, z1); 
    } 
    SNFloat t2 = 0.6 - x2*x2 - y2*y2 - z2*z2; 
    if(t2<0) n2 = 0.0; 
    else { 
		t2 *= t2; 
		n2 = t2 * t2 * dot3(grad3[gi2], x2, y2, z2); 
    } 
    SNFloat t3 = 0.6 - x3*x3 - y3*y3 - z3*z3; 
    if(t3<0) n3 = 0.0; 
    else { 
		t3 *= t3; 
		n3 = t3 * t3 * dot3(grad3[gi3], x3, y3, z3); 
    } 
    // Add contributions from each corner to get the final noise value. 
    // The result is scaled to stay just inside [-1,1] 
    return 32.0*(n0 + n1 + n2 + n3); 
}



//Perlin Noise

//TODO: implement algorithm from
//http://iquilezles.org/www/articles/morenoise/morenoise.htm
void iGetIntegerAndFractional(float a, int *i, float *f) {
	//Naive. Improve.
	*i = (int)a;
	*f = a - (int)a;
}

float sfrand(int *seed )
{
    seed[0] = 0x00269ec3 + seed[0]*0x000343fd;
    int a = (seed[0]>>16) & 32767;
    return( -1.0f + (2.0f/32767.0f)*(float)a );
}

float myRandomMagic(int x, int y, int z) {
	int permuted = perm[perm[x & 255] + (y & 255)] + z;
	//printf("%d %d %d porm: %d", x, y, z, permuted);
	return permuted & 1 ? -1.0f : 1.0f;
}

void dnoise3f( float *vout, const float x, const float y, const float z) {
	_initNoiseIfNecessary();
    int   i, j, k;
    float u, v, w;
	
    iGetIntegerAndFractional( x, &i, &u );
    iGetIntegerAndFractional( y, &j, &v );
    iGetIntegerAndFractional( z, &k, &w );
	
    const float du = 30.0f*u*u*(u*(u-2.0f)+1.0f);
    const float dv = 30.0f*v*v*(v*(v-2.0f)+1.0f);
    const float dw = 30.0f*w*w*(w*(w-2.0f)+1.0f);
	
    u = u*u*u*(u*(u*6.0f-15.0f)+10.0f);
    v = v*v*v*(v*(v*6.0f-15.0f)+10.0f);
    w = w*w*w*(w*(w*6.0f-15.0f)+10.0f);
	
    const float a = myRandomMagic( i+0, j+0, k+0 );
    const float b = myRandomMagic( i+1, j+0, k+0 );
    const float c = myRandomMagic( i+0, j+1, k+0 );
    const float d = myRandomMagic( i+1, j+1, k+0 );
    const float e = myRandomMagic( i+0, j+0, k+1 );
    const float f = myRandomMagic( i+1, j+0, k+1 );
    const float g = myRandomMagic( i+0, j+1, k+1 );
    const float h = myRandomMagic( i+1, j+1, k+1 );
	
    const float k0 =   a;
    const float k1 =   b - a;
    const float k2 =   c - a;
    const float k3 =   e - a;
    const float k4 =   a - b - c + d;
    const float k5 =   a - c - e + g;
    const float k6 =   a - b - e + f;
    const float k7 = - a + b + c - d + e - f - g + h;
	
    vout[0] = k0 + k1*u + k2*v + k3*w + k4*u*v + k5*v*w + k6*w*u + k7*u*v*w;
    vout[1] = du * (k1 + k4*v + k6*w + k7*v*w);
    vout[2] = dv * (k2 + k5*w + k4*u + k7*w*u);
    vout[3] = dw * (k3 + k6*u + k5*v + k7*u*v);
}
