Shader "Custom/PlanetGroundShader"
{
    Properties
    {
        _Glossiness ("Glossiness", float) = 0.5
        _Metallic ("Specular", float) = 0.0
        _Color ("Color", Color) = (1,1,1,1)

        _Biom1MainTex ("Biom1 Albedo (RGB)1", 2D) = "white" {}
        _Biom1NormalMap ("Biom1 Normal Map1", 2D) = "bump" {}  

        _Biom1CliffMainTex ("Biom1 cliff Albedo (RGB)", 2D) = "white" {}
        _Biom1CliffNormalMap ("Biom1 cliff Normal Map", 2D) = "bump" {}  

        _Biom2MainTex ("Biom2 Albedo (RGB)1", 2D) = "white" {}
        _Biom2NormalMap ("Biom2 Normal Map1", 2D) = "bump" {}  

        _Biom2CliffMainTex ("Biom2 cliff Albedo (RGB)", 2D) = "white" {}
        _Biom2CliffNormalMap ("Biom2 cliff Normal Map", 2D) = "bump" {} 
        
        _NoiseFrequency ("Noise Frequency", Float) = 1.0
        _NoiseIterations ("Noise Iterations", Int) = 4
        _NoiseIterationSize ("Noise Iteration Size", Float) = 2.0
        _NoisePower ("Noise Power", Float) = 1.0
        _NoiseIntensity ("Noise Intensity", Float) = 1.0

        _BiomNoiseFrequency ("Biom Noise Frequency", Float) = 1.0
        _BiomNoiseIterations ("Biom Noise Iterations", Int) = 4
        _BiomNoiseIterationSize ("Biom Noise Iteration Size", Float) = 2.0
        _BiomNoisePower ("Biom Noise Power", Float) = 1.0
        _BiomNoiseIntensity ("Biom Noise Intensity", Float) = 1.0
        _BiomTransotionNum ("Biom transition size", Float) = 1.0

        _PlanetPosition ("Planet Position", Vector) = (0,0,0)
        _PlanetR ("Planet radius", Float) = 0
        _TileSize ("Tile Size", Float) = 1.0
        _transitionNum ("color number", Float) = 1.0
        _CliffSize ("_Cliff Size", Float) = 1.0

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
         #pragma surface surf Lambert vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        // Include directive to calculate world position
        //#pragma include "UnityCG.cginc"

        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////perlin noise
        float hash(float3 p) {
            p = float3(dot(p, float3(127.1, 311.7, 74.7)),
                       dot(p, float3(269.5, 183.3, 246.1)),
                       dot(p, float3(113.5, 271.9, 124.6)));
            return frac(sin(dot(p, float3(1.0, 1.0, 1.0))) * 43758.5453);
        }

        // Gradient Noise function
        float GenerateGradientNoise(float3 p) {
            float3 i = floor(p);
            float3 f = frac(p);

            // Compute gradients at the cube's corners
            float n000 = hash(i + float3(0, 0, 0));
            float n100 = hash(i + float3(1, 0, 0));
            float n010 = hash(i + float3(0, 1, 0));
            float n110 = hash(i + float3(1, 1, 0));
            float n001 = hash(i + float3(0, 0, 1));
            float n101 = hash(i + float3(1, 0, 1));
            float n011 = hash(i + float3(0, 1, 1));
            float n111 = hash(i + float3(1, 1, 1));

            // Interpolate between the gradients
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
        
                gradientNoiseValue += pow(abs( gradientNoiseValuePlus), power);

                mountenrelativeSize /= iterationSize;
                mountenrelativeDistortion *= iterationSize;
            }
    
            return gradientNoiseValue * intensity;
        }

        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////perlin noise end
       float PointingToDirection(float3 direction, float3 referenceDirection)
       {
            // Normalize the input vectors if they are not already normalized
            direction = normalize(direction);
            referenceDirection = normalize(referenceDirection);
    
            // Calculate the dot product between the direction vector and the reference direction
            float dotProduct = dot(direction, referenceDirection);
    
    
            return clamp(dotProduct ,0 ,1  );
       }

        sampler2D _Biom1MainTex;
        sampler2D _Biom1NormalMap;
        sampler2D _Biom1MainTex2;
        sampler2D _Biom1NormalMap2;
        sampler2D _Biom1CliffMainTex;
        sampler2D _Biom1CliffNormalMap;
        sampler2D _Biom2MainTex;
        sampler2D _Biom2NormalMap;
        sampler2D _Biom2MainTex2;
        sampler2D _Biom2NormalMap2;
        sampler2D _Biom2CliffMainTex;
        sampler2D _Biom2CliffNormalMap;

        float3 _PlanetPosition;
        float _TileSize;
        float _transitionNum;
        float _PlanetR;
        float _CliffSize;

        float _BiomTransotionNum;
        float _BiomNoiseFrequency;
        float _BiomNoiseIterations;
        float _BiomNoiseIterationSize;
        float _BiomNoisePower;
        float _BiomNoiseIntensity;

        struct Input
        {
            float2 uv_Biom1MainTex;
            float3 normal; 
            float3 worldPos;      
            INTERNAL_DATA
        };


        float _Glossiness;
        float _Metallic;
        fixed4 _Color;

        float _NoiseFrequency;
        int _NoiseIterations;
        float _NoiseIterationSize;
        float _NoisePower;
        float _NoiseIntensity;


       void vert (inout appdata_full v, out Input o) {
          UNITY_INITIALIZE_OUTPUT(Input,o);
          o.normal = abs(v.normal);
       }

       void surf (Input IN, inout SurfaceOutput  o)
       {
           // Scale UV coordinates by the tile size
           float2 uv = IN.uv_Biom1MainTex * _TileSize;

           // Albedo textures
           fixed4 albedo1 = tex2D(_Biom1MainTex, uv) * _Color;
           fixed4 albedoCliff1 = tex2D(_Biom1CliffMainTex, uv) * _Color;
           fixed4 albedoBiom2_1 = tex2D(_Biom2MainTex, uv) * _Color;
           fixed4 albedoCliff2 = tex2D(_Biom2CliffMainTex, uv) * _Color;

           // Normal maps
           fixed3 normalMap1 = UnpackNormal(tex2D(_Biom1NormalMap, uv));
           fixed3 normalCliff1 = UnpackNormal(tex2D(_Biom1CliffNormalMap, uv));
           fixed3 normalBiom2_1 = UnpackNormal(tex2D(_Biom2NormalMap, uv));
           fixed3 normalCliff2 = UnpackNormal(tex2D(_Biom2CliffNormalMap, uv));

           float3 relativePos = IN.worldPos - _PlanetPosition;

           float TerrainNoiseValue1 = generateComplexGradientNoise(relativePos, _NoiseFrequency, _NoiseIterations, _NoiseIterationSize, _NoisePower, _NoiseIntensity);
           float TerrainNoiseValue2 = generateComplexGradientNoise(relativePos+float3(1000,1000,1000), _NoiseFrequency, _NoiseIterations, _NoiseIterationSize, _NoisePower, _NoiseIntensity);
           float TerrainNoiseValue3 = generateComplexGradientNoise(relativePos+float3(5000,5000,5000), _NoiseFrequency, _NoiseIterations, _NoiseIterationSize, _NoisePower, _NoiseIntensity);

           float BiomNoiseValue = generateComplexGradientNoise(relativePos+float3(-1000,-1000,-1000), _BiomNoiseFrequency, _BiomNoiseIterations, _BiomNoiseIterationSize, _BiomNoisePower, _BiomNoiseIntensity);

           float lerpDivideValue =  (_NoiseIntensity*_NoiseIterations);
           float3 terrainColorChange = pow( float3(TerrainNoiseValue1 / lerpDivideValue ,TerrainNoiseValue2 / lerpDivideValue ,TerrainNoiseValue3 / lerpDivideValue ),_transitionNum);

           float BiomChange = pow( BiomNoiseValue / _BiomNoiseIterations ,_BiomTransotionNum);
           BiomChange = clamp(BiomChange,0,1);

           float howMuchpointingToTheSides =  clamp ( dot(IN.normal ,normalize( abs( IN.worldPos)) ), 0,1) ;
           howMuchpointingToTheSides = pow( howMuchpointingToTheSides,_CliffSize);

           float3 terrainColor1 = lerp(albedoCliff1,albedo1 * terrainColorChange,howMuchpointingToTheSides);
           float3 terrainNormalColor1 = lerp(normalCliff1,normalMap1,howMuchpointingToTheSides);

           float3 terrainColor2 = lerp(albedoCliff2,albedoBiom2_1 * terrainColorChange,howMuchpointingToTheSides);
           float3 terrainNormalColor2 = lerp(normalCliff2,normalBiom2_1,howMuchpointingToTheSides);

           float3 FinalTerrainColor2 = lerp(terrainColor1,terrainColor2,BiomChange);
           float3 FinalTerrainNormalColor2 = lerp(terrainNormalColor1,terrainNormalColor2,BiomChange);

           // Metallic and smoothness come from slider variables
           o.Specular = _Metallic;
           o.Gloss = _Glossiness;
           o.Alpha = 1;
           o.Albedo =FinalTerrainColor2;
           o.Normal = FinalTerrainNormalColor2;
       }
        ENDCG
    }
    FallBack "Diffuse"
}
