Shader "Astroite/StencilWall"
{
    Properties
    { 
        _Color("Base Color", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex (RGBA)", 2D) = "gray"{}
        _Stencil ("Stencil", Int) = 10
    }

    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalRenderPipeline" 
        }

        Pass
        {

            Stencil 
            {
                Ref 1 // ReferenceValue = 1
                Comp NotEqual // Only render pixels whose reference value differs from the value in the buffer.
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"            

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv           : TEXCOORD0;
                half3 normal        : NORMAL;          
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv           : TEXCOORD0;
                half3 normal        : TEXCOORD1;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                half4 _Color;
                float4 _MainTex_ST;  
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                // The TransformObjectToHClip function transforms vertex positions
                // from object space to homogenous space
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.normal = TransformObjectToWorldNormal(IN.normal);
                return OUT;
            }
         
            half4 frag(Varyings IN) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                color *= _Color;
                color.rgb *= IN.normal * 0.5 + 0.5;
                return color;
            }
            ENDHLSL
        }
    }
}