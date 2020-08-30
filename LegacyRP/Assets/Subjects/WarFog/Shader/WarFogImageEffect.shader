Shader "Astroite/WarFog/WarFogImageEffect"
{
    Properties
    {
        _FogColor("Fog Color", Color) = (0.2, 0.2, 0.2, 1)
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex; 
            sampler2D _FogTex;
            fixed4 _FogColor;

            float Blur(sampler2D tes, float2 uv)
            {
                float result = 0;
                result += tex2D(tes, uv) * 0.25;
                result += tex2D(tes, uv + float2(0, 1)) * 0.125;
                result += tex2D(tes, uv + float2(1, 0)) * 0.125;
                result += tex2D(tes, uv + float2(0, -1)) * 0.125;
                result += tex2D(tes, uv + float2(-1, 0)) * 0.125;
                result += tex2D(tes, uv + float2(1, 1)) * 0.0625;
                result += tex2D(tes, uv + float2(-1, 1)) * 0.0625;
                result += tex2D(tes, uv + float2(1, -1)) * 0.0625;
                result += tex2D(tes, uv + float2(-1, -1)) * 0.0625;

                return result;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                //float fog = 1 - Blur(_FogTex, i.uv);
                float fog = 1- tex2D(_FogTex, i.uv);
                fog = smoothstep(0.5, 1.2, fog);
                
                col = lerp(col, _FogColor, fog);

                return col;
            }
            ENDCG
        }
    }
}
