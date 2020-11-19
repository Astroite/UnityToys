Shader "Astroite/WorldSpaceLine"
{
    Properties
    { 
        _Color("Base Color", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex (RGBA)", 2D) = "gray"{}
        _CubicCenter ("Cubic Center", Range(0, 1)) = 0.5
        _CubicRange ("Cubic Range", Range(0, 1)) = 0.2
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
            Cull back
            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/Common/Shaders/NoiseH.hlsl"
            #include "Assets/Common/Shaders/ShapeFunctionH.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv           : TEXCOORD0;      
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float4 positionHWS  : TEXCOORD1;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                half4 _Color;
                float4 _MainTex_ST;
                float _CubicCenter;
                float _CubicRange;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionHWS = float4(TransformObjectToWorld(IN.positionOS.xyz), 1);
                OUT.uv          = IN.uv;
                return OUT;
            }
         
            half4 frag(Varyings IN) : SV_Target
            {
                half3 PositionWS = IN.positionHWS.xyz * 10;
                half mask = 0;
                mask += cubicPulse(_CubicCenter, _CubicRange, frac(PositionWS.x));
                mask += cubicPulse(_CubicCenter, _CubicRange, frac(PositionWS.y));
                mask += cubicPulse(_CubicCenter, _CubicRange, frac(PositionWS.z));

                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                color.a = mask;
                clip(mask - 0.01);
                return color;
            }
            ENDHLSL
        }
    }
}