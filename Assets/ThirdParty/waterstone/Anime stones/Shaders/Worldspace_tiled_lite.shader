// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "KumaBeer/Worldspace_tiled_lite"
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
		_GrassTiling("Grass Tiling", Float) = 1
		_Grass("Grass", 2D) = "white" {}
		_GrassNormalmap("Grass Normalmap", 2D) = "white" {}
		_Grasshardness("Grass hardness", Float) = 1
		_Grasssharpen("Grass sharpen", Range( 0.1 , 20)) = 0
		[HDR]_RimColor("Rim Color", Color) = (1,1,1,0)
		_RimStr("Rim Str", Range( 0.01 , 1)) = 0.4
		_Rimoffset("Rim offset", Range( 0 , 1)) = 0.6
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
		UNITY_DECLARE_TEX2D_NOSAMPLER(_GrassNormalmap);
		SamplerState sampler_GrassNormalmap;
		uniform float _GrassTiling;
		uniform float _Grasshardness;
		uniform float _Grasssharpen;
		uniform float _Rimoffset;
		uniform float _RimStr;
		uniform float4 _RimColor;
		uniform float4 _MainColor;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Diffuse);
		SamplerState sampler_Diffuse;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_WSDiffuse);
		SamplerState sampler_WSDiffuse;
		uniform float _WS_blend;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Grass);
		SamplerState sampler_Grass;
		uniform float _BaseCellOffset;
		uniform float _BaseCellSharpness;
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
			float2 temp_cast_3 = (_Main_tiling).xx;
			float2 uv_TexCoord804 = i.uv_texcoord * temp_cast_3;
			float2 MainUV764 = uv_TexCoord804;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float4 triplanar811 = TriplanarSampling811( _WSDiffuse, sampler_WSDiffuse, ase_worldPos, ase_worldNormal, _TriplanarFalloff, _WSTiling, 1.0, 0 );
			float4 lerpResult834 = lerp( SAMPLE_TEXTURE2D( _Diffuse, sampler_Diffuse, MainUV764 ) , triplanar811 , _WS_blend);
			float4 triplanar832 = TriplanarSampling832( _Grass, sampler_Grass, ase_worldPos, ase_worldNormal, _TriplanarFalloff, _GrassTiling, 1.0, 0 );
			float dotResult779 = dot( ase_worldNormal.y , 1.0 );
			float smoothstepResult805 = smoothstep( 0.0 , 1.0 , dotResult779);
			float saferPower859 = abs( smoothstepResult805 );
			float temp_output_827_0 = saturate( (pow( saferPower859 , _Grasshardness )*_Grasssharpen + 0.0) );
			float4 lerpResult763 = lerp( ( _MainColor * lerpResult834 ) , triplanar832 , temp_output_827_0);
			float LightType908 = _WorldSpaceLightPos0.w;
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 triplanar850 = TriplanarSampling850( _WSNormalmap, sampler_WSNormalmap, ase_worldPos, ase_worldNormal, _TriplanarFalloff, _WSTiling, _WS_Normalmapscale, 0 );
			float3 tanTriplanarNormal850 = mul( ase_worldToTangent, triplanar850 );
			float3 triplanar826 = TriplanarSampling826( _GrassNormalmap, sampler_GrassNormalmap, ase_worldPos, ase_worldNormal, _TriplanarFalloff, _GrassTiling, 1.0, 0 );
			float3 tanTriplanarNormal826 = mul( ase_worldToTangent, triplanar826 );
			float3 lerpResult781 = lerp( tanTriplanarNormal850 , tanTriplanarNormal826 , temp_output_827_0);
			float3 normalizeResult771 = normalize( lerpResult781 );
			float3 normalizeResult765 = normalize( normalize( (WorldNormalVector( i , BlendNormals( UnpackScaleNormal( SAMPLE_TEXTURE2D( _MainNormalmap, sampler_MainNormalmap, MainUV764 ), _Normalmapscale ) , normalizeResult771 ) )) ) );
			float3 WSNormal816 = normalizeResult765;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult775 = dot( WSNormal816 , ase_worldlightDir );
			float NdotL800 = dotResult775;
			UnityGI gi843 = gi;
			float3 diffNorm843 = WSNormal816;
			gi843 = UnityGI_Base( data, 1, diffNorm843 );
			float3 indirectDiffuse843 = gi843.indirect.diffuse + diffNorm843 * 0.0001;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 Lightcolor860 = ase_lightColor;
			float4 temp_output_900_0 = ( saturate( ( ( NdotL800 + _BaseCellOffset ) / _BaseCellSharpness ) ) * float4( ( indirectDiffuse843 + ase_lightAtten ) , 0.0 ) * Lightcolor860 );
			float4 lerpResult903 = lerp( _Shadowcolor , float4( 1,1,1,0 ) , temp_output_900_0);
			float4 ifLocalVar902 = 0;
			if( LightType908 == 1.0 )
				ifLocalVar902 = temp_output_900_0;
			else if( LightType908 < 1.0 )
				ifLocalVar902 = lerpResult903;
			c.rgb = ( lerpResult763 * ifLocalVar902 ).xyz;
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
			float3 triplanar826 = TriplanarSampling826( _GrassNormalmap, sampler_GrassNormalmap, ase_worldPos, ase_worldNormal, _TriplanarFalloff, _GrassTiling, 1.0, 0 );
			float3 tanTriplanarNormal826 = mul( ase_worldToTangent, triplanar826 );
			float dotResult779 = dot( ase_worldNormal.y , 1.0 );
			float smoothstepResult805 = smoothstep( 0.0 , 1.0 , dotResult779);
			float saferPower859 = abs( smoothstepResult805 );
			float temp_output_827_0 = saturate( (pow( saferPower859 , _Grasshardness )*_Grasssharpen + 0.0) );
			float3 lerpResult781 = lerp( tanTriplanarNormal850 , tanTriplanarNormal826 , temp_output_827_0);
			float3 normalizeResult771 = normalize( lerpResult781 );
			float3 normalizeResult765 = normalize( normalize( (WorldNormalVector( i , BlendNormals( UnpackScaleNormal( SAMPLE_TEXTURE2D( _MainNormalmap, sampler_MainNormalmap, MainUV764 ), _Normalmapscale ) , normalizeResult771 ) )) ) );
			float3 WSNormal816 = normalizeResult765;
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
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 Lightcolor860 = ase_lightColor;
			o.Emission = ( ( saturate( NdotL800 ) * pow( saferPower788 , _RimStr ) ) * Lightcolor860 * float4( (_RimColor).rgb , 0.0 ) ).rgb;
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
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
38;632;1297;507;3278.421;-600.6658;6.090119;True;True
Node;AmplifyShaderEditor.WorldNormalVector;806;-2492.575,1346.132;Inherit;True;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;779;-2143.129,1352.741;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;805;-1751.796,1335.847;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;818;-620.2515,1525.689;Inherit;False;Property;_Grasshardness;Grass hardness;15;0;Create;True;0;0;0;False;0;False;1;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;859;-357.777,1335.106;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;863;-5.259033,1589.768;Inherit;False;Property;_Grasssharpen;Grass sharpen;16;0;Create;True;0;0;0;False;0;False;0;2.1;0.1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;786;-2306.196,83.69882;Inherit;False;Property;_Main_tiling;Main_tiling;2;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;776;-2296.475,255.6474;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;822;-2420.913,579.9824;Inherit;False;Property;_WS_Normalmapscale;WS_Normalmap scale;11;0;Create;True;0;0;0;False;0;False;1;1.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;762;-2432.943,456.905;Float;False;Property;_GrassTiling;Grass Tiling;12;0;Create;True;0;0;0;False;0;False;1;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;862;-2269.534,420.3038;Float;False;Property;_WSTiling;WS Tiling;8;0;Create;True;0;0;0;False;0;False;1;0.19;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;858;320.0149,1339.314;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;840;-2428.595,756.0355;Inherit;False;Property;_TriplanarFalloff;Triplanar Falloff;6;0;Create;True;0;0;0;False;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;827;813.0659,1354.294;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;826;-2062.518,718.8722;Inherit;True;Spherical;World;True;Grass Normalmap;_GrassNormalmap;white;14;None;Mid Texture 3;_MidTexture3;white;-1;None;Bot Texture 3;_BotTexture3;white;-1;None;Grass Normalmap;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;8;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TriplanarNode;850;-2072.326,512.6907;Inherit;True;Spherical;World;True;WS Normalmap;_WSNormalmap;bump;10;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;WS Normalmap;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;10;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;804;-2070.301,76.00554;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;781;-1654.245,527.8788;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;813;-1727.29,174.0268;Inherit;False;Property;_Normalmapscale;Normalmap scale;5;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;764;-1725.844,88.48602;Inherit;False;MainUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalizeNode;771;-1430.245,527.8788;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;783;-1470.594,60.66282;Inherit;True;Property;_MainNormalmap;Main Normalmap;4;1;[Normal];Create;True;0;0;0;False;0;False;-1;None;0b17666817bf20a42913ea4f4e7bfbdd;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendNormalsNode;836;-1153.286,525.7047;Inherit;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;785;-934.2451,527.8788;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;765;-758.245,527.8788;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;816;-614.245,527.8788;Inherit;False;WSNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;760;-3314.139,-95.89957;Inherit;False;875.1;371.4011;NdotL;5;908;800;775;901;791;NdotL;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;911;-3243.379,18.13211;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;791;-3270.59,-64.70973;Inherit;False;816;WSNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;758;-1668.756,1750.169;Inherit;False;1965.232;706.7625;Rimlight;16;873;861;855;854;851;837;835;828;819;810;809;803;788;772;769;767;Rimlight;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;775;-2949.355,-50.9108;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;803;-1567.442,2073.697;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;810;-1614.473,1962.488;Inherit;False;816;WSNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;757;1226.347,1459.14;Inherit;False;1508.318;654.9337;Shadows;16;902;909;903;789;891;900;894;893;843;899;889;856;766;886;885;793;Shadows;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;800;-2658.741,-51.5283;Float;True;NdotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;885;1301.604,1691.114;Inherit;True;800;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;793;1271.947,1906.334;Float;False;Property;_BaseCellOffset;Base Cell Offset;21;0;Create;True;0;0;0;False;0;False;0;0.5;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;769;-1298.445,2243.139;Float;False;Property;_Rimoffset;Rim offset;19;0;Create;True;0;0;0;False;0;False;0.6;0.8;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;772;-1262.34,2008.805;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;886;1573.172,1879.832;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;838;-3089.004,340.8611;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;766;1306.279,2018.886;Float;False;Property;_BaseCellSharpness;Base Cell Sharpness;20;0;Create;True;0;0;0;False;0;False;0.01;0.85;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;856;1344.001,1523.031;Inherit;False;816;WSNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;857;-1389.968,389.5242;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;756;-208.0291,-344.1639;Inherit;False;2142.631;1038.674;Diffuse;9;872;848;841;834;832;811;808;801;763;Diffuse blend;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;809;-1038.74,2013.022;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;889;1755.949,1881.721;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;767;-878.7402,2013.022;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;839;-262.969,378.3384;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;842;-1983.047,366.4152;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;801;135.569,-43.82767;Inherit;False;764;MainUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LightAttenuation;899;1617.27,1606.938;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;860;-2846.027,336.7571;Inherit;False;Lightcolor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;843;1588.404,1527.868;Inherit;False;World;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;901;-3220.994,169.9965;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;893;1850.073,1528.435;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;891;1903.063,1839.462;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;835;-697.74,2010.022;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;819;-814.7402,2141.022;Float;False;Property;_RimStr;Rim Str;18;0;Create;True;0;0;0;False;0;False;0.4;0.85;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;811;-70.79533,91.63994;Inherit;True;Spherical;World;False;WS Diffuse;_WSDiffuse;white;9;None;Mid Texture 2;_MidTexture2;white;-1;None;Bot Texture 2;_BotTexture2;white;-1;None;WS Diffuse;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;10;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;872;546.3024,171.5553;Inherit;False;Property;_WS_blend;WS_blend;7;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;837;-747.3719,1911.919;Inherit;False;800;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;894;1851.318,1745.791;Inherit;False;860;Lightcolor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;808;327.5691,-75.82767;Inherit;True;Property;_Diffuse;Diffuse;3;0;Create;True;0;0;0;False;0;False;-1;None;903642cf8ff01fe47896dde16b90dc40;True;0;False;white;LockedToTexture2D;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;908;-2960.186,184.9065;Inherit;False;LightType;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;900;2130.734,1604.739;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;788;-510.741,2013.022;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;848;876.5049,-306.1547;Float;False;Property;_MainColor;Main Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;773;-1242.103,425.8849;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;873;-503.8979,1856.741;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;834;840.5701,54.87105;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;855;-503.166,2227.485;Float;False;Property;_RimColor;Rim Color;17;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.4150943,0.4150943,0.4150943,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;789;1895.006,1922.524;Inherit;False;Property;_Shadowcolor;Shadow color;1;1;[HDR];Create;True;0;0;0;False;0;False;0.3921569,0.454902,0.5568628,1;0.1940637,0.2784971,0.4622642,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TriplanarNode;832;11.10498,385.7647;Inherit;True;Spherical;World;False;Grass;_Grass;white;13;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Grass;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;8;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;909;2163.47,1515.506;Inherit;False;908;LightType;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;841;1127.568,-235.8277;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;903;2291.949,1755.898;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;861;-237.517,2226.204;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;854;-250.613,1825.796;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;851;-253.417,2085.961;Inherit;False;860;Lightcolor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ConditionalIfNode;902;2446.28,1536.365;Inherit;True;False;5;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;828;78.34094,1934.848;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;763;1638.177,222.4413;Inherit;True;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;910;1197.238,1364.97;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;865;3931.941,1457.81;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;5;4351.841,1217.854;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;KumaBeer/Worldspace_tiled_lite;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;18;all;True;True;True;False;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;3.3;10;25;False;1;True;0;0;False;-1;0;False;-1;0;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;True;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;779;0;806;2
WireConnection;805;0;779;0
WireConnection;859;0;805;0
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
WireConnection;804;0;786;0
WireConnection;781;0;850;0
WireConnection;781;1;826;0
WireConnection;781;2;827;0
WireConnection;764;0;804;0
WireConnection;771;0;781;0
WireConnection;783;1;764;0
WireConnection;783;5;813;0
WireConnection;836;0;783;0
WireConnection;836;1;771;0
WireConnection;785;0;836;0
WireConnection;765;0;785;0
WireConnection;816;0;765;0
WireConnection;775;0;791;0
WireConnection;775;1;911;0
WireConnection;800;0;775;0
WireConnection;772;0;810;0
WireConnection;772;1;803;0
WireConnection;886;0;885;0
WireConnection;886;1;793;0
WireConnection;857;0;862;0
WireConnection;809;0;772;0
WireConnection;809;1;769;0
WireConnection;889;0;886;0
WireConnection;889;1;766;0
WireConnection;767;0;809;0
WireConnection;839;0;857;0
WireConnection;842;0;776;0
WireConnection;860;0;838;0
WireConnection;843;0;856;0
WireConnection;893;0;843;0
WireConnection;893;1;899;0
WireConnection;891;0;889;0
WireConnection;835;0;767;0
WireConnection;811;9;842;0
WireConnection;811;3;839;0
WireConnection;811;4;840;0
WireConnection;808;1;801;0
WireConnection;908;0;901;2
WireConnection;900;0;891;0
WireConnection;900;1;893;0
WireConnection;900;2;894;0
WireConnection;788;0;835;0
WireConnection;788;1;819;0
WireConnection;773;0;762;0
WireConnection;873;0;837;0
WireConnection;834;0;808;0
WireConnection;834;1;811;0
WireConnection;834;2;872;0
WireConnection;832;9;776;0
WireConnection;832;3;773;0
WireConnection;832;4;840;0
WireConnection;841;0;848;0
WireConnection;841;1;834;0
WireConnection;903;0;789;0
WireConnection;903;2;900;0
WireConnection;861;0;855;0
WireConnection;854;0;873;0
WireConnection;854;1;788;0
WireConnection;902;0;909;0
WireConnection;902;3;900;0
WireConnection;902;4;903;0
WireConnection;828;0;854;0
WireConnection;828;1;851;0
WireConnection;828;2;861;0
WireConnection;763;0;841;0
WireConnection;763;1;832;0
WireConnection;763;2;827;0
WireConnection;910;0;828;0
WireConnection;865;0;763;0
WireConnection;865;1;902;0
WireConnection;5;2;910;0
WireConnection;5;13;865;0
ASEEND*/
//CHKSM=E9312D3613909B4CCCC63A3525B2320746674EE9