//
//  Simplex.metal
//  AHNoise
//
//  Created by Andrew Heard on 23/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//

#include <metal_stdlib>
#include <metal_math>
using namespace metal;

// MARK:- Raw simplex functions




// Skewing and unskewing factors for 3/4D
static constant float F3 = 1.0/3.0;
static constant float G3 = 1.0/6.0;
static constant float F4 = 0.3090169944;
static constant float G4 = 0.1381966011;

// 3D Simplex Noise
float simplex3D(float xin, float yin, float zin, constant float3 *grad3, constant int *perm, constant int *permMod12);
float simplex3D(float xin, float yin, float zin, constant float3 *grad3, constant int *perm, constant int *permMod12)
{
  float3 pos = float3(xin,yin,zin);
  float s = (pos.x+pos.y+pos.z)*F3;
  
  // Noise contribution from the four corners
  float n0; float n1; float n2; float n3;
  
  // Skew the input space to determine which simplex cell we're in
  int i = floor(pos.x+s);
  int j = floor(pos.y+s);
  int k = floor(pos.z+s);
  float t = (i+j+k)*G3;
  
  // Unskew the cell origin back to x,y,z space
  float X0 = i-t;
  float Y0 = j-t;
  float Z0 = k-t;
  
  // The x,y,z distance from the cell origin
  float x0 = pos.x - X0;
  float y0 = pos.y - Y0;
  float z0 = pos.z - Z0;
  
  // For the 3D case the simplex shape is a slightly irregular tetrahedron.
  // Determine which simplex we are in.
  int i1 = 0; int j1 = 0; int k1 = 0;
  int i2 = 0; int j2 = 0; int k2 = 0;
  
  if (x0>=y0){
    if (y0>=z0){
      i1 = 1; i2 = 1; j2 = 1;		// X Y Z order
    }else if (x0>=z0){
      i1=1; i2=1; k2=1;		// X Z Y order
    }else{
      k1=1; i2=1; k2=1;		// Z X Y order
    }
  }else{	// x0<y0
    if (y0<z0){
      k1=1; j2=1; k2=1;		// Z Y X order
    }else if (x0<z0){
      j1=1; j2=1; k2=1;		// Y Z X order
    }else{
      j1=1; i2=1; j2=1;		// Y X Z order
    }
  }
  
  // A step of (1,0,0) in (i,j,k) means a step of (1-c,-c,-c) in (x,y,z),
  // a step of (0,1,0) in (i,j,k) means a step of (-c,1-c,-c) in (x,y,z), and
  // a step of (0,0,1) in (i,j,k) means a step of (-c,-c,1-c) in (x,y,z), where
  // c = 1/6.
  
  // Offsets for second corner in (x,y,z) coords
  float x1 = x0 - i1 + G3;
  float y1 = y0 - j1 + G3;
  float z1 = z0 - k1 + G3;
  
  // Offsets for third corner in (x,y,z) coords
  float x2 = x0 - i2 + 2.0*G3;
  float y2 = y0 - j2 + 2.0*G3;
  float z2 = z0 - k2 + 2.0*G3;
  
  // Offsets for last corner in (x,y,z) coords
  float x3 = x0 - 1.0 + 3.0*G3;
  float y3 = y0 - 1.0 + 3.0*G3;
  float z3 = z0 - 1.0 + 3.0*G3;
  
  // Work out the hashed gradient indices of the four simplex corners
  int ii = i & 255;
  int jj = j & 255;
  int kk = k & 255;
  int gi0 = permMod12[ii+perm[jj+perm[kk]]];
  int gi1 = permMod12[ii+i1+perm[jj+j1+perm[kk+k1]]];
  int gi2 = permMod12[ii+i2+perm[jj+j2+perm[kk+k2]]];
  int gi3 = permMod12[ii+1+perm[jj+1+perm[kk+1]]];
  
  // Calculate the contribution from the four corners
  float t0 = 0.6 - x0*x0 - y0*y0 - z0*z0;
  if (t0<0){
    n0 = 0.0;
  }else{
    t0 *= t0;
    n0 = t0 * t0 * dot(grad3[gi0],float3(x0, y0, z0));
  }
  float t1 = 0.6 - x1*x1 - y1*y1 - z1*z1;
  if (t1<0){
    n1 = 0.0;
  }else{
    t1 *= t1;
    n1 = t1 * t1 * dot(grad3[gi1],float3(x1, y1, z1));
  }
  float t2 = 0.6 - x2*x2 - y2*y2 - z2*z2;
  if (t2<0){
    n2 = 0.0;
  }else{
    t2 *= t2;
    n2 = t2 * t2 * dot(grad3[gi2],float3(x2, y2, z2));
  }
  float t3 = 0.6 - x3*x3 - y3*y3 - z3*z3;
  if (t3<0){
    n3 = 0.0;
  }else{
    t3 *= t3;
    n3 = t3 * t3 * dot(grad3[gi3],float3(x3, y3, z3));
  }
  
  // Add contributions from each corner to get the final noise value.
  // The result is scaled to stay just inside the range -1,1
  return 32.0*(n0 + n1 + n2 + n3);
}

