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
            
            int _Figure;
            int cloumn;
            float row;
            float4 numbers[5];
            float4 showAreas[5];

            void SetParams()
            {

                float4 showArea0 = float4(2, 3, 2, 3);
                float4 showArea1 = float4(1, 2, 2, 3);
                float4 showArea2 = float4(3, 4, 2, 3);

                float4 uv_TO_0 = float4(0.25, 0.25, 0, 0.25);
                float4 uv_TO_1 = float4(0.25, 0.25, 0.25, 0);
                float4 uv_TO_2 = float4(0.25, 0.25, 0.5, 0);

                numbers[0] = uv_TO_0;
                numbers[1] = uv_TO_1;
                numbers[2] = uv_TO_2;

                showAreas[0] = showArea0;
                showAreas[1] = showArea1;
                showAreas[2] = showArea2;
            }            

            float4 SampleNumber(float2 uv, float4 uv_TilingOffset, sampler2D _Tex)
            {
                float2 uv_Number = uv * uv_TilingOffset.xy + uv_TilingOffset.zw;
                return tex2D(_Tex, uv_Number);
            }
            
            float4 SampleNumbers(float2 uv, float4 uv_TO, float4 showArea, sampler2D _Tex, out float flag)
            {
                row = 15;
                cloumn = 5;
                
                float4 number = float4(0.25, 0.25, -0.25, -0.5);
                // float4 showArea = float4(2, 3, 3, 4);

                float2 uvw = frac(uv * float2(row, cloumn));
                fixed4 col = SampleNumber(uvw, uv_TO, _Tex);

                float2 uv_Rect = float2(uv.x * row, uv.y * cloumn);
                flag = step(showArea.x, uv_Rect.x) * step(uv_Rect.x, showArea.y) * step(showArea.z, uv_Rect.y) * step(uv_Rect.y, showArea.w);
                return lerp(float4(0,0,0,1), col, flag);
            }

            float4 MainLoop(float2 uv, sampler2D _Tex)
            {
                float flag = 0;
                float4 color = float4(0,0,0,0);
                for (int i = 0; i < 3; i++)
                {
                    float tempFlag = 0;
                    color += SampleNumbers(uv, numbers[i], showAreas[i], _Tex, tempFlag);
                    flag += tempFlag;
                }
                return lerp(float4(1,1,1,1), color, step(0.9, flag));
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
                SetParams();
                fixed4 col = MainLoop(i.uv.xy, _MainTex);

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
