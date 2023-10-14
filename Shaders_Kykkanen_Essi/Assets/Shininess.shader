Shader "Custom/Shininess"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Shininess ("Shininess", Range(1,512)) = 0.5
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" 
               "RenderPipeline" = "UniversalPipeline" 
               "Queue" = "Geometry" 
             }

        Pass {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vertexFunc
            #pragma fragment fragmentFunc

            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


            struct vextexInput
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct vertexOutput
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD;
                float3 normalWS : TEXCOORD1;
            };
            
            vertexOutput vertexFunc(const vextexInput input) 
            {
                vertexOutput output;
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                //mul(UNITY_MATRIX_MVP, float4(input.positionOS, 1));
                output.positionWS = TransformObjectToWorld(input.positionOS);
                //mul(UNITY_MATRIX_M, input.positionOS);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    
                return output;
            }
            
            float4 _Color;
            float _Shininess;
            float4 BlinnPhong(const vertexOutput output)
            {
                Light mainLight = GetMainLight();
                float3 ambientLight = 0.1 * mainLight.color;
                float3 diffuseLight = saturate(dot(output.normalWS, mainLight.direction)) * mainLight.color;
    
                float3 viewDirection = GetWorldSpaceNormalizeViewDir(output.positionWS);
                float3 midVector = normalize(mainLight.direction + viewDirection);
    
                float3 specularLight = pow(saturate(dot(output.normalWS, midVector)), _Shininess) * mainLight.color;
                float4 color = float4((ambientLight + diffuseLight + specularLight*6) * _Color.rgb, 1);
    
                return color;
            }

            float4 fragmentFunc(const vertexOutput input) : SV_TARGET
            {
                return BlinnPhong(input);
            }
            ENDHLSL
        }
    }
}