// 4D Simplex Noise
float simplex4D(float xin, float yin, float zin, float win, constant float4 *grad4, constant int *perm, constant int *permMod12);
float simplex4D(float xin, float yin, float zin, float win, constant float4 *grad4, constant int *perm, constant int *permMod12)
{
  float4 pos = float4(xin,yin,zin,win);
  
  // Noise contribution from the four corners
  float n0; float n1; float n2; float n3; float n4;
  
  // Factor for 4D skewing
  float s = (pos.x+pos.y+pos.z+pos.w)*F4;
  
  // Skew the (x,y,z,w) space to determine which cell of 24 simplices we are in
  int i = floor(pos.x+s);
  int j = floor(pos.y+s);
  int k = floor(pos.z+s);
  int l = floor(pos.w+s);
  float t = (i+j+k+l)*G4;
  
  // Unskew the cell origin back to x,y,z,w space
  float X0 = i-t;
  float Y0 = j-t;
  float Z0 = k-t;
  float W0 = l-t;
  
  // The x,y,z,w distance from the cell origin
  float x0 = pos.x - X0;
  float y0 = pos.y - Y0;
  float z0 = pos.z - Z0;
  float w0 = pos.w - W0;
  
  // For the 4D case, the simplex is a 4D shape I won't even try to describe.
  // To find out which of the 24 possible simplices we're in, we need to
  // determine the magnitude ordering of x0, y0, z0 and w0.
  // Six pair-wise comparisons are performed between each possible pair
  // of the four coordinates, and the results are used to rank the numbers.
  int rankx = 0;
  int ranky = 0;
  int rankz = 0;
  int rankw = 0;
  
  if (x0>y0){rankx++;}else{ranky++;}
  if (x0>z0){rankx++;}else{rankz++;}
  if (x0>w0){rankx++;}else{rankw++;}
  if (y0>z0){ranky++;}else{rankz++;}
  if (y0>w0){ranky++;}else{rankw++;}
  if (z0>w0){rankz++;}else{rankw++;}
  
  // The integer offsets for the second simplex corner
  int i1 = 0; int j1 = 0; int k1 = 0; int l1 = 0;
  // The integer offsets for the third simplex corner
  int i2 = 0; int j2 = 0; int k2 = 0; int l2 = 0;
  // The integer offsets for the fourth simplex corner
  int i3 = 0; int j3 = 0; int k3 = 0; int l3 = 0;
  
  // simplex[c] is a 4-vector with the numbers 0, 1, 2 and 3 in some order.
  // Many values of c will never occur, since e.g. x>y>z>w makes x<z, y<w and x<w
  // impossible. Only the 24 indices which have non-zero entries make any sense.
  // We use a threshold to set the coordinates in turn from the largest magnitude.
  
  // Rank 3 denotes the largest coordinate.
  i1 = rankx >= 3 ? 1 : 0;
  j1 = ranky >= 3 ? 1 : 0;
  k1 = rankz >= 3 ? 1 : 0;
  l1 = rankw >= 3 ? 1 : 0;
  
  // Rank 2 deonted the second largest coordinate.
  i2 = rankx >= 2 ? 1 : 0;
  j2 = ranky >= 2 ? 1 : 0;
  k2 = rankz >= 2 ? 1 : 0;
  l2 = rankw >= 2 ? 1 : 0;
  
  // Rank 1 deonted the second smallest coordinate.
  i3 = rankx >= 1 ? 1 : 0;
  j3 = ranky >= 1 ? 1 : 0;
  k3 = rankz >= 1 ? 1 : 0;
  l3 = rankw >= 1 ? 1 : 0;
  
  // The fifth corner has all coordinate offsets = -1, so no need to compute it.
  
  
  // Offsets for second corner in (x,y,z,w) coords
  float x1 = x0 - i1 + G4;
  float y1 = y0 - j1 + G4;
  float z1 = z0 - k1 + G4;
  float w1 = w0 - l1 + G4;
  
  // Offsets for third corner in (x,y,z,w) coords
  float x2 = x0 - i2 + 2.0*G4;
  float y2 = y0 - j2 + 2.0*G4;
  float z2 = z0 - k2 + 2.0*G4;
  float w2 = w0 - l2 + 2.0*G4;
  
  // Offsets for fourth corner in (x,y,z,w) coords
  float x3 = x0 - i3 + 3.0*G4;
  float y3 = y0 - j3 + 3.0*G4;
  float z3 = z0 - k3 + 3.0*G4;
  float w3 = w0 - l3 + 3.0*G4;
  
  // Offsets for lastcorner in (x,y,z,w) coords
  float x4 = x0 - 1.0 + 4.0*G4;
  float y4 = y0 - 1.0 + 4.0*G4;
  float z4 = z0 - 1.0 + 4.0*G4;
  float w4 = w0 - 1.0 + 4.0*G4;
  
  // Work out the hashed gradient indices of the five simplex corners
  int ii = i & 255;
  int jj = j & 255;
  int kk = k & 255;
  int ll = l & 255;
  int gi0 = perm[ii+perm[jj+perm[kk+perm[ll]]]] % 32;
  int gi1 = perm[ii+i1+perm[jj+j1+perm[kk+k1+perm[ll+l1]]]] % 32;
  int gi2 = perm[ii+i2+perm[jj+j2+perm[kk+k2+perm[ll+l2]]]] % 32;
  int gi3 = perm[ii+i3+perm[jj+j3+perm[kk+k3+perm[ll+l3]]]] % 32;
  int gi4 = perm[ii+1+perm[jj+1+perm[kk+1+perm[ll+1]]]] % 32;
  
  // Calculate the contribution from the five corners
  float t0 = 0.6 - x0*x0 - y0*y0 - z0*z0 - w0*w0;
  if (t0<0){
    n0 = 0.0;
  }else{
    t0 *= t0;
    n0 = t0 * t0 * dot(grad4[gi0],float4(x0, y0, z0, w0));
  }
  float t1 = 0.6 - x1*x1 - y1*y1 - z1*z1 - w1*w1;
  if (t1<0){
    n1 = 0.0;
  }else{
    t1 *= t1;
    n1 = t1 * t1 * dot(grad4[gi1],float4(x1, y1, z1, w1));
  }
  float t2 = 0.6 - x2*x2 - y2*y2 - z2*z2 - w2*w2;
  if (t2<0){
    n2 = 0.0;
  }else{
    t2 *= t2;
    n2 = t2 * t2 * dot(grad4[gi2],float4(x2, y2, z2, w2));
  }
  float t3 = 0.6 - x3*x3 - y3*y3 - z3*z3 - w3*w3;
  if (t3<0){
    n3 = 0.0;
  }else{
    t3 *= t3;
    n3 = t3 * t3 * dot(grad4[gi3],float4(x3, y3, z3, w3));
  }
  float t4 = 0.6 - x4*x4 - y4*y4 - z4*z4 - w4*w4;
  if (t4<0){
    n4 = 0.0;
  }else{
    t4 *= t4;
    n4 = t4 * t4 * dot(grad4[gi4],float4(x4, y4, z4, w4));
  }
  
  // Add contributions from each corner to get the final noise value.
  // The result is scaled to stay just inside the range -1,1
  return 27.0 * (n0 + n1 + n2 + n3 + n4);
}




