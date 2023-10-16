Shader "Custom/TextureShader"
{
    Properties
    {
        _MainTexture("Main Texture", 2D) = "white" {}
        _SecondaryTexture("Secondary Texture", 2D) = "white" {}
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
            float4 _SecondaryTexture_ST;

            TEXTURE2D(_MainTexture);
            TEXTURE2D(_SecondaryTexture);
            SAMPLER(sampler_MainTexture);
            SAMPLER(sampler_SecondaryTexture);

            struct vextexInput
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct vertexOutput
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            vertexOutput vertexFunc(const vextexInput input) 
            {
                vertexOutput output;
                output.positionHCS = TransformObjectToHClip(input.positionOS);  
                output.uv = input.uv;         
    
                return output;
            }
          
            float3 fragmentFunc(const vertexOutput input) : SV_TARGET
            {               
                float3 color = SAMPLE_TEXTURE2D(_MainTexture, sampler_MainTexture, input.uv * _MainTexture_ST.xy + _MainTexture_ST.zw); //TRANSFORM_TEX(input.uv, _MainTexture);     
                float3 color2 = SAMPLE_TEXTURE2D(_SecondaryTexture, sampler_SecondaryTexture, input.uv * _SecondaryTexture_ST.xy + _SecondaryTexture_ST.zw);
                float3 color3 = lerp(color, color2, smoothstep(0.4, 0.8, input.uv.x));
                return color3;
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
