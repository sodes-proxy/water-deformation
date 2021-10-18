/*
Ripple water shader from Peer Play: https://www.youtube.com/watch?v=UfX9dzhBhg0
*/
Shader "Custom/Water_Ripple"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Scale("Scale",float)=1
        _Speed("Speed",float)=1
        _Frequency("Frequency",float)=1
        _Drop_Positionition("Water drop position",Vector)=(0,0,0,0)
        _DropFell("drop fell", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        Cull off
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        float _Scale,_Speed,_Frequency,_DropFell;
        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float4 _DropPosition;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
        void vert(inout appdata_full v){
            //create ripple effect in @OffsetVert as center and slowly return to normal behaviour
            if(_DropFell!=0){
                float difuse=1-_Time;
                half offsetVert=(v.vertex.x -_DropPosition.x)*(v.vertex.x -_DropPosition.x)+(v.vertex.z-_DropPosition.z)*(v.vertex.z-_DropPosition.z);
                half value= _Scale*sin(_Time.w*_Speed +offsetVert*_Frequency);
                if(offsetVert<0.5){
                    if(difuse<=0){
                        v.vertex.y+=0;
                        v.normal.y+=0;
                    }
                    else{
                        v.vertex.y+=value*difuse;
                        v.normal.xyz+= value*difuse;
                    }
                }
            }
        }
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
        
    }
    FallBack "Diffuse"
}