float grey(float4 in);
float grey(float4 in){
  return ((in.x + in.y + in.z)/3)-0.5;
}

float3 rotatePoints(float3 points, float3 angles, float3 centre);
float3 rotatePoints(float3 points, float3 angles, float3 centre){
  
  points -= centre;
  
  float3x3 rx = float3x3(1.0);
  rx[1][1] = cos(angles.x);
  rx[2][1] = -sin(angles.x);
  rx[1][2] = sin(angles.x);
  rx[2][2] = rx[1][1];
  
  float3x3 ry = float3x3(1.0);
  ry[0][0] = cos(angles.y);
  ry[0][2] = -sin(angles.y);
  ry[2][0] = sin(angles.y);
  ry[2][2] = ry[0][0];
  
  float3x3 rz = float3x3(1.0);
  rz[0][0] = cos(angles.z);
  rz[1][0] = -sin(angles.z);
  rz[0][1] = sin(angles.z);
  rz[1][1] = rz[0][0];
  
  points *= (rx * ry * rz);
  points += centre;
  return points;
}











// MARK:- Voronoi Generator


struct VoronoiInputs {
  float2 pos;
  float2 offsetStrength;
  float3 rotations;
  int octaves;
  float persistence;
  float frequency;
  float lacunarity;
  float zValue;
  float wValue;
  int sphereMap;
  int seamless;
};


float4 getCellPoint(int4 cell, float frequency, constant float4 *grad4, constant int *perm, constant int *permMod12);
float4 getCellPoint(int4 cell, float frequency, constant float4 *grad4, constant int *perm, constant int *permMod12){
  float4 cellBase = float4(cell) / frequency;
  float noiseX = (simplex4D(cell.x, cell.y, cell.z, cell.w, grad4, perm, permMod12)+1)/3;
  float noiseY = (simplex4D(cell.z, cell.w, cell.y, cell.x, grad4, perm, permMod12)+1)/3;
  float noiseZ = (simplex4D(cell.y, cell.x, cell.w, cell.z, grad4, perm, permMod12)+1)/3;
  float noiseW = (simplex4D(cell.w, cell.z, cell.x, cell.y, grad4, perm, permMod12)+1)/3;
  return cellBase + (0.5 + (1.5 * float4(noiseX, noiseY, noiseZ, noiseW))) / frequency;
}



