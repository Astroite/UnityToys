Shader "NPR/Toon"
{
    Properties
    {
        _Color("Color Tint",Color) = (0,0,0,0)
        _MainTex ("Texture", 2D) = "white" {}
        _Ramp("Ramp Texture",2D) = "white"{}
        _Outline("Outline",Range(0, 0.1)) = 0.02
        _Factor("Factor of Outline",Range(0,1)) = 0.5
        _OutlineColor("Outline Color",Color) = (0,0,0,0)
        _Specular("Specular",Color) = (0,0,0,0)
        _SpecularScale("Specular Scale",Range(0,1)) = 0.01

        _Density("Density", Float) = 1
        _Color1("Color1", Color) = (0.4, 0.6, 0.1, 1)
        _Color2("Color2", Color) = (0.4, 0.6, 0.1, 1)
        _Color3("Color3", Color) = (0.4, 0.6, 0.1, 1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            NAME "OUTLINE"
            Cull Front
            ZWrite On

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float _Outline;
            float _Factor;
            fixed4 _OutlineColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                float3 pos = normalize(v.vertex.xyz);
                float3 normal = normalize(v.normal);

                float D = dot(pos, normal);
                pos *= sign(D);
                pos=lerp(normal, pos, _Factor);
                v.vertex.xyz += pos * _Outline;

                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(_OutlineColor.rgb, 1);
            }
            ENDCG
        }
        
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            Cull Back
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "../Common/Noise.cginc"

            fixed4 _Color;
            sampler2D _MainTex; float4 _MainTex_ST;
            sampler2D _Ramp;
            fixed4 _Specular;
            fixed _SpecularScale;

            fixed _Density;
            fixed4 _Color1;
            fixed4 _Color2;
            fixed4 _Color3;

            struct appdata
            {
                float4 vertex:POSITION;
                float2 uv:TEXCOORD0;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
                float3 worldNormal:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
                SHADOW_COORDS(3)
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 worldNormal     = normalize(i.worldNormal);
                fixed3 worldLightDir   = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir    = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 worldHalfDir    = normalize(worldLightDir+worldViewDir);

                // fixed4 c = tex2D(_MainTex, i.uv);
                i.uv *= _Density;
                float2 q, r;
                fixed4 c = _Color1 * patternTime(i.uv + _Time.xx, q, r);
                c = lerp(c, _Color2, q.x);
                c = lerp(c, _Color3, r.x);
                fixed3 albedo=c.rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                fixed diff = dot(worldNormal, worldLightDir);
                diff= (diff * 0.5 + 0.5) * atten;

                //卡通渲染的核心内容，对漫反射进行区域色阶的离散变化
                fixed3 diffuse = _LightColor0.rgb * albedo * tex2D(_Ramp, float2(diff, diff)).rgb;

                //计算半兰伯特高光系数，并将高光边缘的过渡进行抗锯齿处理，系数越大，过渡越明显
                fixed spec = dot(worldNormal, worldHalfDir);
                fixed w = fwidth(spec) * 3.0;

                //计算高光，在[-w,w]范围内平滑插值
                fixed3 specular =_Specular.rgb * smoothstep(-w, w, spec - (-_SpecularScale)) * step(0.0001, _SpecularScale);

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}