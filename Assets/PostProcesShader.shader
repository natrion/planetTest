Shader "Custom/RayDirectionPostProcessing"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;

            float3 _PlanetPos;
            float _planetRadius;
             
            float4x4 _InverseProjectionMatrix;
            float4x4 _ViewMatrix;

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }
            float intersectSphereDistance(float3 viewPoint, float3 viewDir, float3 spherePoint, float sphereRadius) {
                // Calculate vector from spherePoint to viewPoint
                float3 sphereToViewPoint = viewPoint - spherePoint;

                // Calculate quadratic coefficients
                float a = dot(viewDir, viewDir);  // dot(viewDir, viewDir) is |viewDir|^2
                float b = 2.0 * dot(viewDir, sphereToViewPoint);
                float c = dot(sphereToViewPoint, sphereToViewPoint) - sphereRadius * sphereRadius;

                // Calculate discriminant
                float discriminant = b * b - 4.0 * a * c;

                // If discriminant < 0, no intersection
                if (discriminant < 0.0) {
                    return -1.0; // No intersection
                }

                // Calculate the two possible solutions for t (parameter along the line)
                float sqrtDiscriminant = sqrt(discriminant);
                float t1 = (-b - sqrtDiscriminant) / (2.0 * a);
                float t2 = (-b + sqrtDiscriminant) / (2.0 * a);

                // Find the valid intersection point within the sphere
                float t = -1.0;
                if (t1 >= 0.0 && t1 <= 1.0) {
                    t = t1;
                } else if (t2 >= 0.0 && t2 <= 1.0) {
                    t = t2;
                }

                // If t is valid, calculate the distance along the viewDir
                if (t >= 0.0 && t <= 1.0) {
                    return length(viewDir * t);
                } else {
                    return 0.0; // No intersection within the valid range
                }
            }

            half4 frag (v2f i) : SV_Target
            {
                // Transform screen space coordinates to NDC space
                float2 ndc = i.uv * 2.0 - 1.0;

                // Create clip space position (homogeneous coordinates)
                float4 clipPos = float4(ndc, 0.0, 1.0);

                // Transform to view space
                float4 viewPos = mul(_InverseProjectionMatrix, clipPos);
                viewPos /= viewPos.w;

                // Transform to world space
                float3 worldPos = mul(_ViewMatrix, viewPos).xyz;

                // Compute ray direction from camera position (assumed to be origin in view space)
                float3 rayDirection = normalize(worldPos);

                // For demonstration, convert ray direction to color
                half4 returnColor = tex2D(_MainTex, i.uv);

                if  (intersectSphereDistance(worldPos,rayDirection,_PlanetPos,_planetRadius) != 0)
                {
                    returnColor *= returnColor;
                }
                return returnColor ;
            }
            ENDCG
        }
    }
}
