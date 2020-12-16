Shader "Astroite/Lightning"
{
    Properties
    {
        [HDR]_Color ("Lightning Color", Color) = (1, 1, 1, 1)
        _NoiseTiling("Noise Scale(X) Speed(Y) Strength(Z)", Vector) = (1, 1, 0, 0)
        _Rectangle("Rectangle Width(X Height(Y))", Vector) = (1, 1, 1, 1)

        _Flash("Flash ", Range(-1, 1)) = 1
        _FlashLength("Flash Length", Range(1, 10)) = 10
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Assets/Common/Shader/Noise.cginc"
            #include "Assets/Common/Shader/UnityNodes.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float4 _Color;
            float4 _NoiseTiling;
            float4 _Rectangle;
            float _LightningRate;
            float _Flash;
            float _FlashLength;

            float expSustainedImpulse( float x, float f, float k )
            {
                float s = max(x - f, 0.0);
                return min( x*x / (f*f), 1 + (2.0 / f) * s * exp(-k * s));
            }

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = fixed4(0,0,0,0);

                // float flash = saturate(smoothstep(_Flash, 0, i.uv.x * _FlashBeg));
                // flash += step(i.uv.x * _FlashBeg, _Flash);
                // float flashTail = (_Flash - 1);

                fixed noise = Unity_SimpleNoise(i.uv + _NoiseTiling.y * _Time.y, _NoiseTiling.x);
                float uv_rect = lerp(i.uv.yx, noise.rr, _NoiseTiling.z);
                fixed4 rect = Unity_Rectangle(uv_rect, _Rectangle.x, _Rectangle.y);
                fixed4 lightning = rect * _Color;

                float flash = expSustainedImpulse(_FlashLength * (1 - i.uv.x + _Flash), 3, 1) * step(i.uv.x, _Flash + 1);
                flash *= 1 - smoothstep(i.uv.x, 1, saturate(_Flash));
                col = lightning * flash;
                return col;
            }
            ENDCG
        }
    }
}
