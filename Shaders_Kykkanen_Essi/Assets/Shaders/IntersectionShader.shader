Shader "Custom/IntersectionShader"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _IntersectionColor("Intersection Color", Color) = (0, 0, 1, 1)
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" 
               "RenderPipeline" = "UniversalPipeline" 
               "Queue" = "Transparent" 
             }

        Pass 
        {
            Name "IntersectionUnlit"
            Tags { "LightMode" = "SRPDefaultUnlit" }

            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On

            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"        
                
            float4 _Color;
            float4 _IntersectionColor;

            struct Attributes 
            {
                float3 positionOS : POSITION;
            };
            
            struct Varyings 
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD1;
            };
               
            Varyings Vertex(const Attributes input) 
            {
                Varyings output;                
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);

                return output;
            }             
            
            half4 Fragment(Varyings input) : SV_TARGET 
            {
                float2 ScreenSpaceUV=GetNormalizedScreenSpaceUV(input.positionHCS);
                float SceneDepth=SampleSceneDepth(ScreenSpaceUV);
                float LinEyeDepth = LinearEyeDepth(SceneDepth, _ZBufferParams);
                float LinEyeDepthOBJ = LinearEyeDepth(input.positionWS, UNITY_MATRIX_V);
                float4 LerpValue = pow(1 - saturate(LinEyeDepth - LinEyeDepthOBJ), 10);

                return lerp(_Color, _IntersectionColor, LerpValue);
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
