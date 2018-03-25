Shader "Custom/ThickShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_ThicknessTex("Thickness Texture", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass
		{
			Cull Front
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				//float3 normal : NORMAL;
				//float uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 screenuv : TEXCOORD1;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.screenuv = ComputeScreenPos(o.pos);
				return o;
			}

			sampler2D _CameraDepthTexture;

			fixed4 frag(v2f i) : SV_Target
			{
				float2 uv = i.screenuv.xy / i.screenuv.w;
				float front = tex2D(_CameraDepthTexture, uv).r;
				float back = i.pos.z;
				float thickness = front - back;
				return fixed4(thickness, thickness, thickness, 1);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
