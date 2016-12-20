//
//  Combiners.metal
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


// Add Combiner
kernel void addCombiner(texture2d<float, access::read> inTexture1 [[texture(0)]],
                        texture2d<float, access::read> inTexture2 [[texture(1)]],
                        texture2d<float, access::write> outTexture [[texture(2)]],
                        constant bool &uniforms [[buffer(0)]],
                        uint2 gid [[thread_position_in_grid]])
{
  float4 in1 = inTexture1.read(gid);
  float4 in2 = inTexture2.read(gid);
  float3 out = in1.rgb+in2.rgb;
  if (uniforms == true){
    out /= 2;
  }
  
  outTexture.write(float4(out,1), gid);
}

// Subtract Combiner
kernel void subtractCombiner(texture2d<float, access::read> inTexture1 [[texture(0)]],
                             texture2d<float, access::read> inTexture2 [[texture(1)]],
                             texture2d<float, access::write> outTexture [[texture(2)]],
                             uint2 gid [[thread_position_in_grid]])
{
  float4 in1 = inTexture1.read(gid);
  float4 in2 = inTexture2.read(gid);
  float3 out = in1.rgb-in2.rgb;
  
  outTexture.write(float4(out,1), gid);
}

// Multiply Combiner
kernel void multiplyCombiner(texture2d<float, access::read> inTexture1 [[texture(0)]],
                             texture2d<float, access::read> inTexture2 [[texture(1)]],
                             texture2d<float, access::write> outTexture [[texture(2)]],
                             uint2 gid [[thread_position_in_grid]])
{
  float4 in1 = inTexture1.read(gid);
  float4 in2 = inTexture2.read(gid);
  float3 out = in1.rgb*in2.rgb;
  
  outTexture.write(float4(out,1), gid);
}

// Divide Combiner
kernel void divideCombiner(texture2d<float, access::read> inTexture1 [[texture(0)]],
                           texture2d<float, access::read> inTexture2 [[texture(1)]],
                           texture2d<float, access::write> outTexture [[texture(2)]],
                           uint2 gid [[thread_position_in_grid]])
{
  float4 in1 = inTexture1.read(gid);
  float4 in2 = inTexture2.read(gid);
  float3 out = in1.rgb/in2.rgb;
  
  outTexture.write(float4(out,1), gid);
}

// Power Combiner
kernel void powerCombiner(texture2d<float, access::read> inTexture1 [[texture(0)]],
                          texture2d<float, access::read> inTexture2 [[texture(1)]],
                          texture2d<float, access::write> outTexture [[texture(2)]],
                          uint2 gid [[thread_position_in_grid]])
{
  float4 in1 = inTexture1.read(gid);
  float4 in2 = inTexture2.read(gid);
  float3 out = pow(in1.rgb, in2.rgb);
  
  outTexture.write(float4(out,1), gid);
}

// Min Combiner
kernel void minCombiner(texture2d<float, access::read> inTexture1 [[texture(0)]],
                        texture2d<float, access::read> inTexture2 [[texture(1)]],
                        texture2d<float, access::write> outTexture [[texture(2)]],
                        uint2 gid [[thread_position_in_grid]])
{
  float4 in1 = inTexture1.read(gid);
  float4 in2 = inTexture2.read(gid);
  float ave1 = (in1.r + in1.g + in1.b)/3;
  float ave2 = (in2.r + in2.g + in2.b)/3;
  
  if (ave1 < ave2){
    outTexture.write(in1, gid);
  }else{
    outTexture.write(in2, gid);
  }
}

// Max Combiner
kernel void maxCombiner(texture2d<float, access::read> inTexture1 [[texture(0)]],
                        texture2d<float, access::read> inTexture2 [[texture(1)]],
                        texture2d<float, access::write> outTexture [[texture(2)]],
                        uint2 gid [[thread_position_in_grid]])
{
  float4 in1 = inTexture1.read(gid);
  float4 in2 = inTexture2.read(gid);
  float ave1 = (in1.r + in1.g + in1.b)/3;
  float ave2 = (in2.r + in2.g + in2.b)/3;
  
  if (ave1 > ave2){
    outTexture.write(in1, gid);
  }else{
    outTexture.write(in2, gid);
  }
}