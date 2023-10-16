Shader "Custom/TextureShader"
{
    Properties
    {
        _MainTexture("Main Texture", 2D) = "white" {}
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

            float4 _MainTexture_ST;
            TEXTURE2D(_MainTexture);
            SAMPLER(sampler_MainTexture);

            struct vextexInput
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct vertexOutput
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD1;
            };
            
            vertexOutput vertexFunc(const vextexInput input) 
            {
                vertexOutput output;
                output.positionHCS = TransformObjectToHClip(input.positionOS);  
               
                output.uv = input.uv*_MainTexture_ST.xy+(_MainTexture_ST.zw + (_Time.y * float2(2,0))/2); //TRANSFORM_TEX(input.uv, _MainTexture);
    
                return output;
            }

           
            float4 fragmentFunc(const vertexOutput input) : SV_TARGET
            {
                return SAMPLE_TEXTURE2D(_MainTexture, sampler_MainTexture, input.uv);
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
