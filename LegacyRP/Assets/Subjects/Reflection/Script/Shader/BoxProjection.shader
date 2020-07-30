Shader "Astroite/Reflection/BoxProjection"
{
	Properties
	{
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
            #include "UnityStandardUtils.cginc"
 
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 reflectionDir : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
			};
			
			v2f vert (appdata_full v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldViewDir = WorldSpaceViewDir(v.vertex);
				o.reflectionDir = reflect(-worldViewDir, worldNormal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}
			
            half4 frag (v2f i) : SV_Target
            {
                float3 reflectDir = i.reflectionDir;
                //通过BoxProjectedCubemapDirection函数修正reflectDir
                reflectDir = BoxProjectedCubemapDirection(reflectDir, i.worldPos, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
                half4 rgbm = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflectDir);
                half3 color = DecodeHDR(rgbm, unity_SpecCube0_HDR);
				
                return half4(color, 1.0);
            }
			ENDCG
		}
	}
}