Shader "Hidden/Water&Atmosphere"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it uses non-square matrices
#pragma exclude_renderers gles
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Includes/Math.cginc"
			//

			struct appdata {
					float4 vertex : POSITION;
					float4 uv : TEXCOORD0;
			};

			struct v2f {
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
					float3 viewVector : TEXCOORD1;
			};

			v2f vert (appdata v) {
					v2f output;
					output.pos = UnityObjectToClipPos(v.vertex);
					output.uv = v.uv;
					// Camera space matches OpenGL convention where cam forward is -z. In unity forward is positive z.
					// (https://docs.unity3d.com/ScriptReference/Camera-cameraToWorldMatrix.html)
					float3 viewVector = mul(unity_CameraInvProjection, float4(v.uv.xy * 2 - 1, 0, -1));
					output.viewVector = mul(unity_CameraToWorld, float4(viewVector,0));
					return output;
			}
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
			sampler2D _MainTex;
			sampler2D _CameraDepthTexture;
			float3 _PlanetPos;
			float _PlanetRadius;
			float _mul;
			float _exp;
			sampler2D _oceanColor;
			float _oceanBottom;
		    float CalculateDistanceToTheFarhestVisiblePointOnSphere(float r, float h )
			{
				
				// Calculate the distance using the Pythagorean theorem
				float distance = sqrt(h * h - r * r);
				return distance;
				        
			}

			float3 GetRaySphereIntersection(float radius, float3 rayDirection, float3 rayPosition)
			{
				// Calculate the vector from the origin (sphere center) to the ray's origin
				float3 originToRay = rayPosition;
    
				// Calculate the coefficients of the quadratic equation
				float a = dot(rayDirection, rayDirection);
				float b = 2.0 * dot(originToRay, rayDirection);
				float c = dot(originToRay, originToRay) - radius * radius;
    
				// Calculate the discriminant
				float discriminant = b * b - 4.0 * a * c;
    
				// If the discriminant is negative, there is no intersection
				if (discriminant < 0.0)
				{
					return float3(0.0, 0.0, 0.0); // No intersection, return a default value
				}
    
				// Calculate the distance to the intersection point (only the nearest intersection)
				float sqrtDiscriminant = sqrt(discriminant);
				float t = (-b - sqrtDiscriminant) / (2.0 * a);
    
				// Compute the intersection point
				float3 intersectionPoint = rayPosition + t * rayDirection;
    
				return intersectionPoint;
			}
			float NthRoot(float x, float n)
			{
				return pow(x, 1.0 / n);
			}
			float3 _sunDir;
			float _sunIntensity;
			float4 _sunColor;

			float freqency = 1.0f;
			int iterations = 5;
			float iterationSize = 2.0f;
			float power = 2.0f;
			float Intensity = 2.0f;
			float _waveStreanght;
			float _atmosphereSize;
			float _atmosphereDensity;

			float3 CalculatePosOnPlanet(float3 pos) {
				float3 SpherePosition = normalize(pos) * _PlanetRadius;

				float gradientNoise =  generateComplexGradientNoise(SpherePosition, freqency, iterations, iterationSize, power,Intensity);
				return SpherePosition * (1 + (gradientNoise ));
			}
			float3x3 GeneratePerpendicularDirections(float3 inputDir)
			{
				inputDir = normalize(inputDir);
            
				// Generate the first perpendicular direction
				float3 up = abs(inputDir.y) < 0.999 ? float3(0, 1, 0) : float3(1, 0, 0);
				float3 perpendicular1 = normalize(cross(inputDir, up));
            
				// Generate the second perpendicular direction
				float3 perpendicular2 = cross(inputDir, perpendicular1);
            
				// Construct the float3x3 matrix
				return float3x3(perpendicular1, perpendicular2, inputDir);
			}

			float3 CalculateNormalDir(float3 finalPos)
			{
				float3 normalizeDfinalPos = normalize(finalPos);

				float delta = 1.0f ; // Small delta for finite differences

				float3x3 NormalPos = GeneratePerpendicularDirections(normalizeDfinalPos);

				// Scale the perpendicular directions by delta
				NormalPos = NormalPos * delta;

				// Calculate positions on the planet
				float3 worldPos1 = CalculatePosOnPlanet(NormalPos[0] + finalPos / _PlanetRadius);
				float3 worldPos2 = CalculatePosOnPlanet(NormalPos[1] + finalPos/ _PlanetRadius);

				float3 direction1 = worldPos1 - finalPos;
				float3 direction2 = worldPos2 - finalPos;

				// Calculate the cross product of worldPos1 and worldPos2
				float3 normal = cross(normalize(direction1),normalize( direction2));

				// Return the normalized normal vector

				return lerp(normalize(finalPos),normal,_waveStreanght);
			}

			float4 findAtmosphereColor(float3 hit,float3 exit,float4 originalCol,bool inAtmosphere, float atmosphereR)
			{
				return originalCol + float4(0.1,0.1,0.1,0);
			}

			float4 findOceanColor(float3 hit,float3 exit,float4 originalCol,bool inWater)
			{
				float endStartDis = distance(hit,exit);

				float whatWaterColor = min(endStartDis/_oceanBottom,0.5);

				float4 _color = tex2D( _oceanColor  ,float2(whatWaterColor,0) );

				endStartDis = min(NthRoot(endStartDis/_PlanetRadius,_exp)*_mul,1);

                float3 lightDir = normalize(_sunDir.xyz);

				float3 normalDir ;
				//float test =generateComplexGradientNoise(hit, freqency, iterations, iterationSize, power,Intensity  );
				if(inWater == true)
				{
					 normalDir = CalculateNormalDir(exit);
				}else{
					 normalDir = CalculateNormalDir(hit);
				}
				
				float pointShine = dot(normalDir,lightDir*-1)*0.5+0.5;

				//pointShine *=0.5;
				float sunIntensityModifi = NthRoot( _sunIntensity ,2)/2;
				_color = lerp(float4(0,0,0,1), float4(_color.x+pointShine*sunIntensityModifi*_sunColor.x,_color.y+pointShine*sunIntensityModifi*_sunColor.y,_color.z+pointShine*sunIntensityModifi*_sunColor.z,1),pointShine*sunIntensityModifi );
				return lerp(originalCol,_color, endStartDis);//float4(test,test,test,1);//lerp(originalCol,_color, endStartDis);
			}

			struct getHit1Hit2onSphereOutput
			{
				float3 enter;
				float3 stop;
				bool interacted;
				bool inWater;
			};
			getHit1Hit2onSphereOutput getHit1Hit2onSphere(float3 _PlanetPos,float3 PlayerPos ,float3 rayDir ,float _PlanetRadius,float sceneDepth)
			{
				getHit1Hit2onSphereOutput result ;

				float PlayerPlanetDis = distance(PlayerPos, _PlanetPos);
				
				float DistanceToTheFarhestVisiblePointOnSphere = CalculateDistanceToTheFarhestVisiblePointOnSphere(_PlanetRadius,PlayerPlanetDis);

				float3 rayMiddleplanetPos = rayDir*DistanceToTheFarhestVisiblePointOnSphere+PlayerPos;

				float rayMiddlePlanetDis = distance(rayMiddleplanetPos,_PlanetPos);

				//return float4(sceneDepth/20,sceneDepth/20,sceneDepth/20,1);

				if (PlayerPlanetDis < _PlanetRadius )
				{
					
					float3 PlayerRelativePos = PlayerPos - _PlanetPos;

					result.enter = PlayerRelativePos;
					float3 endhit = GetRaySphereIntersection(_PlanetRadius,rayDir*-1,PlayerRelativePos);

					result.stop = min(distance(endhit,PlayerPos),sceneDepth) * rayDir + PlayerPos;
					result.interacted = true;
					result.inWater= true;
				
					return result;

				}else if(rayMiddlePlanetDis<_PlanetRadius )
				{
					result.inWater = false;
					float3 startHit = GetRaySphereIntersection(_PlanetRadius,rayDir,rayMiddleplanetPos- _PlanetPos);
					

					if(distance(startHit,PlayerPos)> sceneDepth)
					{
						result.interacted = false;
						return result;
					}else
					{
						result.interacted = true;
						result.enter = startHit;
						float3 endhit = GetRaySphereIntersection(_PlanetRadius,rayDir*-1,rayMiddleplanetPos - _PlanetPos);
						result.stop= min(distance(endhit,PlayerPos), sceneDepth) * rayDir + PlayerPos;
						//float3 test = GetRaySphereIntersection(1,float3(0,0,0),float3(0,0.5,0));
					
						return result;

					}					
				}else
				{
					result.interacted = false;
					return result;
				}
			}

			float4 frag (v2f i) : SV_Target
			{
				float4 originalCol = tex2D(_MainTex, i.uv);
				float sceneDepthNonLinear = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
				float sceneDepth = LinearEyeDepth(sceneDepthNonLinear) * length(i.viewVector);
											
				float3 PlayerPos = _WorldSpaceCameraPos;
				float3 rayDir = normalize(i.viewVector);
				
				getHit1Hit2onSphereOutput atmosphereHitsInf = getHit1Hit2onSphere( _PlanetPos, PlayerPos , rayDir , _atmosphereSize, sceneDepth);
				getHit1Hit2onSphereOutput waterHitsInf = getHit1Hit2onSphere( _PlanetPos, PlayerPos , rayDir , _PlanetRadius, sceneDepth);

				if(atmosphereHitsInf.interacted == true  )
				{
					if(waterHitsInf.interacted == true)
					{
						if(waterHitsInf.inWater == true)
						{
							originalCol = findOceanColor(waterHitsInf.stop, atmosphereHitsInf.stop,originalCol,atmosphereHitsInf.inWater);
						}else originalCol = findOceanColor(atmosphereHitsInf.enter, waterHitsInf.enter,originalCol,atmosphereHitsInf.inWater);

					}else originalCol = findOceanColor(atmosphereHitsInf.enter, atmosphereHitsInf.stop,originalCol,atmosphereHitsInf.inWater);					
				} 

				if(waterHitsInf.interacted == true)
				{
					originalCol = findOceanColor(waterHitsInf.enter, waterHitsInf.stop,originalCol,waterHitsInf.inWater);
				} 
							
				return originalCol; 
			}

			

			ENDCG
		}
		
	}
}