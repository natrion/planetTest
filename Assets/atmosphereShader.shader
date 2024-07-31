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
			// Cellular noise ("Worley noise") in 3D in HLSL.
			// Based on Stefan Gustavson's GLSL implementation.

			float3 mod289(float3 x) {
				return x - floor(x * (1.0 / 289.0)) * 289.0;
			}

			float3 mod7(float3 x) {
				return x - floor(x * (1.0 / 7.0)) * 7.0;
			}

			float3 permute(float3 x) {
				return mod289((34.0 * x + 1.0) * x);
			}

			float2 cellular(float3 P) {
				#define K 0.142857142857 // 1/7
				#define Ko 0.428571428571 // 1/2-K/2
				#define K2 0.020408163265306 // 1/(7*7)
				#define Kz 0.166666666667 // 1/6
				#define Kzo 0.416666666667 // 1/2-1/6*2
				#define jitter 1.0 // smaller jitter gives more regular pattern

				float3 Pi = mod289(floor(P));
				float3 Pf = frac(P) - 0.5;

				float3 Pfx = Pf.x + float3(1.0, 0.0, -1.0);
				float3 Pfy = Pf.y + float3(1.0, 0.0, -1.0);
				float3 Pfz = Pf.z + float3(1.0, 0.0, -1.0);

				float3 p = permute(Pi.x + float3(-1.0, 0.0, 1.0));
				float3 p1 = permute(p + Pi.y - 1.0);
				float3 p2 = permute(p + Pi.y);
				float3 p3 = permute(p + Pi.y + 1.0);

				float3 p11 = permute(p1 + Pi.z - 1.0);
				float3 p12 = permute(p1 + Pi.z);
				float3 p13 = permute(p1 + Pi.z + 1.0);

				float3 p21 = permute(p2 + Pi.z - 1.0);
				float3 p22 = permute(p2 + Pi.z);
				float3 p23 = permute(p2 + Pi.z + 1.0);

				float3 p31 = permute(p3 + Pi.z - 1.0);
				float3 p32 = permute(p3 + Pi.z);
				float3 p33 = permute(p3 + Pi.z + 1.0);

				float3 ox11 = frac(p11*K) - Ko;
				float3 oy11 = mod7(floor(p11*K))*K - Ko;
				float3 oz11 = floor(p11*K2)*Kz - Kzo; // p11 < 289 guaranteed

				float3 ox12 = frac(p12*K) - Ko;
				float3 oy12 = mod7(floor(p12*K))*K - Ko;
				float3 oz12 = floor(p12*K2)*Kz - Kzo;

				float3 ox13 = frac(p13*K) - Ko;
				float3 oy13 = mod7(floor(p13*K))*K - Ko;
				float3 oz13 = floor(p13*K2)*Kz - Kzo;

				float3 ox21 = frac(p21*K) - Ko;
				float3 oy21 = mod7(floor(p21*K))*K - Ko;
				float3 oz21 = floor(p21*K2)*Kz - Kzo;

				float3 ox22 = frac(p22*K) - Ko;
				float3 oy22 = mod7(floor(p22*K))*K - Ko;
				float3 oz22 = floor(p22*K2)*Kz - Kzo;

				float3 ox23 = frac(p23*K) - Ko;
				float3 oy23 = mod7(floor(p23*K))*K - Ko;
				float3 oz23 = floor(p23*K2)*Kz - Kzo;

				float3 ox31 = frac(p31*K) - Ko;
				float3 oy31 = mod7(floor(p31*K))*K - Ko;
				float3 oz31 = floor(p31*K2)*Kz - Kzo;

				float3 ox32 = frac(p32*K) - Ko;
				float3 oy32 = mod7(floor(p32*K))*K - Ko;
				float3 oz32 = floor(p32*K2)*Kz - Kzo;

				float3 ox33 = frac(p33*K) - Ko;
				float3 oy33 = mod7(floor(p33*K))*K - Ko;
				float3 oz33 = floor(p33*K2)*Kz - Kzo;

				float3 dx11 = Pfx + jitter*ox11;
				float3 dy11 = Pfy.x + jitter*oy11;
				float3 dz11 = Pfz.x + jitter*oz11;

				float3 dx12 = Pfx + jitter*ox12;
				float3 dy12 = Pfy.x + jitter*oy12;
				float3 dz12 = Pfz.y + jitter*oz12;

				float3 dx13 = Pfx + jitter*ox13;
				float3 dy13 = Pfy.x + jitter*oy13;
				float3 dz13 = Pfz.z + jitter*oz13;

				float3 dx21 = Pfx + jitter*ox21;
				float3 dy21 = Pfy.y + jitter*oy21;
				float3 dz21 = Pfz.x + jitter*oz21;

				float3 dx22 = Pfx + jitter*ox22;
				float3 dy22 = Pfy.y + jitter*oy22;
				float3 dz22 = Pfz.y + jitter*oz22;

				float3 dx23 = Pfx + jitter*ox23;
				float3 dy23 = Pfy.y + jitter*oy23;
				float3 dz23 = Pfz.z + jitter*oz23;

				float3 dx31 = Pfx + jitter*ox31;
				float3 dy31 = Pfy.z + jitter*oy31;
				float3 dz31 = Pfz.x + jitter*oz31;

				float3 dx32 = Pfx + jitter*ox32;
				float3 dy32 = Pfy.z + jitter*oy32;
				float3 dz32 = Pfz.y + jitter*oz32;

				float3 dx33 = Pfx + jitter*ox33;
				float3 dy33 = Pfy.z + jitter*oy33;
				float3 dz33 = Pfz.z + jitter*oz33;

				float3 d11 = dx11 * dx11 + dy11 * dy11 + dz11 * dz11;
				float3 d12 = dx12 * dx12 + dy12 * dy12 + dz12 * dz12;
				float3 d13 = dx13 * dx13 + dy13 * dy13 + dz13 * dz13;
				float3 d21 = dx21 * dx21 + dy21 * dy21 + dz21 * dz21;
				float3 d22 = dx22 * dx22 + dy22 * dy22 + dz22 * dz22;
				float3 d23 = dx23 * dx23 + dy23 * dy23 + dz23 * dz23;
				float3 d31 = dx31 * dx31 + dy31 * dy31 + dz31 * dz31;
				float3 d32 = dx32 * dx32 + dy32 * dy32 + dz32 * dz32;
				float3 d33 = dx33 * dx33 + dy33 * dy33 + dz33 * dz33;

				// Sort out the two smallest distances (F1, F2)
				#if true
				// Cheat and sort out only F1
				float3 d1 = min(min(d11,d12), d13);
				float3 d2 = min(min(d21,d22), d23);
				float3 d3 = min(min(d31,d32), d33);
				float3 d = min(min(d1,d2), d3);
				d.x = min(min(d.x,d.y),d.z);
				return float2(sqrt(d.x)); // F1 duplicated, no F2 computed
				#else
				// Do it right and sort out both F1 and F2
				float3 d1a = min(d11, d12);
				d12 = max(d11, d12);
				d11 = min(d1a, d13); // Smallest now not in d12 or d13
				d13 = max(d1a, d13);
				d12 = min(d12, d13); // 2nd smallest now not in d13
				float3 d2a = min(d21, d22);
				d22 = max(d21, d22);
				d21 = min(d2a, d23); // Smallest now not in d22 or d23
				d23 = max(d2a, d23);
				d22 = min(d22, d23); // 2nd smallest now not in d23
				float3 d3a = min(d31, d32);
				d32 = max(d31, d32);
				d31 = min(d3a, d33); // Smallest now not in d32 or d33
				d33 = max(d3a, d33);
				d32 = min(d32, d33); // 2nd smallest now not in d33
				float3 da = min(d11, d21);
				d21 = max(d11, d21);
				d11 = min(da, d31); // Smallest now in d11
				d31 = max(da, d31); // 2nd smallest now not in d31
				d11.xy = (d11.x < d11.y) ? d11.xy : d11.yx;
				d11.xz = (d11.x < d11.z) ? d11.xz : d11.zx; // d11.x now smallest
				d12 = min(d12, d21); // 2nd smallest now not in d21
				d12 = min(d12, d22); // nor in d22
				d12 = min(d12, d31); // nor in d31
				d12 = min(d12, d32); // nor in d32
				d11.yz = min(d11.yz,d12.xy); // nor in d12.yz
				d11.y = min(d11.y,d12.z); // Only two more to go
				d11.y = min(d11.y,d11.z); // Done! (Phew!)
				return sqrt(d11.xy); // F1, F2
				#endif
			}
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
			
			float generateComplexCellNoise(float3 pos, float frequency, int iterations, float iterationSize, float power, float intensity) {

				float gradientNoiseValue = 0.0;

				float mountenrelativeSize = 1.0;
				float mountenrelativeDistortion = 1.0;

				for (int i = 0; i < iterations; i++) {         
					float gradientNoiseValuePlus = 1- cellular(pos * frequency * mountenrelativeDistortion) * mountenrelativeSize;
        
					gradientNoiseValue += pow(abs( gradientNoiseValuePlus), power);

					mountenrelativeSize /= iterationSize;
					mountenrelativeDistortion *= iterationSize;
				}
    
				return gradientNoiseValue * intensity;
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
				float smallSpot = pow(GenerateGradientNoise((pos*frequency)/4),2);
				return gradientNoiseValue * intensity*smallSpot;
			}
			sampler2D _MainTex;
			sampler2D _CameraDepthTexture;
			float3 _PlanetPos;
			float _WaterRadius;
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
			float4 _atmosphereColor;

			float _atmosphericFallof;
			float _cloudsStepSize;
			float _cloudsFreqency = 1.0f;
			int _cloudsIterations = 5;
			float _cloudsIterationSize = 2.0f;
			float _cloudsPower = 2.0f;
			float _cloudsIntensity = 2.0f;

			float _cloudsLayerCentreConcetaration = 2.0f;
			float _cloudsLayerWith = 2.0f;
			float _cloudsHight = 2.0f;


			float4 _cloudColor;

			float3 CalculatePosOnPlanet(float3 pos) {
				float3 SpherePosition = normalize(pos) * _WaterRadius;

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
				float3 worldPos1 = CalculatePosOnPlanet(NormalPos[0] + finalPos / _WaterRadius);
				float3 worldPos2 = CalculatePosOnPlanet(NormalPos[1] + finalPos/ _WaterRadius);

				float3 direction1 = worldPos1 - finalPos;
				float3 direction2 = worldPos2 - finalPos;

				// Calculate the cross product of worldPos1 and worldPos2
				float3 normal = cross(normalize(direction1),normalize( direction2));

				// Return the normalized normal vector

				return lerp(normalize(finalPos),normal,_waveStreanght);
			}
			float AverageExpValue(float dist1, float dist2) {
				// Ensure dist1 and dist2 are within the range [0, 1]
				dist1 = clamp(dist1, 0.0, 1.0);
				dist2 = clamp(dist2, 0.0, 1.0);

				// Swap dist1 and dist2 if they are out of order
				if (dist1 > dist2) {
					float temp = dist1;
					dist1 = dist2;
					dist2 = temp;
				}

				// Calculate the integral of 1/x from dist1 to dist2
				float integralDist1 = log(dist1);
				float integralDist2 = log(dist2);

				// Calculate the average value
				float average = (integralDist2 - integralDist1) / (dist2 - dist1);

				return average;
			}

			float4 findAtmosphereColor(float3 hit,float3 exit,float4 originalCol,bool inAtmosphere)
			{
				//float atmosphereSize = _atmosphereSize ;
				//float hightFromSeeLevel0to1 = (( distance(lerp(hit,exit,0.5),_PlanetPos) - _WaterRadius+_atmosphericFallof) )/(atmosphereSize - _WaterRadius+_atmosphericFallof);
				//float avarageDesnsity = 1/(max(hightFromSeeLevel0to1,0.01));
				float3 midlePoint = lerp(hit,exit,0.5);
				float3 distances = float3((  distance(hit,_PlanetPos)-_WaterRadius) / (_atmosphereSize-_WaterRadius),(distance(midlePoint,_PlanetPos)-_WaterRadius) / (_atmosphereSize-_WaterRadius),( distance(exit,_PlanetPos)-_WaterRadius) / (_atmosphereSize-_WaterRadius));
			    distances = clamp(distances + float3(0.01,0.01,0.01),float3(0.001,0.001,0.001),float3(1,1,1));
				float avrg1 = AverageExpValue(distances.x,distances.y);
				float avrg2 = AverageExpValue(distances.y,distances.z);
				float avrgDensity = (avrg1 + avrg2)/2;
				avrgDensity = pow(avrgDensity, _atmosphericFallof);
				
				float endStartDis = distance(hit,exit);
				
				float cloudValue = 0;
				float distanceTraveld = 0;
				int maxTestSteps = 100;
				int steps = 0;
				while(endStartDis > distanceTraveld & maxTestSteps>steps)
				{										
					float3 pos = lerp(hit,exit,distanceTraveld/endStartDis);

					float hight =distance(pos, _PlanetPos)-_WaterRadius;
					float cloudsHightMulNum =  pow(_cloudsLayerWith / max(abs( hight- _cloudsHight),_cloudsLayerWith),_cloudsLayerCentreConcetaration);

					cloudValue += generateComplexGradientNoise(pos, _cloudsFreqency, _cloudsIterations, _cloudsIterationSize, _cloudsPower,_cloudsIntensity) * cloudsHightMulNum;
					
					distanceTraveld += _cloudsStepSize * max((abs( hight- _cloudsHight)/(_atmosphereSize-_WaterRadius))*25,1);
					steps++;
				}
				cloudValue = min(cloudValue,1);
				float mul  = endStartDis *avrgDensity* _atmosphereDensity;

				float4 cloudsPlusColor = _cloudColor * cloudValue;

				mul = clamp(mul,0,1);
				return lerp(originalCol , _atmosphereColor,mul)  + cloudsPlusColor ;//*avarageDesnsity;
			}
			float4 findOceanColor(float3 hit,float3 exit,float4 originalCol,bool inWater)
			{
				float endStartDis = distance(hit,exit);

				float whatWaterColor = min(endStartDis/_oceanBottom,0.5);

				float4 _color = tex2D( _oceanColor  ,float2(whatWaterColor,0) );

				endStartDis = min(NthRoot(endStartDis/_WaterRadius,_exp)*_mul,1);

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
			getHit1Hit2onSphereOutput getHit1Hit2onSphere(float3 _PlanetPos,float3 PlayerPos ,float3 rayDir ,float _WaterRadius,float sceneDepth)
			{
				getHit1Hit2onSphereOutput result ;

				float PlayerPlanetDis = distance(PlayerPos, _PlanetPos);
				
				float DistanceToTheFarhestVisiblePointOnSphere = CalculateDistanceToTheFarhestVisiblePointOnSphere(_WaterRadius,PlayerPlanetDis);

				float3 rayMiddleplanetPos = rayDir*DistanceToTheFarhestVisiblePointOnSphere+PlayerPos;

				float rayMiddlePlanetDis = distance(rayMiddleplanetPos,_PlanetPos);

				//return float4(sceneDepth/20,sceneDepth/20,sceneDepth/20,1);

				if (PlayerPlanetDis < _WaterRadius )
				{
					
					float3 PlayerRelativePos = PlayerPos - _PlanetPos;

					result.enter = PlayerRelativePos;
					float3 endhit = GetRaySphereIntersection(_WaterRadius,rayDir*-1,PlayerRelativePos);

					result.stop = min(distance(endhit,PlayerPos),sceneDepth) * rayDir + PlayerPos;
					result.interacted = true;
					result.inWater= true;
				
					return result;

				}else if(rayMiddlePlanetDis<_WaterRadius )
				{
					result.inWater = false;
					float3 startHit = GetRaySphereIntersection(_WaterRadius,rayDir,rayMiddleplanetPos- _PlanetPos);
					

					if(distance(startHit,PlayerPos)> sceneDepth)
					{
						result.interacted = false;
						return result;
					}else
					{
						result.interacted = true;
						result.enter = startHit;
						float3 endhit = GetRaySphereIntersection(_WaterRadius,rayDir*-1,rayMiddleplanetPos - _PlanetPos);
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
				getHit1Hit2onSphereOutput waterHitsInf = getHit1Hit2onSphere( _PlanetPos, PlayerPos , rayDir , _WaterRadius, sceneDepth);

				if(waterHitsInf.interacted == true)
				{
					originalCol = findOceanColor(waterHitsInf.enter, waterHitsInf.stop,originalCol,waterHitsInf.inWater);
				} 

				if(atmosphereHitsInf.interacted == true  )
				{
					if(waterHitsInf.interacted == true)
					{
						if(waterHitsInf.inWater == true)
						{
							originalCol = findAtmosphereColor(waterHitsInf.stop, atmosphereHitsInf.stop,originalCol,atmosphereHitsInf.inWater);
						}else originalCol = findAtmosphereColor(atmosphereHitsInf.enter, waterHitsInf.enter,originalCol,atmosphereHitsInf.inWater);

					}else originalCol = findAtmosphereColor(atmosphereHitsInf.enter, atmosphereHitsInf.stop,originalCol,atmosphereHitsInf.inWater);					
				} 
				
							
				return originalCol; 
			}

			

			ENDCG
		}
		
	}
}