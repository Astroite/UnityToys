Shader "Astroite/StencilMask"
{
    Properties
    { 
        _Color("Base Color", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex (RGBA)", 2D) = "gray"{}
        _Stencil ("Stencil", Int) = 10
        _RadialScale ("RadialScale", Float) = 1.0
        _LengthScale ("LengthScale", Float) = 1.0
    }

    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalRenderPipeline" 
        }

        ColorMask 0
        Blend One OneMinusSrcAlpha
        ZWrite Off
        Stencil
        {
            Ref 1 // ReferenceValue = 1
            Comp Always // Comparison Function - Make the stencil test always pass.
            Pass Replace // Write the reference value into the buffer.
        }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/Common/Shaders/NoiseH.hlsl"            

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv           : TEXCOORD0;      
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float4 positionORI  : TEXCOORD0;
                float4 positionHWS  : TEXCOORD1;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                half4 _Color;
                float4 _MainTex_ST;
                float _LengthScale;
                float _RadialScale;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionHWS = float4(TransformObjectToWorld(IN.positionOS.xyz), 1);
                OUT.positionORI = float4(TransformObjectToWorld(float3(0,0,0)), 1);
                return OUT;
            }
         
            half4 frag(Varyings IN) : SV_Target
            {
                half dist = distance(IN.positionHWS.xyz, IN.positionORI.xyz) * 0.15;
                half noise = fbmTime(half2(IN.positionHWS.x + IN.positionHWS.z, IN.positionHWS.y + IN.positionHWS.z) * smoothstep(0.2, 0.4, dist));
                noise = lerp(noise, 1.0, dist * 0.4);
                half eclipse = smoothstep(0.3, 0.7, noise * dist);

                half4 color = half4(lerp(half3(0,0,0), half3(1,1,1), eclipse), 1.0);
                clip(0.01 - color.r);
                return color;
            }
            ENDHLSL

        }
    }
}