Shader "Custom/ProximityDeform"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
        _PlayerPosition("Player Position", Vector) = (0,0,0,0)
        _DistanceAttenuation("Player Position", Range(1,10)) = 1
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" 
               "RenderPipeline" = "UniversalPipeline" 
               "Queue" = "Geometry" 
             }

        Pass 
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vertexFunc
            #pragma fragment fragmentFunc
    
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float4 _Color;
            float3 _PlayerPosition;
            float _DistanceAttenuation;

            TEXTURE2D(_MainTexture);
            SAMPLER(sampler_MainTexture);

            struct vextexInput
            {
                float3 positionOS : POSITION;
            };

            struct vertexOutput
            {
                float4 positionHCS : SV_POSITION;
           
            };
            
            vertexOutput vertexFunc(const vextexInput input) 
            {
                vertexOutput output;
                const float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                const float3 dir = positionWS - _PlayerPosition;
                float distance = length(dir);
                distance = saturate(1 - distance / _DistanceAttenuation);
                output.positionHCS = TransformWorldToHClip(positionWS + normalize(dir) * distance);
                
                return output;
            }
          
            float3 fragmentFunc(const vertexOutput input) : SV_TARGET
            {               
                return _Color;
            }

            ENDHLSL
        }

        // GRID 
        Pass
        {
            Name "Depth"
            Tags { "LightMode" = "DepthOnly" }
                
            Cull Back
            ZTest LEqual
            ZWrite On
            ColorMask R
                
            HLSLPROGRAM
                
            #pragma vertex DepthVert
            #pragma fragment DepthFrag

            #include "Common/DepthOnly.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "Normals"
            Tags { "LightMode" = "DepthNormalsOnly" }
                
            Cull Back
            ZTest LEqual
            ZWrite On
                
            HLSLPROGRAM
                
            #pragma vertex DepthNormalsVert
            #pragma fragment DepthNormalsFrag
            
            #include "Common/DepthNormalsOnly.hlsl"
                
            ENDHLSL
        }
    }
}
