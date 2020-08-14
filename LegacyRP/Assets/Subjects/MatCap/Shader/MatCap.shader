Shader "Astroite/MatCap/Basic" {
	Properties {
		_MainTex ("Diffuse (RGB)", 2D) = "white" {}
        _MatCap ("MatCap (RGB)", 2D) = "white" {}
	}
	
	Subshader {
		Tags { "RenderType"="Opaque" }
		
		Pass {
			Tags { "LightMode" = "Always" }
			
			CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            struct v2f 
            { 
                float4 pos : SV_POSITION;
                float2	NtoV : TEXCOORD1;
            };
            
            v2f vert (appdata_tan v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);

                o.NtoV.x = mul(UNITY_MATRIX_IT_MV[0], v.normal);
                o.NtoV.y = mul(UNITY_MATRIX_IT_MV[1], v.normal);
                return o;
            }
            
            uniform sampler2D _MainTex;
            
            float4 frag (v2f i) : COLOR
            {
                fixed4 matcapLookup = tex2D(_MainTex, i.NtoV * 0.5 + 0.5);					
                fixed4 finalColor = matcapLookup;
                return finalColor;
            }
			ENDCG
		}
	}
}