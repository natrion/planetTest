Shader "Hidden/Atmosphere"
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
			float4 findOceanColor(float3 hit,float3 exit,float4 originalCol)
			{
				float endStartDis = distance(hit,exit);

				float whatWaterColor = min(endStartDis/_oceanBottom,0.5);

				float4 _color = tex2D( _oceanColor  ,float2(whatWaterColor,0) );

				endStartDis = min(NthRoot(endStartDis/_PlanetRadius,_exp)*_mul,1);
				
				return  lerp(originalCol,_color, endStartDis);
			}
			float4 frag (v2f i) : SV_Target
			{
				float4 originalCol = tex2D(_MainTex, i.uv);
				float sceneDepthNonLinear = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
				float sceneDepth = LinearEyeDepth(sceneDepthNonLinear) * length(i.viewVector);
											
				float3 PlayerPos = _WorldSpaceCameraPos;
				float3 rayDir = normalize(i.viewVector);
				
				float PlayerPlanetDis = distance(PlayerPos, _PlanetPos);
				
				float DistanceToTheFarhestVisiblePointOnSphere = CalculateDistanceToTheFarhestVisiblePointOnSphere(_PlanetRadius,PlayerPlanetDis);

				float3 rayMiddleplanetPos = rayDir*DistanceToTheFarhestVisiblePointOnSphere+PlayerPos;

				float rayMiddlePlanetDis = distance(rayMiddleplanetPos,_PlanetPos);

				//return float4(sceneDepth/20,sceneDepth/20,sceneDepth/20,1);

				if (PlayerPlanetDis < _PlanetRadius )
				{
					float3 PlayerRelativePos = PlayerPos - _PlanetPos;

					float3 startHit = PlayerRelativePos;
					float3 endhit = GetRaySphereIntersection(_PlanetRadius,rayDir*-1,PlayerRelativePos);

					float3 realEndHit = min(distance(endhit,PlayerPos),sceneDepth) * rayDir + PlayerPos;

				
					return  findOceanColor(startHit, realEndHit,originalCol);

				}else if(rayMiddlePlanetDis<_PlanetRadius )
				{
					float3 startHit = GetRaySphereIntersection(_PlanetRadius,rayDir,rayMiddleplanetPos- _PlanetPos);
					if(distance(startHit,PlayerPos)> sceneDepth)
					{
						return originalCol;
					}else
					{
						float3 endhit = GetRaySphereIntersection(_PlanetRadius,rayDir*-1,rayMiddleplanetPos - _PlanetPos);
						float3 realEndHit = min(distance(endhit,PlayerPos), sceneDepth) * rayDir + PlayerPos;
						//float3 test = GetRaySphereIntersection(1,float3(0,0,0),float3(0,0.5,0));
						float endStartDis = distance(startHit,realEndHit)/_PlanetRadius;
					
						return  findOceanColor(startHit, realEndHit,originalCol);

					}					
				}else
				{
					return originalCol;
				}
			}
			

			ENDCG
		}
		
	}
}