Shader "Hidden/AdditiveShader"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _SecondTex ("Second Texture (RGB)", 2D) = "white" {}
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
            sampler2D _SecondTex;
            float4 _MainTex_ST;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color1 = tex2D(_MainTex, i.uv);
                fixed4 color2 = tex2D(_SecondTex, i.uv);
                return color1 + color2;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
