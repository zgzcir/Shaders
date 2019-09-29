﻿Shader "Unlit/007-VertexHighLightReflection"
{
    Properties {
        _MainTex("Texture", 2D) = "white" {}
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(1,256))=5
    }
    SubShader {
        Tags {
            "RenderType" = "Opaque"
        }
        LOD 100

        Pass {
                CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            sampler2D _MainTex;
            float4 _MainTex_ST;


            struct v2f {
                float4 vertex: SV_POSITION;
                fixed3 color: COLOR;
                         };


                v2f vert(appdata_base v) 
                {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal=UnityObjectToWorldNormal(v.normal);
                fixed3 worldLight=normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLight));

                //phong
                    fixed3 reflectLight=normalize(reflect(-worldLight,worldNormal));
                 fixed3 viewDir=normalize(_WorldSpaceCameraPos.xyz-UnityObjectToWorldDir(v.vertex));
                fixed3 specular= _LightColor0.rgb*_Specular.rgb*pow(max(0,dot(reflectLight,viewDir)),_Gloss);


                o.color=diffuse+ambient+specular;
                return o;
            }

            fixed4 frag(v2f i): SV_Target {
                return fixed4(i.color,1);
            }
            ENDCG
        }
    }
}
