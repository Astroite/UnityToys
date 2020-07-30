// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "UnityToy/RayMarch/Liquid"
{
    Properties
    {
        _Radius("Radius", Float) = 1
        //_Centre("Center", Vector) = (0,0,0,0)
        _Color("Liquid Color", Color) = (0.3,0.4,0.7,0.4)
        //_PlaneNormal("Plane Normal", Vector) = (0, 1, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        
        Pass
        {
            ZWrite On
            ColorMask 0  //用于设置颜色通道的写掩码,0表示不写入任何通道
        }

        Pass
        {

            Ztest Lequal
            ZWrite On
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define STEPS 128
            #define STEP_SIZE 0.01

            float3 _Centre; //球心
            float _Radius; //球半径
            fixed4 _Color; //液体颜色
            float3 _PlaneNormal; //平面法向量
            float3 _PlaneCenter; //平面中心

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 wPos : TEXCOORD0;
            };

            bool sphereHit (float3 p)
            {
                return distance(p, _Centre) < _Radius ;
            }

            bool UnderPlane(float3 p){
                return dot(normalize(p - _Centre), _PlaneNormal) < 0;
            }

            float4 raymarchHit (float3 position, float3 direction)
            {
                float4 color =  float4(0.5, 0.4, 0.9, 0);
                for (int i = 0; i < STEPS; i++)
                {
                    if ( sphereHit(position) && UnderPlane(position))
                        color.a += 0.01;
                    position += direction * STEP_SIZE;
                }
                return color;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = i.wPos;
                float3 viewDir = normalize(i.wPos - _WorldSpaceCameraPos);
                float4 col = raymarchHit(worldPos, viewDir);
                // if(raymarchHit(worldPos, viewDir))
                //     col =  _Color;
                // else
                //     col = fixed4(0,0,0,0);
                clip(col.a - 0.1);
                return col;
            }
            ENDCG
        }
    }
}
