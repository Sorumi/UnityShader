Shader "Custom/Chapter10/GlassRefraction" {
	Properties {
		_MainTex ("Main Texture", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_Cubemap ("Environment Cubemap", Cube) = "_Skybox" {}
		_Distortion ("Distortion", Range(0, 200)) = 10
		_RefractAmount ("Refraction Amount", Range(0, 1)) = 1
	}
	SubShader {
		Tags {
			"RenderType" = "Opaque"
			"Queue" = "Transparent"
		}

		GrabPass {
			"_RefrationTex"
		}

		Pass {
			Tags {
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			// #pragma multi_compile_fwdbase

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			samplerCUBE _Cubemap;
			float _Distortion;
			float _RefractAmount;
			sampler2D _RefrationTex;
			float4 _RefrationTex_TexelSize;
			

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT; 
				float2 texcoord: TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float4 scrPos : TEXCOORD0;
				float4 uv : TEXCOORD1;
				float4 TtoW0 : TEXCOORD2;  
			    float4 TtoW1 : TEXCOORD3;  
			    float4 TtoW2 : TEXCOORD4;
				// SHADOW_COORDS(2)
			};

			v2f vert(a2v v) {
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.scrPos = ComputeGrabScreenPos(o.pos);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);


				// TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET {
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);

				fixed3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));

				float2 offset = bump.xy * _Distortion * _RefrationTex_TexelSize.xy;
				i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
				fixed3 refractColor = tex2D(_RefrationTex, i.scrPos.xy/i.scrPos.w).rgb;

				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				fixed3 worldReflect = reflect(-worldView, bump);
				
				fixed4 texColor = tex2D(_MainTex, i.uv.xy);
				fixed3 reflectColor = texCUBE(_Cubemap, worldReflect).rgb * texColor;

				fixed3 color = refractColor * _RefractAmount + reflectColor * (1 - _RefractAmount);

				return fixed4(color, 1.0);
			}

			ENDCG
		}
		
	}
	FallBack "Diffuse"
}
