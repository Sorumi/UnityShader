Shader "Custom/Surface/AlphaBlend" {
	Properties {
		_Illumin ("Illumin Color", Color) = (0, 0, 0, 0)  
		_Diffuse ("Diffuse Color", Color) = (1, 1, 1, 1)
		_Ambient ("Ambient Color", Color) = (1, 1, 1, 1)
		_Specular ("Specular Color", Color) = (1, 1, 1, 1)
        _Emission ("Emisstion Color", Color) = (0, 0, 0, 0)
        _Shininess ("Shininess", Range (0.01, 1)) = 0.7
		_MainTex ("Main texture", 2D) = "white" {}
		_BlendTex ("Blend Texture", 2D) = "white" {}
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
            
			SetTexture [_MainTex] { 
                constantColor [_Illumin]  
                combine constant lerp(texture) previous  
            }  

			SetTexture [_MainTex] {
				Combine previous * texture
			}

			SetTexture [_BlendTex] {
				Combine previous * texture
			}

			SetTexture [_MainTex] {  
                Combine previous * primary DOUBLE, previous * primary
            } 
		}
	}
}
