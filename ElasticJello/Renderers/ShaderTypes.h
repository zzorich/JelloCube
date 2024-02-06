//
//  ShaderTypes.h
//  ElasticJello
//
//  Created by lingji zhou on 2/4/24.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h
#include <simd/simd.h>

// Buffer index values shared between shader and C code to ensure Metal shader buffer inputs
// match Metal API buffer set calls.
typedef enum: int{
    AAPLVertexInputIndexVertices     = 0,
    AAPLVertexInputIndexViewportSize = 1
} AAPLVertexInputIndex;


//  This structure defines the layout of vertices sent to the vertex
//  shader. This header is shared between the .metal shader and C code, to guarantee that
//  the layout of the vertex array in the C code matches the layout that the .metal
//  vertex shader expects.
struct AAPLVertex {
    vector_float2 position;
    vector_float4 color;
};

#endif /* ShaderTypes_h */
