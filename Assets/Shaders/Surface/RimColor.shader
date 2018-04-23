Shader "Custom/Surface/RimColor" {  
	Properties {  
        _MainTex ("Main Texture", 2D) = "white" {}  
        _BumpMap ("Bumpmap", 2D) = "bump" {}  
        _RimColor ("Rim Color", Color) = (0.17, 0.36, 0.81, 1.0)  
        _RimScale ("Rim Scale", Range(0, 9.0)) = 1.0  
    }  

	SubShader { 
        Tags {
			"RenderType" = "Opaque"
		}
        
		CGPROGRAM

        #pragma surface surf Lambert  
        struct Input {  
            float2 uv_MainTex;//纹理贴图  
            float2 uv_BumpMap;//法线贴图  
            float3 viewDir;//观察方向  
        };  
  
        sampler2D _MainTex;  
        sampler2D _BumpMap;
        float4 _RimColor;
        float _RimScale;
  
        void surf (Input i, inout SurfaceOutput o) {  
            //表面反射颜色为纹理颜色
            o.Albedo = tex2D(_MainTex, i.uv_MainTex).rgb;  
            //表面法线为凹凸纹理的颜色
            o.Normal = UnpackNormal(tex2D(_BumpMap, i.uv_BumpMap));  
            //边缘颜色
            half rim = 1.0 - saturate(dot(normalize(i.viewDir), o.Normal));  
            //边缘颜色强度
            o.Emission = _RimColor.rgb * pow(rim, _RimScale);  
        } 

        ENDCG  
    }   

    Fallback "Diffuse"  
}  
