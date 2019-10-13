Shader "Unlit/019-Snow"
{
   Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Diffuse("Color",Color)=(1,1,1,1)
        _BumpMap("Normal",2D)="bump"{}
        _BumpScale("Scale",float)=1
        _Outline("Outline",Range(0.0001,0.2))=0.2
        _OutlineColor("OutlineColor",Color)=(0,0,0,0)
        _Steps("Steps",Range(1,30))=1
        _ToonEffect("ToonEffect",Range(0,1))=0.5

      _Snow("Snow Level",Range(0,1))=0.5
        _SnowDir("SnowDir",vector)=(0,1,0)
        _SnowColor("SnowColor",color)=(1,1,1,1)

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
         UsePass "Unlit/018-Toon/Outline"

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile __ SNOW_ON
            #include "Lighting.cginc"
            #include "UnityCG.cginc"

       
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
	        	float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 :TEXCOORD2;
				float4 TtoW2 :TEXCOORD3;


                };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Diffuse;
            float _Steps;
            float _ToonEffect;

            float4 _SnowColor;
            float4 _SnowDir;
            float _Snow;
            v2f vert (appdata_tan v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw=TRANSFORM_TEX(v.texcoord,_BumpMap);
                
                fixed3 worldPos=mul(unity_ObjectToWorld,v.vertex);
                fixed3 worldNormal=UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent=UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal=cross(worldNormal,worldTangent)*v.tangent.w;
              

   				o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z, worldPos.z);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient= UNITY_LIGHTMODEL_AMBIENT;
                fixed4 albedo = tex2D(_MainTex, i.uv);
                float3 worldPos=float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
                fixed3 lightDir=UnityWorldSpaceLightDir(worldPos);
                fixed3 viewDir=normalize(UnityWorldSpaceViewDir(worldPos));

                fixed4 packedNormal=tex2D(_BumpMap,i.uv.zw);
                fixed3 tangentNormal=UnpackNormal(packedNormal);
                tangentNormal.xy*=_BumpScale;
                fixed3 worldNormal=normalize(float3(dot(i.TtoW0.xyz,tangentNormal),dot(i.TtoW1.xyz,tangentNormal),dot(i.TtoW2.xyz,tangentNormal)));

                float difLight=dot(lightDir,worldNormal)*0.5+0.5;
                difLight=smoothstep(0,1,difLight);
                float toon=floor(difLight*_Steps)/_Steps;
                difLight=lerp(difLight,toon,_ToonEffect);
                fixed3 diffuse=_LightColor0.rgb*albedo*_Diffuse.rgb*difLight;
              
                   fixed4 color=fixed4(diffuse+ambient,1);


               
				#if SNOW_ON
				if(dot(worldNormal, _SnowDir.xyz) > lerp(1,-1,_Snow))
				{
					color.rgb = _SnowColor.rgb;
				}
                #endif
                return color;
            }
            ENDCG

        }
    }
}
