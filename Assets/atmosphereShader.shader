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

			float4 frag (v2f i) : SV_Target
			{
				float4 originalCol = tex2D(_MainTex, i.uv);
				float sceneDepthNonLinear = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
				float sceneDepth = LinearEyeDepth(sceneDepthNonLinear) * length(i.viewVector);
											
				float3 PlayerPos = _WorldSpaceCameraPos;
				float3 rayDir = normalize(i.viewVector);
				
				float PlayerPlanetDis = distance(PlayerPos, _PlanetPos);
				
				float3 rayMiddleplanetPos = rayDir*PlayerPlanetDis+PlayerPos;

				float rayMiddlePlanetDis = distance(rayMiddleplanetPos,_PlanetPos);

				if(PlayerPlanetDis < _PlanetRadius | rayMiddlePlanetDis<_PlanetRadius)
				{
					return float4(0,0,0,1);
				}else
				{
					return originalCol;
				}
			}


			ENDCG
		}
	}
}