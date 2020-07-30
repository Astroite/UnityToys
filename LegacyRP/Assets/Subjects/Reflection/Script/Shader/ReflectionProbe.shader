Shader "Astroite/Reflection/ProbeReflection"
{
	Properties
	{
		_CubeTex ("Cube Tex", Cube) = ""{}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
 
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
 
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 reflectionDir : TEXCOORD0;
			};
			
			uniform samplerCUBE _CubeTex;
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldViewDir = WorldSpaceViewDir(v.vertex);
				o.reflectionDir = reflect(-worldViewDir, worldNormal);
				return o;
			}
			
            half4 frag (v2f i) : SV_Target
            {
                half4 rgbm = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, i.reflectionDir);
                half3 color = DecodeHDR(rgbm, unity_SpecCube0_HDR);
                return half4(color, 1.0);
            }
			ENDCG
		}
	}
}