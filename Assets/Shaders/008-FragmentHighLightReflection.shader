Shader "Unlit/008-FragmentHighLightReflection"
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
                fixed3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                             };


                v2f vert(appdata_base v) 
                {

                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                fixed3 worldNormal=UnityObjectToWorldNormal(v.normal);
                o.worldNormal=worldNormal;
                o.worldPos=UnityObjectToWorldDir(v.vertex);
                return o;
                }

                fixed4 frag(v2f i): SV_Target {
                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldLight=normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse=_LightColor0*_Diffuse*(dot(worldLight,i.worldNormal)*0.5+0.5);

                fixed3 reflectLight=normalize(reflect(-worldLight,i.worldNormal));
                 fixed3 viewDir=normalize(_WorldSpaceCameraPos.xyz-UnityObjectToWorldDir(i.worldPos));
                fixed3 specular= _LightColor0.rgb*_Specular.rgb*pow(max(0,dot(reflectLight,viewDir)),_Gloss);


                fixed3 color=ambient+diffuse+specular;
                return fixed4(color,1);
            }
            ENDCG
        }
    }
}
