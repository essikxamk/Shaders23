Shader "Custom/ProximityTextureShader"
{
    Properties
    {
        _MainTexture("Main Texture", 2D) = "white" {}
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

            float4 _MainTexture_ST;

            float3 _PlayerPosition;

            float _DistanceAttenuation;

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
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
            };
            
            vertexOutput vertexFunc(const vextexInput input) 
            {
                vertexOutput output;
                output.positionHCS = TransformObjectToHClip(input.positionOS); 
                output.positionWS=TransformObjectToWorld(input.positionOS);
                output.uv = input.uv;         
    
                return output;
            }
          
            float3 fragmentFunc(const vertexOutput input) : SV_TARGET
            {               
                float3 color = SAMPLE_TEXTURE2D(_MainTexture, sampler_MainTexture, input.uv * _MainTexture_ST.xy + _MainTexture_ST.zw); //TRANSFORM_TEX(input.uv, _MainTexture);     
                float distance = length(_PlayerPosition - input.positionWS);
                distance = saturate(1-distance/ _DistanceAttenuation);
                return lerp(0, (sin(distance * 50 + _Time.y*5)), distance);
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
