Shader "Unlit/NewBuilding"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}

        _BumpScale("Scale", Float) = 1.0
        _BumpMap("Normal Map", 2D) = "bump" {}

        _MultiTex("Multi Function Map", 2D) = "black" {}
        _VirLiColor("Virtual Light Color", Color) = (1, 1, 1, 1)

        _Kd("Kd", Float) = 1

    }
    SubShader
    {        
        Tags { "RenderType"="opaque" "LightMode"="ForwardBase"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
                float3 normal : TEXCOORD3;
                UNITY_FOG_COORDS(4)
                SHADOW_COORDS(5)
                float3 objSpaceVerPos : TEXCOORD6;
                float3 objSpaceCamPos : TEXCOORD7;
                fixed3 ambient : COLOR0;
            };

            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _BumpMap; uniform float4 _BumpMap_ST;
            uniform sampler2D _MultiTex; uniform float4 _MultiTex_ST;
            uniform float3 _Color;
            uniform float _BumpScale;
            uniform fixed4 _VirLiColor;
            uniform float _Kd;

            v2f vert (appdata_tan v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                float3 binormal = cross( normalize(v.normal), normalize(v.tangent.xyz) ) * v.tangent.w;
                float3x3 rotation = float3x3( v.tangent.xyz, binormal, v.normal );
                o.normal = mul(rotation, v.normal);
				o.lightDir = mul(rotation, _WorldSpaceLightPos0.xyz);
				o.viewDir  = mul(rotation, _WorldSpaceCameraPos.xyz - v.vertex);

                // float3 ObjSpaceLightDir
                o.objSpaceVerPos = mul(rotation, float4(v.vertex.xyz, 1)).xyz;
                o.objSpaceCamPos = mul(rotation, _WorldSpaceCameraPos).xyz;
                
                o.ambient = ShadeSH9(half4(v.normal, 1));

                TRANSFER_SHADOW(o)
                UNITY_TRANSFER_FOG(o, o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= _Color;

                // fixed4 multi = tex2D(_MultiTex, i.uv);

                // fixed3 normal = UnpackNormalDXT5nm(tex2D(_BumpMap, i.uv));
                // //normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));
                // normal *= _BumpScale;
                fixed3 normal = normalize(i.normal);

                fixed distanceSquare = (i.objSpaceCamPos  - i.objSpaceVerPos) * (i.objSpaceCamPos  - i.objSpaceVerPos);
                fixed3 lightDir = normalize(i.lightDir);
                float ndotl = max(0, dot(lightDir, normal));

                float4 color;
                color.rgb =  (_Kd / 1) * col.rgb  * _LightColor0.rgb *  max(0, ndotl);
                // color.rgb =  col.rgb  * _LightColor0.rgb *  ndotl;

                // fixed shadow = SHADOW_ATTENUATION(i);
                // fixed3 lighting  = _LightColor0.rgb * shadow * ndotl + i.ambient + _VirLiColor * multi.r;
                // col.rgb *= lighting;

                UNITY_APPLY_FOG(i.fogCoord, col);
                return color;
            }
            ENDCG
        }

       //  UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }

    // FallBack "VertexLit"
}