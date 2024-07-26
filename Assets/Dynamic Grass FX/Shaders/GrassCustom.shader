// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Bytesized/GrassCustom"
{
    Properties
    {
		[Header(Shading)]
        _TopColor("Top Color", Color) = (0.57, 0.84, 0.32, 1.0)
		_BottomColor("Bottom Color", Color) = (0.0625, 0.375, 0.07, 1.0)
		_TranslucentGain("Translucent Gain", Range(0,1)) = 0.5
		[Header(Wind)]
		_WindStrength("Wind Strength", Range(0.0001, 1)) = 0.3
		[Header(Spacing)]
		_ViewLOD ("View Radius", Float) = 48
		_MaxStages ("Max Stages", Range(2, 64)) = 7
		_BaseStages ("Base Stages", Range(-64, 64)) = -0.5
		[Header(Grass Blades)]
		_BladeWidth("Blade Width", Range(0, 0.4)) = 0.05
		_BladeWidthRandom("Blade Width Random", Range(0, 0.4)) = 0.02
		_BladeHeight("Blade Height", Float) = 0.5
		_BladeHeightRandom("Blade Height Random", Float) = 0.3
		_BladeForward("Blade Stiffness Amount", Range(0, 1)) = 0.38
		_BladeCurve("Blade Curvature Amount", Range(1, 4)) = 2
		_BendRotationRandom("Bend Rotation Random", Range(0, 1)) = 0.2


        _Biom1MainTex ("Biom1 Albedo (RGB)1", Color)= (1, 1, 1.0)

        _Biom2MainTex ("Biom2 Albedo (RGB)1", Color) = (1, 1, 1.0)
        
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
        _transitionNum ("color number", Float) = 1.0
        _CliffSize ("_Cliff Size", Range(0, 1)) = 1.0
    }

	CGINCLUDE
	#include "UnityCG.cginc"
	#include "Autolight.cginc"
	/* Include the tesselation, hull and domain shader which will help us increase the amount of grass on the mesh depending on the distance from the camera. */
	#include "GrassTessellation.cginc"
	/* Include some helper functions for creating matrices and random numbers */
	#include "Helpers.cginc"
	
	struct geometryOutput
    {
        float4 color : TEXCOORD2;
        float4 pos : SV_POSITION;        
        float3 normal : NORMAL;
        float2 uv : TEXCOORD0;
        unityShadowCoord4 _ShadowCoord : TEXCOORD1;
    };

	float4 _Biom1MainTex;
    float4 _Biom2MainTex;

    float3 _PlanetPosition;
    float _TileSize;
    float _transitionNum;
    float _CliffSize;

    float _BiomTransotionNum;
    float _BiomNoiseFrequency;
    float _BiomNoiseIterations;
    float _BiomNoiseIterationSize;
    float _BiomNoisePower;
    float _BiomNoiseIntensity;

    float _NoiseFrequency;
    int _NoiseIterations;
    float _NoiseIterationSize;
    float _NoisePower;
    float _NoiseIntensity;

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

	float4 getColor(float3 pos )
	{
		
          float3 relativePos = mul(unity_ObjectToWorld,pos).xyz - _PlanetPosition;

          float TerrainNoiseValue1 = generateComplexGradientNoise(relativePos, _NoiseFrequency, _NoiseIterations, _NoiseIterationSize, _NoisePower, _NoiseIntensity);
          float BiomNoiseValue = generateComplexGradientNoise(relativePos+float3(-1000,-1000,-1000), _BiomNoiseFrequency, _BiomNoiseIterations, _BiomNoiseIterationSize, _BiomNoisePower, _BiomNoiseIntensity);

          float lerpDivideValue =  (_NoiseIntensity*_NoiseIterations);
          float3 terrainColorChange = pow( TerrainNoiseValue1 / lerpDivideValue ,_transitionNum) * float3(1,1,1);

          float BiomChange = pow( BiomNoiseValue / _BiomNoiseIterations ,_BiomTransotionNum);
          BiomChange = clamp(BiomChange,0,1);

          //float howMuchpointingToTheSides =  clamp ( dot( abs(normal) ,normalize( abs( relativePos)) ), 0,1) ;
          // howMuchpointingToTheSides = pow( howMuchpointingToTheSides,_CliffSize);

          float3 terrainColor1 = _Biom1MainTex.xyz * terrainColorChange;

          float3 terrainColor2 = _Biom2MainTex.xyz * terrainColorChange;

          float3 FinalTerrainColor2 = lerp(terrainColor1,terrainColor2,BiomChange);

		  return float4(FinalTerrainColor2,1);
	}
	geometryOutput VertexOutput(float3 pos, float3 normal, float2 uv)
	{
		geometryOutput o;
		o.color = getColor(pos);
		o.pos = UnityObjectToClipPos(pos);
		o.normal = UnityObjectToWorldNormal(normal);
		o.uv = uv;
		o._ShadowCoord = ComputeScreenPos(o.pos);
	#if UNITY_PASS_SHADOWCASTER
		o.pos = UnityApplyLinearShadowBias(o.pos);
	#endif
		return o;
	}

	/* Create a vertex of the grass blade, increasing its scale the further away it is from the camera. This allows us to generate less grass the farther away from the camera it is. Improves performance. */
	geometryOutput GenerateGrassVertex(float3 vertexPosition, float width, float height, float forward, float2 uv, float3x3 transformMatrix)
	{
		float distanceFromCamera = 1.0 + max(0.0, min(1.0, distance(mul(unity_ObjectToWorld, float4(vertexPosition, 1)).xyz, _WorldSpaceCameraPos) / _ViewLOD)) * 2.0;
		float3 tangentPoint = float3(width, forward, height);
		float3 tangentNormal = normalize(float3(0, -1, forward));
		float3 localPosition = vertexPosition + mul(transformMatrix, tangentPoint) * distanceFromCamera;
		float3 localNormal = mul(transformMatrix, tangentNormal);
		return VertexOutput(localPosition, localNormal, uv);
	}

	float _BladeHeight;
	float _BladeHeightRandom;
	float _BladeWidthRandom;
	float _BladeWidth;
	float _BladeForward;
	float _BladeCurve;
	float _BendRotationRandom;
	float _WindStrength;
	#define BLADE_SEGMENTS 3

	/* Geometry shader that takes in a single vertex and outputs a grass blade. We need 2 vertices per segment and one for the tip */
	[maxvertexcount(BLADE_SEGMENTS * 2 + 1)]
	void geo(point vertexOutput IN[1], inout TriangleStream<geometryOutput> triStream)
	{
		/*
		* Each blade of grass is constructed in tangent space with respect
		* to the emitting vertex's normal and tangent vectors, where the width
		* lies along the X axis and the height along Z.
		*/
		float3 pos = IN[0].vertex.xyz;

		float3 worldNormal =mul( unity_ObjectToWorld, float4( IN[0].normal, 0.0 ) ).xyz; 
		float3 worldPos =mul(unity_ObjectToWorld, IN[0].vertex).xyz - _PlanetPosition;

		float howMuchpointingToTheSides =   dot( worldNormal ,normalize(  worldPos) ) ;
		if(howMuchpointingToTheSides>_CliffSize)
		{
            /* Construct rotation 2 matrices, one to make the blade face in a random rotation and the other to make the blade bend into the direction its facing */
			float3x3 facingRotationMatrix = RotationMatrix(rand(pos) * UNITY_TWO_PI, float3(0, 0, 1));
			float3x3 bendRotationMatrix = RotationMatrix(rand(pos.zzx) * _BendRotationRandom * UNITY_PI * 0.5, float3(-1, 0, 0));
			/* Simulate the wind effect by feeding an unique seed to the sine & cosine functions */
			float2 windValue = float2(cos(_Time.y + pos.x + pos.z), sin(_Time.y + pos.x + pos.z)) * _WindStrength * .25;
			/* Build a rotation matrix from the wind sample and a normalized vector of it. */
			float3x3 windRotation = RotationMatrix(UNITY_PI * windValue, normalize(float3(windValue.x, windValue.y, 0)));
			/* Create a matrix to transform the vertices from tangent space to local space. This method is from Helpers.cginc */
			float3x3 tangentToLocal = TangentToLocal(IN[0].normal, IN[0].tangent);
			/* Create a new matrix that contains all of out transformations (wind, bend, facing, tangentToLocal). */
			float3x3 transformationMatrix = mul(mul(mul(tangentToLocal, windRotation), facingRotationMatrix), bendRotationMatrix);
			/* Create the same as above but without any bending. This will be used for the root segement of the grass blade. */
			float3x3 transformationMatrixWithoutBending = mul(tangentToLocal, facingRotationMatrix);

			/* Apply some randomness to the transformation values. */
			float height = (rand(pos.zyx) * 2 - 1) * _BladeHeightRandom + _BladeHeight;
			float width = (rand(pos.xzy) * 2 - 1) * _BladeWidthRandom + _BladeWidth;
			float forward = rand(pos.yyz) * _BladeForward;
			for (int i = 0; i < BLADE_SEGMENTS; i++)
			{
				/* For each segment the width should decrease and the height should increase. */
				float t = i / (float)BLADE_SEGMENTS;
				float segmentHeight = height * t;
				float segmentWidth = width * (1 - t);
				float segmentForward = pow(t, _BladeCurve) * forward;

				/* For the root segment use the matrix without bending */
				float3x3 transformMatrix = i == 0 ? transformationMatrixWithoutBending : transformationMatrix;
				/* Create the necessary vertices to complete the triangle strip */
				triStream.Append(GenerateGrassVertex(pos, segmentWidth, segmentHeight, segmentForward, float2(0, t), transformMatrix) );
				triStream.Append(GenerateGrassVertex(pos, -segmentWidth, segmentHeight, segmentForward, float2(1, t), transformMatrix) );
			}
			/* End the triangle strip by adding the tip of the grass blade */
			triStream.Append(GenerateGrassVertex(pos, 0, height, forward, float2(0.5, 1), transformationMatrix));
		}
	}


	

	ENDCG

    SubShader
    {
		//Cull Off

        Pass
        {
			Tags
			{
				"RenderType" = "Diffuse"
				"LightMode" = "ForwardBase"
			}

			// Enable depth writing
            ZWrite On
            // Set the depth testing mode
            ZTest LEqual

            CGPROGRAM
            #pragma vertex vert
			#pragma geometry geo
            #pragma fragment frag
			#pragma hull hull
			#pragma domain domain
			#pragma target 4.6
			#pragma multi_compile_fwdbase
            
			#include "Lighting.cginc"

			float4 _TopColor;
			float4 _BottomColor;
			float _TranslucentGain;

			

			float4 frag(geometryOutput i,  fixed facing : VFACE) : SV_Target
            {
				/* Do some lighting on the fragments of the grass blade */	
				float3 normal = facing > 0 ? i.normal : -i.normal;
				float shadow = SHADOW_ATTENUATION(i);
				float NdotL = saturate(saturate(dot(normal, _WorldSpaceLightPos0)) + _TranslucentGain) * shadow;
				float3 ambient = ShadeSH9(float4(normal, 1));
				float4 lightIntensity = NdotL * _LightColor0 + float4(ambient, 1);
				/* Paint the grass by interpolating between the colors passed as uniforms */
				float4 finalColor =lerp(_BottomColor*  lightIntensity * i.color , _TopColor * lightIntensity * i.color, i.uv.y)*4;
				return float4(finalColor.xyz,1);
            }
            ENDCG
        }

		
    }
	FallBack "Diffuse"
}
