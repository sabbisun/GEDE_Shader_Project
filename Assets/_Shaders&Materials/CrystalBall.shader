﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/CrystalBall" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		//_MainTex ("Color (RGB) Alpha (A)", 2D) = "white" {}
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Power ("Power", Range(0,5)) = 0.0
		_Scale ("Scale", Range(0,5)) = 0.0
		_Distortion ("Distortion", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }
		LOD 200

		/*Pass {
			ZWrite On
			ColorMask 0
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
        	#include "UnityCG.cginc"
	        struct v2f {
	            float4 pos : SV_POSITION;
	        };
	 
	        v2f vert (appdata_base v)
	        {
	            v2f o;
	            o.pos = UnityObjectToClipPos (v.vertex);
	            return o;
	        }

	        half4 frag (v2f i) : COLOR
	        {
	            return half4 (i);
	        }
			ENDCG
		}*/

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standardfrag fullforwardshadows //alpha

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _Power;
		float _Scale;
		float _Distortion;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		#include "UnityPBSLighting.cginc"
	    inline fixed4 LightingStandardfrag(SurfaceOutputStandard s, fixed3 viewDir, UnityGI gi) {
	    	//Standard lighting as baseline to work from
	        fixed4 pb = LightingStandard(s, viewDir, gi);

	        //Vectors to the light and camera and surface normal
	        float3 L = gi.light.dir;
	        float3 V = viewDir;
	        float3 N = s.Normal;

	        //Computing halfway vector and applying distortion
	        float3 H = (L + N * _Distortion);

	        //Computing backlight intensity, could also be a dot product instead of multiplication
	        float I = pow(saturate(dot(V,(-H))), _Power) * _Scale;

	        //Adding to color and outputtingZ
	        pb.rgb += gi.light.color * I;
	        return pb;
	    }

	    void LightingStandardfrag_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi) {
			LightingStandard_GI(s, data, gi);		
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Transparent/Diffuse"
}
