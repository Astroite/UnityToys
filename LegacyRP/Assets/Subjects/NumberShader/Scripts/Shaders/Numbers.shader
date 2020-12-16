Shader "Astroite/Numbers"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            int cloumn;
            float row;
            float4 numbers[5];
            float4 showAreas[5];
            

            float4 SampleNumber(float2 uv, float4 uv_TilingOffset)
            {
                float2 uv_Number = uv * uv_TilingOffset.xy + uv_TilingOffset.zw;
                return tex2D(_MainTex, uv_Number);
            }

            float4 SampleNumbers(float2 uv)
            {
                row = 5;
                cloumn = 5;
                
                float4 number = float4(0.25, 0.25, -0.25, -0.5);
                float4 showArea = float4(2, 3, 0, 1);

                float4 uv_TO_1 = float4(0.25, 0.25, 0.25, 0);
                float4 uv_TO_0 = float4(0.25, 0.25, 0, 0);

                float2 uvw = frac(uv * float2(row, cloumn));
                fixed4 col1 = SampleNumber(uvw, uv_TO_1);

                float2 uv_Rect = float2(uv.x * row, uv.y * cloumn);
                if(uv_Rect.x < showArea.x || uv_Rect.x > showArea.y || uv_Rect.y < showArea.z || uv_Rect.y > showArea.w)
                {
                    return float4(1, 1, 1, 1);
                }
                return col1;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = SampleNumbers(i.uv.xy);

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
