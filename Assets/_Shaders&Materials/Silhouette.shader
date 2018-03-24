// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Silhouette" {
	Properties{
		_Color("Color", Color) = (1, 1, 1, 1) //The color of our object
		//_Tex("Pattern", 2D) = "white" {} //Optional texture

		_Shininess("Shininess", Float) = 10 //Shininess
		_SpecColor("Specular Color", Color) = (1, 1, 1, 1) //Specular highlights color
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass{
			CGPROGRAM

			#pragma vertex vert             
			#pragma fragment frag
			#include "UnityCG.cginc"

			uniform float4 _LightColor0; //From UnityCG

			sampler2D _Tex; //Used for texture
			float4 _Tex_ST; //For tiling

			uniform float4 _Color; //Use the above variables in here
			uniform float4 _SpecColor;
			uniform float _Shininess;

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

			// Vertex Shader
			v2f vert(appdata input) {

				v2f o;

				
				o.posWorld = mul(unity_ObjectToWorld, input.vertex);
				o.normal = normalize(mul(float4(input.normal, 0.0), unity_WorldToObject).xyz);

				o.pos = UnityObjectToClipPos(input.vertex);

				return o;
			}

			fixed4 frag(v2f i) : COLOR
			{
				float3 normalDirection = normalize(i.normal);
				float3 viewDirection = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);

				float3 vert2LightSource = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
				float oneOverDistance = 1.0 / length(vert2LightSource);
				float attenuation = lerp(1.0, oneOverDistance, _WorldSpaceLightPos0.w); //Optimization for spot lights. This isn't needed if you're just getting started.
				float3 lightDirection = - _WorldSpaceLightPos0.xyz + i.posWorld.xyz * _WorldSpaceLightPos0.w;

				float3 ambientLighting = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb; //Ambient component
				float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDirection, lightDirection)); //Diffuse component
				float3 specularReflection;
				if (dot(i.normal, lightDirection) < 0.0) //Light on the wrong side - no specular
				{
					specularReflection = float3(0.0, 0.0, 0.0);
				}
				else
				{
					//Specular component
					specularReflection = attenuation * _LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
				}

				float3 color = (ambientLighting + diffuseReflection) + specularReflection; //Texture is not applient on specularReflection
				return float4(color, 1.0);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}

