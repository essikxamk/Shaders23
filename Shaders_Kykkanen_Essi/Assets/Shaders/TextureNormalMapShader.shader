Shader "Custom/TextureNormalMapShader"
{
    Properties
    {
        _MainTexture("Main Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _Shininess ("Shininess", Range(1,512)) = 0.5
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            float4 _MainTexture_ST;
            float4 _NormalMap_ST;

            float _Shininess;

            TEXTURE2D(_MainTexture);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_MainTexture);
            SAMPLER(sampler_NormalMap);

            struct vertexInput
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 tangentOS : TANGENT;
                float3 normalOS : NORMAL;
            };

            struct vertexOutput
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 tangentWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;
                float2 uv : TEXCOORD4;
            };
            
            vertexOutput vertexFunc(vertexInput input) 
            {
                vertexOutput output;
                VertexPositionInputs pos_inputs = GetVertexPositionInputs(input.positionOS);
                VertexNormalInputs norm_inputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                output.positionHCS = pos_inputs.positionCS;  
                output.normalWS = norm_inputs.normalWS;  
                output.tangentWS = norm_inputs.tangentWS;  
                output.bitangentWS = norm_inputs.bitangentWS;  
                output.positionWS = pos_inputs.positionWS;       
    
                output.uv = input.uv;     

                return output;
            }
            float4 BlinnPhong(const vertexOutput input, float4 Color)
            {
                Light mainLight = GetMainLight();
                float3 ambientLight = 0.1 * mainLight.color;
                float3 diffuseLight = saturate(dot(input.normalWS, mainLight.direction)) * mainLight.color;
    
                float3 viewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
                float3 midVector = normalize(mainLight.direction + viewDirection);
    
                float3 specularLight = pow(saturate(dot(input.normalWS, midVector)), _Shininess) * mainLight.color;
               
    
                return float4((ambientLight + diffuseLight + specularLight*10) * Color.rgb, 1);
            }
          
            float3 fragmentFunc(vertexOutput input) : SV_TARGET
            {               
                float4 color = SAMPLE_TEXTURE2D(_MainTexture, sampler_MainTexture, input.uv * _MainTexture_ST.xy + _MainTexture_ST.zw); //TRANSFORM_TEX(input.uv, _MainTexture);     
                float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, TRANSFORM_TEX(input.uv, _MainTexture)));     
                float3x3 TangentToWorld = float3x3(input.tangentWS, input.bitangentWS, input.normalWS);

                const float3 normalWS=TransformTangentToWorld(normalTS, TangentToWorld, true);
                input.normalWS = normalWS;

                return BlinnPhong(input, color);
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
