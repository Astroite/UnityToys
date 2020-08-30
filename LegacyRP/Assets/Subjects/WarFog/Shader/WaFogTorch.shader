Shader "Astroite/WarFog/WaFogTorch"
{
    Properties
    {
        _Color("FogTorchColor", Color) = (1,0,0,0)
    }
    SubShader
    {
        Tags 
        { 
            "RenderType" = "TransParent" 
            "Queue" = "TransParent"
        }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha


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

            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float dist = distance(float2(0.5, 0.5), i.uv);
                float factor =smoothstep(0.4, 1.2, saturate(1 - dist));
                fixed4 col = _Color * factor;
                
                return col;
            }
            ENDCG
        }
    }
}
