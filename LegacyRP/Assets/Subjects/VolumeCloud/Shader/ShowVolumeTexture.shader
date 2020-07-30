Shader "UnityToy/ShowVolume"
{
	Properties
	{
		_Volume ("Texture", 3D) = "white" {}
        _CutOff ("Cut Off", Range(0, 1)) = 0.5
	}
	SubShader
	{
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
				float2 uv: TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 worldPos : TEXCOORD1;
				float4 modelPos : TEXCOORD2;
			};

			sampler3D _Volume;
            float _CutOff;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_WorldToObject,v.vertex);
				o.modelPos = v.vertex;
				o.uv = v.uv;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 volume = tex3D(_Volume, i.modelPos.xzy);
                clip(volume.a - _CutOff);
				return volume;
			}
			ENDCG
		}
	}
}
