Shader "Lost/Toon" {
	Properties {
		_Color ("Main Color", Color) = (.5,.5,.5,1)
		_ColorFactor ("Main Color Factor", Range(1.0, 5.0)) = 1.0
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BrightColor ("BrightColor", Color) = (1,1,1,1)
		_BrightFactor ("BrightFactor", float) = 1.5
		_LightDir ("LightDir", Vector) = (1,0,0,0)
		_MinDot ("MinDot", float) = 0.7
		_RimColor ("Rim Color", Color) = (0.0, 0.0, 0.0, 0.0)
		_RimPower ("Rim Power", float) = 2.0
		_TwinkleColor ("TwinkleColor", Color) = (0.0, 0.0, 0.0, 0.0)
		_TwinklePos ("TwinklePos", Vector) = (0.0, 0.0, 1.0, 0.0)
	}


	SubShader {
		Tags { "RenderType"="Opaque" }
		Pass {
			Name "BASE"
			Cull Off
			// Fog { Mode Off }
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest 

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			samplerCUBE _ToonShade;
			float4 _MainTex_ST;
			float4 _Color;
			float _ColorFactor;
			float4 _BrightColor;
			float _BrightFactor;
			float4 _LightDir;
			float _MinDot;
			float4 _RimColor;    
			half _RimPower;
			float4 _TwinkleColor;
			float4 _TwinklePos;

			struct appdata {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : POSITION0;
				float4 basePos : POSITION1;
				float2 texcoord : TEXCOORD0;
				float3 normalDir : TEXCOORD1;
				float3 lightDir : TEXCOORD2;
				float4 rimColor : COLOR0;
				float4 twinkleColor : COLOR1;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.basePos.y = mul(_Object2World, v.vertex).y;
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				
				o.normalDir = mul(_Object2World, float4(v.normal,0)).xyz;
				o.lightDir = _WorldSpaceLightPos0.xyz;

				float3	viewDir		= ObjSpaceViewDir(v.vertex);
				fixed	rim			= 1.0 - saturate(dot(normalize(viewDir), v.normal));
				float4	rimColor	= _RimColor.rgba * pow(rim, _RimPower);

				o.rimColor = rimColor;

				float4 pos = _TwinklePos - v.vertex;
				fixed twinkle = saturate(dot(normalize(pos), v.normal));

				o.twinkleColor = twinkle * _TwinkleColor;

				return o;
			}

			float4 frag (v2f i) : COLOR
			{
				float4	col			= tex2D(_MainTex, i.texcoord);
				float3	nor			= normalize(float3(i.normalDir.x, 0, i.normalDir.z));
				float3	lightDir	= normalize(float3(i.lightDir.x, 0, i.lightDir.z));
				float	lightDot	= dot(nor, lightDir);
				lightDot = clamp(lightDot, 0, 1);
				
				float3 color;
				color.x = 1;
				color.y = 1;
				color.z = 1;
				color = color.rgb * pow (lightDot, 8) * 3;

				col.rgb += color;
				
				float y = i.basePos.y - 1.28;
				float hight = 0.5;
				
				col = col * 0.5 + col * y / hight * 1.2;
				
				return col;
			}
			ENDCG			
		}
	} 

	SubShader {
		Tags { "RenderType"="Opaque" }
		Pass {
			Name "BASE"
			Cull Off
			SetTexture [_MainTex] {
				constantColor [_Color]
				Combine texture * constant
			} 
			SetTexture [_ToonShade] {
				combine texture * previous DOUBLE, previous
			}
		}
	} 
	
	Fallback "VertexLit"
}
