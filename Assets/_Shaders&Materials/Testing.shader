Shader "Custom/Testing" {
	Properties{
		//_ThicknessTex("Thickness Texture", 2D) = "white" {}
		_Color("Main Color", Color) = (1,1,1,1)
		_Sigma("Sigma", Float) = 1.0
	}

	SubShader{
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
		Tags{ "RenderType" = "Opaque" }
		LOD 200
		
		Pass // Front
		{
			//Cull Off ZWrite Off ZTest Always
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
			};
			
			//Vertex Shader
			v2f vert(appdata input) {
				v2f o;

				o.posWorld = mul(unity_ObjectToWorld, input.vertex);
				o.pos = UnityObjectToClipPos(input.vertex);
			
				o.uv = input.uv;
				#if UNITY_UV_STARTS_AT_TOP
					o.uv.y = 1 - o.uv.y;
				#endif
			
				o.normal = normalize(mul(float4(input.normal, 0.0), unity_WorldToObject).xyz);

				return o;
			}

			float4 _Color;
			sampler2D _ThicknessTex;

			//fixed4 frag(fixed facing : VFACE) : SV_Target
			float4 frag(v2f input) : SV_Target
			{
				float thickness = abs(tex2D(_ThicknessTex, input.uv).r);
				//float depthValue = Linear01Depth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(input.depth)).r);
				float depthValue = input.pos.z;
				half4 depth;

				depth.r = depthValue;
				depth.g = depthValue; //depthValue;
				depth.b = depthValue; // depthValue;

				depth.a = 1;
				return depth;
			}
			ENDCG
		}

		BlendOp RevSub
		BLEND One One
		
		Pass // Back
		{
			Cull Front
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				//float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : POSITION;
				float3 normal : NORMAL;
				//float2 uv : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
			};

			v2f vert(appdata input) {
				v2f o;

				o.posWorld = mul(unity_ObjectToWorld, input.vertex);
				o.pos = UnityObjectToClipPos(input.vertex);
				o.normal = normalize(mul(float4(input.normal, 0.0), unity_WorldToObject).xyz);

				return o;
			}

			float4 _Color;

			float4 frag(v2f input) : SV_Target
			{
				//float depthValue = Linear01Depth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(input.depth)).r);
				float depthValue = input.pos.z;
				half4 depth;// = _Color;

				depth.r = depthValue;
				depth.g = depthValue; //depthValue;
				depth.b = depthValue; // depthValue;

				depth.a = 1;
				return depth;
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
