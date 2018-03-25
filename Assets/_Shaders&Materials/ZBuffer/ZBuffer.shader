// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ZBuffer"
{
	Properties{
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		//Cull Off ZWrite Off ZTest Always
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 screenuv : TEXCOORD1;
				float4 extra : TEXCOORD2;
				//float2 uv : TEXCOORD0;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.screenuv = ComputeScreenPos(o.pos);
				o.extra = float4(UnityObjectToViewPos(v.vertex), 0);
				return o;
			}

			sampler2D _CameraDepthTexture;
			fixed4 frag(v2f i) : SV_Target
			{
				float2 uv = i.screenuv.xy / i.screenuv.w;
				float depth = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
				float linearDepth = i.extra.z;
				return fixed4(depth, 0, 0, 1);

			}
			ENDCG
		}
	}
}