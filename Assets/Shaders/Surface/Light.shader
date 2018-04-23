Shader "Custom/Surface/Light" {
	Properties {
		_Diffuse ("Diffuse Color", Color) = (1, 1, 1, 1)
		_Ambient ("Ambient Color", Color) = (1, 1, 1, 1)
		_Specular ("Specular Color", Color) = (1, 1, 1, 1)
        _Emission ("Emisstion Color", Color) = (0, 0, 0, 0)
        _Shininess ("Shininess", Range (0.01, 1)) = 0.7
        _MainTex ("Main Texture", 2D) = "white" {}
	}

	SubShader {     
        Pass {
            Lighting On
            SeparateSpecular On

            Material {
                Diffuse [_Diffuse]  
                Ambient [_Ambient]
                Specular [_Specular]
                Emission [_Emission]
				Shininess [_Shininess]
            }
            
            SetTexture [_MainTex]   
            {  
                Combine texture * primary DOUBLE, texture * primary  
            }  
        }  
    }  
}