float pythagorean(float4 p1, float4 p2);
float pythagorean(float4 p1, float4 p2){
  return distance(p1, p2);
}

float manhattan(float4 p1, float4 p2);
float manhattan(float4 p1, float4 p2){
  float x = p1.x - p2.x;
  float y = p1.y - p2.y;
  return abs(x) + abs(y);
}

float chebyshev(float4 p1, float4 p2);
float chebyshev(float4 p1, float4 p2){
  float x = p1.x - p2.x;
  float y = p1.y - p2.y;
  if (abs(x) <= abs(y)){
    return abs(x);
  }
  return abs(y);
}

float quadratic(float4 p1, float4 p2);
float quadratic(float4 p1, float4 p2){
  float x = p1.x - p2.x;
  float y = p1.y - p2.y;
  return x*x + x*y + y*y;
}

float minkowski(float4 p1, float4 p2, float c);
float minkowski(float4 p1, float4 p2, float c){
  float x = p1.x - p2.x;
  float y = p1.y - p2.y;
  return pow(pow(abs(x),c) + pow(abs(y),c), (1/c));
}



float worley(float4 coo, float frequency, constant float4 *grad4, constant int *perm, constant int *permMod12);
float worley(float4 coo, float frequency, constant float4 *grad4, constant int *perm, constant int *permMod12){
  int4 cell = int4(coo * frequency);
  float dist = 1.0;
  float dist2 = 1.0;
  

  for (int x = -2; x < 2; x++) {
    for (int y = -2; y < 2; y++) {
      for (int z = -2; z < 2; z++) {
        for (int w = -2; w < 2; w++) {
          float4 cellPoint = getCellPoint(cell + int4(x, y, z, w), frequency, grad4, perm, permMod12);
          float d = pythagorean(cellPoint, coo);
          if (d < dist){
            dist2 = dist;
            dist = d;
          }else if (d < dist2){
            dist2 = d;
          }
        }
      }
    }
  }
  
  dist /= length(float2(1.0 / frequency));
  dist2 /= length(float2(1.0 / frequency));
  return dist2-dist;
}


kernel void voronoiGenerator(texture2d<float, access::write> outTexture [[texture(0)]],
                             texture2d<float, access::read> xoffset [[texture(1)]],
                             texture2d<float, access::read> yoffset [[texture(2)]],
                             constant float3 *grad3 [[buffer(0)]],
                             constant float4 *grad4 [[buffer(1)]],
                             constant int *perm [[buffer(2)]],
                             constant int *permMod12 [[buffer(3)]],
                             constant VoronoiInputs &uniforms [[buffer(4)]],
                             uint2 gid [[thread_position_in_grid]],
                             uint2 threads [[threads_per_grid]])
{
  float2 p = uniforms.pos;
  float xFrac = (float(gid.x) / float(threads.x))+p.x;
  float yFrac = (float(gid.y) / float(threads.y))+p.y;
  float3 centre = float3(0.5+p.x, 0.5+p.y, uniforms.zValue);
  float3 rot = rotatePoints(float3(xFrac,yFrac,uniforms.zValue), uniforms.rotations, centre);
  xFrac = rot.x;
  yFrac = rot.y;
  float z = rot.z;
  float w = uniforms.wValue;
  
  float disStren = uniforms.offsetStrength.x;
  float dx = grey(xoffset.read(gid)) * disStren;
  float dy = grey(yoffset.read(gid)) * disStren;
  
  float total = 0.0;
  float amplitude = 1.0;
  float maxAmplitude = 0.0;
  int octaves = uniforms.octaves;
  float freq = uniforms.frequency;
  float lacunarity = uniforms.lacunarity;
  float persistence = uniforms.persistence;
  int seamless = uniforms.seamless;
  int sphereMap = uniforms.sphereMap;
  
  float x = xFrac+dx;
  float y = yFrac+dy;
  
  if (sphereMap != 0){
    float pi = 3.14159265;
    float xx = cos(pi*2*x)*sin(pi*y);
    float yy = sin(pi*2*x)*sin(pi*y);
    z = cos(pi*y);
    x = xx;
    y = yy;
  }
  
  if (seamless != 0){
    float pi = 3.14159265;
    
    float nx = cos(2*pi*x);
    float ny = cos(2*pi*y);
    float nz = sin(2*pi*x);
    float nw = sin(2*pi*y);
    x = nx;
    y = ny;
    z = nz;
    w = nw;
  }
  for (int j = 0; j < octaves; ++j){
    total += worley(float4(x, y, z, w), freq, grad4, perm, permMod12) * amplitude;
    
    freq *= lacunarity;
    maxAmplitude += amplitude;
    amplitude *= persistence;
  }
  
  float r = total / maxAmplitude;
  
  
  outTexture.write(float4(float3(r), 1),gid);
}
























// MARK:- Simplex Kernels

struct CoherentInputs{
  float2 pos;
  float3 rotations;
  int octaves;
  float persistence;
  float frequency;
  float lacunarity;
  float z;
  float w;
  float offsetStrength;
  int useFourD;
  int sphereMap;
  int seamless;
};



