﻿Shader "Unlit/012-WorldSpaceNormalMap"
{

 Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", float) = 1
		_Diffuse("Diffuse", Color) = (1,1,1,1)
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(1,256)) = 5
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 uv : TEXCOORD0;
                float4 TtiW1:TEXCOORD1;
                float4 TtiW2:TEXCOORD2;
                float4 TtiW3:TEXCOORD3;
    			};

			v2f vert (appdata_tan v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
		    	o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
                
                //世界坐标下 顶点位置 法线 切线 副法线
                float3 worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;

                fixed3 worldNormal=UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent=UnityObjectToWorldDir(v.tangent).xyz;
                fixed3 worldBiNormal=cross(worldNormal,worldTangent)*v.tangent.w;

                //按列摆放得到切线空间到世界空间变换矩阵
                o.TtiW1=float4(worldTangent.x,worldBiNormal.x,worldNormal.x,worldPos.x);
                o.TtiW2=float4(worldTangent.y,worldBiNormal.y,worldNormal.y,worldPos.y);
                o.TtiW3=float4(worldTangent.x,worldBiNormal.z,worldNormal.z,worldPos.z);


				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

                float3 worldPos=float3(i.TtiW1.w,i.TtiW2.w,i.TtiW3.w);
                
                fixed3 lightDir=normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir=normalize(UnityWorldSpaceViewDir(worldPos));
	

				fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
                //切线空间法线
				fixed3 tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
                //法线转换到世界空间
                float3  worldNormal=normalize(float3(dot(i.TtiW1.xyz,tangentNormal),dot(i.TtiW2.xyz,tangentNormal),dot(i.TtiW3.xyz,tangentNormal)));

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb;
				//漫反射
				fixed3 diffuse = _LightColor0.rgb * albedo * _Diffuse.rgb * (dot(lightDir,worldNormal)*0.5+0.5);

				//高光反射
				fixed3 halfDir = normalize(lightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);
				
				fixed3 color = ambient + diffuse + specular;
				return fixed4(color,1);
			}
			ENDCG
		}
	}
}

