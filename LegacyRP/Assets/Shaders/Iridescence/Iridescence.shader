Shader "Astroite/Iridescence"
{
    Properties
    {
        _Dinc("Dinc", Range(0.0, 10.0)) = 0.84
        _Eta2("Eta2", Range(1.0, 5.0)) = 1.3
        _Eta3("Eta3", Range(1.0, 5.0)) = 1.96
        _Kappa3("Kappa3", Range(0.0, 5.0)) = 0.36
        _Alpha("Alpha", Range(0.01, 1)) = 0.25
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
            #include "./Iridescent.cginc"

            float _Dinc;
            float _Eta2;
            float _Eta3;
            float _Kappa3;
            float _Alpha;

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                o.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(v.vertex, (float3x3)unity_WorldToObject));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = fixed(1.0).xxxx;

                // 
                float3 LightDir = normalize(WorldSpaceLightDir(i.vertex));
                float3 ViewDir = i.viewDir;
                float3 NormalWS = i.normal;

                LightDir = float3(0.724, 0.385, 0.385);
                ViewDir = float3(0.75, 0.327, 0.591);
                NormalWS = float3(0.833, 0.288, 0.827);


                // // L
                // float3 LightDir = normalize(WorldSpaceLightDir(i.vertex));
                // float3 NoV = dot(NormalWS, ViewDir);
                // float3 L = NormalWS * NoV * 2 - ViewDir;
                // float alpha = (1 - _Alpha) * (_Alpha + sqrt(1 - _Alpha));
                // L = lerp(NormalWS, L, alpha);
                // col.xyz *= BRDF(L, V, N);


                // col.xyz = IridescenceBRDF(LightDir, ViewDir, NormalWS, _Dinc, _Eta2, _Eta3, _Kappa3, _Alpha);
                col.xyz = IridescenceBRDF(LightDir, ViewDir, NormalWS, 0.84, 1.3, 1.96, 0.36, 0.25);
                // col.xyz = NormalWS;

                return col;
            }
            ENDCG
        }
    }
}
