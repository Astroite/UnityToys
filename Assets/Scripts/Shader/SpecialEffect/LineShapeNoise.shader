Shader "SpecialEffect/LineShapeNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseScale ("Noise Scale", Float) = 1
        _MultiVector ("MultiFun Vector", Vector) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "../Common/Noise.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uvWorld : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex; float4 _MainTex_ST;
            float4 _MultiVector;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvWorld = mul(unity_ObjectToWorld, v.vertex).xz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                
                float2 offset = (0).xx;
                float2 uv = float2(i.uvWorld.x * _MultiVector.z, i.uvWorld.y * _MultiVector.w) + offset;
                float4 noise = fbm(uv * _NoiseScale).xxxx;
                noise = smoothstep(_MultiVector.x, _MultiVector.y, noise);
                noise = saturate(noise + 0.1);
                
                return col * noise;
            }
            ENDCG
        }
    }
}