kernel void simplexGenerator(texture2d<float, access::write> outTexture [[texture(0)]],
                             texture2d<float, access::read> xoffset [[texture(1)]],
                             texture2d<float, access::read> yoffset [[texture(2)]],
                             constant float3 *grad3 [[buffer(0)]],
                             constant float4 *grad4 [[buffer(1)]],
                             constant int *perm [[buffer(2)]],
                             constant int *permMod12 [[buffer(3)]],
                             constant CoherentInputs &uniforms [[buffer(4)]],
                             uint2 gid [[thread_position_in_grid]],
                             uint2 threads [[threads_per_grid]])
{
  float total = 0.0;
  float amplitude = 1.0;
  float maxAmplitude = 0.0;
  float disStren = uniforms.offsetStrength;
  int use4D = uniforms.useFourD;
  int sphereMap = uniforms.sphereMap;
  int seamless = uniforms.seamless;
  
  int octaves = uniforms.octaves;
  float freq = uniforms.frequency;
  float lacunarity = uniforms.lacunarity;
  float persistence = uniforms.persistence;
  float x = uniforms.pos.x + (float(gid.x)/float(threads.x)) + (grey(xoffset.read(gid)) * disStren);
  float y = uniforms.pos.y + (float(gid.y)/float(threads.y)) + (grey(yoffset.read(gid)) * disStren);
  float z = uniforms.z;
  float3 centre = float3(uniforms.pos.x + 0.5, uniforms.pos.y + 0.5, z);
  float3 rot = rotatePoints(float3(x,y,z), uniforms.rotations, centre);
  x = rot.x;
  y = rot.y;
  z = rot.z;
  float w = uniforms.w;
  
  if (sphereMap != 0){
    float pi = 3.14159265;
    float xx = cos(pi*2*x)*sin(pi*y);
    float yy = sin(pi*2*x)*sin(pi*y);
    z = cos(pi*y);
    x = xx;
    y = yy;
  }
  
  if (seamless != 0){
    float pi = 3.14159265;
    
    float nx = cos(2*pi*x);
    float ny = cos(2*pi*y);
    float nz = sin(2*pi*x);
    float nw = sin(2*pi*y);
    x = nx;
    y = ny;
    z = nz;
    w = nw;
    freq /= pi;
  }
  
  for (int j = 0; j < octaves; ++j){
    if (use4D == 0){
      total += ((simplex3D(x*freq,y*freq,z*freq,grad3,perm,permMod12)+1)/2) * amplitude;
    }else{
      total += ((simplex4D(x*freq,y*freq,z*freq,w*freq,grad4,perm,permMod12)+1)/2) * amplitude;
    }
    
    freq *= lacunarity;
    maxAmplitude += amplitude;
    amplitude *= persistence;
  }
  
  float r = total / maxAmplitude;
  outTexture.write(float4(r,r,r,1),gid);
}



// MARK:- Billow Kernel
kernel void billowGenerator(texture2d<float, access::write> outTexture [[texture(0)]],
                            texture2d<float, access::read> xoffset [[texture(1)]],
                            texture2d<float, access::read> yoffset [[texture(2)]],
                            constant float3 *grad3 [[buffer(0)]],
                            constant float4 *grad4 [[buffer(1)]],
                            constant int *perm [[buffer(2)]],
                            constant int *permMod12 [[buffer(3)]],
                            constant CoherentInputs &uniforms [[buffer(4)]],
                            uint2 gid [[thread_position_in_grid]],
                            uint2 threads [[threads_per_grid]])
{
  float total = 0.0;
  float amplitude = 1.0;
  float maxAmplitude = 0.0;
  float disStren = uniforms.offsetStrength;
  int use4D = uniforms.useFourD;
  int sphereMap = uniforms.sphereMap;
  int seamless = uniforms.seamless;
  
  int octaves = uniforms.octaves;
  float freq = uniforms.frequency;
  float lacunarity = uniforms.lacunarity;
  float persistence = uniforms.persistence;
  float x = uniforms.pos.x + (float(gid.x)/float(threads.x)) + (grey(xoffset.read(gid)) * disStren);
  float y = uniforms.pos.y + (float(gid.y)/float(threads.y)) + (grey(yoffset.read(gid)) * disStren);
  float z = uniforms.z;
  float3 centre = float3(uniforms.pos.x + 0.5, uniforms.pos.y + 0.5, z);
  float3 rot = rotatePoints(float3(x,y,z), uniforms.rotations, centre);
  x = rot.x;
  y = rot.y;
  z = rot.z;
  float w = uniforms.w;
  
  if (sphereMap != 0){
    float pi = 3.14159265;
    float xx = cos(pi*2*x)*sin(pi*y);
    float yy = sin(pi*2*x)*sin(pi*y);
    z = cos(pi*y);
    x = xx;
    y = yy;
  }
  
  if (seamless != 0){
    float pi = 3.14159265;
    
    float nx = cos(2*pi*x);
    float ny = cos(2*pi*y);
    float nz = sin(2*pi*x);
    float nw = sin(2*pi*y);
    x = nx;
    y = ny;
    z = nz;
    w = nw;
    freq /= pi;
  }
  
  for (int j = 0; j < octaves; ++j){
    
    if (use4D == 0){
      total += abs(simplex3D(x*freq,y*freq,z*freq,grad3,perm,permMod12)) * amplitude;
    }else{
      total += abs(simplex4D(x*freq,y*freq,z*freq,w*freq,grad4,perm,permMod12)) * amplitude;
    }
    
    freq *= lacunarity;
    maxAmplitude += amplitude;
    amplitude *= persistence;
  }
  
  float r = total / maxAmplitude;
  outTexture.write(float4(r,r,r,1),gid);
}



