Shader "Custom/TestiShader"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque" 
            "RenderPipeline"="UniversalPipeline" 
            "Queue" = "Geometry" 
        }
        
Pass {
        Name "OmaPass"

        Tags
        {
            "LightMode"="UniversalForward"
        }

        HLSLPROGRAM
        #pragma vertex Vert
        #pragma fragment Frag

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

        struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
        };
        
        struct Varyings
        {
            float4 positionHCS : SV_POSITION;
            float3 positionWS : TEXCOORD;
            float3 normal : TEXCOORD1;
        };


        Varyings Vert(const Attributes input)
        {
            Varyings output;
            output.positionHCS = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, mul(UNITY_MATRIX_M, float4(input.positionOS, 1))));
          //  output.positionHCS = TransformObjectToHClip(input.positionOS);
            output.positionWS = mul(UNITY_MATRIX_M, input.positionOS);  //TransformObjectToWorld(input.positionOS);
            
            output.normal = TransformObjectToWorldNormal(input.normalOS);
            
            return output;
        }

        float4 _Color;
        float4 Frag(const Varyings input) : SV_Target
        {
           /* _Color = 0;
            _Color.rgb = input.normal * 0.5 + 0.5;
            return _Color;*/
            return _Color * clamp(input.positionWS.x,0,1);
        }

        ENDHLSL

        }
    }
}
