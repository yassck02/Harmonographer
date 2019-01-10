//
//  shaders.metal
//  harmonographer
//
//  Created by Connor yass on 1/6/19.
//  Copyright © 2019 HSY_Technologies. All rights reserved.
//

#include <metal_stdlib>
#include <metal_math>
using namespace metal;

struct Vertex {
    float3 position;
    float4 color;
};

struct RasterizerData {
    float4 position [[ position ]];
    float4 color;
};

vertex RasterizerData vertex_shader(const device Vertex* verticies [[ buffer(0) ]],
                           unsigned int i [[ vertex_id ]])
{
    
    float t = i / 10000.0 * 100 * M_PI_F;
    
    float d1 = 0.004;
    float d2 = 0.0065;
    float d3 = 0.008;
    float d4 = 0.019;
    
    float f1 = 3.001;
    float f2 = 2.0;
    float f3 = 3.0;
    float f4 = 2.0;
    
    float p1 = 0.0;
    float p2 = 0.0;
    float p3 = M_PI_F / 2.0;
    float p4 = 3.0 * M_PI_F / 2.0;

    RasterizerData rd;
    rd.position = float4(exp(-d1*t) * sin(t*f1 + p1) + exp(-d2*t) * sin(t*f2 + p2),
                         exp(-d3*t) * sin(t*f3 + p3) + exp(-d4*t) * sin(t*f4 + p4), 1, 1);
    
    rd.color = verticies[i].color;
    return rd;
}


fragment half4 fragment_shader(RasterizerData rd [[ stage_in ]])
{
    float4 color = rd.color;
    return half4(color.r, color.g, color.b, color.a);
}
