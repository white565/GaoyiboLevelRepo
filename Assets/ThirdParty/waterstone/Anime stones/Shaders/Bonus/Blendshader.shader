// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "KumaBeer/Blendshader"
{
	Properties
	{
		_MainColor("Main Color", Color) = (1,1,1,1)
		[HDR]_Shadowcolor("Shadow color", Color) = (0.3921569,0.454902,0.5568628,1)
		_GrassTiling("Grass Tiling", Float) = 1
		_Grass("Grass", 2D) = "white" {}
		_GrassNormalmap("Grass Normalmap", 2D) = "white" {}
		_Blendstrength("Blend strength", Float) = 0
		_Blenddistance("Blend distance", Float) = -0.3
		[HDR]_RimColor("Rim Color", Color) = (1,1,1,0)
		_RimStr("Rim Str", Range( 0.01 , 1)) = 0.4
		_BaseCellSharpness("Base Cell Sharpness", Range( 0.01 , 1)) = 0.01
		_Rimoffset("Rim offset", Range( 0 , 1)) = 0.6
		_IndirectDiffuseContribution("Indirect Diffuse Contribution", Range( 0 , 1)) = 1
		_BaseCellOffset("Base Cell Offset", Range( -1 , 1)) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha DstAlpha
		
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma surface surf StandardCustomLighting keepalpha 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
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

		sampler2D _GrassNormalmap;
		uniform float _GrassTiling;
		uniform float _Rimoffset;
		uniform float _RimStr;
		uniform float4 _RimColor;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Blenddistance;
		uniform float _Blendstrength;
		uniform float4 _MainColor;
		sampler2D _Grass;
		uniform float _BaseCellOffset;
		uniform float _BaseCellSharpness;
		uniform float _IndirectDiffuseContribution;
		uniform float4 _Shadowcolor;


		inline float3 TriplanarSampling826( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			xNorm.xyz  = half3( UnpackNormal( xNorm ).xy * float2(  nsign.x, 1.0 ) + worldNormal.zy, worldNormal.x ).zyx;
			yNorm.xyz  = half3( UnpackNormal( yNorm ).xy * float2(  nsign.y, 1.0 ) + worldNormal.xz, worldNormal.y ).xzy;
			zNorm.xyz  = half3( UnpackNormal( zNorm ).xy * float2( -nsign.z, 1.0 ) + worldNormal.xy, worldNormal.z ).xyz;
			return normalize( xNorm.xyz * projNormal.x + yNorm.xyz * projNormal.y + zNorm.xyz * projNormal.z );
		}


		inline float4 TriplanarSampling832( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
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
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth878 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth878 = abs( ( screenDepth878 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _Blenddistance ) );
			float clampResult882 = clamp( (distanceDepth878*_Blendstrength + _Blenddistance) , 0.0 , 1.0 );
			float Blendmask883 = clampResult882;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float4 triplanar832 = TriplanarSampling832( _Grass, ase_worldPos, ase_worldNormal, 8.0, _GrassTiling, 1.0, 0 );
			float LightType931 = _WorldSpaceLightPos0.w;
			float3 triplanar826 = TriplanarSampling826( _GrassNormalmap, ase_worldPos, ase_worldNormal, 8.0, _GrassTiling, 1.0, 0 );
			float3 WSNormal816 = triplanar826;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult775 = dot( WSNormal816 , ase_worldlightDir );
			float NdotL800 = dotResult775;
			float3 temp_cast_3 = (1.0).xxx;
			UnityGI gi1014 = gi;
			float3 diffNorm1014 = WSNormal816;
			gi1014 = UnityGI_Base( data, 1, diffNorm1014 );
			float3 indirectDiffuse1014 = gi1014.indirect.diffuse + diffNorm1014 * 0.0001;
			float3 lerpResult1016 = lerp( temp_cast_3 , indirectDiffuse1014 , _IndirectDiffuseContribution);
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 Lightcolor860 = ase_lightColor;
			float4 temp_output_999_0 = ( saturate( ( ( NdotL800 + _BaseCellOffset ) / _BaseCellSharpness ) ) * float4( ( ase_lightAtten + lerpResult1016 ) , 0.0 ) * Lightcolor860 );
			float4 lerpResult1003 = lerp( _Shadowcolor , float4( 1,1,1,0 ) , temp_output_999_0);
			float4 ifLocalVar1004 = 0;
			if( LightType931 == 1.0 )
				ifLocalVar1004 = temp_output_999_0;
			else if( LightType931 < 1.0 )
				ifLocalVar1004 = lerpResult1003;
			c.rgb = ( ( _MainColor * triplanar832 ) * ifLocalVar1004 ).rgb;
			c.a = Blendmask883;
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
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 triplanar826 = TriplanarSampling826( _GrassNormalmap, ase_worldPos, ase_worldNormal, 8.0, _GrassTiling, 1.0, 0 );
			float3 WSNormal816 = triplanar826;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult775 = dot( WSNormal816 , ase_worldlightDir );
			float NdotL800 = dotResult775;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult973 = dot( WSNormal816 , ase_worldViewDir );
			float saferPower982 = abs( ( 1.0 - saturate( ( dotResult973 + _Rimoffset ) ) ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 Lightcolor860 = ase_lightColor;
			o.Emission = ( ( saturate( NdotL800 ) * pow( saferPower982 , _RimStr ) ) * float4( (_RimColor).rgb , 0.0 ) * Lightcolor860 ).rgb;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18921
133;532;1297;519;-1189.309;-135.7657;2.936128;True;True
Node;AmplifyShaderEditor.CommentaryNode;756;1201.592,-135.5668;Inherit;False;1762.515;680.9788;Diffuse;10;768;777;841;832;848;816;930;826;776;762;Main;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;776;1329.774,-40.14151;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;762;1233.662,108.7551;Float;False;Property;_GrassTiling;Grass Tiling;3;0;Create;True;0;0;0;False;0;False;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;826;1560.811,333.8523;Inherit;True;Spherical;World;True;Grass Normalmap;_GrassNormalmap;white;5;None;Mid Texture 3;_MidTexture3;white;-1;None;Bot Texture 3;_BotTexture3;white;-1;None;Grass Normalmap;World;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;8;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;930;2415.552,374.8538;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;760;195.9741,-30.28401;Inherit;False;854.0812;307.4;NdotL;4;800;775;791;952;NdotL;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;816;2530.17,417.8787;Inherit;False;WSNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;791;240.7043,8.905836;Inherit;False;816;WSNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;952;242.6713,124.8469;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;775;537.9392,37.70473;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1011;1334.977,592.0311;Inherit;False;828.4254;361.0605;Comment;5;1016;1015;1014;1013;1012;Indirect Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;989;1296.157,1010.001;Inherit;False;2315.376;481.6804;Shadows;14;1004;1003;1001;1000;999;998;997;996;995;994;993;992;991;990;Shadows;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;800;828.553,37.08724;Float;True;NdotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;970;2721.015,-880.1461;Inherit;False;1965.232;706.7625;Rimlight;16;986;985;984;983;982;981;980;979;978;977;976;975;974;973;972;971;Rimlight;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;971;2775.299,-667.8268;Inherit;False;816;WSNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;972;2822.329,-556.6179;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;990;1330.617,1068.09;Inherit;True;800;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;991;1313.837,1261.139;Float;False;Property;_BaseCellOffset;Base Cell Offset;13;0;Create;True;0;0;0;False;0;False;0;-0.35;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1012;1384.977,736.4122;Inherit;False;816;WSNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;838;288.5342,419.2642;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;992;1607.858,1067.361;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;1014;1627.906,740.4871;Inherit;False;World;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1013;1643.967,843.0931;Float;False;Property;_IndirectDiffuseContribution;Indirect Diffuse Contribution;12;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;993;1618.237,1208.809;Float;False;Property;_BaseCellSharpness;Base Cell Sharpness;10;0;Create;True;0;0;0;False;0;False;0.01;0.35;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1015;1763.587,642.0311;Float;False;Constant;_Float0;Float 0;20;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;974;3091.327,-387.176;Float;False;Property;_Rimoffset;Rim offset;11;0;Create;True;0;0;0;False;0;False;0.6;0.658;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;973;3127.432,-621.5099;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;876;1398.52,1673.2;Inherit;False;1792.508;455.2864;;6;883;882;901;878;879;877;Blend;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;975;3351.032,-617.2929;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;997;2217.306,1081.741;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;877;1438.567,1855.787;Inherit;False;Property;_Blenddistance;Blend distance;7;0;Create;True;0;0;0;False;0;False;-0.3;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;994;1930.917,1069.139;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;860;534.2039,416.1531;Inherit;False;Lightcolor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1016;1916.457,686.3912;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;998;2485.178,1081.919;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;932;225.5933,295.5661;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SaturateNode;995;2122.187,1207.463;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;996;2696.125,1239.462;Inherit;False;860;Lightcolor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;879;1803.44,2001.116;Inherit;False;Property;_Blendstrength;Blend strength;6;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;878;1691.389,1720.671;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;976;3511.032,-617.2929;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;977;3575.032,-489.2929;Float;False;Property;_RimStr;Rim Str;9;0;Create;True;0;0;0;False;0;False;0.4;0.279;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;979;3729.779,-712.9348;Inherit;False;800;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;978;3692.032,-620.2929;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;931;545.4011,312.4761;Inherit;False;LightType;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1000;2672.507,1320.962;Inherit;False;Property;_Shadowcolor;Shadow color;2;1;[HDR];Create;True;0;0;0;False;0;False;0.3921569,0.454902,0.5568628,1;0.5377358,0.5377358,0.5377358,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;999;2897.878,1164.587;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;901;2256.02,1892.632;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;832;1894.506,71.67845;Inherit;True;Spherical;World;False;Grass;_Grass;white;4;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Grass;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;8;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;982;3879.03,-617.2929;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;848;2510.329,-64.85059;Float;False;Property;_MainColor;Main Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;882;2533.884,1892.788;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1003;3158.733,1369.009;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;980;3954.417,-706.9877;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;981;3886.605,-402.8298;Float;False;Property;_RimColor;Rim Color;8;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.6980392,0.2745098,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1001;3138.263,1074.39;Inherit;False;931;LightType;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;984;3667.112,-276.0397;Inherit;False;860;Lightcolor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;841;2741.522,52.95525;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;985;4152.255,-404.1108;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;983;4156.784,-694.8478;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;883;2953.909,1874.664;Inherit;False;Blendmask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;1004;3363.289,1080.409;Inherit;True;False;5;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;768;2701.5,281.4039;Inherit;False;GrassheightMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;777;2393.008,230.5879;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;986;4471.602,-430.8779;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;923;5104.938,8.121532;Inherit;False;883;Blendmask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;865;3757.264,696.3869;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;925;5471.181,-169.0135;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;KumaBeer/Blendshader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;1;5;False;-1;7;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;826;9;776;0
WireConnection;826;3;762;0
WireConnection;930;0;826;0
WireConnection;816;0;930;0
WireConnection;775;0;791;0
WireConnection;775;1;952;0
WireConnection;800;0;775;0
WireConnection;992;0;990;0
WireConnection;992;1;991;0
WireConnection;1014;0;1012;0
WireConnection;973;0;971;0
WireConnection;973;1;972;0
WireConnection;975;0;973;0
WireConnection;975;1;974;0
WireConnection;994;0;992;0
WireConnection;994;1;993;0
WireConnection;860;0;838;0
WireConnection;1016;0;1015;0
WireConnection;1016;1;1014;0
WireConnection;1016;2;1013;0
WireConnection;998;0;997;0
WireConnection;998;1;1016;0
WireConnection;995;0;994;0
WireConnection;878;0;877;0
WireConnection;976;0;975;0
WireConnection;978;0;976;0
WireConnection;931;0;932;2
WireConnection;999;0;995;0
WireConnection;999;1;998;0
WireConnection;999;2;996;0
WireConnection;901;0;878;0
WireConnection;901;1;879;0
WireConnection;901;2;877;0
WireConnection;832;9;776;0
WireConnection;832;3;762;0
WireConnection;982;0;978;0
WireConnection;982;1;977;0
WireConnection;882;0;901;0
WireConnection;1003;0;1000;0
WireConnection;1003;2;999;0
WireConnection;980;0;979;0
WireConnection;841;0;848;0
WireConnection;841;1;832;0
WireConnection;985;0;981;0
WireConnection;983;0;980;0
WireConnection;983;1;982;0
WireConnection;883;0;882;0
WireConnection;1004;0;1001;0
WireConnection;1004;3;999;0
WireConnection;1004;4;1003;0
WireConnection;768;0;777;0
WireConnection;777;0;832;4
WireConnection;986;0;983;0
WireConnection;986;1;985;0
WireConnection;986;2;984;0
WireConnection;865;0;841;0
WireConnection;865;1;1004;0
WireConnection;925;2;986;0
WireConnection;925;9;923;0
WireConnection;925;13;865;0
ASEEND*/
//CHKSM=B8EC2B8FCB9704A3A61CB7FC95DF34A9CB484056