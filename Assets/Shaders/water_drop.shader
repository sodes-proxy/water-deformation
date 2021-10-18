
Shader "Custom/water_drop"
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
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType"="Transparent" }
        LOD 200
        Cull off
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard alpha:fade vertex:vert
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        float _Scale,_Speed,_Frequency;
        struct Input
        {
            float2 uv_MainTex;
        };
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
        void vert(inout appdata_full v){
            //9.8 is gravity, trying to simulate a deformation of the droplet by gravity
            float deformation=2*9.8*_Time*_Time;
            half offsetVert=(v.vertex.x *v.vertex.x)+(v.vertex.z*v.vertex.z );
            half value= _Scale*sin(_Time.w*_Speed +offsetVert*_Frequency);
            if (v.vertex.y>=0){
                // preventing the deformation to look terrible, with bigger values it starts to look really weird
                if(deformation>5){
                    deformation=4;
                }
                v.vertex.y+=(value*deformation);
                v.normal.y+=value;
            }
            else{
                v.vertex.y+=value;
                v.normal.y+=value;
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
            o.Alpha = 0.5;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
