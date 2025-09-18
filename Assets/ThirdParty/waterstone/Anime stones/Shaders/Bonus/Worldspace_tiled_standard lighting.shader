// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "KumaBeer/Worldspace_tiled_Standard_Lighting"
{
	Properties
	{
		_MainColor("Main Color", Color) = (1,1,1,1)
		_Specular("Specular", Color) = (0,0,0,0)
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		[HDR]_Shadowreplacement("Shadow replacement", Color) = (0.3921569,0.454902,0.5568628,1)
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
		_Grassheight("Grassheight", Float) = -2.54
		_Grassmaskdetail("Grass mask detail", Float) = 0.5
		_Color_D("Color_D", Color) = (0.1739943,0.4339623,0.1826832,0)
		_Falloffcolor("Falloff color", Float) = 0
		_Distancecolorblending("Distance color blending", Float) = 2
		[HDR]_RimColor("Rim Color", Color) = (1,1,1,0)
		_RimStr("Rim Str", Range( 0.01 , 1)) = 0.4
		_Rimoffset("Rim offset", Range( 0 , 1)) = 0.6
		_BaseCellOffset("Base Cell Offset", Range( 0.45 , 2)) = 1
		_BaseCellOffset02("Base Cell Offset 02", Range( 0 , 0.5)) = 0
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

		uniform float4 _RimColor;
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
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Grass);
		SamplerState sampler_Grass;
		uniform float _Grassheight;
		uniform float _Rimoffset;
		uniform float _RimStr;
		uniform float4 _MainColor;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Diffuse);
		SamplerState sampler_Diffuse;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_WSDiffuse);
		SamplerState sampler_WSDiffuse;
		uniform float _WS_blend;
		uniform float4 _Color_D;
		uniform float _Distancecolorblending;
		uniform float _Falloffcolor;
		uniform float _Grassmaskdetail;
		uniform float _Grasshardness;
		uniform float _Grasssharpen;
		uniform float _BaseCellOffset02;
		uniform float _BaseCellOffset;
		uniform float4 _Specular;
		uniform float _Smoothness;
		uniform float4 _Shadowreplacement;


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


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 temp_cast_1 = (_Main_tiling).xx;
			float2 uv_TexCoord804 = i.uv_texcoord * temp_cast_1;
			float2 MainUV764 = uv_TexCoord804;
			float4 tex2DNode808 = SAMPLE_TEXTURE2D( _Diffuse, sampler_Diffuse, MainUV764 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float4 triplanar811 = TriplanarSampling811( _WSDiffuse, sampler_WSDiffuse, ase_worldPos, ase_worldNormal, _TriplanarFalloff, _WSTiling, 1.0, 0 );
			float4 lerpResult834 = lerp( float4( (tex2DNode808).rgb , 0.0 ) , triplanar811 , _WS_blend);
			float4 triplanar832 = TriplanarSampling832( _Grass, sampler_Grass, ase_worldPos, ase_worldNormal, _TriplanarFalloff, _GrassTiling, 1.0, 0 );
			float saferPower807 = abs( ( distance( ase_worldPos , _WorldSpaceCameraPos ) / _Distancecolorblending ) );
			float4 lerpResult874 = lerp( triplanar832 , _Color_D , saturate( pow( saferPower807 , _Falloffcolor ) ));
			float lerpResult994 = lerp( ( 1.0 - tex2DNode808.a ) , ( 1.0 - triplanar811.a ) , ( _WS_blend * _Grassmaskdetail ));
			float HeightMask797 = lerpResult994;
			float GrassheightMask768 = ( 1.0 - triplanar832.a );
			float lerpResult770 = lerp( GrassheightMask768 , 0.0 , _Grassheight);
			float dotResult779 = dot( ase_worldNormal.y , 1.0 );
			float smoothstepResult805 = smoothstep( lerpResult770 , 1.0 , dotResult779);
			float saferPower859 = abs( ( HeightMask797 + smoothstepResult805 ) );
			float4 lerpResult763 = lerp( ( _MainColor * lerpResult834 ) , lerpResult874 , saturate( (pow( saferPower859 , _Grasshardness )*_Grasssharpen + 0.0) ));
			float3 temp_cast_5 = (_BaseCellOffset02).xxx;
			float3 temp_cast_6 = (_BaseCellOffset).xxx;
			SurfaceOutputStandardSpecular s930 = (SurfaceOutputStandardSpecular ) 0;
			float4 color934 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			s930.Albedo = color934.rgb;
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 triplanar850 = TriplanarSampling850( _WSNormalmap, sampler_WSNormalmap, ase_worldPos, ase_worldNormal, _TriplanarFalloff, _WSTiling, _WS_Normalmapscale, 0 );
			float3 tanTriplanarNormal850 = mul( ase_worldToTangent, triplanar850 );
			float3 triplanar826 = TriplanarSampling826( _GrassNormalmap, sampler_GrassNormalmap, ase_worldPos, ase_worldNormal, _TriplanarFalloff, _GrassTiling, 1.0, 0 );
			float3 tanTriplanarNormal826 = mul( ase_worldToTangent, triplanar826 );
			float3 lerpResult781 = lerp( tanTriplanarNormal850 , tanTriplanarNormal826 , saturate( smoothstepResult805 ));
			float3 normalizeResult771 = normalize( lerpResult781 );
			float3 temp_output_836_0 = BlendNormals( UnpackScaleNormal( SAMPLE_TEXTURE2D( _MainNormalmap, sampler_MainNormalmap, MainUV764 ), _Normalmapscale ) , normalizeResult771 );
			s930.Normal = WorldNormalVector( i , temp_output_836_0 );
			s930.Emission = float3( 0,0,0 );
			s930.Specular = _Specular.rgb;
			s930.Smoothness = _Smoothness;
			s930.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi930 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g930 = UnityGlossyEnvironmentSetup( s930.Smoothness, data.worldViewDir, s930.Normal, float3(0,0,0));
			gi930 = UnityGlobalIllumination( data, s930.Occlusion, s930.Normal, g930 );
			#endif

			float3 surfResult930 = LightingStandardSpecular ( s930, viewDir, gi930 ).rgb;
			surfResult930 += s930.Emission;

			#ifdef UNITY_PASS_FORWARDADD//930
			surfResult930 -= s930.Emission;
			#endif//930
			float3 smoothstepResult937 = smoothstep( temp_cast_5 , temp_cast_6 , surfResult930);
			float4 lerpResult1003 = lerp( _Shadowreplacement , float4( 1,1,1,0 ) , float4( smoothstepResult937 , 0.0 ));
			float4 ifLocalVar1004 = 0;
			if( _WorldSpaceLightPos0.w == 1.0 )
				ifLocalVar1004 = float4( smoothstepResult937 , 0.0 );
			else if( _WorldSpaceLightPos0.w < 1.0 )
				ifLocalVar1004 = lerpResult1003;
			c.rgb = ( lerpResult763 * ifLocalVar1004 ).rgb;
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
			float4 triplanar832 = TriplanarSampling832( _Grass, sampler_Grass, ase_worldPos, ase_worldNormal, _TriplanarFalloff, _GrassTiling, 1.0, 0 );
			float GrassheightMask768 = ( 1.0 - triplanar832.w );
			float lerpResult770 = lerp( GrassheightMask768 , 0.0 , _Grassheight);
			float dotResult779 = dot( ase_worldNormal.y , 1.0 );
			float smoothstepResult805 = smoothstep( lerpResult770 , 1.0 , dotResult779);
			float3 lerpResult781 = lerp( tanTriplanarNormal850 , tanTriplanarNormal826 , saturate( smoothstepResult805 ));
			float3 normalizeResult771 = normalize( lerpResult781 );
			float3 temp_output_836_0 = BlendNormals( UnpackScaleNormal( SAMPLE_TEXTURE2D( _MainNormalmap, sampler_MainNormalmap, MainUV764 ), _Normalmapscale ) , normalizeResult771 );
			float3 normalizeResult765 = normalize( normalize( (WorldNormalVector( i , temp_output_836_0 )) ) );
			float3 WSNormal816 = normalizeResult765;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult772 = dot( WSNormal816 , ase_worldViewDir );
			float saferPower788 = abs( ( 1.0 - saturate( ( dotResult772 + _Rimoffset ) ) ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult992 = dot( ase_worldNormal , ase_worldlightDir );
			o.Emission = ( (_RimColor).rgb * ( pow( saferPower788 , _RimStr ) * saturate( dotResult992 ) ) );
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
41;626;1297;513;-2577.001;-840.7997;1.700497;True;True
Node;AmplifyShaderEditor.RangedFloatNode;762;-1015.941,334.3792;Float;False;Property;_GrassTiling;Grass Tiling;14;0;Create;True;0;0;0;False;0;False;1;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;756;2094.611,-425.9085;Inherit;False;2142.631;1038.674;Diffuse;21;874;872;852;849;848;841;834;832;823;811;808;801;797;780;777;768;763;994;996;997;998;Diffuse blend;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;776;-879.4733,133.1212;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;840;-1011.593,633.5089;Inherit;False;Property;_TriplanarFalloff;Triplanar Falloff;8;0;Create;True;0;0;0;False;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;773;174.8987,303.3591;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;832;2313.745,304.0203;Inherit;True;Spherical;World;False;Grass;_Grass;white;15;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Grass;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;8;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;777;2727.571,258.4279;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;946;-1882.122,930.4718;Inherit;False;2182.74;1047.506;Comment;15;992;858;859;863;830;818;991;870;761;805;770;779;806;794;802;Grass Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;768;2897.959,219.1514;Inherit;False;GrassheightMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;802;-1391.935,1643.576;Inherit;False;Property;_Grassheight;Grassheight;19;0;Create;True;0;0;0;False;0;False;-2.54;0.24;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;786;-1196.783,-65.68436;Inherit;False;Property;_Main_tiling;Main_tiling;4;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;806;-1839.536,1220.166;Inherit;True;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;794;-1435.818,1545.326;Inherit;False;768;GrassheightMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;779;-1490.09,1226.775;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;770;-1213.149,1541.018;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;862;-852.5317,297.7781;Float;False;Property;_WSTiling;WS Tiling;10;0;Create;True;0;0;0;False;0;False;1;0.19;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;804;-978.888,-83.37772;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;764;-634.4309,-70.89713;Inherit;False;MainUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;857;27.03397,266.9985;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;822;-1003.911,457.4565;Inherit;False;Property;_WS_Normalmapscale;WS_Normalmap scale;13;0;Create;True;0;0;0;False;0;False;1;1.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;805;-1098.757,1209.881;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;801;2154.448,-324.6297;Inherit;False;764;MainUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TriplanarNode;826;-694.521,589.5862;Inherit;True;Spherical;World;True;Grass Normalmap;_GrassNormalmap;white;16;None;Mid Texture 3;_MidTexture3;white;-1;None;Bot Texture 3;_BotTexture3;white;-1;None;Grass Normalmap;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;8;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;839;113.8482,392.307;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;850;-655.3242,390.1649;Inherit;True;Spherical;World;True;WS Normalmap;_WSNormalmap;bump;12;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;WS Normalmap;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;10;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;842;-566.0452,243.8894;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;761;-1055.604,1000.32;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;808;2346.448,-356.6294;Inherit;True;Property;_Diffuse;Diffuse;5;0;Create;True;0;0;0;False;0;False;-1;None;903642cf8ff01fe47896dde16b90dc40;True;0;False;white;LockedToTexture2D;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;872;2697.452,13.50426;Inherit;False;Property;_WS_blend;WS_blend;9;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;811;2152.615,3.152615;Inherit;True;Spherical;World;False;WS Diffuse;_WSDiffuse;white;11;None;Mid Texture 2;_MidTexture2;white;-1;None;Bot Texture 2;_BotTexture2;white;-1;None;WS Diffuse;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;10;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;998;2905.499,128.3711;Inherit;False;Property;_Grassmaskdetail;Grass mask detail;20;0;Create;True;0;0;0;False;0;False;0.5;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;781;-237.2426,405.3528;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;813;-635.877,14.64357;Inherit;False;Property;_Normalmapscale;Normalmap scale;7;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;996;2551.685,95.36651;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;997;3276.856,72.45937;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;771;-13.24265,405.3528;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;783;-379.1808,-98.72031;Inherit;True;Property;_MainNormalmap;Main Normalmap;6;1;[Normal];Create;True;0;0;0;False;0;False;-1;None;0b17666817bf20a42913ea4f4e7bfbdd;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;780;2664.841,-244.3514;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;836;261.8987,-26.00259;Inherit;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;994;3578.293,27.69047;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;785;534.7867,407.8908;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;797;3879.728,-41.7504;Inherit;False;HeightMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;759;1651.724,721.524;Inherit;False;1257.089;345.2527;Distance;8;875;847;825;815;812;807;782;778;Distance color blending;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;815;1678.22,907.9622;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;870;-897.7195,1316.075;Inherit;False;797;HeightMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;765;732.3602,410.4289;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;812;1695.348,763.4989;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DistanceOpNode;778;2010.824,776.3221;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;758;993.8364,1623.213;Inherit;False;1965.232;706.7625;Rimlight;14;861;855;835;828;819;810;809;803;788;772;769;767;854;993;Rimlight;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;847;1984.762,896.8651;Inherit;False;Property;_Distancecolorblending;Distance color blending;23;0;Create;True;0;0;0;False;0;False;2;40;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;830;-643.5992,1331.957;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;818;-1328.405,1438.144;Inherit;False;Property;_Grasshardness;Grass hardness;17;0;Create;True;0;0;0;False;0;False;1;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;816;967.7296,447.2304;Inherit;False;WSNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;875;2299.04,915.9722;Inherit;False;Property;_Falloffcolor;Falloff color;22;0;Create;True;0;0;0;False;0;False;0;1.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;825;2231.26,776.4231;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;803;1095.151,1946.742;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;810;1048.12,1835.533;Inherit;False;816;WSNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;863;-363.2987,1589.768;Inherit;False;Property;_Grasssharpen;Grass sharpen;18;0;Create;True;0;0;0;False;0;False;0;2.1;0.1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;859;-357.777,1335.106;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;769;1364.148,2116.182;Float;False;Property;_Rimoffset;Rim offset;26;0;Create;True;0;0;0;False;0;False;0.6;0.8;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;807;2478.557,776.045;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;858;-61.55777,1337.633;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;772;1400.253,1881.85;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;972;3378.444,936.6872;Inherit;False;1479.317;814.332;Shadow replacement;12;979;978;941;937;789;793;930;934;1003;1004;1006;1007;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;849;2710.209,370.4276;Inherit;False;Property;_Color_D;Color_D;21;0;Create;True;0;0;0;False;0;False;0.1739943,0.4339623,0.1826832,0;0.3450972,0.419607,0.06274445,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;809;1623.853,1886.067;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;827;813.0659,1354.294;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;782;2740.174,775.181;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;823;2650.447,-324.6297;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;834;3003.446,-115.8139;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;999;3083.151,1347.993;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;767;1783.854,1886.067;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;848;3179.145,-387.8992;Float;False;Property;_MainColor;Main Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;991;-1794.132,1782.89;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;934;3398.101,983.9361;Inherit;False;Constant;_Color0;Color 0;27;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;874;3078.21,306.4276;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;945;1453.571,1031.556;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;979;3406.24,1267.232;Inherit;False;Property;_Specular;Specular;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;978;3393.833,1165.585;Inherit;False;Property;_Smoothness;Smoothness;2;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;793;3736.534,1244.526;Float;False;Property;_BaseCellOffset;Base Cell Offset;27;0;Create;True;0;0;0;False;0;False;1;0.45;0.45;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;841;3430.208,-317.5721;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;992;-1505.695,1742.484;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;819;1847.854,2014.066;Float;False;Property;_RimStr;Rim Str;25;0;Create;True;0;0;0;False;0;False;0.4;0.85;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1007;3700.149,1354.52;Inherit;False;Property;_BaseCellOffset02;Base Cell Offset 02;28;0;Create;True;0;0;0;False;0;False;0;0;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1000;3349.25,322.0128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;852;3366.209,194.4279;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomStandardSurface;930;3713.315,1006.59;Inherit;False;Specular;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;835;1964.854,1883.068;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;993;1530.028,1729.938;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;763;3940.817,140.6971;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;937;4069.49,1203.145;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;855;2159.431,2100.529;Float;False;Property;_RimColor;Rim Color;24;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.4150943,0.4150943,0.4150943,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;788;2151.856,1886.067;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;789;4071.174,1413.482;Inherit;False;Property;_Shadowreplacement;Shadow replacement;3;1;[HDR];Create;True;0;0;0;False;0;False;0.3921569,0.454902,0.5568628,1;0.2843983,0.4253314,0.7264151,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;854;2438.517,1674.386;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;1006;4188.067,1097.258;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ComponentMaskNode;861;2425.081,2099.248;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;1003;4352.881,1321.471;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;1001;4399.62,398.2745;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ConditionalIfNode;1004;4508.883,1134.337;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;1002;4421.065,1144.728;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;828;2740.939,1807.892;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;941;4695.965,1294.232;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;774;5030.598,1800.391;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;5;5155.125,1503.505;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;KumaBeer/Worldspace_tiled_Standard_Lighting;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0;True;True;0;False;Opaque;;Geometry;All;18;all;True;True;True;False;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;1;False;-1;8;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;True;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;773;0;762;0
WireConnection;832;9;776;0
WireConnection;832;3;773;0
WireConnection;832;4;840;0
WireConnection;777;0;832;4
WireConnection;768;0;777;0
WireConnection;779;0;806;2
WireConnection;770;0;794;0
WireConnection;770;2;802;0
WireConnection;804;0;786;0
WireConnection;764;0;804;0
WireConnection;857;0;862;0
WireConnection;805;0;779;0
WireConnection;805;1;770;0
WireConnection;826;9;776;0
WireConnection;826;3;762;0
WireConnection;826;4;840;0
WireConnection;839;0;857;0
WireConnection;850;9;776;0
WireConnection;850;8;822;0
WireConnection;850;3;862;0
WireConnection;850;4;840;0
WireConnection;842;0;776;0
WireConnection;761;0;805;0
WireConnection;808;1;801;0
WireConnection;811;9;842;0
WireConnection;811;3;839;0
WireConnection;811;4;840;0
WireConnection;781;0;850;0
WireConnection;781;1;826;0
WireConnection;781;2;761;0
WireConnection;996;0;811;4
WireConnection;997;0;872;0
WireConnection;997;1;998;0
WireConnection;771;0;781;0
WireConnection;783;1;764;0
WireConnection;783;5;813;0
WireConnection;780;0;808;4
WireConnection;836;0;783;0
WireConnection;836;1;771;0
WireConnection;994;0;780;0
WireConnection;994;1;996;0
WireConnection;994;2;997;0
WireConnection;785;0;836;0
WireConnection;797;0;994;0
WireConnection;765;0;785;0
WireConnection;778;0;812;0
WireConnection;778;1;815;0
WireConnection;830;0;870;0
WireConnection;830;1;805;0
WireConnection;816;0;765;0
WireConnection;825;0;778;0
WireConnection;825;1;847;0
WireConnection;859;0;830;0
WireConnection;859;1;818;0
WireConnection;807;0;825;0
WireConnection;807;1;875;0
WireConnection;858;0;859;0
WireConnection;858;1;863;0
WireConnection;772;0;810;0
WireConnection;772;1;803;0
WireConnection;809;0;772;0
WireConnection;809;1;769;0
WireConnection;827;0;858;0
WireConnection;782;0;807;0
WireConnection;823;0;808;0
WireConnection;834;0;823;0
WireConnection;834;1;811;0
WireConnection;834;2;872;0
WireConnection;999;0;827;0
WireConnection;767;0;809;0
WireConnection;874;0;832;0
WireConnection;874;1;849;0
WireConnection;874;2;782;0
WireConnection;945;0;836;0
WireConnection;841;0;848;0
WireConnection;841;1;834;0
WireConnection;992;0;806;0
WireConnection;992;1;991;0
WireConnection;1000;0;999;0
WireConnection;852;0;874;0
WireConnection;930;0;934;0
WireConnection;930;1;945;0
WireConnection;930;3;979;0
WireConnection;930;4;978;0
WireConnection;835;0;767;0
WireConnection;993;0;992;0
WireConnection;763;0;841;0
WireConnection;763;1;852;0
WireConnection;763;2;1000;0
WireConnection;937;0;930;0
WireConnection;937;1;1007;0
WireConnection;937;2;793;0
WireConnection;788;0;835;0
WireConnection;788;1;819;0
WireConnection;854;0;788;0
WireConnection;854;1;993;0
WireConnection;861;0;855;0
WireConnection;1003;0;789;0
WireConnection;1003;2;937;0
WireConnection;1001;0;763;0
WireConnection;1004;0;1006;2
WireConnection;1004;3;937;0
WireConnection;1004;4;1003;0
WireConnection;1002;0;1001;0
WireConnection;828;0;861;0
WireConnection;828;1;854;0
WireConnection;941;0;1002;0
WireConnection;941;1;1004;0
WireConnection;774;0;828;0
WireConnection;5;2;774;0
WireConnection;5;13;941;0
ASEEND*/
//CHKSM=10618BF8FFA47D9BD0880D13BF5A5628EFBBF63F