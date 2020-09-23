
// Noise Function
half2 randVec(half2 value)
{
    half2 vec = half2(dot(value, half2(127.1, 337.1)), dot(value, half2(269.5, 183.3)));
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
    half2 pos = frac(uv);
    a = dot(randVec(half2(x0, y0)), pos - half2(0, 0));
    b = dot(randVec(half2(x0, y1)), pos - half2(0, 1));
    c = dot(randVec(half2(x1, y1)), pos - half2(1, 1));
    d = dot(randVec(half2(x1, y0)), pos - half2(1, 0));
    float2 st = 6 * pow(pos, 5) - 15 * pow(pos, 4) + 10 * pow(pos, 3);
    a = lerp(a, d, st.x);
    b = lerp(b, c, st.x);
    a = lerp(a, b, st.y);
    return a + 0.2;
}


// Noise With Time
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