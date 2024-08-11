Shader "Hidden/BlurShader"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _BlurSize ("Blur Size", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _BlurSize;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float2 offset = _BlurSize / _ScreenParams.xy;
                fixed4 color = tex2D(_MainTex, uv) * 0.111111;

                color += tex2D(_MainTex, uv + float2(offset.x, 0)) * 0.111111;
                color += tex2D(_MainTex, uv - float2(offset.x, 0)) * 0.111111;
                color += tex2D(_MainTex, uv + float2(0, offset.y)) * 0.111111;
                color += tex2D(_MainTex, uv - float2(0, offset.y)) * 0.111111;

                color += tex2D(_MainTex, uv + float2(offset.x, offset.y)) * 0.111111;
                color += tex2D(_MainTex, uv - float2(offset.x, offset.y)) * 0.111111;
                color += tex2D(_MainTex, uv + float2(offset.x, -offset.y)) * 0.111111;
                color += tex2D(_MainTex, uv - float2(offset.x, -offset.y)) * 0.111111;

                return color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
