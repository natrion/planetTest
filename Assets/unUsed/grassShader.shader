Shader "Custom/PlanetGrassShader"
{
    Properties
    {
        _Glossiness ("Glossiness", float) = 0.5
        _Metallic ("Specular", float) = 0.0
        _Color ("Color", Color) = (1,1,1,1)

        _Biom1MainTex ("Biom1 Albedo (RGB)1", Color)  = (1,1,1,1)

        _Biom1CliffMainTex ("Biom1 cliff Albedo (RGB)", Color)  = (1,1,1,1)

        _Biom2MainTex ("Biom2 Albedo (RGB)1", Color)  = (1,1,1,1)

        _Biom2CliffMainTex ("Biom2 cliff Albedo (RGB)", Color)  = (1,1,1,1)

        _BiomNoiseFrequency ("Biom Noise Frequency", Float) = 1.0
        _BiomNoiseIterations ("Biom Noise Iterations", Int) = 4
        _BiomNoiseIterationSize ("Biom Noise Iteration Size", Float) = 2.0
        _BiomNoisePower ("Biom Noise Power", Float) = 1.0
        _BiomNoiseIntensity ("Biom Noise Intensity", Float) = 1.0
        _BiomTransotionNum ("Biom transition size", Float) = 1.0

        _PlanetPosition ("Planet Position", Vector) = (0,0,0)
        _CliffSize ("Cliff Size", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
       
        LOD 10000

        Pass
        {

            CGPROGRAM
            #include "UnityCG.cginc"

            // User-defined functions

            float hash(float3 p) {
                p = float3(dot(p, float3(127.1, 311.7, 74.7)),
                           dot(p, float3(269.5, 183.3, 246.1)),
                           dot(p, float3(113.5, 271.9, 124.6)));
                return frac(sin(dot(p, float3(1.0, 1.0, 1.0))) * 43758.5453);
            }

            float GenerateGradientNoise(float3 p) {
                float3 i = floor(p);
                float3 f = frac(p);

                float n000 = hash(i + float3(0, 0, 0));
                float n100 = hash(i + float3(1, 0, 0));
                float n010 = hash(i + float3(0, 1, 0));
                float n110 = hash(i + float3(1, 1, 0));
                float n001 = hash(i + float3(0, 0, 1));
                float n101 = hash(i + float3(1, 0, 1));
                float n011 = hash(i + float3(0, 1, 1));
                float n111 = hash(i + float3(1, 1, 1));

                float3 fade_xyz = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
                float n00 = lerp(n000, n100, fade_xyz.x);
                float n01 = lerp(n001, n101, fade_xyz.x);
                float n10 = lerp(n010, n110, fade_xyz.x);
                float n11 = lerp(n011, n111, fade_xyz.x);
                float n0 = lerp(n00, n10, fade_xyz.y);
                float n1 = lerp(n01, n11, fade_xyz.y);
                float n = lerp(n0, n1, fade_xyz.z);

                return n;
            }

            float generateComplexGradientNoise(float3 pos, float frequency, int iterations, float iterationSize, float power, float intensity) {
                float gradientNoiseValue = 0.0;
                float mountenrelativeSize = 1.0;
                float mountenrelativeDistortion = 1.0;

                for (int i = 0; i < iterations; i++) {
                    float gradientNoiseValuePlus = GenerateGradientNoise(pos * frequency * mountenrelativeDistortion) * mountenrelativeSize;
                    gradientNoiseValue += pow(abs(gradientNoiseValuePlus), power);

                    mountenrelativeSize /= iterationSize;
                    mountenrelativeDistortion *= iterationSize;
                }

                return gradientNoiseValue * intensity;
            }

            float PointingToDirection(float3 direction, float3 referenceDirection) {
                direction = normalize(direction);
                referenceDirection = normalize(referenceDirection);
                float dotProduct = dot(direction, referenceDirection);
                return clamp(dotProduct, 0, 1);
            }

            // Shader variables
            float4 _Biom1MainTex;
            float4 _Biom1CliffMainTex;
            float4 _Biom2MainTex;
            float4 _Biom2CliffMainTex;
            float4 _PlanetPosition;
            float _TileSize;
            float _CliffSize;
            float _BiomTransotionNum;
            float _BiomNoiseFrequency;
            float _BiomNoiseIterations;
            float _BiomNoiseIterationSize;
            float _BiomNoisePower;
            float _BiomNoiseIntensity;
            float _Glossiness;
            float _Metallic;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 normal : TEXCOORD1;
            };

            v2f vert(appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal = abs(UnityObjectToWorldNormal(v.normal));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float3 relativePos = i.worldPos - _PlanetPosition.xyz;

                float BiomNoiseValue = generateComplexGradientNoise(relativePos + float3(-1000, -1000, -1000), _BiomNoiseFrequency, _BiomNoiseIterations, _BiomNoiseIterationSize, _BiomNoisePower, _BiomNoiseIntensity);

                float BiomChange = pow(BiomNoiseValue / _BiomNoiseIterations, _BiomTransotionNum);
                BiomChange = clamp(BiomChange, 0, 1);

                float howMuchpointingToTheSides = clamp(dot(i.normal, normalize(abs(i.worldPos))), 0, 1);
                howMuchpointingToTheSides = pow(howMuchpointingToTheSides, _CliffSize);

                float4 terrainColor1 = lerp(_Biom1CliffMainTex, _Biom1MainTex, howMuchpointingToTheSides);
                float4 terrainColor2 = lerp(_Biom2CliffMainTex, _Biom2MainTex, howMuchpointingToTheSides);
                float4 FinalTerrainColor2 = lerp(terrainColor1, terrainColor2, BiomChange);

                return float4(1,1,1,1);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}