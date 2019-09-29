Shader "Unlit/002"
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
            
            v2f vert(a2v a2v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(a2v.vertex);

                o.color=a2v.normal*0.5+fixed3(0.5,0.5,0.5);
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                fixed3 c=i.color;
                c*=_Color.rgb;
                return fixed4(c,1);
            }

            ENDCG
        }
    }
}
