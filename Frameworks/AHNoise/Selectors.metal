//
//  Selectors.metal
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


// Blend Selector
kernel void blendSelector(texture2d<float, access::read> inTexture1 [[texture(0)]],
                          texture2d<float, access::read> inTexture2 [[texture(1)]],
                          texture2d<float, access::read> selector [[texture(2)]],
                          texture2d<float, access::write> outTexture [[texture(3)]],
                          uint2 gid [[thread_position_in_grid]])
{
  float4 in1 = inTexture1.read(gid);
  float4 in2 = inTexture2.read(gid);
  float4 sel = selector.read(gid);
  float weight = (sel.r + sel.g + sel.b)/3;
  
  float3 out = mix(in1.rgb, in2.rgb, weight);
  
  outTexture.write(float4(out,1), gid);
}

// Select Selector
kernel void selectSelector(texture2d<float, access::read> inTexture1 [[texture(0)]],
                           texture2d<float, access::read> inTexture2 [[texture(1)]],
                           texture2d<float, access::read> selector [[texture(2)]],
                           texture2d<float, access::write> outTexture [[texture(3)]],
                           constant float2 &uniforms [[buffer(0)]],
                           uint2 gid [[thread_position_in_grid]])
{
  float4 in1 = inTexture1.read(gid);
  float4 in2 = inTexture2.read(gid);
  float4 sel = selector.read(gid);
  float weight = (sel.r + sel.g + sel.b)/3;
  float edge = uniforms.x;
  float bound = uniforms.y;
  float nedge = bound-(edge/2);
  
  if (weight <= nedge){
    outTexture.write(in1, gid);
  }else if (weight > nedge && weight <((bound*2)-nedge)){
    float fac = (((edge/2)-bound)+weight)/edge;
    outTexture.write(float4(mix(in1.rgb, in2.rgb, fac),1),gid);
  }else{
    outTexture.write(in2, gid);
  }
}