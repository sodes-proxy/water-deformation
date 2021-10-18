/*
Gerstner waves implementation followed from:
https://catlikecoding.com/unity/tutorials/flow/waves/
*/
Shader "Custom/waves"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _WaveA ("Wave A (dir, steepness, wavelength)", Vector) = (1,0,0.5,10)
        _WaveB ("Wave B (dir, steepness, wavelength)", Vector) = (0,1,0.25,20)
        _WaveC ("Wave C (dir, steepness, wavelength)", Vector) = (1,1,0.15,10)
        //properties for ripple
        _Scale("Scale",float)=1
        _Speed("Speed",float)=1
        _Frequency("Frequency",float)=1
        _DropPosition("Water drop pos",Vector)=(0,0,0,0)
        _DropFell("drop fell", Float) = 0

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types *addshadow*
        #pragma surface surf Standard fullforwardshadows vertex:vert 
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float4 _WaveA;
        float4 _WaveB;
        float4 _WaveC;
        float4 _DropPosition;
        float _Scale,_Speed,_Frequency,_DropFell;
        //function wich calculates a gerstner wave, to have a nice looking effect we need more than one wave
        float3 GerstnerWave (
        float4 wave, float3 p, inout float3 tangent, inout float3 binormal
        ) {
            float steepness = wave.z;
            float wavelength = wave.w;
            //phase speed of waves
            float k = 2 * 3.1416 / wavelength;
            float c = sqrt(9.8 / k);
            //wave direction
            float2 d = normalize(wave.xy);
            //wave force
            float f = k * (dot(d, p.xz) - c * _Time.y);
            float a = steepness / k;
            tangent += float3(
            -d.x * d.x * (steepness * sin(f)),
            d.x * (steepness * cos(f)),
            -d.x * d.y * (steepness * sin(f))
            );
            binormal += float3(
            -d.x * d.y * (steepness * sin(f)),
            d.y * (steepness * cos(f)),
            -d.y * d.y * (steepness * sin(f))
            );
            return float3(
            d.x * (a * cos(f)),
            a * sin(f),
            d.y * (a * cos(f))
            );
        }

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
        void vert(inout appdata_full vertexData){
            
            //wave variables to create the ocean-like effect
            float3 gridPoint = vertexData.vertex.xyz;
            float3 tangent = float3(1, 0, 0);
            float3 binormal = float3(0, 0, 1);
            float3 p = gridPoint;
            p += GerstnerWave(_WaveA, gridPoint, tangent, binormal);
            p += GerstnerWave(_WaveB, gridPoint, tangent, binormal);
            p += GerstnerWave(_WaveC, gridPoint, tangent, binormal);
            float3 normal = normalize(cross(binormal, tangent));
            //vertex data for wave, applying the calculations to the vertices
            vertexData.vertex.xyz += p;
            vertexData.normal = normal;
            //vertex data for ripple
            //if drop has not fallen behave like the wave
            if(_DropFell!=0){
                //slowly return to normal behaviour
                float difuse=.3-_Time;
                //center position of ripple
                half offsetVert=(vertexData.vertex.x -_DropPosition.x)*(vertexData.vertex.x -_DropPosition.x)+(vertexData.vertex.z-_DropPosition.z)*(vertexData.vertex.z-_DropPosition.z);
                half value= _Scale*sin(_Time.w*_Speed +offsetVert*_Frequency);  
                //radius of ripple              
                if(offsetVert<20){
                    if(difuse<=0){
                        //return to normal behaviour
                        vertexData.vertex.y+=0;
                        vertexData.normal.y+=0;
                    }
                    else{
                        //ripple effect (failed to get it to work properly, ugly shadows and not spherical ripple)
                        vertexData.vertex.y+=(value*difuse);
                        vertexData.normal.y+= float3(-1 * _Speed * _Scale * sin(-1 * _Time.w * _Speed + offsetVert * _Frequency), _Speed * _Scale * sin(-1 * _Time.w * _Speed + offsetVert * _Frequency),1)*difuse;
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