// MARK:- Ridged Multi Kernel
kernel void ridgedMultiGenerator(texture2d<float, access::write> outTexture [[texture(0)]],
                                 texture2d<float, access::read> xoffset [[texture(1)]],
                                 texture2d<float, access::read> yoffset [[texture(2)]],
                                 constant float3 *grad3 [[buffer(0)]],
                                 constant float4 *grad4 [[buffer(1)]],
                                 constant int *perm [[buffer(2)]],
                                 constant int *permMod12 [[buffer(3)]],
                                 constant CoherentInputs &uniforms [[buffer(4)]],
                                 uint2 gid [[thread_position_in_grid]],
                                 uint2 threads [[threads_per_grid]])
{
  float total = 0.0;
  float amplitude = 1.0;
  float maxAmplitude = 0.0;
  float disStren = uniforms.offsetStrength;
  int use4D = uniforms.useFourD;
  int sphereMap = uniforms.sphereMap;
  int seamless = uniforms.seamless;
  
  int octaves = uniforms.octaves;
  float freq = uniforms.frequency;
  float lacunarity = uniforms.lacunarity;
  float persistence = uniforms.persistence;
  float x = uniforms.pos.x + (float(gid.x)/float(threads.x)) + (grey(xoffset.read(gid)) * disStren);
  float y = uniforms.pos.y + (float(gid.y)/float(threads.y)) + (grey(yoffset.read(gid)) * disStren);
  float z = uniforms.z;
  float3 centre = float3(uniforms.pos.x + 0.5, uniforms.pos.y + 0.5, z);
  float3 rot = rotatePoints(float3(x,y,z), uniforms.rotations, centre);
  x = rot.x;
  y = rot.y;
  z = rot.z;
  float w = uniforms.w;
  
  if (sphereMap != 0){
    float pi = 3.14159265;
    float xx = cos(pi*2*x)*sin(pi*y);
    float yy = sin(pi*2*x)*sin(pi*y);
    z = cos(pi*y);
    x = xx;
    y = yy;
  }
  
  if (seamless != 0){
    float pi = 3.14159265;
    
    float nx = cos(2*pi*x);
    float ny = cos(2*pi*y);
    float nz = sin(2*pi*x);
    float nw = sin(2*pi*y);
    x = nx;
    y = ny;
    z = nz;
    w = nw;
    freq /= pi;
  }
  
  for (int j = 0; j < octaves; ++j){
    if (use4D == 0){
      total += ((-abs(simplex3D(x*freq,y*freq,z*freq,grad3,perm,permMod12))*2)+1) * amplitude;
    }else{
      total += ((-abs(simplex4D(x*freq,y*freq,z*freq,w*freq,grad4,perm,permMod12))*2)+1) * amplitude;
    }
    
    freq *= lacunarity;
    maxAmplitude += amplitude;
    amplitude *= persistence;
  }
  
  float r = total / maxAmplitude;
  outTexture.write(float4(r,r,r,1),gid);
}






// MARK:- Uniform Output Kernel
kernel void uniformGenerator(texture2d<float, access::write> outTexture [[texture(0)]],
                             texture2d<float, access::read> xoffset [[texture(1)]],
                             texture2d<float, access::read> yoffset [[texture(2)]],
                             constant float3 &uniforms [[buffer(0)]],
                             uint2 gid [[thread_position_in_grid]])
{
  outTexture.write(float4(uniforms,1),gid);
}






// MARK:- Geometric Kernels
struct GeometricInputs{
  float offset;
  float frequency;
  float xPosition;
  float yPosition;
  float zValue;
  float offsetStrength;
  float3 rotations;
};



