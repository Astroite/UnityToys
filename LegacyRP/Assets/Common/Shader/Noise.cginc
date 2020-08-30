//Paraments
float _NoiseScale;
sampler2D _NoiseTex;

//Stand PerlinNoise FBM Pattern
fixed2 randVec(fixed2 value)
{
    fixed2 vec = fixed2(dot(value, fixed2(127.1, 337.1)), dot(value, fixed2(269.5, 183.3)));
    vec = -1 + 2 * frac(sin(vec) * 43758.5453123);
    return vec;
}

float perlinNoise(float2 uv)
{
    float a, b, c, d;
    float x0 = floor(uv.x);
    float x1 = ceil(uv.x);
    float y0 = floor(uv.y);
    float y1 = ceil(uv.y);
    fixed2 pos = frac(uv);
    a = dot(randVec(fixed2(x0, y0)), pos - fixed2(0, 0));
    b = dot(randVec(fixed2(x0, y1)), pos - fixed2(0, 1));
    c = dot(randVec(fixed2(x1, y1)), pos - fixed2(1, 1));
    d = dot(randVec(fixed2(x1, y0)), pos - fixed2(1, 0));
    float2 st = 6 * pow(pos, 5) - 15 * pow(pos, 4) + 10 * pow(pos, 3);
    a = lerp(a, d, st.x);
    b = lerp(b, c, st.x);
    a = lerp(a, b, st.y);
    return a + 0.2;
}

float fbm(float2 uv)
{
    float f = 0;
    float a = 1;
    for (int i = 0; i < 3; i++)
    {
        f += a * perlinNoise(uv);
        uv *= 2;
        a /= 2;
    }
    return f;
}

float pattern(float2 uv, out float2 q, out float2 r)
{
    q = float2( fbm(uv + float2(0.0, 0.0)), 
                fbm(uv + float2(5.2, 1.3)));

    r = float2( fbm(uv + 4 * q + float2(1.7, 9.2)),
                fbm(uv + 4 * q + float2(8.3, 2.8)));

    return fbm(uv + 4 * r);
}

//Noise changed by Time
float perlinNoiseTime(float2 uv)
{
    float a, b, c, d;
    float x0 = floor(uv.x);
    float x1 = ceil(uv.x);
    float y0 = floor(uv.y);
    float y1 = ceil(uv.y);
    fixed2 pos = frac(uv);
    a = dot(randVec(fixed2(x0, y0)), pos - fixed2(0, 0));
    b = dot(randVec(fixed2(x0, y1)), pos - fixed2(0, 1));
    c = dot(randVec(fixed2(x1, y1)), pos - fixed2(1, 1));
    d = dot(randVec(fixed2(x1, y0)), pos - fixed2(1, 0));
    float2 st = 6 * pow(pos, 5) - 15 * pow(pos, 4) + 10 * pow(pos, 3);
    a = lerp(a, d, st.x);
    b = lerp(b, c, st.x);
    a = lerp(a, b, st.y);
    return a + 0.2;
}

float fbmTime(float2 uv)
{
    float f = 0;
    float a = 1;
    for (int i = 0; i < 3; i++)
    {
        f += a * perlinNoise(uv + _Time.xx);
        uv *= 2;
        a /= 2;
    }
    return f;
}

float patternTime(float2 uv, out float2 q, out float2 r)
{
    q = float2( fbmTime(uv + float2(0.0, 0.0)), 
                fbmTime(uv + float2(5.2, 1.3)));

    r = float2( fbmTime(uv + 4 * q + float2(1.7, 9.2)),
                fbmTime(uv + 4 * q + float2(8.3, 2.8)));

    return fbmTime(uv + 4 * r);
}

// A test for LUT based 3D (value) noise which is much faster than its hash based (purely procedural) counterpart. 
// By IQ https://www.shadertoy.com/view/4sfGzS
float noiseLUT(in float3 x)
{
	float3 p = floor(x);
	float3 f = frac(x);
	f = f * f * (3.0 - 2.0 * f);
	float2 uv2 = (p.xy + float2(37.0, 17.0) * p.z) + f.xy;
	float2 rg = tex2Dlod(_NoiseTex, float4((uv2 + 0.5) / 256.0, 0, 0)).yx;
	return lerp(rg.x, rg.y, f.z);
}

float noiseBlurLUT(in float3 x)
{
    float3 i = floor(x);
	float3 f = frac(x);
	f = f * f * (3.0 - 2.0 * f);
    float2 uv = i.xy + float2(37.0, 17.0) * i.z;
    float2 rgA = tex2D(_NoiseTex, uv + float2(0, 0)).yx;
    float2 rgB = tex2D(_NoiseTex, uv + float2(1, 0)).yx;
    float2 rgC = tex2D(_NoiseTex, uv + float2(0, 1)).yx;
    float2 rgD = tex2D(_NoiseTex, uv + float2(1, 1)).yx;
    float2 rg  = lerp(  lerp(rgA, rgB, f.x),
                        lerp(rgC, rgD, f.x),
                        f.y);
    return lerp(rg.x, rg.y, f.z);
}