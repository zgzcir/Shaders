﻿Shader "Unlit/015-AlphaTest"
{
  Properties
	{
                _MainTex ("Texture", 2D) = "white" {}
		_Diffuse("Diffuse", Color) = (1,1,1,1)
        _Cutoff("Alpah Cutoff",Range(0,1))=0.5
	}

	SubShader
	{
		Tags { "Quene"="AlphaTest""IgnoreProjector"="True" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Diffuse;
            float _Cutoff;
            sampler2D _MainTex;
			float4 _MainTex_ST;
            struct v2f
			{
				float4 vertex : SV_POSITION;
				fixed3 worldNormal: TEXCOORD0;
				float3 worldPos: TEXCOORD1;
                float2 uv:TEXCOORD2;
			};

			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				fixed3 worldNormal = UnityObjectToWorldNormal( v.normal);
				o.worldNormal = worldNormal;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				
                // o.uv=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
                 o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);    
                return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
    			fixed4 testColor=tex2D(_MainTex,i.uv);

                if((testColor.a-_Cutoff)<0)
                {
                    discard;
                }

            	//漫反射
				fixed3 worldLightDir = UnityWorldSpaceLightDir(i.worldPos);
				//fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse =testColor.rgb* _LightColor0.rgb * _Diffuse.rgb * (max(0,dot(worldLightDir,i.worldNormal))*0.5+0.5);

			
				
				fixed3 color = ambient + diffuse;
				return fixed4(color,1);
			}
			ENDCG
		}
	}
        Fallback "Diffuse"

}