// MARK:- Cylinder Kernel
kernel void cylinderGenerator(texture2d<float, access::write> outTexture [[texture(0)]],
                              texture2d<float, access::read> xoffset [[texture(1)]],
                              texture2d<float, access::read> yoffset [[texture(2)]],
                              constant GeometricInputs &uniforms [[buffer(0)]],
                              uint2 gid [[thread_position_in_grid]],
                              uint2 threads [[threads_per_grid]])
{
  float delay = uniforms.offset;
  float frequency = uniforms.frequency;
  float xPos = uniforms.xPosition;
  float yPos = uniforms.yPosition;
  float disStren = uniforms.offsetStrength;
  
  float xFrac = float(gid.x) / float(threads.x);
  float yFrac = float(gid.y) / float(threads.y);
  float3 centre = float3(0.5, 0.5, uniforms.zValue);
  float3 rot = rotatePoints(float3(xFrac,yFrac,0), uniforms.rotations, centre);
  xFrac = rot.x;
  yFrac = rot.y;

  float dx = xPos - xFrac + (grey(xoffset.read(gid)) * disStren);
  float dy = yPos - yFrac + (grey(yoffset.read(gid)) * disStren);
  float4 out = float4(0,0,0,1);
  float distSquared = (dx*dx) + (dy*dy);
  
  if (distSquared > (delay*delay)){
    float o = (-cos((sqrt(distSquared)-delay) * frequency * 25)+1)/2;
    out = float4(o,o,o,1);
  }
  
  outTexture.write(out,gid);
}


// MARK:- Sphere Kernel
kernel void sphereGenerator(texture2d<float, access::write> outTexture [[texture(0)]],
                            texture2d<float, access::read> xoffset [[texture(1)]],
                            texture2d<float, access::read> yoffset [[texture(2)]],
                            constant GeometricInputs &uniforms [[buffer(0)]],
                            uint2 gid [[thread_position_in_grid]],
                            uint2 threads [[threads_per_grid]])
{
  float delay = uniforms.offset;
  float frequency = uniforms.frequency;
  float xPos = uniforms.xPosition;
  float yPos = uniforms.yPosition;
  float zPos = uniforms.zValue;
  float disStren = uniforms.offsetStrength;

  float xFrac = float(gid.x) / float(threads.x);
  float yFrac = float(gid.y) / float(threads.y);
  
  float3 centre = float3(0.5, 0.5, 0.0);
  float3 rot = rotatePoints(float3(xFrac,yFrac,zPos), uniforms.rotations, centre);
  xFrac = rot.x;
  yFrac = rot.y;
  zPos = rot.z;

  float dx = xPos - xFrac + (grey(xoffset.read(gid)) * disStren);
  float dy = yPos - yFrac + (grey(yoffset.read(gid)) * disStren);
  float4 out = float4(0,0,0,1);
  float distSquared = (dx*dx) + (dy*dy) + (zPos*zPos);
  
  if (distSquared > (delay*delay)){
    float o = (-cos((sqrt(distSquared)-delay) * frequency * 50)+1)/2;
    out = float4(o,o,o,1);
  }
  
  outTexture.write(out,gid);
}


// MARK:- Checker Kernel
kernel void checkerGenerator(texture2d<float, access::write> outTexture [[texture(0)]],
                             texture2d<float, access::read> xoffset [[texture(1)]],
                             texture2d<float, access::read> yoffset [[texture(2)]],
                             constant GeometricInputs &uniforms [[buffer(0)]],
                             uint2 gid [[thread_position_in_grid]],
                             uint2 threads [[threads_per_grid]])
{
  float frequency = uniforms.frequency*3;
  float disStren = uniforms.offsetStrength;
  float4 out = float4(0,0,0,1);
  
  float2 pos = float2(gid)/(float2(threads)/frequency);
  float zPos = uniforms.zValue;
  float3 centre = float3(frequency/2, frequency/2, 0.0);
  float3 rot = rotatePoints(float3(pos.x,pos.y,zPos), uniforms.rotations, centre);
  pos = float2(rot.x, rot.y);
  pos.x += (grey(xoffset.read(gid)) * disStren);
  pos.y += (grey(yoffset.read(gid)) * disStren);
  zPos = rot.z;
  int2 ipos = int2(floor(pos));
  int c = int((abs(ipos.x)+abs(ipos.y)+int(zPos)) % 2 == 0);
  out = float4(c,c,c,1);
  
  outTexture.write(out,gid);
}




struct GradientInputs{
  float4 positions;
  float offsetStrength;
  float3 rotations;
};


// MARK:- Linear Gradient Generator
kernel void linearGradientGenerator(texture2d<float, access::write> outTexture [[texture(0)]],
                                    texture2d<float, access::read> xoffset [[texture(1)]],
                                    texture2d<float, access::read> yoffset [[texture(2)]],
                                    constant GradientInputs &uniforms [[buffer(0)]],
                                    uint2 gid [[thread_position_in_grid]],
                                    uint2 threads [[threads_per_grid]])
{
  float2 s = float2(uniforms.positions.x, uniforms.positions.y);
  float2 e = float2(uniforms.positions.z, uniforms.positions.w);
  float2 m = (e+s)/2;
  
  float2 p = float2(gid)/float2(threads);
  float3 centre = float3(0.5, 0.5, 0);
  float3 rot = rotatePoints(float3(p.x,p.y,0),uniforms.rotations, centre);
  p.x = rot.x;
  p.y = rot.y;

  float disStren = uniforms.offsetStrength;
  p.x += (grey(xoffset.read(gid)) * disStren);
  p.y += (grey(yoffset.read(gid)) * disStren);

  
  float2 me = e-m;
  float lme = length(me);
  
  float2 mp = p-m;
  float lmp = length(mp);
  
  float angle = dot(me,mp)/(lmp*lme);
  if (length(m - p) < 0.005){
    angle = 0.5;
  }else{
    angle = (((angle*lmp)/length(e-s))+0.5);
  }
  
  float4 out = float4(angle,angle,angle,1);
  
  outTexture.write(out,gid);
}



