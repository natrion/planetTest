Shader "Custom/atmosphere"
{
    Properties
    {
		_texture("Biom1 Albedo (RGB)1", 2D) = "white" {}
		_PlanetPos ("Planet Position", Vector) = (0,0,0)
        _sunDir ("Sun Direction", Vector) = (0,1,0)
        _sunIntensity ("Sun Intensity", Float) = 1.0
        _sunColor ("Sun Color", Color) = (1,1,1,1)
        _atmosphereSize ("Atmosphere Size", Float) = 100.0
        _atmosphereDensity ("Atmosphere Density", Float) = 1.0
        _atmosphereColor ("Atmosphere Color", Color) = (0.5,0.5,1,1)
        _atmosphericFallof ("Atmospheric Falloff", Float) = 1.0
        _cloudsStepSize ("Clouds Step Size", Float) = 1.0
        _cloudsFreqency ("Clouds Frequency", Float) = 1.0
        _cloudsIterations ("Clouds Iterations", Int) = 5
        _cloudsIterationSize ("Clouds Iteration Size", Float) = 2.0
        _cloudsPower ("Clouds Power", Float) = 2.0
        _cloudsIntensity ("Clouds Intensity", Float) = 2.0
        _cloudsLayerCentreConcetaration ("Clouds Layer Centre Concentration", Float) = 2.0
        _cloudsLayerWith ("Clouds Layer Width", Float) = 2.0
        _cloudsHight ("Clouds Height", Float) = 2.0
        _cloudColor ("Cloud Color", Color) = (1,1,1,1)
        _WaterRadius ("Water Radius", Float) = 50.0
    }
    SubShader
    {
        Tags { "Queue"="Overlay" } // Ensure the shader is rendered after opaque objects
        Pass
        {
            ZWrite On
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
			#include "ShaderIncludes/Math.cginc"

            		
			float hash(float3 p) {
				p = float3(dot(p, float3(127.1, 311.7, 74.7)),
							dot(p, float3(269.5, 183.3, 246.1)),
							dot(p, float3(113.5, 271.9, 124.6)));
				return frac(sin(dot(p, float3(1.0, 1.0, 1.0))) * 43758.5453);
			}

			sampler2D _texture;

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
				float smallSpot = pow(GenerateGradientNoise((pos*frequency)/4),2);
				return gradientNoiseValue * intensity*smallSpot;
			}
			float3 _PlanetPos;
			
			float NthRoot(float x, float n)
			{
				return pow(x, 1.0 / n);
			}
			float3 _sunDir;
			float _sunIntensity;
			float4 _sunColor;

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
			float _WaterRadius;
			float4 findAtmosphereColor(float3 hit,float3 exit,bool inAtmosphere)
			{
				float3 PlanetPos = float3(0,0,0);
				float3 midlePoint = lerp(hit,exit,0.5);
				float3 distances = float3((  distance(hit,PlanetPos)-_WaterRadius) / (_atmosphereSize-_WaterRadius),(distance(midlePoint,PlanetPos)-_WaterRadius) / (_atmosphereSize-_WaterRadius),( distance(exit,PlanetPos)-_WaterRadius) / (_atmosphereSize-_WaterRadius));
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

					float hight =distance(pos, PlanetPos)-_WaterRadius;
					float cloudsHightMulNum =  pow(_cloudsLayerWith / max(abs( hight- _cloudsHight),_cloudsLayerWith),_cloudsLayerCentreConcetaration);

					cloudValue += generateComplexGradientNoise(pos, _cloudsFreqency, _cloudsIterations, _cloudsIterationSize, _cloudsPower,_cloudsIntensity) * cloudsHightMulNum;
					
					distanceTraveld += _cloudsStepSize * max((abs( hight- _cloudsHight)/(_atmosphereSize-_WaterRadius))*50,1);
					steps++;
				}

				cloudValue = min(cloudValue,1);
				float mul  = endStartDis *avrgDensity* _atmosphereDensity;

				float4 cloudsPlusColor = _cloudColor * cloudValue;

				mul = clamp(mul,0,1);

			    float3 lightDir = normalize(_sunDir.xyz);
				float3 normalDir;
				if(inAtmosphere == true)
				{
					 normalDir = normalize(hit - _PlanetPos);
				}else{
					 normalDir = normalize(hit - _PlanetPos);
				}
				float pointShine = dot(normalDir,lightDir*-1)*0.5+0.5;
				float sunIntensityModifi = NthRoot( _sunIntensity ,2)/2;

				float4 LightedAtmosphereColor = lerp(float4(0,0,0,1), _atmosphereColor + _sunColor*sunIntensityModifi,pointShine*sunIntensityModifi );
				float4 LightedCloudsPlusColor = lerp(float4(0,0,0,1), float4 (cloudsPlusColor.x * _sunColor.x*sunIntensityModifi,cloudsPlusColor.y * _sunColor.y*sunIntensityModifi,cloudsPlusColor.z * _sunColor.z*sunIntensityModifi,1 ),pointShine*sunIntensityModifi );

				float4 finalColor = float4( LightedAtmosphereColor.rgb,mul)  + float4(LightedCloudsPlusColor.rgb,cloudValue) ;
				return float4(finalColor.rgb,clamp(finalColor.a,0,1));//*avarageDesnsity;
			}
            struct appdata_t
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
            };

            sampler2D _CameraDepthTexture;
            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = o.pos.xy / o.pos.w * 0.5 + 0.5; // Convert clip space to UVs
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }
            float _float;
			struct getHit1Hit2onSphereOutput
			{
				float3 enter;
				float3 stop;
	
			};

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
			getHit1Hit2onSphereOutput getHit1Hit2onSphere(float3 PlayerPos ,float3 rayDir ,float r,float sceneDepth)
			{
				float3 PlanetPos = float3(0,0,0);

				getHit1Hit2onSphereOutput result ;

				float PlayerPlanetDis = distance(PlayerPos, PlanetPos);
				
				float DistanceToTheFarhestVisiblePointOnSphere = CalculateDistanceToTheFarhestVisiblePointOnSphere(r,PlayerPlanetDis);

				float3 rayMiddleplanetPos = rayDir*DistanceToTheFarhestVisiblePointOnSphere+PlayerPos;

				float rayMiddlePlanetDis = distance(rayMiddleplanetPos,PlanetPos);

				//return float4(sceneDepth/20,sceneDepth/20,sceneDepth/20,1);

			
			    
				float3 startHit = GetRaySphereIntersection(r,rayDir,rayMiddleplanetPos- PlanetPos);
					

				if(distance(startHit,PlayerPos)> sceneDepth)
				{
					return result;
				}else
				{
					result.enter = startHit;
					float3 endhit = GetRaySphereIntersection(r,rayDir*-1,rayMiddleplanetPos - PlanetPos);
					result.stop= min(distance(endhit,PlayerPos), sceneDepth) * rayDir + PlayerPos;
					//float3 test = GetRaySphereIntersection(1,float3(0,0,0),float3(0,0.5,0));
					
					return result;

				}					
				
			}

			float3 ClipToWorldPos(float4 clipPos)
			{
			#ifdef UNITY_REVERSED_Z
				// unity_CameraInvProjection always in OpenGL matrix form
				// that doesn't match the current view matrix used to calculate the clip space

				// transform clip space into normalized device coordinates
				float3 ndc = clipPos.xyz / clipPos.w;

				// convert ndc's depth from 1.0 near to 0.0 far to OpenGL style -1.0 near to 1.0 far 
				ndc = float3(ndc.x, ndc.y * _ProjectionParams.x, (1.0 - ndc.z) * 2.0 - 1.0);

				// transform back into clip space and apply inverse projection matrix
				float3 viewPos =  mul(unity_CameraInvProjection, float4(ndc * clipPos.w, clipPos.w));
			#else
				// using OpenGL, unity_CameraInvProjection matches view matrix
				float3 viewPos = mul(unity_CameraInvProjection, clipPos);
			#endif

				// transform from view to world space
				return mul(unity_MatrixInvV, float4(viewPos, 1.0)).xyz;
			}
            half4 frag (v2f i) : SV_Target
            {			
				float3 worldPos =i.worldPos;
                // Sample the depth texture at the UV coordinate
                float3 dir = normalize(worldPos- _WorldSpaceCameraPos);
                float sceneDepthNonLinear = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, float2(i.uv.x,i.uv.y*-1+1));
				float sceneDepth = LinearEyeDepth(sceneDepthNonLinear) * length(dir);

				//float3 exit = _WorldSpaceCameraPos + dir * min( sceneDepth);
				getHit1Hit2onSphereOutput hits= getHit1Hit2onSphere(_WorldSpaceCameraPos - _PlanetPos,dir,_atmosphereSize,sceneDepth);
                // Use the depth value in some meaningful way
                // For example, visualize depth as color
                return findAtmosphereColor(hits.enter,hits.stop,false); // Output depth value as color for visualization
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
