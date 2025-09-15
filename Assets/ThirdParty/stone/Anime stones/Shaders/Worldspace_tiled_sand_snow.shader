// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "KumaBeer/Worldspace_tiled_sand_snow"
{
	Properties
	{
		_MainColor("Main Color", Color) = (1,1,1,1)
		[HDR]_Shadowcolor("Shadow color", Color) = (0.3921569,0.454902,0.5568628,1)
		_Main_tiling("Main_tiling", Float) = 1
		_Diffuse("Diffuse", 2D) = "white" {}
		[Normal]_MainNormalmap("Main Normalmap", 2D) = "bump" {}
		_Normalmapscale("Normalmap scale", Float) = 1
		_TriplanarFalloff("Triplanar Falloff", Float) = 4
		_WS_blend("WS_blend", Range( 0 , 1)) = 0
		_WSTiling("WS Tiling", Float) = 1
		_WSDiffuse("WS Diffuse", 2D) = "white" {}
		_WSNormalmap("WS Normalmap", 2D) = "bump" {}
		_WS_Normalmapscale("WS_Normalmap scale", Float) = 1
		_SandSnowTiling("Sand/Snow Tiling", Float) = 1
		_Sandnoise("Sand noise", 2D) = "gray" {}
		_SandSnownoiseTile("Sand/Snow noise Tile", Float) = 3
		_SandSnow("Sand/Snow", 2D) = "white" {}
		_SandSnowNormalmap("Sand/Snow Normalmap", 2D) = "white" {}
		_NoiseRimStr("Noise Rim Str", Float) = 20
		_Grasshardness("Sand/Snow hardness", Float) = 1
		_Grasssharpen("Sand/Snow sharpen", Range( 0.1 , 20)) = 0.1
		_Grassheight("Sand/Snow height", Float) = -2.54
		_Grassmaskdetail("Sand/Snow mask detail", Float) = 0.5
		_Color_D("Color_D", Color) = (1,1,1,0)
		_Falloffcolor("Falloff color", Float) = 0
		_Distancecolorblending("Distance color blending", Float) = 2
		[HDR]_RimColor("Rim Color", Color) = (1,1,1,0)
		_RimStr("Rim Str", Range( 0.01 , 1)) = 0.4
		_Rimoffset("Rim offset", Range( 0 , 1)) = 0.6
		_ShadowContribution("Shadow Contribution", Range( 0 , 1)) = 0.5
		_BaseCellSharpness("Base Cell Sharpness", Range( 0.01 , 1)) = 0.01
		_BaseCellOffset("Base Cell Offset", Range( -1 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		ColorMask RGB
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#define ASE_USING_SAMPLING_MACROS 1
		#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
		#else//ASE Sampling Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
		#endif//ASE Sampling Macros

		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 worldPos;
			float4 screenPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		UNITY_DECLARE_TEX2D_NOSAMPLER(_MainNormalmap);
		uniform float _Main_tiling;
		SamplerState sampler_MainNormalmap;
		uniform float _Normalmapscale;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_WSNormalmap);
		SamplerState sampler_WSNormalmap;
		uniform float _WSTiling;
		uniform float _TriplanarFalloff;
		uniform float _WS_Normalmapscale;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_SandSnowNormalmap);
		SamplerState sampler_SandSnowNormalmap;
		uniform float _SandSnowTiling;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Diffuse);
		SamplerState sampler_Diffuse;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_WSDiffuse);
		SamplerState sampler_WSDiffuse;
		uniform float _WS_blend;
		uniform float _Grassmaskdetail;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_SandSnow);
		SamplerState sampler_SandSnow;
		uniform float _Grassheight;
		uniform float _Grasshardness;
		uniform float _Grasssharpen;
		uniform float _Rimoffset;
		uniform float _RimStr;
		uniform float _NoiseRimStr;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Sandnoise);
		SamplerState sampler_Sandnoise;
		uniform float _SandSnownoiseTile;
		uniform float4 _RimColor;
		uniform float4 _MainColor;
		uniform float4 _Color_D;
		uniform float _Distancecolorblending;
		uniform float _Falloffcolor;
		uniform float _BaseCellOffset;
		uniform float _BaseCellSharpness;
		uniform float _ShadowContribution;
		uniform float4 _Shadowcolor;


		inline float3 TriplanarSampling850( UNITY_DECLARE_TEX2D_NOSAMPLER(topTexMap), SamplerState samplertopTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			xNorm.xyz  = half3( UnpackScaleNormal( xNorm, normalScale.y ).xy * float2(  nsign.x, 1.0 ) + worldNormal.zy, worldNormal.x ).zyx;
			yNorm.xyz  = half3( UnpackScaleNormal( yNorm, normalScale.x ).xy * float2(  nsign.y, 1.0 ) + worldNormal.xz, worldNormal.y ).xzy;
			zNorm.xyz  = half3( UnpackScaleNormal( zNorm, normalScale.y ).xy * float2( -nsign.z, 1.0 ) + worldNormal.xy, worldNormal.z ).xyz;
			return normalize( xNorm.xyz * projNormal.x + yNorm.xyz * projNormal.y + zNorm.xyz * projNormal.z );
		}


		inline float3 TriplanarSampling826( UNITY_DECLARE_TEX2D_NOSAMPLER(topTexMap), SamplerState samplertopTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			xNorm.xyz  = half3( UnpackNormal( xNorm ).xy * float2(  nsign.x, 1.0 ) + worldNormal.zy, worldNormal.x ).zyx;
			yNorm.xyz  = half3( UnpackNormal( yNorm ).xy * float2(  nsign.y, 1.0 ) + worldNormal.xz, worldNormal.y ).xzy;
			zNorm.xyz  = half3( UnpackNormal( zNorm ).xy * float2( -nsign.z, 1.0 ) + worldNormal.xy, worldNormal.z ).xyz;
			return normalize( xNorm.xyz * projNormal.x + yNorm.xyz * projNormal.y + zNorm.xyz * projNormal.z );
		}


		inline float4 TriplanarSampling811( UNITY_DECLARE_TEX2D_NOSAMPLER(topTexMap), SamplerState samplertopTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		inline float4 TriplanarSampling832( UNITY_DECLARE_TEX2D_NOSAMPLER(topTexMap), SamplerState samplertopTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		inline float4 TriplanarSampling945( UNITY_DECLARE_TEX2D_NOSAMPLER(topTexMap), SamplerState samplertopTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 temp_cast_4 = (_Main_tiling).xx;
			float2 uv_TexCoord804 = i.uv_texcoord * temp_cast_4;
			float2 MainUV764 = uv_TexCoord804;
			float4 tex2DNode808 = SAMPLE_TEXTURE2D( _Diffuse, sampler_Diffuse, MainUV764 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float4 triplanar811 = TriplanarSampling811( _WSDiffuse, sampler_WSDiffuse, ase_worldPos, ase_worldNormal, _TriplanarFalloff, _WSTiling, 1.0, 0 );
			float4 lerpResult834 = lerp( float4( (tex2DNode808).rgb , 0.0 ) , triplanar811 , _WS_blend);
			float4 triplanar832 = TriplanarSampling832( _SandSnow, sampler_SandSnow, ase_worldPos, ase_worldNormal, _TriplanarFalloff, _SandSnowTiling, 1.0, 0 );
			float saferPower807 = abs( ( distance( ase_worldPos , _WorldSpaceCameraPos ) / _Distancecolorblending ) );
			float4 lerpResult874 = lerp( triplanar832 , _Color_D , saturate( pow( saferPower807 , _Falloffcolor ) ));
			float lerpResult880 = lerp( ( 1.0 - tex2DNode808.a ) , ( 1.0 - triplanar811.a ) , ( _WS_blend * _Grassmaskdetail ));
			float HeightMask797 = lerpResult880;
			float GrassheightMask768 = ( 1.0 - triplanar832.a );
			float lerpResult770 = lerp( GrassheightMask768 , 0.0 , _Grassheight);
			float dotResult779 = dot( ase_worldNormal.y , 1.0 );
			float smoothstepResult805 = smoothstep( lerpResult770 , 1.0 , dotResult779);
			float saferPower859 = abs( ( HeightMask797 + smoothstepResult805 ) );
			float temp_output_827_0 = saturate( (pow( saferPower859 , _Grasshardness )*_Grasssharpen + 0.0) );
			float4 lerpResult763 = lerp( ( _MainColor * lerpResult834 ) , lerpResult874 , temp_output_827_0);
			float LightType936 = _WorldSpaceLightPos0.w;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 Lightcolor860 = ase_lightColor;
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 triplanar850 = TriplanarSampling850( _WSNormalmap, sampler_WSNormalmap, ase_worldPos, ase_worldNormal, _TriplanarFalloff, _WSTiling, _WS_Normalmapscale, 0 );
			float3 tanTriplanarNormal850 = mul( ase_worldToTangent, triplanar850 );
			float3 triplanar826 = TriplanarSampling826( _SandSnowNormalmap, sampler_SandSnowNormalmap, ase_worldPos, ase_worldNormal, _TriplanarFalloff, _SandSnowTiling, 1.0, 0 );
			float3 tanTriplanarNormal826 = mul( ase_worldToTangent, triplanar826 );
			float3 lerpResult781 = lerp( tanTriplanarNormal850 , tanTriplanarNormal826 , temp_output_827_0);
			float3 normalizeResult771 = normalize( lerpResult781 );
			float3 WSNormal816 = normalize( (WorldNormalVector( i , BlendNormals( UnpackScaleNormal( SAMPLE_TEXTURE2D( _MainNormalmap, sampler_MainNormalmap, MainUV764 ), _Normalmapscale ) , normalizeResult771 ) )) );
			UnityGI gi843 = gi;
			float3 diffNorm843 = WSNormal816;
			gi843 = UnityGI_Base( data, 1, diffNorm843 );
			float3 indirectDiffuse843 = gi843.indirect.diffuse + diffNorm843 * 0.0001;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult775 = dot( WSNormal816 , ase_worldlightDir );
			float NdotL800 = dotResult775;
			float4 triplanar945 = TriplanarSampling945( _Sandnoise, sampler_Sandnoise, ase_worldPos, ase_worldNormal, 8.0, _SandSnownoiseTile, 1.0, 0 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float dotResult946 = dot( float4( ase_worldlightDir , 0.0 ) , ase_screenPosNorm );
			float lerpResult947 = lerp( triplanar945.x , 0.0 , dotResult946);
			float temp_output_948_0 = saturate( ( lerpResult947 * temp_output_827_0 ) );
			float3 temp_cast_10 = (saturate( ( ( NdotL800 + _BaseCellOffset + temp_output_948_0 ) / _BaseCellSharpness ) )).xxx;
			float temp_output_2_0_g11 = _ShadowContribution;
			float temp_output_3_0_g11 = ( 1.0 - temp_output_2_0_g11 );
			float3 appendResult7_g11 = (float3(temp_output_3_0_g11 , temp_output_3_0_g11 , temp_output_3_0_g11));
			float4 temp_output_933_0 = ( Lightcolor860 * float4( ( indirectDiffuse843 + ase_lightAtten ) , 0.0 ) * float4( ( ( temp_cast_10 * temp_output_2_0_g11 ) + appendResult7_g11 ) , 0.0 ) );
			float4 lerpResult934 = lerp( _Shadowcolor , float4( 1,1,1,0 ) , temp_output_933_0);
			float4 ifLocalVar931 = 0;
			if( LightType936 == 1.0 )
				ifLocalVar931 = temp_output_933_0;
			else if( LightType936 < 1.0 )
				ifLocalVar931 = lerpResult934;
			c.rgb = ( lerpResult763 * ifLocalVar931 ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
			float2 temp_cast_0 = (_Main_tiling).xx;
			float2 uv_TexCoord804 = i.uv_texcoord * temp_cast_0;
			float2 MainUV764 = uv_TexCoord804;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 triplanar850 = TriplanarSampling850( _WSNormalmap, sampler_WSNormalmap, ase_worldPos, ase_worldNormal, _TriplanarFalloff, _WSTiling, _WS_Normalmapscale, 0 );
			float3 tanTriplanarNormal850 = mul( ase_worldToTangent, triplanar850 );
			float3 triplanar826 = TriplanarSampling826( _SandSnowNormalmap, sampler_SandSnowNormalmap, ase_worldPos, ase_worldNormal, _TriplanarFalloff, _SandSnowTiling, 1.0, 0 );
			float3 tanTriplanarNormal826 = mul( ase_worldToTangent, triplanar826 );
			float4 tex2DNode808 = SAMPLE_TEXTURE2D( _Diffuse, sampler_Diffuse, MainUV764 );
			float4 triplanar811 = TriplanarSampling811( _WSDiffuse, sampler_WSDiffuse, ase_worldPos, ase_worldNormal, _TriplanarFalloff, _WSTiling, 1.0, 0 );
			float lerpResult880 = lerp( ( 1.0 - tex2DNode808.a ) , ( 1.0 - triplanar811.w ) , ( _WS_blend * _Grassmaskdetail ));
			float HeightMask797 = lerpResult880;
			float4 triplanar832 = TriplanarSampling832( _SandSnow, sampler_SandSnow, ase_worldPos, ase_worldNormal, _TriplanarFalloff, _SandSnowTiling, 1.0, 0 );
			float GrassheightMask768 = ( 1.0 - triplanar832.w );
			float lerpResult770 = lerp( GrassheightMask768 , 0.0 , _Grassheight);
			float dotResult779 = dot( ase_worldNormal.y , 1.0 );
			float smoothstepResult805 = smoothstep( lerpResult770 , 1.0 , dotResult779);
			float saferPower859 = abs( ( HeightMask797 + smoothstepResult805 ) );
			float temp_output_827_0 = saturate( (pow( saferPower859 , _Grasshardness )*_Grasssharpen + 0.0) );
			float3 lerpResult781 = lerp( tanTriplanarNormal850 , tanTriplanarNormal826 , temp_output_827_0);
			float3 normalizeResult771 = normalize( lerpResult781 );
			float3 WSNormal816 = normalize( (WorldNormalVector( i , BlendNormals( UnpackScaleNormal( SAMPLE_TEXTURE2D( _MainNormalmap, sampler_MainNormalmap, MainUV764 ), _Normalmapscale ) , normalizeResult771 ) )) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult775 = dot( WSNormal816 , ase_worldlightDir );
			float NdotL800 = dotResult775;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult772 = dot( WSNormal816 , ase_worldViewDir );
			float saferPower788 = abs( ( 1.0 - saturate( ( dotResult772 + _Rimoffset ) ) ) );
			float temp_output_854_0 = ( NdotL800 * pow( saferPower788 , _RimStr ) );
			float4 triplanar945 = TriplanarSampling945( _Sandnoise, sampler_Sandnoise, ase_worldPos, ase_worldNormal, 8.0, _SandSnownoiseTile, 1.0, 0 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float dotResult946 = dot( float4( ase_worldlightDir , 0.0 ) , ase_screenPosNorm );
			float lerpResult947 = lerp( triplanar945.x , 0.0 , dotResult946);
			float temp_output_948_0 = saturate( ( lerpResult947 * temp_output_827_0 ) );
			float lerpResult949 = lerp( 0.0 , _NoiseRimStr , temp_output_948_0);
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 Lightcolor860 = ase_lightColor;
			o.Emission = ( saturate( ( ( temp_output_854_0 * lerpResult949 ) + temp_output_854_0 ) ) * float4( (_RimColor).rgb , 0.0 ) * Lightcolor860 ).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18921
38;632;1297;507;285.4139;82.69298;5.35764;True;True
Node;AmplifyShaderEditor.RangedFloatNode;786;-2306.196,83.69882;Inherit;False;Property;_Main_tiling;Main_tiling;2;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;862;-2269.534,420.3038;Float;False;Property;_WSTiling;WS Tiling;8;0;Create;True;0;0;0;False;0;False;1;0.19;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;804;-2070.301,76.00554;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;857;-1389.968,389.5242;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;762;-2432.943,456.905;Float;False;Property;_SandSnowTiling;Sand/Snow Tiling;12;0;Create;True;0;0;0;False;0;False;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;776;-2296.475,255.6474;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;764;-1725.844,88.48602;Inherit;False;MainUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;840;-2428.595,756.0355;Inherit;False;Property;_TriplanarFalloff;Triplanar Falloff;6;0;Create;True;0;0;0;False;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;839;-262.969,378.3384;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;756;-208.0291,-344.1639;Inherit;False;2142.631;1038.674;Diffuse;22;874;872;852;849;848;841;834;832;823;811;808;801;797;780;777;768;763;877;880;881;882;883;Diffuse blend;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;773;-1242.103,425.8849;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;842;-1185.251,257.8596;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TriplanarNode;811;-67.22695,91.63994;Inherit;True;Spherical;World;False;WS Diffuse;_WSDiffuse;white;9;None;Mid Texture 2;_MidTexture2;white;-1;None;Bot Texture 2;_BotTexture2;white;-1;None;WS Diffuse;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;10;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TriplanarNode;832;11.10498,385.7647;Inherit;True;Spherical;World;False;Sand/Snow;_SandSnow;white;15;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Sand/Snow;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;8;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;801;135.569,-43.82767;Inherit;False;764;MainUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;883;854.5845,287.1911;Inherit;False;Property;_Grassmaskdetail;Sand/Snow mask detail;21;0;Create;False;0;0;0;False;0;False;0.5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;872;546.3024,171.5553;Inherit;False;Property;_WS_blend;WS_blend;7;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;777;424.9309,340.1722;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;877;356.2959,181.4733;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;808;327.5691,-75.82767;Inherit;True;Property;_Diffuse;Diffuse;3;0;Create;True;0;0;0;False;0;False;-1;None;903642cf8ff01fe47896dde16b90dc40;True;0;False;white;LockedToTexture2D;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;882;1091.507,196.0908;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;780;632.1276,30.18962;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;768;595.3191,300.8957;Inherit;False;GrassheightMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;881;841.8137,267.9604;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;802;-2420.76,1504.539;Inherit;False;Property;_Grassheight;Sand/Snow height;20;0;Create;False;0;0;0;False;0;False;-2.54;0.28;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;794;-2451.384,1426.178;Inherit;False;768;GrassheightMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;806;-2532.498,1093.576;Inherit;True;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;880;1261.523,47.75422;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;797;1691.224,-151.5192;Inherit;False;HeightMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;779;-2271.052,1094.185;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;770;-2228.714,1421.87;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;805;-2046.718,1094.291;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;870;-1039.429,1063.682;Inherit;False;797;HeightMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;830;-786.141,1070.079;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;818;-633.8198,1391.276;Inherit;False;Property;_Grasshardness;Sand/Snow hardness;18;0;Create;False;0;0;0;False;0;False;1;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;863;-55.95393,1594.837;Inherit;False;Property;_Grasssharpen;Sand/Snow sharpen;19;0;Create;False;0;0;0;False;0;False;0.1;0.7;0.1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;859;-408.472,1340.175;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;822;-2420.913,579.9824;Inherit;False;Property;_WS_Normalmapscale;WS_Normalmap scale;11;0;Create;True;0;0;0;False;0;False;1;1.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;858;269.3199,1344.383;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;827;739.3543,1354.56;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;826;-2062.518,718.8722;Inherit;True;Spherical;World;True;Sand/Snow Normalmap;_SandSnowNormalmap;white;16;None;Mid Texture 3;_MidTexture3;white;-1;None;Bot Texture 3;_BotTexture3;white;-1;None;Sand/Snow Normalmap;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;8;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TriplanarNode;850;-2072.326,512.6907;Inherit;True;Spherical;World;True;WS Normalmap;_WSNormalmap;bump;10;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;WS Normalmap;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;10;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;781;-1654.245,527.8788;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;813;-1727.29,174.0268;Inherit;False;Property;_Normalmapscale;Normalmap scale;5;0;Create;True;0;0;0;False;0;False;1;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;783;-1470.594,60.66282;Inherit;True;Property;_MainNormalmap;Main Normalmap;4;1;[Normal];Create;True;0;0;0;False;0;False;-1;None;0b17666817bf20a42913ea4f4e7bfbdd;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;771;-1430.245,527.8788;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;836;-1153.286,525.7047;Inherit;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;951;-953.7146,2089.019;Inherit;False;1637.706;473.5732;Sand/snow;9;949;947;945;946;943;944;948;950;953;Sand/snow;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;785;-839.4026,526.0191;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;760;-3314.139,-95.89957;Inherit;False;852.9001;307.4;NdotL;4;800;791;775;942;NdotL;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;944;-898.0161,2199.844;Float;False;Property;_SandSnownoiseTile;Sand/Snow noise Tile;14;0;Create;True;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;942;-3250.691,36.36362;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScreenPosInputsNode;943;-911.0161,2316.844;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;816;-466.4025,522.0191;Inherit;False;WSNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;946;-287.0145,2300.844;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;945;-687.0156,2156.844;Inherit;True;Spherical;World;False;Sand noise;_Sandnoise;gray;13;None;Mid Texture 4;_MidTexture4;white;-1;None;Bot Texture 4;_BotTexture4;white;-1;None;Sand noise;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;8;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;791;-3270.59,-64.70973;Inherit;False;816;WSNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;758;1687.465,2195.306;Inherit;False;2417.978;698.3262;Rimlight;18;941;873;851;861;855;828;854;837;788;835;819;767;809;769;772;803;810;956;Rimlight;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;775;-2973.355,-27.9108;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;810;1741.749,2407.625;Inherit;False;816;WSNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;803;1788.779,2518.834;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;947;-110.4769,2178.254;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;800;-2682.741,-28.5283;Float;True;NdotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;953;90.25081,2156.226;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;757;1153.448,1529.65;Inherit;False;2085.868;451.7779;Shadows;16;789;931;934;938;933;932;893;894;790;817;891;889;886;885;793;766;Shadows;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;759;-365.537,948.0759;Inherit;False;1257.089;345.2527;Distance;8;875;847;825;815;812;807;782;778;Distance color blending;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;772;2093.882,2453.942;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;769;2057.777,2688.276;Float;False;Property;_Rimoffset;Rim offset;27;0;Create;True;0;0;0;False;0;False;0.6;0.8;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;885;1216.378,1588.192;Inherit;True;800;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;793;1186.721,1803.41;Float;False;Property;_BaseCellOffset;Base Cell Offset;30;0;Create;True;0;0;0;False;0;False;0;0.45;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;948;251.4449,2178.941;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;809;2317.482,2458.159;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;815;-339.041,1134.514;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;812;-321.913,990.0508;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;766;1188.053,1887.961;Float;False;Property;_BaseCellSharpness;Base Cell Sharpness;29;0;Create;True;0;0;0;False;0;False;0.01;0.85;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;886;1489.946,1760.286;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;778;-6.437988,1002.874;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;767;2477.482,2458.159;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;847;-32.5,1123.417;Inherit;False;Property;_Distancecolorblending;Distance color blending;24;0;Create;True;0;0;0;False;0;False;2;40;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;819;2541.482,2586.159;Float;False;Property;_RimStr;Rim Str;26;0;Create;True;0;0;0;False;0;False;0.4;0.85;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;838;-3089.004,340.8611;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;889;1670.723,1785.175;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;963;1751.543,1579.359;Inherit;False;816;WSNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;875;281.7781,1142.524;Inherit;False;Property;_Falloffcolor;Falloff color;23;0;Create;True;0;0;0;False;0;False;0;1.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;835;2658.482,2455.159;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;825;213.998,1002.975;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;837;2794.229,2375.517;Inherit;False;800;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;788;2845.48,2458.159;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;950;96.30005,2345.071;Inherit;False;Property;_NoiseRimStr;Noise Rim Str;17;0;Create;True;0;0;0;False;0;False;20;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;807;461.2949,1002.597;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;860;-2846.027,336.7571;Inherit;False;Lightcolor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;932;2068.479,1669.053;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;891;1839.042,1785.677;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;817;1718.042,1887.668;Float;False;Property;_ShadowContribution;Shadow Contribution;28;0;Create;True;0;0;0;False;0;False;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;843;2039.865,1585.179;Inherit;False;World;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;790;2066.796,1745.277;Inherit;True;Lerp White To;-1;;11;047d7c189c36a62438973bad9d37b1c2;0;2;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;937;-3336,234;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LerpOp;949;420.2913,2324.568;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;849;407.5691,452.1722;Inherit;False;Property;_Color_D;Color_D;22;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,0.7653478,0.5235848,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;894;2346.448,1586.305;Inherit;False;860;Lightcolor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;854;3123.234,2380.604;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;782;709.9109,1013.733;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;893;2307.686,1659.276;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;823;631.5691,-43.82767;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;828;3340.79,2293.171;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;848;876.5049,-306.1547;Float;False;Property;_MainColor;Main Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,0.9547959,0.9009434,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;874;775.5691,388.1721;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;834;840.5701,54.87105;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;936;-2976,224;Inherit;False;LightType;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;789;2534.868,1798.213;Inherit;False;Property;_Shadowcolor;Shadow color;1;1;[HDR];Create;True;0;0;0;False;0;False;0.3921569,0.454902,0.5568628,1;0.1940637,0.2784971,0.4622642,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;933;2561.498,1635.333;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;841;1127.568,-235.8277;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;855;3320.044,2672.622;Float;False;Property;_RimColor;Rim Color;25;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.4433962,0.359748,0.3409131,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;852;1063.569,276.1722;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;938;2695.258,1590.503;Inherit;False;936;LightType;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;934;2816.712,1744.632;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;956;3517.638,2355.932;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;851;3581.038,2778.407;Inherit;False;860;Lightcolor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;861;3585.694,2671.341;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ConditionalIfNode;931;2979.043,1595.098;Inherit;True;False;5;0;FLOAT;0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;873;3737.44,2579.459;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;763;1638.177,222.4413;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;865;3874.438,1060.718;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;941;3883.881,2651.457;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;5;4390.322,967.725;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;KumaBeer/Worldspace_tiled_sand_snow;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;18;all;True;True;True;False;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;3.3;10;25;False;1;True;0;5;False;-1;1;False;-1;0;5;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;True;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;804;0;786;0
WireConnection;857;0;862;0
WireConnection;764;0;804;0
WireConnection;839;0;857;0
WireConnection;773;0;762;0
WireConnection;842;0;776;0
WireConnection;811;9;842;0
WireConnection;811;3;839;0
WireConnection;811;4;840;0
WireConnection;832;9;776;0
WireConnection;832;3;773;0
WireConnection;832;4;840;0
WireConnection;777;0;832;4
WireConnection;877;0;811;4
WireConnection;808;1;801;0
WireConnection;882;0;872;0
WireConnection;882;1;883;0
WireConnection;780;0;808;4
WireConnection;768;0;777;0
WireConnection;881;0;877;0
WireConnection;880;0;780;0
WireConnection;880;1;881;0
WireConnection;880;2;882;0
WireConnection;797;0;880;0
WireConnection;779;0;806;2
WireConnection;770;0;794;0
WireConnection;770;2;802;0
WireConnection;805;0;779;0
WireConnection;805;1;770;0
WireConnection;830;0;870;0
WireConnection;830;1;805;0
WireConnection;859;0;830;0
WireConnection;859;1;818;0
WireConnection;858;0;859;0
WireConnection;858;1;863;0
WireConnection;827;0;858;0
WireConnection;826;9;776;0
WireConnection;826;3;762;0
WireConnection;826;4;840;0
WireConnection;850;9;776;0
WireConnection;850;8;822;0
WireConnection;850;3;862;0
WireConnection;850;4;840;0
WireConnection;781;0;850;0
WireConnection;781;1;826;0
WireConnection;781;2;827;0
WireConnection;783;1;764;0
WireConnection;783;5;813;0
WireConnection;771;0;781;0
WireConnection;836;0;783;0
WireConnection;836;1;771;0
WireConnection;785;0;836;0
WireConnection;816;0;785;0
WireConnection;946;0;942;0
WireConnection;946;1;943;0
WireConnection;945;3;944;0
WireConnection;775;0;791;0
WireConnection;775;1;942;0
WireConnection;947;0;945;1
WireConnection;947;2;946;0
WireConnection;800;0;775;0
WireConnection;953;0;947;0
WireConnection;953;1;827;0
WireConnection;772;0;810;0
WireConnection;772;1;803;0
WireConnection;948;0;953;0
WireConnection;809;0;772;0
WireConnection;809;1;769;0
WireConnection;886;0;885;0
WireConnection;886;1;793;0
WireConnection;886;2;948;0
WireConnection;778;0;812;0
WireConnection;778;1;815;0
WireConnection;767;0;809;0
WireConnection;889;0;886;0
WireConnection;889;1;766;0
WireConnection;835;0;767;0
WireConnection;825;0;778;0
WireConnection;825;1;847;0
WireConnection;788;0;835;0
WireConnection;788;1;819;0
WireConnection;807;0;825;0
WireConnection;807;1;875;0
WireConnection;860;0;838;0
WireConnection;891;0;889;0
WireConnection;843;0;963;0
WireConnection;790;1;891;0
WireConnection;790;2;817;0
WireConnection;949;1;950;0
WireConnection;949;2;948;0
WireConnection;854;0;837;0
WireConnection;854;1;788;0
WireConnection;782;0;807;0
WireConnection;893;0;843;0
WireConnection;893;1;932;0
WireConnection;823;0;808;0
WireConnection;828;0;854;0
WireConnection;828;1;949;0
WireConnection;874;0;832;0
WireConnection;874;1;849;0
WireConnection;874;2;782;0
WireConnection;834;0;823;0
WireConnection;834;1;811;0
WireConnection;834;2;872;0
WireConnection;936;0;937;2
WireConnection;933;0;894;0
WireConnection;933;1;893;0
WireConnection;933;2;790;0
WireConnection;841;0;848;0
WireConnection;841;1;834;0
WireConnection;852;0;874;0
WireConnection;934;0;789;0
WireConnection;934;2;933;0
WireConnection;956;0;828;0
WireConnection;956;1;854;0
WireConnection;861;0;855;0
WireConnection;931;0;938;0
WireConnection;931;3;933;0
WireConnection;931;4;934;0
WireConnection;873;0;956;0
WireConnection;763;0;841;0
WireConnection;763;1;852;0
WireConnection;763;2;827;0
WireConnection;865;0;763;0
WireConnection;865;1;931;0
WireConnection;941;0;873;0
WireConnection;941;1;861;0
WireConnection;941;2;851;0
WireConnection;5;2;941;0
WireConnection;5;13;865;0
ASEEND*/
//CHKSM=3E21A5983A90A3603B0C44658728F1E147E97335