Shader "Unlit/018-Toon"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Diffuse("Color",Color)=(1,1,1,1)
        _Outline("Outline",Range(0,0.01))=1
        _OutlineColor("OutlineColor",Color)=(0,0,0,0)
        _Steps("Steps",Range(1,20))=1
        _ToonEffect("ToonEfect",Range(0,1))=0.5
        _RampTex("RampTex",2d)="white"{}
        _RimColor("RimColor",Color)=(1,1,1,1)
        _RimPower("RimPower",Range(0.0001,3))=1
        _XrayColor("XrayColor",Color)=(1,1,1,1)
        _XrayPower("XrayPower",Range(0.0001,3))=1
        
    }
    SubShader
    {
        Tags { "Quene"="Geometry+1000" "RenderType"="Opaque" }
        LOD 100
        Pass{
            Name "XRay"
            Tags{"ForceNoShadowCasting"="true"}
            Blend SrcAlpha One
            ZWrite Off
            ZTest Greater
CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
fixed4 _XrayColor;
float _XrayPower;
struct v2f{
    float4 vertex:SV_POSITION;
    float3 viewDir:TEXCOORD0;
    float3 normal:TEXCOORD1;

}; 

v2f vert(appdata_base v)
{   v2f o;
    o.vertex=UnityObjectToClipPos(v.vertex);
        o.normal=UnityObjectToWorldNormal(v.normal);
        o.viewDir=UnityWorldSpaceViewDir(v.vertex);
    return o;
}

float4 frag(v2f i):SV_TARGET
{
    float3 normal=normalize(i.normal);
    float3 viewDir=normalize(i.viewDir);
    float rim=1-dot(viewDir,normal);
    // return _XrayColor*pow(rim,1/_XrayPower);
    return _XrayColor*rim*_XrayPower;
}


ENDCG
        }
       	Pass
		{
			Name "Outline"
			Cull Front
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			float _Outline;
			fixed4 _OutlineColor;

			struct v2f
			{
				float4 vertex :SV_POSITION;
			};

			v2f vert (appdata_base v)
			{
				v2f o;
				//物体空间法线外拓
				//v.vertex.xyz += v.normal * _Outline;
				//o.vertex = UnityObjectToClipPos(v.vertex);

				//视角空间法线外拓
				//float4 pos = mul(UNITY_MATRIX_V, mul(unity_ObjectToWorld, v.vertex));
				//float3 normal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV,v.normal));
				//pos = pos + float4(normal,0) * _Outline;
				//o.vertex =  mul(UNITY_MATRIX_P, pos);

				//裁剪空间法线外拓
				o.vertex = UnityObjectToClipPos(v.vertex);
				float3 normal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV,v.normal));
				float2 viewNoraml = TransformViewToProjection(normal.xy);
				o.vertex.xy += viewNoraml * _Outline;
				return o;
			}

			float4 frag(v2f i):SV_Target
			{
				return _OutlineColor;
			}
			ENDCG
		}
        Pass
        {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            

    
            struct v2f
            {
                float4 vertex:SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed3 worldNormal:TEXCOORD1;                
                float3 worldPos:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Diffuse;
            float _Steps;
            float _ToonEffect;
            sampler2D _RampTex;
            float4 _RampTex_ST;
            float4 _RimColor;
            float _RimPower;
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal=UnityObjectToWorldNormal(v.normal);
                o.worldPos=mul(unity_ObjectToWorld,v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target 
            { 
                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed4 albedo=tex2D(_MainTex,i.uv);
                fixed3 worldLightDir=UnityWorldSpaceLightDir(i.worldPos);
                fixed3 viewDir=normalize(UnityWorldSpaceViewDir(i.worldPos));
                float difLight=dot(worldLightDir,i.worldNormal)*0.5+0.5;
                //渐变纹理采样
                // fixed4 rampColor=tex2D(_RampTex,fixed2(difLight,difLight));

                 difLight=smoothstep(0,1,difLight);
                 float toon=floor(difLight*_Steps)/_Steps;
                 difLight=lerp(difLight,toon,_ToonEffect);    


                
                fixed3 diffuse=_LightColor0.rgb*albedo*_Diffuse.rgb*difLight;//rampColor; 

                float rim=1-dot(i.worldNormal,viewDir);
                fixed3 rimColor=_RimColor*pow(rim,1/_RimPower);
              return float4(ambient+diffuse+rimColor,1);
            }
            ENDCG
        }
    }
}
