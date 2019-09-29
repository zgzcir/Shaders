Shader "Unlit/003"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color)=(1,1,1,1)

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
            fixed4 _Color;
            //aplication 2 vertex
            struct a2v
            {
                //用模型顶点填充v变量
                float4 vertex:POSITION;
                //用模法线填充n变量
                float3 normal:NORMAL;
                // 用模型第一套uv填充
                float4 texcoord:TEXCOORD0;

            };
            struct v2f
            {
              float4 pos:SV_POSITION;
              fixed3 color:COLOR0;
            };
            
            v2f vert(appdata_full a2v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(a2v.vertex);
                o.color=a2v.normal*0.5+fixed3(0.5,0.5,0.5);
                o.color=a2v.tangent.xyz*0.5+fixed3(0.5,0.5,0.5);
                o.color= fixed4(a2v.texcoord.xy,0.56,1); 
                // o.color=a2v.color;
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                return fixed4(i.color,1);
            }

            ENDCG
        }
    }
}
