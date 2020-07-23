Shader "SpecialEffect/DomainWarping"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_Color2("Color2", Color) = (1,1,1,1)
		_Color3("Color3", Color) = (1,1,1,1)
		_Density("Density", Float) = 6
	}

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "../Common/Noise.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            fixed4 _Color;
            fixed4 _Color2;
            fixed4 _Color3;
            fixed _Fade;
            float _Density;

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = mul(unity_ObjectToWorld, v.vertex).xz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                i.uv *= _Density;
                float2 q, r;
                fixed4 col = _Color * pattern(i.uv, q, r);
                col = lerp(col, _Color2, q.x);
                col = lerp(col, _Color3, r.x);

                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

