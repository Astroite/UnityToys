Shader "Astroite/Shadow/VertexShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightDir ("Light Direction", Vector) = (-1,-1,-1,1) 
        _ShadowColor("Shaodw Color", Color) = (0,0,0,1)
        _ShadowPlane ("Shadow Plane", Range(-10,10)) = 0
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

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }

        Pass
		{
			Tags { "RenderQueue"="Transparent" }

			Stencil
			{
				Ref 0
				Comp equal
				Pass incrWrap
				Fail keep
				ZFail keep
			}
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite off
			Offset -1 , 0

			CGPROGRAM
			#include "UnityCG.cginc"
            #include "Assets/Common/Shader/Noise.cginc"

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			
			struct appdata_vert
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
                float4 shadowEdge : TEXCOORD0;
				UNITY_VERTEX_OUTPUT_STEREO
			};

            uniform float4 _LightDir;
			uniform float4 _ShadowColor;
            uniform float _ShadowPlane;

			void ShadowProjectPos(inout float4 vertPos, out float alpha)
			{
                float3 worldOriPos = mul(unity_ObjectToWorld, float4(vertPos.xy, 0, 1)).xyz;
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 worldPos = mul(unity_ObjectToWorld, vertPos).xyz;

				vertPos.y = min(worldPos.y, _ShadowPlane);
				vertPos.xz = worldPos.xz - lightDir.xz * max(0, worldPos.y - _ShadowPlane) / lightDir.y;
                // shadowEdgePos = vertPos;
                // shadowEdgePos.xz += normalize(shadowEdgePos.xz - worldOriPos.xz) * 0.01;

				alpha = 1 - smoothstep(0.1, 1.3, distance(vertPos, worldPos));
			}

			v2f vert (appdata_vert v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v); 
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
				ShadowProjectPos(v.vertex, o.color.a);

				o.vertex = UnityWorldToClipPos(v.vertex);
				o.color.rgb = _ShadowColor.rgb; 
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
                // float2 uv = i.shadowEdge.xz - i.vertex.xz;
                // return float4(uv.yyyy);
				return i.color;
			}
			ENDCG
		}	
    }
}