// MARK:- Radial Gradient Generator
kernel void radialGradientGenerator(texture2d<float, access::write> outTexture [[texture(0)]],
                                    texture2d<float, access::read> xoffset [[texture(1)]],
                                    texture2d<float, access::read> yoffset [[texture(2)]],
                                    constant GradientInputs &uniforms [[buffer(0)]],
                                    uint2 gid [[thread_position_in_grid]],
                                    uint2 threads [[threads_per_grid]])
{
  float2 s = float2(uniforms.positions.x, uniforms.positions.y);
  float2 f = float2(uniforms.positions.z, uniforms.positions.w);
  
  float2 p = float2(gid)/float2(threads);
  float3 centre = float3(0.5, 0.5, 0);
  float3 rot = rotatePoints(float3(p.x,p.y,0),uniforms.rotations, centre);
  p.x = rot.x;
  p.y = rot.y;
  
  float disStren = uniforms.offsetStrength;
  p.x += (grey(xoffset.read(gid)) * disStren);
  p.y += (grey(yoffset.read(gid)) * disStren);
  float2 d = p-s;
  float2 weight = d*f*2;
  
  float o = 1-(length(weight));
  
  float4 out = float4(o,o,o,1);
  
  outTexture.write(out,gid);
}



// MARK:- Box Gradient Generator
kernel void boxGradientGenerator(texture2d<float, access::write> outTexture [[texture(0)]],
                                 texture2d<float, access::read> xoffset [[texture(1)]],
                                 texture2d<float, access::read> yoffset [[texture(2)]],
                                 constant GradientInputs &uniforms [[buffer(0)]],
                                 uint2 gid [[thread_position_in_grid]],
                                 uint2 threads [[threads_per_grid]])
{
  float2 f = float2(uniforms.positions.x, uniforms.positions.y);
  
  float o = 1.0;
  if (f.x <= 0.99 || f.y <= 0.99){
    float2 p = float2(gid)/float2(threads);
    float3 centre = float3(0.5, 0.5, 0);
    float3 rot = rotatePoints(float3(p.x,p.y,0),uniforms.rotations, centre);
    p.x = rot.x;
    p.y = rot.y;
    
    float disStren = uniforms.offsetStrength;
    p.x += (grey(xoffset.read(gid)) * disStren);
    p.y += (grey(yoffset.read(gid)) * disStren);
    float2 c = 1-(abs(p-0.5)*2);
    c = c/(1-f);
    o = min(c.x,c.y);
  }
  
  float4 out = float4(o,o,o,1);
  
  outTexture.write(out,gid);
}



struct WaveInputs {
  float frequency;
  float offsetStrength;
  float3 rotations;
};

// MARK:- Wave Generator
kernel void waveGenerator(texture2d<float, access::write> outTexture [[texture(0)]],
                          texture2d<float, access::read> xoffset [[texture(1)]],
                          texture2d<float, access::read> yoffset [[texture(2)]],
                          constant WaveInputs &uniforms [[buffer(0)]],
                          uint2 gid [[thread_position_in_grid]],
                          uint2 threads [[threads_per_grid]])
{
  float freq = uniforms.frequency;
  
  float2 p = float2(gid)/float2(threads);
  float3 centre = float3(0.5, 0.5, 0);
  float3 rot = rotatePoints(float3(p.x,p.y,0),uniforms.rotations, centre);
  p.x = rot.x;
  p.y = rot.y;
  
  float disStren = uniforms.offsetStrength;
  p.x += (grey(xoffset.read(gid)) * disStren);
  p.y += (grey(yoffset.read(gid)) * disStren);
  
  float x = (p.x)*sin(0.0);
  float y = (p.y)*cos(0.0);
  float o = sin((x+y)*freq*8);
  o = (o+1)/2;
  
  float4 out = float4(o,o,o,1);
  
  outTexture.write(out,gid);
}




// MARK:- Test Kernel
kernel void test(constant CoherentInputs &uniforms [[buffer(0)]],
                 device float &outBuffer [[buffer(1)]],
                 uint2 gid [[threads_per_grid]],
                 uint2 gp [[thread_position_in_grid]])
{
  
  outBuffer = uniforms.sphereMap;
}

