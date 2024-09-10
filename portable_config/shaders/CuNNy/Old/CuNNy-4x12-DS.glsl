// CuNNy 4x12 DS
// Copyright (c) 2024 cunnyplapper

// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 3.0 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this program.  If not, see <https://www.gnu.org/licenses/>.
/* ------------------------------------------------------------------- */


//!DESC CuNNy-4x12-DS-in
//!HOOK LUMA
//!COMPUTE 24 8 8 8
//!BIND LUMA
//!SAVE in
//!WIDTH LUMA.w 3 *
//!HEIGHT LUMA.h
//!COMPONENTS 4
//!WHEN OUTPUT.w LUMA.w / 1.3 > OUTPUT.h LUMA.h / 1.3 > *
#extension GL_EXT_shader_explicit_arithmetic_types_float16 : enable
#ifdef GL_EXT_shader_explicit_arithmetic_types_float16
#	define V4 f16vec4
#	define M4 f16mat4
#	define F float16_t
#else
#	define V4 vec4
#	define M4 mat4
#	define F float
#endif
#define l0(x, y) F(LUMA_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(1, 1) + ivec2(0, 0)) + vec2(0.5)) * LUMA_pt).r)
shared F G[1][10][10];
void hook() {
	ivec2 xy = ivec2(gl_LocalInvocationID.xy);
	ivec2 pos = ivec2(gl_WorkGroupID.xy) * ivec2(8, 8) + xy;
	ivec2 opos = pos * ivec2(3, 1);
	ivec2 sz = ivec2(LUMA_size) - ivec2(1);
	for (int y = 0; y < 10; y += 8) {
		int ay = xy.y + y;
		if (ay >= 10) break;
		for (int x = 0; x < 10; x += 8) {
			int ax = xy.x + x;
			if (ax >= 10) break;
			G[0][ay][ax] = l0(x - 1, y - 1);
		}
	}
	barrier();
	F s0_0_0, s0_0_1, s0_0_2, s0_1_0, s0_1_1, s0_1_2, s0_2_0, s0_2_1, s0_2_2;
	V4 r0, r1, r2;
	r0 = V4(0.0); r1 = V4(0.0); r2 = V4(0.0);
	s0_0_0 = G[0][xy.y+0][xy.x+0]; s0_0_1 = G[0][xy.y+0][xy.x+1];
	s0_0_2 = G[0][xy.y+0][xy.x+2]; s0_1_0 = G[0][xy.y+1][xy.x+0];
	s0_1_1 = G[0][xy.y+1][xy.x+1]; s0_1_2 = G[0][xy.y+1][xy.x+2];
	s0_2_0 = G[0][xy.y+2][xy.x+0]; s0_2_1 = G[0][xy.y+2][xy.x+1];
	s0_2_2 = G[0][xy.y+2][xy.x+2];
	r0 += V4(-1.843e+00, -1.758e-02, 3.796e-04, 3.294e-03) * s0_0_0;
	r1 += V4(-1.121e-01, -3.878e-01, -3.230e-02, 5.185e-01) * s0_0_0;
	r2 += V4(-1.082e-01, 2.994e-02, 6.441e-02, -2.484e-01) * s0_0_0;
	r0 += V4(-5.607e-02, 1.392e-01, -1.217e-01, 1.486e-01) * s0_0_1;
	r1 += V4(-2.119e-02, -4.951e-01, -5.351e-02, -4.893e-01) * s0_0_1;
	r2 += V4(7.514e-02, -3.366e-02, -4.004e-02, -1.041e-01) * s0_0_1;
	r0 += V4(4.222e-02, -7.486e-02, 2.442e-02, 2.883e-02) * s0_0_2;
	r1 += V4(-6.893e-03, 3.363e-02, -3.348e-01, -2.708e-02) * s0_0_2;
	r2 += V4(2.631e-03, -1.596e-02, -1.770e-02, 3.837e-03) * s0_0_2;
	r0 += V4(2.550e-02, 1.709e-01, -2.992e-02, 4.433e-02) * s0_1_0;
	r1 += V4(-3.526e-01, 3.799e-01, 1.798e-02, -5.806e-01) * s0_1_0;
	r2 += V4(3.586e-01, -4.661e-03, 8.028e-01, -3.927e-01) * s0_1_0;
	r0 += V4(2.365e-02, 5.305e-02, -6.967e-01, 4.091e-01) * s0_1_1;
	r1 += V4(7.051e-01, 5.020e-01, 4.008e-01, 3.553e-01) * s0_1_1;
	r2 += V4(-3.584e-01, -1.587e-01, -8.066e-01, 7.324e-01) * s0_1_1;
	r0 += V4(8.776e-03, 1.984e-01, 3.016e-01, -8.379e-01) * s0_1_2;
	r1 += V4(7.148e-03, -1.500e-02, 4.376e-01, 2.133e-01) * s0_1_2;
	r2 += V4(2.439e-03, -3.877e-01, 1.454e-03, 1.613e-02) * s0_1_2;
	r0 += V4(6.695e-02, 4.099e-03, 4.938e-02, -4.178e-03) * s0_2_0;
	r1 += V4(-1.207e-01, -1.117e-02, 7.917e-03, 9.545e-02) * s0_2_0;
	r2 += V4(1.925e-02, -3.857e-03, 1.371e-02, -4.288e-02) * s0_2_0;
	r0 += V4(-3.266e-02, 2.179e-02, 2.908e-01, 1.193e-01) * s0_2_1;
	r1 += V4(-7.790e-02, 4.925e-02, -3.420e-01, 9.741e-02) * s0_2_1;
	r2 += V4(6.728e-02, 5.038e-01, -3.245e-03, 5.628e-02) * s0_2_1;
	r0 += V4(-5.197e-03, 3.518e-02, 1.772e-01, 6.662e-02) * s0_2_2;
	r1 += V4(1.156e-03, -5.307e-02, -9.253e-02, -1.815e-01) * s0_2_2;
	r2 += V4(-7.273e-02, 6.703e-02, -1.854e-02, -7.999e-03) * s0_2_2;
	r0 += V4(6.665e-02, -1.471e-02, 1.972e-02, -1.972e-02);
	r0 = max(r0, V4(0.0));
	imageStore(out_image, opos + ivec2(0, 0), vec4(r0));
	r1 += V4(1.492e-02, 1.203e-02, -3.225e-04, -1.064e-03);
	r1 = max(r1, V4(0.0));
	imageStore(out_image, opos + ivec2(1, 0), vec4(r1));
	r2 += V4(4.784e-02, 4.334e-02, 1.233e-02, -1.385e-02);
	r2 = max(r2, V4(0.0));
	imageStore(out_image, opos + ivec2(2, 0), vec4(r2));
}

//!DESC CuNNy-4x12-DS-conv1
//!HOOK LUMA
//!COMPUTE 24 8 8 8
//!BIND in
//!BIND LUMA
//!SAVE conv1
//!WIDTH LUMA.w 3 *
//!HEIGHT LUMA.h
//!COMPONENTS 4
//!WHEN OUTPUT.w LUMA.w / 1.3 > OUTPUT.h LUMA.h / 1.3 > *
#extension GL_EXT_spirv_intrinsics : require
#define l0(x, y) in_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(3, 1) + ivec2(0, 0)) + vec2(0.5)) * in_pt)
#define l1(x, y) in_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(3, 1) + ivec2(1, 0)) + vec2(0.5)) * in_pt)
#define l2(x, y) in_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(3, 1) + ivec2(2, 0)) + vec2(0.5)) * in_pt)
spirv_instruction (extensions = ["SPV_KHR_integer_dot_product"], capabilities = [6019, 6018], id = 4450)
int dp4(int a, int b, spirv_literal int fmt);
#define D(r, s, a, b, c, d) r + ivec4(dp4(s, a, 0), dp4(s, b, 0), dp4(s, c, 0), dp4(s, d, 0))
shared int G[3][10][10];
void hook() {
	ivec2 xy = ivec2(gl_LocalInvocationID.xy);
	ivec2 pos = ivec2(gl_WorkGroupID.xy) * ivec2(8, 8) + xy;
	ivec2 opos = pos * ivec2(3, 1);
	ivec2 sz = ivec2(LUMA_size) - ivec2(1);
	for (int y = 0; y < 10; y += 8) {
		int ay = xy.y + y;
		if (ay >= 10) break;
		for (int x = 0; x < 10; x += 8) {
			int ax = xy.x + x;
			if (ax >= 10) break;
			vec4 v0 = l0(x - 1, y - 1) * 1.0000000e+00;
			vec4 v1 = l1(x - 1, y - 1) * 1.0000000e+00;
			vec4 v2 = l2(x - 1, y - 1) * 1.0000000e+00;
			G[0][ay][ax] = int(packSnorm4x8(v0));
			G[1][ay][ax] = int(packSnorm4x8(v1));
			G[2][ay][ax] = int(packSnorm4x8(v2));
		}
	}
	barrier();
	int s0_0_0, s0_0_1, s0_0_2, s0_1_0, s0_1_1, s0_1_2, s0_2_0, s0_2_1, s0_2_2, s1_0_0, s1_0_1, s1_0_2, s1_1_0, s1_1_1, s1_1_2, s1_2_0, s1_2_1, s1_2_2;
	ivec4 r0, r1, r2;
	vec4 f0, f1, f2;
	r0 = ivec4(0); r1 = ivec4(0); r2 = ivec4(0);
	s0_0_0 = G[0][xy.y+0][xy.x+0]; s0_0_1 = G[0][xy.y+0][xy.x+1];
	s0_0_2 = G[0][xy.y+0][xy.x+2]; s0_1_0 = G[0][xy.y+1][xy.x+0];
	s0_1_1 = G[0][xy.y+1][xy.x+1]; s0_1_2 = G[0][xy.y+1][xy.x+2];
	s0_2_0 = G[0][xy.y+2][xy.x+0]; s0_2_1 = G[0][xy.y+2][xy.x+1];
	s0_2_2 = G[0][xy.y+2][xy.x+2]; s1_0_0 = G[1][xy.y+0][xy.x+0];
	s1_0_1 = G[1][xy.y+0][xy.x+1]; s1_0_2 = G[1][xy.y+0][xy.x+2];
	s1_1_0 = G[1][xy.y+1][xy.x+0]; s1_1_1 = G[1][xy.y+1][xy.x+1];
	s1_1_2 = G[1][xy.y+1][xy.x+2]; s1_2_0 = G[1][xy.y+2][xy.x+0];
	s1_2_1 = G[1][xy.y+2][xy.x+1]; s1_2_2 = G[1][xy.y+2][xy.x+2];
	r0 = D(r0, s0_0_0, 0x1F14EEFA, 0x19110700, 0xDF00E309, 0xFFAE3705);
	r1 = D(r1, s0_0_0, 0x40F2E318, 0xECFC0DF7, 0xE8FD3806, 0x05FEFC0F);
	r2 = D(r2, s0_0_0, 0xE02FF7FA, 0x36F7EFFB, 0xD30B2308, 0x04F01105);
	r0 = D(r0, s0_0_1, 0xF6E1EBF1, 0x07EB2408, 0x00F80205, 0x0FC51624);
	r1 = D(r1, s0_0_1, 0x0804F609, 0x12F11903, 0xDDCDD300, 0x0D1A0D08);
	r2 = D(r2, s0_0_1, 0x130D1A13, 0x011203DD, 0xF6F5330A, 0xF2F4EB03);
	r0 = D(r0, s0_0_2, 0x17E8140D, 0x03FC11FC, 0x06F8050C, 0x10031CF0);
	r1 = D(r1, s0_0_2, 0xF8F8FBF6, 0xFEFA0BFC, 0xF709E1F8, 0xF5F716EF);
	r2 = D(r2, s0_0_2, 0xFFFE0B07, 0x0110CE31, 0x04F4F7F4, 0x0AFF0C02);
	r0 = D(r0, s0_1_0, 0x9721F6FF, 0xC1FF18FF, 0xCFF2F90E, 0x631CE3DD);
	r1 = D(r1, s0_1_0, 0xE91E02F7, 0x23F5DB0A, 0x1AFEFB03, 0xF5FFF600);
	r2 = D(r2, s0_1_0, 0x32F9EE06, 0xD69B07DA, 0x430CCDFF, 0xDDA5F701);
	r0 = D(r0, s0_1_1, 0x24071C20, 0x140C010B, 0xE4DE1C1A, 0x0228F4EA);
	r1 = D(r1, s0_1_1, 0x292D0611, 0xB5E5F216, 0x0DD51404, 0x83E4140A);
	r2 = D(r2, s0_1_1, 0x7FE1DE04, 0xF4AC0848, 0xE23CD7F0, 0xDD1DE202);
	r0 = D(r0, s0_1_2, 0xFDFD09D6, 0x05F71F05, 0x0000F826, 0xF9F1FA08);
	r1 = D(r1, s0_1_2, 0x07C0FFD8, 0x06E8E410, 0xFC02F303, 0x35B9FA3F);
	r2 = D(r2, s0_1_2, 0xF61CFDB0, 0xEB10F318, 0xFDF9F92B, 0xFFFEEA25);
	r0 = D(r0, s0_2_0, 0x31E3F90B, 0x07F9FBF7, 0xCDF633EE, 0xF410DF0E);
	r1 = D(r1, s0_2_0, 0xAFF3FF01, 0xECF608F7, 0x03FEF2ED, 0x1203F1F1);
	r2 = D(r2, s0_2_0, 0xECF0F6F6, 0xC0811054, 0x08141305, 0x0A092BFE);
	r0 = D(r0, s0_2_1, 0xF7EA12FB, 0x13092104, 0xF00CF4AD, 0x0D14EB0D);
	r1 = D(r1, s0_2_1, 0x0BE00520, 0x301C001E, 0xF5FC2EDF, 0x5909DCF9);
	r2 = D(r2, s0_2_1, 0xDEE527E5, 0x24DC1D48, 0x0FF5F70B, 0x090DF8E9);
	r0 = D(r0, s0_2_2, 0xFDF8F80D, 0x050106D6, 0xFC06E22A, 0x0609FEF2);
	r1 = D(r1, s0_2_2, 0x07EF1D19, 0x12061976, 0xFD0EE60A, 0x02F911E5);
	r2 = D(r2, s0_2_2, 0xFE0CFC76, 0x050A0FA0, 0xFCF40331, 0x05FF1228);
	r0 = D(r0, s1_0_0, 0x1D0B2106, 0x03F40503, 0xFF19FCFB, 0x03ED06F9);
	r1 = D(r1, s1_0_0, 0x0AF507FA, 0x04040C00, 0x00F40008, 0xF803F6FC);
	r2 = D(r2, s1_0_0, 0xFCF90B00, 0xEBCF143B, 0x0AE402FC, 0xFFF60103);
	r0 = D(r0, s1_0_1, 0x18F7F2D7, 0x06F302E4, 0x03EEF4FC, 0xEF1AF1EA);
	r1 = D(r1, s1_0_1, 0x0B5BEA22, 0x131DF90F, 0xEACAEF0D, 0xFB0D04EF);
	r2 = D(r2, s1_0_1, 0x1E2BF52D, 0x181F18D6, 0xFBE0FE23, 0xF8F301D1);
	r0 = D(r0, s1_0_2, 0x24F50AF5, 0x010106FE, 0x06FB02FE, 0x16EE010F);
	r1 = D(r1, s1_0_2, 0xE202EF0C, 0xFD04E8FA, 0xEC081E27, 0xF40CFDF0);
	r2 = D(r2, s1_0_2, 0x0103F017, 0x1607D9F7, 0xFEFA1BE2, 0xFD05041F);
	r0 = D(r0, s1_1_0, 0x1C2A08F9, 0x0815F909, 0x091AF7F3, 0xF9DB070E);
	r1 = D(r1, s1_1_0, 0x06EC03EA, 0x05150001, 0x0000FAF7, 0x00FC0A05);
	r2 = D(r2, s1_1_0, 0xED18DFFB, 0xF7F90D0C, 0x161609F0, 0xF8191B31);
	r0 = D(r0, s1_1_1, 0x06CCDD14, 0x0E0A0C4E, 0xE2FADCF3, 0x0CFC81BE);
	r1 = D(r1, s1_1_1, 0x3446FF0E, 0x1411118F, 0xD9FDD632, 0x181D0B16);
	r2 = D(r2, s1_1_1, 0xEC3DD9E5, 0xD040D613, 0x1907F4DE, 0x180DD9D5);
	r0 = D(r0, s1_1_2, 0xE91A36E7, 0xFB0103D5, 0xF2FF0000, 0x0DFC0718);
	r1 = D(r1, s1_1_2, 0x14ECA132, 0xE81CD12D, 0xE4F90BFA, 0x12F6E643);
	r2 = D(r2, s1_1_2, 0xFB0B3C92, 0x210DBEE6, 0x10F60627, 0xFA0BEA00);
	r0 = D(r0, s1_2_0, 0x1B1ADEF6, 0x0104FBFE, 0x060DF9F5, 0x03EBFFFA);
	r1 = D(r1, s1_2_0, 0xE8EBF924, 0xFAFB0208, 0xFD14F3EB, 0xF80B08FD);
	r2 = D(r2, s1_2_0, 0xE1F8F606, 0xE5010324, 0x17030F09, 0x04F912FE);
	r0 = D(r0, s1_2_1, 0xECFA81FF, 0x03F906F6, 0xF9EFF7F6, 0xF2F3D22D);
	r1 = D(r1, s1_2_1, 0x010C18FE, 0xF101232D, 0xF1FB08F7, 0x1036FECA);
	r2 = D(r2, s1_2_1, 0xE0FAE11D, 0x1845819B, 0x1D10F5EF, 0xF9071EF3);
	r0 = D(r0, s1_2_2, 0xE8F4D71D, 0xFC0AF4F7, 0xFE03091A, 0x1607FF08);
	r1 = D(r1, s1_2_2, 0x1709B3EC, 0xF40CFA04, 0xF508FC03, 0xEEEBC2D7);
	r2 = D(r2, s1_2_2, 0x01F10310, 0x43D8B9EC, 0x0E00F3F1, 0x1006E506);
	s0_0_0 = G[2][xy.y+0][xy.x+0]; s0_0_1 = G[2][xy.y+0][xy.x+1];
	s0_0_2 = G[2][xy.y+0][xy.x+2]; s0_1_0 = G[2][xy.y+1][xy.x+0];
	s0_1_1 = G[2][xy.y+1][xy.x+1]; s0_1_2 = G[2][xy.y+1][xy.x+2];
	s0_2_0 = G[2][xy.y+2][xy.x+0]; s0_2_1 = G[2][xy.y+2][xy.x+1];
	s0_2_2 = G[2][xy.y+2][xy.x+2];
	r0 = D(r0, s0_0_0, 0xFEFFFEFB, 0x07FEFAE9, 0x0AFF27FD, 0x0AECF313);
	r1 = D(r1, s0_0_0, 0x000AD300, 0x050A14D7, 0x0EF80AF0, 0x02FEFC10);
	r2 = D(r2, s0_0_0, 0x050D06E1, 0xADE01622, 0x0F0400EA, 0xFB000900);
	r0 = D(r0, s0_0_1, 0xEE1416E1, 0xFAE616EC, 0x0A3FFF00, 0x3FE321E6);
	r1 = D(r1, s0_0_1, 0xF6D2B5F6, 0x132020D3, 0x050EE7F2, 0x05F60124);
	r2 = D(r2, s0_0_1, 0xFA0A81AE, 0x22DAF4E6, 0xFF0F09F3, 0x25FF33E8);
	r0 = D(r0, s0_0_2, 0xFD37EA09, 0x090202F9, 0x0603FCEB, 0x04F5EE1B);
	r1 = D(r1, s0_0_2, 0xE3C809FD, 0x0DFFF003, 0x09F60107, 0xF8FC0B01);
	r2 = D(r2, s0_0_2, 0xEEF91A23, 0x24FDE707, 0x0BFFECF3, 0xF4F6EFF5);
	r0 = D(r0, s0_1_0, 0x031422F0, 0xF911F203, 0xFF151FE8, 0x020B25E9);
	r1 = D(r1, s0_1_0, 0x09072106, 0xFAFCF616, 0x082308FB, 0xFFF9FE0E);
	r2 = D(r2, s0_1_0, 0xF6020211, 0x22B5D938, 0xFF0DF2F2, 0xD601190F);
	r0 = D(r0, s0_1_1, 0x383CDFED, 0x2E0B0F24, 0x017FFF7F, 0xEBA6E93F);
	r1 = D(r1, s0_1_1, 0xB12FEBFB, 0x1808201B, 0x1948E53F, 0xF9F68103);
	r2 = D(r2, s0_1_1, 0xD709E523, 0xEF10AFF1, 0x1A181434, 0x487F1F51);
	r0 = D(r0, s0_1_2, 0x83D2E635, 0x0BF6000D, 0x1A1BF7D6, 0xE5F90504);
	r1 = D(r1, s0_1_2, 0xED81EE44, 0x743C00FA, 0x3716FB03, 0x1355B4B5);
	r2 = D(r2, s0_1_2, 0x49861704, 0x28EE1E17, 0xFBFA02E0, 0xF428FD07);
	r0 = D(r0, s0_2_0, 0x0B021E1B, 0x0205FDFC, 0x12F804F5, 0xF7150003);
	r1 = D(r1, s0_2_0, 0xEEEB2721, 0xFD0116FB, 0x1514F4F8, 0xF905F4EC);
	r2 = D(r2, s0_2_0, 0xFDF50812, 0xCE0014F8, 0xF908F000, 0x1403F2EB);
	r0 = D(r0, s0_2_1, 0xF9A81944, 0xF01402F8, 0x2E2901DD, 0x0115F1EC);
	r1 = D(r1, s0_2_1, 0x14410EB2, 0xF7E0FE10, 0x3806FE27, 0x0E0DF3E0);
	r2 = D(r2, s0_2_1, 0xF31A17DD, 0x627302F5, 0x23F3F408, 0x0BFCEEE3);
	r0 = D(r0, s0_2_2, 0x813202D1, 0x0601FA01, 0xFBEFFB0D, 0xF70301E1);
	r1 = D(r1, s0_2_2, 0x20EC0DEC, 0x10ADE81A, 0x0817FBF8, 0xCCDDEC62);
	r2 = D(r2, s0_2_2, 0x103BE8FD, 0x14331EE7, 0x14030E02, 0xF4F8FDFE);
	f0 = vec4(r0) * 6.2000124e-05;
	f0 += vec4(1.759e-03, -9.972e-03, -4.895e-02, 5.795e-02);
	f0 = max(f0, vec4(0.0));
	imageStore(out_image, opos + ivec2(0, 0), f0);
	f1 = vec4(r1) * 6.2000124e-05;
	f1 += vec4(3.370e-02, 7.282e-03, 3.381e-02, 7.203e-02);
	f1 = max(f1, vec4(0.0));
	imageStore(out_image, opos + ivec2(1, 0), f1);
	f2 = vec4(r2) * 6.2000124e-05;
	f2 += vec4(6.762e-02, 2.472e-02, 3.992e-02, 6.167e-03);
	f2 = max(f2, vec4(0.0));
	imageStore(out_image, opos + ivec2(2, 0), f2);
}

//!DESC CuNNy-4x12-DS-conv2
//!HOOK LUMA
//!COMPUTE 24 8 8 8
//!BIND conv1
//!BIND LUMA
//!SAVE conv2
//!WIDTH LUMA.w 3 *
//!HEIGHT LUMA.h
//!COMPONENTS 4
//!WHEN OUTPUT.w LUMA.w / 1.3 > OUTPUT.h LUMA.h / 1.3 > *
#extension GL_EXT_spirv_intrinsics : require
#define l0(x, y) conv1_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(3, 1) + ivec2(0, 0)) + vec2(0.5)) * conv1_pt)
#define l1(x, y) conv1_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(3, 1) + ivec2(1, 0)) + vec2(0.5)) * conv1_pt)
#define l2(x, y) conv1_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(3, 1) + ivec2(2, 0)) + vec2(0.5)) * conv1_pt)
spirv_instruction (extensions = ["SPV_KHR_integer_dot_product"], capabilities = [6019, 6018], id = 4450)
int dp4(int a, int b, spirv_literal int fmt);
#define D(r, s, a, b, c, d) r + ivec4(dp4(s, a, 0), dp4(s, b, 0), dp4(s, c, 0), dp4(s, d, 0))
shared int G[3][10][10];
void hook() {
	ivec2 xy = ivec2(gl_LocalInvocationID.xy);
	ivec2 pos = ivec2(gl_WorkGroupID.xy) * ivec2(8, 8) + xy;
	ivec2 opos = pos * ivec2(3, 1);
	ivec2 sz = ivec2(LUMA_size) - ivec2(1);
	for (int y = 0; y < 10; y += 8) {
		int ay = xy.y + y;
		if (ay >= 10) break;
		for (int x = 0; x < 10; x += 8) {
			int ax = xy.x + x;
			if (ax >= 10) break;
			vec4 v0 = l0(x - 1, y - 1) * 1.0000000e+00;
			vec4 v1 = l1(x - 1, y - 1) * 1.0000000e+00;
			vec4 v2 = l2(x - 1, y - 1) * 1.0000000e+00;
			G[0][ay][ax] = int(packSnorm4x8(v0));
			G[1][ay][ax] = int(packSnorm4x8(v1));
			G[2][ay][ax] = int(packSnorm4x8(v2));
		}
	}
	barrier();
	int s0_0_0, s0_0_1, s0_0_2, s0_1_0, s0_1_1, s0_1_2, s0_2_0, s0_2_1, s0_2_2, s1_0_0, s1_0_1, s1_0_2, s1_1_0, s1_1_1, s1_1_2, s1_2_0, s1_2_1, s1_2_2;
	ivec4 r0, r1, r2;
	vec4 f0, f1, f2;
	r0 = ivec4(0); r1 = ivec4(0); r2 = ivec4(0);
	s0_0_0 = G[0][xy.y+0][xy.x+0]; s0_0_1 = G[0][xy.y+0][xy.x+1];
	s0_0_2 = G[0][xy.y+0][xy.x+2]; s0_1_0 = G[0][xy.y+1][xy.x+0];
	s0_1_1 = G[0][xy.y+1][xy.x+1]; s0_1_2 = G[0][xy.y+1][xy.x+2];
	s0_2_0 = G[0][xy.y+2][xy.x+0]; s0_2_1 = G[0][xy.y+2][xy.x+1];
	s0_2_2 = G[0][xy.y+2][xy.x+2]; s1_0_0 = G[1][xy.y+0][xy.x+0];
	s1_0_1 = G[1][xy.y+0][xy.x+1]; s1_0_2 = G[1][xy.y+0][xy.x+2];
	s1_1_0 = G[1][xy.y+1][xy.x+0]; s1_1_1 = G[1][xy.y+1][xy.x+1];
	s1_1_2 = G[1][xy.y+1][xy.x+2]; s1_2_0 = G[1][xy.y+2][xy.x+0];
	s1_2_1 = G[1][xy.y+2][xy.x+1]; s1_2_2 = G[1][xy.y+2][xy.x+2];
	r0 = D(r0, s0_0_0, 0x0A0E0900, 0x1BEFFDF4, 0x04100E0F, 0x00F20007);
	r1 = D(r1, s0_0_0, 0xF8ED040B, 0xF7FFF412, 0x03F208FE, 0x02FAF903);
	r2 = D(r2, s0_0_0, 0xFAF9F8F9, 0x09040C1A, 0x1401FA05, 0x00020A00);
	r0 = D(r0, s0_0_1, 0x051C010A, 0xE4F4E4D1, 0x0504EE04, 0xED03FB07);
	r1 = D(r1, s0_0_1, 0x00EB0E0A, 0xE21D180B, 0xFDF7E7F9, 0xFF02F6FE);
	r2 = D(r2, s0_0_1, 0x0EF6F101, 0xF9EDEF06, 0x1622F9F6, 0x0401F3FC);
	r0 = D(r0, s0_0_2, 0xF4000703, 0x01F3FEFE, 0x14ED0801, 0xFEF3F509);
	r1 = D(r1, s0_0_2, 0xFDF4FB05, 0xFD0106FE, 0x03F90004, 0xFAFFFB04);
	r2 = D(r2, s0_0_2, 0x0AFBFAEF, 0x0407F205, 0x180CFF02, 0xE0E6F40A);
	r0 = D(r0, s0_1_0, 0x39090F17, 0x2B23C2EA, 0xFF00181F, 0xEEFEF8F3);
	r1 = D(r1, s0_1_0, 0x01A43A0F, 0x00EBF80B, 0x01F8E1FD, 0x2207DCF9);
	r2 = D(r2, s0_1_0, 0xFA0CDE13, 0xE605200F, 0xF406C036, 0x003AEBEB);
	r0 = D(r0, s0_1_1, 0x13333D16, 0xD27F2181, 0xE1C9361E, 0x29143001);
	r1 = D(r1, s0_1_1, 0xF181BE27, 0x13F6F90A, 0xF732C70B, 0x112700F9);
	r2 = D(r2, s0_1_1, 0xFA2BC8FC, 0x33F5D5F7, 0xBEEDCADB, 0xFEDE46EF);
	r0 = D(r0, s0_1_2, 0xFFDD0702, 0xFA5AFF1C, 0x12EFC80C, 0x24180300);
	r1 = D(r1, s0_1_2, 0x15B0FBF7, 0xF0431FF7, 0x03FBFDF5, 0xF70C06FD);
	r2 = D(r2, s0_1_2, 0xDDD4F3FC, 0x1BCD1000, 0xED1CED0B, 0x0A140400);
	r0 = D(r0, s0_2_0, 0x05F4F7F4, 0x12FE0B1A, 0x01F308F8, 0x040D04FB);
	r1 = D(r1, s0_2_0, 0x0BED0EFA, 0xF9F6FCE1, 0x05F9FCFD, 0x12020106);
	r2 = D(r2, s0_2_0, 0xFEFD1703, 0x01F802F8, 0x2014EEFB, 0x25DF0801);
	r0 = D(r0, s0_2_1, 0x2411BD01, 0xE211271E, 0x230AE6F1, 0x150CFCF7);
	r1 = D(r1, s0_2_1, 0x03D5DD18, 0x4F29E8DA, 0x0D01FB03, 0xDEFB30FD);
	r2 = D(r2, s0_2_1, 0xA5AA4EEF, 0xF8EC1EFB, 0xE16902F6, 0xFCF5E302);
	r0 = D(r0, s0_2_2, 0x22DEECFD, 0xCE260515, 0x0D0A09F9, 0xFAD2FD0A);
	r1 = D(r1, s0_2_2, 0x04EC0E0A, 0x04EAFFFC, 0x04F8F904, 0xEB160506);
	r2 = D(r2, s0_2_2, 0xC5201DF1, 0xFEF0F10B, 0xF7F0EC17, 0x06F6F5FD);
	r0 = D(r0, s1_0_0, 0x02F00810, 0x492C05FC, 0xD31A18DD, 0xE70D1214);
	r1 = D(r1, s1_0_0, 0x04F3E002, 0x2DFFDC04, 0x11FB0305, 0x13F50310);
	r2 = D(r2, s1_0_0, 0x2302FE01, 0xE1F20E0A, 0x241C31E8, 0xFF0FE012);
	r0 = D(r0, s1_0_1, 0x02FBFEFB, 0x0F23291B, 0xD6FEDBE8, 0xD9E70D00);
	r1 = D(r1, s1_0_1, 0x0DE4FDEF, 0x18FEFCED, 0xF7F200F4, 0x04ED050D);
	r2 = D(r2, s1_0_1, 0x2B1805F6, 0xD80B20FE, 0x12EE25FE, 0xDF370D18);
	r0 = D(r0, s1_0_2, 0x070AFC07, 0xF9D41AF6, 0xF70E0DE1, 0xFEFF0406);
	r1 = D(r1, s1_0_2, 0xFE07FE07, 0x0AFDF203, 0x080801FD, 0xFFF50105);
	r2 = D(r2, s1_0_2, 0x04FF00F8, 0x00F60C07, 0xF6EA06F8, 0x0423021B);
	r0 = D(r0, s1_1_0, 0xD2182EE7, 0x50EB24C3, 0x03FCECD8, 0x04EF1A13);
	r1 = D(r1, s1_1_0, 0x00FFDF01, 0xF1150213, 0xF413F800, 0x320D20FD);
	r2 = D(r2, s1_1_0, 0x7AEBE419, 0x11EC04EB, 0x59043B12, 0x15E20551);
	r0 = D(r0, s1_1_1, 0xE906EDE3, 0xEB8121C1, 0x0D13C5AC, 0x01F0CD0E);
	r1 = D(r1, s1_1_1, 0x00E718EB, 0x18F5EBC9, 0xFBEA1CF4, 0x11EB030A);
	r2 = D(r2, s1_1_1, 0x28EF1C05, 0xFB13DB1D, 0xF7B82AFD, 0xEFDAB530);
	r0 = D(r0, s1_1_2, 0x031009F8, 0x063CF1D8, 0xF91DFAF7, 0x00F5FC21);
	r1 = D(r1, s1_1_2, 0x0C120BEF, 0xFE0109E9, 0xFEFF0108, 0x0402FA0E);
	r2 = D(r2, s1_1_2, 0x0DF2FEFE, 0xFEFEFC1C, 0x10F30403, 0xF302F615);
	r0 = D(r0, s1_2_0, 0xEEF3FA02, 0xF6F30EFA, 0x08F508D7, 0x050A0B01);
	r1 = D(r1, s1_2_0, 0x03F2010D, 0xFA0C1B14, 0x02FDFE0A, 0x02EF0504);
	r2 = D(r2, s1_2_0, 0x03FD012A, 0xFD08FBF7, 0x0E0C30E2, 0x0B17230E);
	r0 = D(r0, s1_2_1, 0x0A00F40D, 0x0140EAE1, 0x0CF10AC7, 0x09F60414);
	r1 = D(r1, s1_2_1, 0xFAFB03FD, 0x0CC70E27, 0xFF010409, 0x010808FF);
	r2 = D(r2, s1_2_1, 0xFE2817F4, 0x0504050C, 0xEB062005, 0x0DFA0D2E);
	r0 = D(r0, s1_2_2, 0xFFF5FFFC, 0xF8E30AE6, 0xFBF40BEF, 0x051DFF0B);
	r1 = D(r1, s1_2_2, 0x01F8FEF9, 0xFC1B10E5, 0x0004FFFF, 0x0003FE03);
	r2 = D(r2, s1_2_2, 0x03F70200, 0x0403F80B, 0x051D1502, 0xFF12EE2B);
	s0_0_0 = G[2][xy.y+0][xy.x+0]; s0_0_1 = G[2][xy.y+0][xy.x+1];
	s0_0_2 = G[2][xy.y+0][xy.x+2]; s0_1_0 = G[2][xy.y+1][xy.x+0];
	s0_1_1 = G[2][xy.y+1][xy.x+1]; s0_1_2 = G[2][xy.y+1][xy.x+2];
	s0_2_0 = G[2][xy.y+2][xy.x+0]; s0_2_1 = G[2][xy.y+2][xy.x+1];
	s0_2_2 = G[2][xy.y+2][xy.x+2];
	r0 = D(r0, s0_0_0, 0xF704F4F5, 0xE8021DE8, 0xE2F62D06, 0x0BF507FB);
	r1 = D(r1, s0_0_0, 0x0121EC03, 0x01FAFE15, 0x0C13FF05, 0x0311F4F6);
	r2 = D(r2, s0_0_0, 0xF717FCFB, 0x05EDFC03, 0xEDE421E8, 0xDFF4DFDE);
	r0 = D(r0, s0_0_1, 0x18E2F60F, 0xF2F823EF, 0x001308F3, 0xEF29F105);
	r1 = D(r1, s0_0_1, 0xFCFAEB1A, 0xEF1E070B, 0xFF00F609, 0x14FDFF08);
	r2 = D(r2, s0_0_1, 0xFEF316FD, 0xEB14F9FC, 0xEBD8FBFD, 0x0ED5EAF8);
	r0 = D(r0, s0_0_2, 0x02050B09, 0x130AF304, 0xDB2839FF, 0x0C0710FF);
	r1 = D(r1, s0_0_2, 0x05F8F208, 0xFB0E3001, 0x0FF506F9, 0x0A00F9FF);
	r2 = D(r2, s0_0_2, 0x02F9FDFD, 0x10F41B09, 0xF7F60904, 0x0EF4FF02);
	r0 = D(r0, s0_1_0, 0xF5081803, 0xF22036B8, 0xEAEB2AED, 0xF421FFE5);
	r1 = D(r1, s0_1_0, 0x46EFF110, 0x15FD0BB8, 0x09FF0202, 0x0028040A);
	r2 = D(r2, s0_1_0, 0x1A08D91A, 0xF32D02E5, 0x0A4208FA, 0xECF5E8C0);
	r0 = D(r0, s0_1_1, 0xCB42EE0F, 0xA4EBE4F1, 0xB9431ACB, 0xF20E040F);
	r1 = D(r1, s0_1_1, 0x58FD0006, 0x2F110325, 0xEE1D0703, 0x0AE80802);
	r2 = D(r2, s0_1_1, 0x2ADF0DFE, 0x4535ED1A, 0x0D225F0C, 0x330BDEBE);
	r0 = D(r0, s0_1_2, 0x09130903, 0xBFDC2EFD, 0xF506260C, 0x18090D03);
	r1 = D(r1, s0_1_2, 0x1FE706FF, 0xD50005F7, 0xFF0F010A, 0x000AF800);
	r2 = D(r2, s0_1_2, 0x330BD9FE, 0x1F180905, 0x10CE3203, 0xED03CE0D);
	r0 = D(r0, s0_2_0, 0x13F612FA, 0x0FF21703, 0x0F0E19D5, 0xED16FBFF);
	r1 = D(r1, s0_2_0, 0x18050200, 0x07050BF2, 0x070403FC, 0x0BF90105);
	r2 = D(r2, s0_2_0, 0xFFF7F002, 0x0FF7F506, 0xE8180D37, 0x17F2FF23);
	r0 = D(r0, s0_2_1, 0x07F5FCE9, 0xDE0002FA, 0xE12718F0, 0x050D0413);
	r1 = D(r1, s0_2_1, 0x17F407F7, 0x02180A4A, 0xF90C0509, 0xFEFB00F2);
	r2 = D(r2, s0_2_1, 0x24BFFCF3, 0x0E0309F7, 0xC01A090D, 0x34E2ED1B);
	r0 = D(r0, s0_2_2, 0x090402FE, 0xD813030D, 0xDB2A1C17, 0xFE14FA09);
	r1 = D(r1, s0_2_2, 0xF41202F8, 0xFAE00CF6, 0x03080101, 0xF00902FF);
	r2 = D(r2, s0_2_2, 0x040A07F5, 0xFE0EFC06, 0x01FC1BFC, 0x070CFE13);
	f0 = vec4(r0) * 6.2000124e-05;
	f0 += vec4(-3.057e-02, 6.819e-02, 3.838e-03, -5.978e-03);
	f0 = max(f0, vec4(0.0));
	imageStore(out_image, opos + ivec2(0, 0), f0);
	f1 = vec4(r1) * 6.2000124e-05;
	f1 += vec4(-1.021e-02, -3.049e-02, 5.641e-01, 3.756e-03);
	f1 = max(f1, vec4(0.0));
	imageStore(out_image, opos + ivec2(1, 0), f1);
	f2 = vec4(r2) * 6.2000124e-05;
	f2 += vec4(-6.615e-03, -5.725e-02, -1.080e-01, -8.240e-02);
	f2 = max(f2, vec4(0.0));
	imageStore(out_image, opos + ivec2(2, 0), f2);
}

//!DESC CuNNy-4x12-DS-conv3
//!HOOK LUMA
//!COMPUTE 24 8 8 8
//!BIND conv2
//!BIND LUMA
//!SAVE conv3
//!WIDTH LUMA.w 3 *
//!HEIGHT LUMA.h
//!COMPONENTS 4
//!WHEN OUTPUT.w LUMA.w / 1.3 > OUTPUT.h LUMA.h / 1.3 > *
#extension GL_EXT_spirv_intrinsics : require
#define l0(x, y) conv2_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(3, 1) + ivec2(0, 0)) + vec2(0.5)) * conv2_pt)
#define l1(x, y) conv2_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(3, 1) + ivec2(1, 0)) + vec2(0.5)) * conv2_pt)
#define l2(x, y) conv2_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(3, 1) + ivec2(2, 0)) + vec2(0.5)) * conv2_pt)
spirv_instruction (extensions = ["SPV_KHR_integer_dot_product"], capabilities = [6019, 6018], id = 4450)
int dp4(int a, int b, spirv_literal int fmt);
#define D(r, s, a, b, c, d) r + ivec4(dp4(s, a, 0), dp4(s, b, 0), dp4(s, c, 0), dp4(s, d, 0))
shared int G[3][10][10];
void hook() {
	ivec2 xy = ivec2(gl_LocalInvocationID.xy);
	ivec2 pos = ivec2(gl_WorkGroupID.xy) * ivec2(8, 8) + xy;
	ivec2 opos = pos * ivec2(3, 1);
	ivec2 sz = ivec2(LUMA_size) - ivec2(1);
	for (int y = 0; y < 10; y += 8) {
		int ay = xy.y + y;
		if (ay >= 10) break;
		for (int x = 0; x < 10; x += 8) {
			int ax = xy.x + x;
			if (ax >= 10) break;
			vec4 v0 = l0(x - 1, y - 1) * 1.0000000e+00;
			vec4 v1 = l1(x - 1, y - 1) * 1.0000000e+00;
			vec4 v2 = l2(x - 1, y - 1) * 1.0000000e+00;
			G[0][ay][ax] = int(packSnorm4x8(v0));
			G[1][ay][ax] = int(packSnorm4x8(v1));
			G[2][ay][ax] = int(packSnorm4x8(v2));
		}
	}
	barrier();
	int s0_0_0, s0_0_1, s0_0_2, s0_1_0, s0_1_1, s0_1_2, s0_2_0, s0_2_1, s0_2_2, s1_0_0, s1_0_1, s1_0_2, s1_1_0, s1_1_1, s1_1_2, s1_2_0, s1_2_1, s1_2_2;
	ivec4 r0, r1, r2;
	vec4 f0, f1, f2;
	r0 = ivec4(0); r1 = ivec4(0); r2 = ivec4(0);
	s0_0_0 = G[0][xy.y+0][xy.x+0]; s0_0_1 = G[0][xy.y+0][xy.x+1];
	s0_0_2 = G[0][xy.y+0][xy.x+2]; s0_1_0 = G[0][xy.y+1][xy.x+0];
	s0_1_1 = G[0][xy.y+1][xy.x+1]; s0_1_2 = G[0][xy.y+1][xy.x+2];
	s0_2_0 = G[0][xy.y+2][xy.x+0]; s0_2_1 = G[0][xy.y+2][xy.x+1];
	s0_2_2 = G[0][xy.y+2][xy.x+2]; s1_0_0 = G[1][xy.y+0][xy.x+0];
	s1_0_1 = G[1][xy.y+0][xy.x+1]; s1_0_2 = G[1][xy.y+0][xy.x+2];
	s1_1_0 = G[1][xy.y+1][xy.x+0]; s1_1_1 = G[1][xy.y+1][xy.x+1];
	s1_1_2 = G[1][xy.y+1][xy.x+2]; s1_2_0 = G[1][xy.y+2][xy.x+0];
	s1_2_1 = G[1][xy.y+2][xy.x+1]; s1_2_2 = G[1][xy.y+2][xy.x+2];
	r0 = D(r0, s0_0_0, 0x0D09040C, 0xF3FAF5F4, 0xF4FD04F9, 0xF3D8C9F2);
	r1 = D(r1, s0_0_0, 0x010801FB, 0xED06F5E9, 0x0404020B, 0x07FCF40A);
	r2 = D(r2, s0_0_0, 0x0C04FEF9, 0x0E00120F, 0x100A2B07, 0xF7E5FEE2);
	r0 = D(r0, s0_0_1, 0x2002FA15, 0x04F1E0FE, 0x00F90CEF, 0x17D3E8FB);
	r1 = D(r1, s0_0_1, 0xF7FD0204, 0x070FE3F6, 0xF4FE10F8, 0x34E61419);
	r2 = D(r2, s0_0_1, 0x10D5F40A, 0x01011E0E, 0xF1E70D14, 0xDB24110F);
	r0 = D(r0, s0_0_2, 0x0603FE06, 0x1EE2F8ED, 0xF9FF0604, 0x1301F903);
	r1 = D(r1, s0_0_2, 0xFD0102FC, 0x08E10AF3, 0x02FF0A05, 0x06F9FA11);
	r2 = D(r2, s0_0_2, 0x0A04F7FD, 0x14FDFC0B, 0x03F8FEFB, 0x01F5F9E7);
	r0 = D(r0, s0_1_0, 0xD5FEF8E3, 0x1701FD0A, 0x14F304F1, 0x10DA1612);
	r1 = D(r1, s0_1_0, 0xF5F4EEF7, 0x1804F11B, 0xFCFD0BF0, 0xF4EDE3FA);
	r2 = D(r2, s0_1_0, 0xFBE70A02, 0x0CFF37F3, 0xF6F921F5, 0x2BF1FB33);
	r0 = D(r0, s0_1_1, 0x1FFFF30A, 0xE8E001CE, 0x6A031A2E, 0x05F91AFD);
	r1 = D(r1, s0_1_1, 0x2A011802, 0xDA1FF2E5, 0x380622ED, 0x22DC23FE);
	r2 = D(r2, s0_1_1, 0xD50205F4, 0xDFEE2A0A, 0xBE0A2B12, 0x191E81D1);
	r0 = D(r0, s0_1_2, 0x0D000307, 0x0EE61FDD, 0xF8F114EE, 0x0306F3F3);
	r1 = D(r1, s0_1_2, 0x0103FE0D, 0xE6ED0DE2, 0xFCFCF80F, 0x14E7F110);
	r2 = D(r2, s0_1_2, 0xEAE2F225, 0x01FBF900, 0xDF0AF70A, 0x082AEDF5);
	r0 = D(r0, s0_2_0, 0xFEFDEAF0, 0xFA1CFA15, 0x0C0409FA, 0x1100F20D);
	r1 = D(r1, s0_2_0, 0xEC0515E0, 0x1F1AFE15, 0xFAF5FF02, 0xFDE7F001);
	r2 = D(r2, s0_2_0, 0x0BF4FBFE, 0x0BE62EFD, 0x03FD0201, 0x3C16F118);
	r0 = D(r0, s0_2_1, 0x08FE02F6, 0xF7EADBFB, 0x16FB0B03, 0x08FCE9F8);
	r1 = D(r1, s0_2_1, 0x24F5EF17, 0xFB0BDD0D, 0xF50C0102, 0xF70014FB);
	r2 = D(r2, s0_2_1, 0xFD0809F7, 0xE41EFB11, 0x00FEF410, 0x23E9B9DA);
	r0 = D(r0, s0_2_2, 0x00010003, 0xFA010AE1, 0x04050819, 0xFCFAE602);
	r1 = D(r1, s0_2_2, 0xFE0412FA, 0xFAFD03EB, 0x0DF8FFFD, 0xF103FE0C);
	r2 = D(r2, s0_2_2, 0xEF07F606, 0xEE04F403, 0xFBFD0004, 0x0E022CF0);
	r0 = D(r0, s1_0_0, 0xF7FC070D, 0x150B07F7, 0x0FC60710, 0x2A1816E0);
	r1 = D(r1, s1_0_0, 0x040BF8FB, 0x120A1004, 0xF7F6FD04, 0x0A0CFC0B);
	r2 = D(r2, s1_0_0, 0x00030BFE, 0xEBF2040E, 0xEBF70E06, 0x0A0FFDF5);
	r0 = D(r0, s1_0_1, 0xF7FB05FC, 0x06FD1EE8, 0x36820F0A, 0xD7F30407);
	r1 = D(r1, s1_0_1, 0x020100EE, 0x111415F1, 0x0B040AF7, 0xDCEDEDF1);
	r2 = D(r2, s1_0_1, 0xEBF804FA, 0xEBFF0AF9, 0x01F51402, 0x072A00FF);
	r0 = D(r0, s1_0_2, 0xFC00FE04, 0x15F3FFFB, 0x18B811EC, 0xFEFDFA09);
	r1 = D(r1, s1_0_2, 0xF9FD01FA, 0x11E1150B, 0xF206FA11, 0xEBFFFAF6);
	r2 = D(r2, s1_0_2, 0xE40200F8, 0xDB0DFBF3, 0xD7110213, 0x36080B0F);
	r0 = D(r0, s1_1_0, 0x260E1201, 0xFDF7110F, 0x03B01F04, 0xE4D4FF10);
	r1 = D(r1, s1_1_0, 0x17180DDD, 0xD706E706, 0x081D0FFF, 0xF31608F9);
	r2 = D(r2, s1_1_0, 0xFED8FE00, 0xEBBE2009, 0x00E81601, 0xDAE1D00A);
	r0 = D(r0, s1_1_1, 0x29FE05F1, 0x7FE11E36, 0x09811E00, 0xDE080B0D);
	r1 = D(r1, s1_1_1, 0xFEE4FFD4, 0x56CDF60D, 0x11E0132A, 0x1A0720C6);
	r2 = D(r2, s1_1_1, 0xE64AF3F0, 0xEA1F1317, 0x0716FFF3, 0x0E1EC3E5);
	r0 = D(r0, s1_1_2, 0xFFFEFF06, 0x81110514, 0xD0B816EB, 0x1809F213);
	r1 = D(r1, s1_1_2, 0x010201F7, 0xF0FD15F9, 0x02F8FEE3, 0xFFF303C3);
	r2 = D(r2, s1_1_2, 0x2D00FFDA, 0xFB18FA11, 0x23F402FF, 0x27EDF514);
	r0 = D(r0, s1_2_0, 0x0E060404, 0xEEEBF803, 0xFE030901, 0xFF13FA08);
	r1 = D(r1, s1_2_0, 0x0F2517C7, 0xD2F7DBFB, 0xFEFD0501, 0xFDEB020C);
	r2 = D(r2, s1_2_0, 0x0D19FFF7, 0xF12903E8, 0x0502FDFC, 0x04D8000B);
	r0 = D(r0, s1_2_1, 0xE403FF01, 0xF92F05F2, 0xF1B20B16, 0xFC100F06);
	r1 = D(r1, s1_2_1, 0xFED1FEF4, 0xF813E4FB, 0xF408FDFD, 0x031104F9);
	r2 = D(r2, s1_2_1, 0x12E207EF, 0x26FA060D, 0x0F03FA05, 0xD706F7FB);
	r0 = D(r0, s1_2_2, 0xFFFE0009, 0xD2FC0DCC, 0x11E307F0, 0xE4F4F7E1);
	r1 = D(r1, s1_2_2, 0xCE08F8FC, 0xCB1BF8F4, 0xEB09FA11, 0x0E0708FD);
	r2 = D(r2, s1_2_2, 0x25F70BF3, 0x0AE1FDF7, 0x05FD02ED, 0xB8FFF90F);
	s0_0_0 = G[2][xy.y+0][xy.x+0]; s0_0_1 = G[2][xy.y+0][xy.x+1];
	s0_0_2 = G[2][xy.y+0][xy.x+2]; s0_1_0 = G[2][xy.y+1][xy.x+0];
	s0_1_1 = G[2][xy.y+1][xy.x+1]; s0_1_2 = G[2][xy.y+1][xy.x+2];
	s0_2_0 = G[2][xy.y+2][xy.x+0]; s0_2_1 = G[2][xy.y+2][xy.x+1];
	s0_2_2 = G[2][xy.y+2][xy.x+2];
	r0 = D(r0, s0_0_0, 0x10FCF811, 0xF8FE03FE, 0x05FA07FD, 0x0DFE030E);
	r1 = D(r1, s0_0_0, 0x040004E8, 0xFA0BFF17, 0x01F4FB13, 0x11F7F603);
	r2 = D(r2, s0_0_0, 0x0106FB06, 0xF3FAFA0D, 0xF7FFF20B, 0xE11213D0);
	r0 = D(r0, s0_0_1, 0x0405EF0A, 0x02FE0A13, 0xF9081538, 0x2308FE14);
	r1 = D(r1, s0_0_1, 0xF3FC0700, 0x001C0218, 0xFD080E30, 0x14FBEB2A);
	r2 = D(r2, s0_0_1, 0x0B23F605, 0xF4EFFA0A, 0xEE021D09, 0x06E416D8);
	r0 = D(r0, s0_0_2, 0xFEFFFCFD, 0x1101FBFE, 0xF2111A08, 0xF11603FD);
	r1 = D(r1, s0_0_2, 0x02030502, 0x0CF21120, 0xFAF1F70D, 0xE4EFEC03);
	r2 = D(r2, s0_0_2, 0xF61FFAFF, 0xFA04F014, 0x07FCF509, 0x000408F3);
	r0 = D(r0, s0_1_0, 0x020408EA, 0xEF0AD5DD, 0xEF09F713, 0x16FEF20B);
	r1 = D(r1, s0_1_0, 0xFB060C00, 0x080BF4E8, 0xF603F307, 0x0800F00A);
	r2 = D(r2, s0_1_0, 0xFB040C1C, 0xDB0BF90E, 0xFA00FBFE, 0x34E035C1);
	r0 = D(r0, s0_1_1, 0xFEFEDF13, 0x03ED1A05, 0xFD17DE06, 0xF8E11327);
	r1 = D(r1, s0_1_1, 0xF6FFF01A, 0x230ADE93, 0x03FE05FE, 0xC912DE15);
	r2 = D(r2, s0_1_1, 0xD324F7FD, 0xD9EF0B06, 0xF9F11EF4, 0xF8F5CFA4);
	r0 = D(r0, s0_1_2, 0x07FEF003, 0x0CDC2B2F, 0x080E1B0D, 0x0C0EF404);
	r1 = D(r1, s0_1_2, 0xFA0F05FD, 0x07D4512D, 0x09F5EB0B, 0x11F3E710);
	r2 = D(r2, s0_1_2, 0x071C13DC, 0x0C1BE700, 0x000D09EB, 0xEC15150C);
	r0 = D(r0, s0_2_0, 0xFF0407F6, 0x0315FA0A, 0xF504FDFF, 0xF807FD16);
	r1 = D(r1, s0_2_0, 0xF20206ED, 0x0CF5031C, 0xFE0602FE, 0x010606FA);
	r2 = D(r2, s0_2_0, 0x0207FB03, 0x01FE0303, 0xFF05FCFF, 0xE424F03C);
	r0 = D(r0, s0_2_1, 0x05FF0508, 0x000618F6, 0xFC13EF1C, 0xFFFF0506);
	r1 = D(r1, s0_2_1, 0xF6F4F20A, 0x11FAF5F1, 0x02FF0204, 0x010410F8);
	r2 = D(r2, s0_2_1, 0xE90EF6FD, 0xDA0304F4, 0xF90608FA, 0x2F1BE2F0);
	r0 = D(r0, s0_2_2, 0x0100FC01, 0xFD091B05, 0xF2FF0804, 0xFE080D01);
	r1 = D(r1, s0_2_2, 0x040CFD06, 0x08DB1F09, 0xFB06F706, 0x05050903);
	r2 = D(r2, s0_2_2, 0x0214F401, 0x1A020AF2, 0x100308F7, 0x05F01414);
	f0 = vec4(r0) * 6.2000124e-05;
	f0 += vec4(-2.216e-02, -1.275e-02, -1.275e-01, -3.646e-02);
	f0 = max(f0, vec4(0.0));
	imageStore(out_image, opos + ivec2(0, 0), f0);
	f1 = vec4(r1) * 6.2000124e-05;
	f1 += vec4(-3.162e-02, 4.492e-02, -4.038e-02, -7.375e-02);
	f1 = max(f1, vec4(0.0));
	imageStore(out_image, opos + ivec2(1, 0), f1);
	f2 = vec4(r2) * 6.2000124e-05;
	f2 += vec4(-7.021e-02, 1.595e-02, 6.565e-02, -6.707e-02);
	f2 = max(f2, vec4(0.0));
	imageStore(out_image, opos + ivec2(2, 0), f2);
}

//!DESC CuNNy-4x12-DS-conv4
//!HOOK LUMA
//!COMPUTE 24 8 8 8
//!BIND conv3
//!BIND LUMA
//!SAVE conv4
//!WIDTH LUMA.w 3 *
//!HEIGHT LUMA.h
//!COMPONENTS 4
//!WHEN OUTPUT.w LUMA.w / 1.3 > OUTPUT.h LUMA.h / 1.3 > *
#extension GL_EXT_spirv_intrinsics : require
#define l0(x, y) conv3_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(3, 1) + ivec2(0, 0)) + vec2(0.5)) * conv3_pt)
#define l1(x, y) conv3_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(3, 1) + ivec2(1, 0)) + vec2(0.5)) * conv3_pt)
#define l2(x, y) conv3_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(3, 1) + ivec2(2, 0)) + vec2(0.5)) * conv3_pt)
spirv_instruction (extensions = ["SPV_KHR_integer_dot_product"], capabilities = [6019, 6018], id = 4450)
int dp4(int a, int b, spirv_literal int fmt);
#define D(r, s, a, b, c, d) r + ivec4(dp4(s, a, 0), dp4(s, b, 0), dp4(s, c, 0), dp4(s, d, 0))
shared int G[3][10][10];
void hook() {
	ivec2 xy = ivec2(gl_LocalInvocationID.xy);
	ivec2 pos = ivec2(gl_WorkGroupID.xy) * ivec2(8, 8) + xy;
	ivec2 opos = pos * ivec2(3, 1);
	ivec2 sz = ivec2(LUMA_size) - ivec2(1);
	for (int y = 0; y < 10; y += 8) {
		int ay = xy.y + y;
		if (ay >= 10) break;
		for (int x = 0; x < 10; x += 8) {
			int ax = xy.x + x;
			if (ax >= 10) break;
			vec4 v0 = l0(x - 1, y - 1) * 1.0000000e+00;
			vec4 v1 = l1(x - 1, y - 1) * 1.0000000e+00;
			vec4 v2 = l2(x - 1, y - 1) * 1.0000000e+00;
			G[0][ay][ax] = int(packSnorm4x8(v0));
			G[1][ay][ax] = int(packSnorm4x8(v1));
			G[2][ay][ax] = int(packSnorm4x8(v2));
		}
	}
	barrier();
	int s0_0_0, s0_0_1, s0_0_2, s0_1_0, s0_1_1, s0_1_2, s0_2_0, s0_2_1, s0_2_2, s1_0_0, s1_0_1, s1_0_2, s1_1_0, s1_1_1, s1_1_2, s1_2_0, s1_2_1, s1_2_2;
	ivec4 r0, r1, r2;
	vec4 f0, f1, f2;
	r0 = ivec4(0); r1 = ivec4(0); r2 = ivec4(0);
	s0_0_0 = G[0][xy.y+0][xy.x+0]; s0_0_1 = G[0][xy.y+0][xy.x+1];
	s0_0_2 = G[0][xy.y+0][xy.x+2]; s0_1_0 = G[0][xy.y+1][xy.x+0];
	s0_1_1 = G[0][xy.y+1][xy.x+1]; s0_1_2 = G[0][xy.y+1][xy.x+2];
	s0_2_0 = G[0][xy.y+2][xy.x+0]; s0_2_1 = G[0][xy.y+2][xy.x+1];
	s0_2_2 = G[0][xy.y+2][xy.x+2]; s1_0_0 = G[1][xy.y+0][xy.x+0];
	s1_0_1 = G[1][xy.y+0][xy.x+1]; s1_0_2 = G[1][xy.y+0][xy.x+2];
	s1_1_0 = G[1][xy.y+1][xy.x+0]; s1_1_1 = G[1][xy.y+1][xy.x+1];
	s1_1_2 = G[1][xy.y+1][xy.x+2]; s1_2_0 = G[1][xy.y+2][xy.x+0];
	s1_2_1 = G[1][xy.y+2][xy.x+1]; s1_2_2 = G[1][xy.y+2][xy.x+2];
	r0 = D(r0, s0_0_0, 0x000911F3, 0xFB110F04, 0x061B07FE, 0xFF120001);
	r1 = D(r1, s0_0_0, 0x050604FA, 0xFE070202, 0xFBFAFA04, 0x0B1D0B04);
	r2 = D(r2, s0_0_0, 0x060205FC, 0x0200FEFD, 0x0B0D05F7, 0x021600FC);
	r0 = D(r0, s0_0_1, 0x011A00FD, 0xF20EFD11, 0xF4050CF6, 0x0626FC06);
	r1 = D(r1, s0_0_1, 0xCE09020F, 0x070119EE, 0xFE1714FC, 0x1A1A08F0);
	r2 = D(r2, s0_0_1, 0x010912FE, 0xFE0CFC00, 0x0600F8F9, 0x001407F9);
	r0 = D(r0, s0_0_2, 0x0003060D, 0xF8190CF2, 0xF605FF0F, 0x0512FFE8);
	r1 = D(r1, s0_0_2, 0xF209FF11, 0x110CFCEF, 0xF7FCF7FC, 0x0407FEF5);
	r2 = D(r2, s0_0_2, 0x080703FE, 0xFD0B0006, 0xFC02FD08, 0x020FFFFD);
	r0 = D(r0, s0_1_0, 0xF3CD23F7, 0x0207FB07, 0xF7EC19F4, 0x0220FBF6);
	r1 = D(r1, s0_1_0, 0xFD0A1B09, 0x0713DFFB, 0x001405F7, 0xFBFD1F0B);
	r2 = D(r2, s0_1_0, 0xF8140B01, 0xFEF30D04, 0xEF0934EE, 0x00160BFE);
	r0 = D(r0, s0_1_1, 0x09E5EE1B, 0x12973C19, 0xEAC60504, 0xFF3618F0);
	r1 = D(r1, s0_1_1, 0x329534FD, 0xDA8164E1, 0xD88100F5, 0xBD9D1B20);
	r2 = D(r2, s0_1_1, 0x00BA160D, 0x12EDF603, 0x0F81D2D9, 0x04F10803);
	r0 = D(r0, s0_1_2, 0x160DF9F3, 0x02E70D26, 0xE2171413, 0xF624083D);
	r1 = D(r1, s0_1_2, 0x0A0B10F4, 0x0F070217, 0xEB15171D, 0xF3110A21);
	r2 = D(r2, s0_1_2, 0xD302EC2D, 0xFE080508, 0xF6130E1F, 0xFA0A050D);
	r0 = D(r0, s0_2_0, 0x001DF1F5, 0xFFFC0101, 0xFCF41607, 0x01130204);
	r1 = D(r1, s0_2_0, 0x010C07F5, 0x0A05FD06, 0xFEEE1502, 0x000FFC09);
	r2 = D(r2, s0_2_0, 0x040B0204, 0xFF1201FD, 0x0011FEF4, 0x04170002);
	r0 = D(r0, s0_2_1, 0x13811504, 0xF80CEEF9, 0xEF160204, 0xFA23FDFA);
	r1 = D(r1, s0_2_1, 0xC91FE8E1, 0xDD0910E6, 0xEF150A0F, 0x06FD1700);
	r2 = D(r2, s0_2_1, 0xF80710FA, 0x010412FB, 0x1B010BFB, 0x02F11B00);
	r0 = D(r0, s0_2_2, 0xD4271EFA, 0xF60903F4, 0xEA0605F9, 0xFB1503F7);
	r1 = D(r1, s0_2_2, 0x030608F1, 0x1C0AF107, 0xDF0901F9, 0x01FD08F8);
	r2 = D(r2, s0_2_2, 0x08111AD1, 0xFA0100FD, 0xE51006FD, 0x0403FD04);
	r0 = D(r0, s1_0_0, 0x07FD0113, 0x00F7F800, 0x02EF0314, 0x03030100);
	r1 = D(r1, s1_0_0, 0x0505FDF0, 0x010008FC, 0xFA00FF03, 0xF502F2FE);
	r2 = D(r2, s1_0_0, 0xF600FE05, 0x06FEFD03, 0x02F7080A, 0x06FB0305);
	r0 = D(r0, s1_0_1, 0x09F80103, 0x041AFAD5, 0xF803EFFB, 0x00FBFF0E);
	r1 = D(r1, s1_0_1, 0xFD030DD3, 0x0EEDF51F, 0x01F6FA0F, 0xE9E80307);
	r2 = D(r2, s1_0_1, 0xF7FDFB09, 0x0F0B01E5, 0xF2F6FD0C, 0xFD05F6FA);
	r0 = D(r0, s1_0_2, 0xF7FA0303, 0xF2FBF8F8, 0xF50AFC1A, 0x03FB0100);
	r1 = D(r1, s1_0_2, 0xFAF10BF9, 0xF5EE0738, 0xFEFE041E, 0x000702E4);
	r2 = D(r2, s1_0_2, 0xF7FA01F0, 0xFC010018, 0xF6090113, 0x01FF0301);
	r0 = D(r0, s1_1_0, 0xE8DCFD22, 0xFEF6FAFE, 0x02F3ED01, 0x0B040802);
	r1 = D(r1, s1_1_0, 0xFC04FAFC, 0x170A0DFD, 0x08040608, 0x050FF0F7);
	r2 = D(r2, s1_1_0, 0x0700FD02, 0xF4F6F705, 0x08E6051F, 0x05FB0B04);
	r0 = D(r0, s1_1_1, 0x3606EFF1, 0xE70BEBF7, 0x11EEFC14, 0x15300112);
	r1 = D(r1, s1_1_1, 0x04269C0C, 0x07BEC417, 0x0DC0DB0A, 0x3811D7D3);
	r2 = D(r2, s1_1_1, 0x1BDDC4DC, 0x19FCFE0D, 0x2CEF1618, 0x1EE9F2FC);
	r0 = D(r0, s1_1_2, 0xDDEA092D, 0x0E16E6E3, 0xDC11F801, 0xE409FEF5);
	r1 = D(r1, s1_1_2, 0x0821ECE5, 0xFBF1082F, 0xDE20F1FD, 0xF809F5F8);
	r2 = D(r2, s1_1_2, 0xF901F6FC, 0xFB04FD06, 0xE3F5FE12, 0x0106FF09);
	r0 = D(r0, s1_2_0, 0x00EF0B09, 0xFB050403, 0xEDF9F609, 0x020101FE);
	r1 = D(r1, s1_2_0, 0x0618FFFC, 0x06021003, 0xF2F5EF03, 0xEFF8FE02);
	r2 = D(r2, s1_2_0, 0x01F902FE, 0x010B0800, 0x04E508FE, 0x01FD06FF);
	r0 = D(r0, s1_2_1, 0x32E5E2F4, 0x13000503, 0x05140201, 0x10F80100);
	r1 = D(r1, s1_2_1, 0x16FF0EFB, 0xFEECF504, 0x00280EFF, 0xDD070604);
	r2 = D(r2, s1_2_1, 0xFE4310EB, 0xFD09FEFD, 0x19FBEC0F, 0xEBF9F603);
	r0 = D(r0, s1_2_2, 0xE2F2F409, 0xF3050302, 0xFBF80201, 0x03FD02FF);
	r1 = D(r1, s1_2_2, 0xFD060B00, 0x0BE3FE00, 0xF4EE0201, 0x02FD03FD);
	r2 = D(r2, s1_2_2, 0x0B2100E8, 0x03010100, 0x03F10003, 0x03FE0100);
	s0_0_0 = G[2][xy.y+0][xy.x+0]; s0_0_1 = G[2][xy.y+0][xy.x+1];
	s0_0_2 = G[2][xy.y+0][xy.x+2]; s0_1_0 = G[2][xy.y+1][xy.x+0];
	s0_1_1 = G[2][xy.y+1][xy.x+1]; s0_1_2 = G[2][xy.y+1][xy.x+2];
	s0_2_0 = G[2][xy.y+2][xy.x+0]; s0_2_1 = G[2][xy.y+2][xy.x+1];
	s0_2_2 = G[2][xy.y+2][xy.x+2];
	r0 = D(r0, s0_0_0, 0x0609ED0B, 0xFDF401FF, 0x01030AF8, 0x01FF02FD);
	r1 = D(r1, s0_0_0, 0xF900FE07, 0x02FA05FA, 0x0500FEFF, 0xFAFD0500);
	r2 = D(r2, s0_0_0, 0xFE04FF00, 0xFFFCF704, 0xFE08FCFD, 0xFFFF03FA);
	r0 = D(r0, s0_0_1, 0xF00119EC, 0xE0E9EE0B, 0xF2FCE50D, 0xFF020202);
	r1 = D(r1, s0_0_1, 0xE8EA0414, 0xEF1DD502, 0xE806ED0B, 0xD80AE208);
	r2 = D(r2, s0_0_1, 0xFD070C01, 0xFA020F0D, 0xE908F8FB, 0xF702E107);
	r0 = D(r0, s0_0_2, 0xF3F9F20B, 0xC7D10112, 0xFB0A0301, 0xFB06F9FA);
	r1 = D(r1, s0_0_2, 0xFEE81201, 0xD81123F8, 0xFEFF0902, 0xF904EB01);
	r2 = D(r2, s0_0_2, 0xFA06E803, 0xFDFBFA03, 0xF9030203, 0xF70905FD);
	r0 = D(r0, s0_1_0, 0x00FEF515, 0xFF090202, 0xFFEC0509, 0xFF0001FF);
	r1 = D(r1, s0_1_0, 0xFEF30705, 0x010203D8, 0xFC0C0100, 0xF8E71101);
	r2 = D(r2, s0_1_0, 0xFCEB11FC, 0xFD0C000B, 0xF90CF609, 0xFEFB0301);
	r0 = D(r0, s0_1_1, 0xF9ED18B4, 0xF2160C18, 0xF4300C01, 0xFCFAF901);
	r1 = D(r1, s0_1_1, 0xEE26D9C6, 0xEDFDCC2E, 0xF0EE0EFD, 0xDAB45CB3);
	r2 = D(r2, s0_1_1, 0xDAC21A11, 0xF514F420, 0xF21D1AF1, 0xF7201112);
	r0 = D(r0, s0_1_2, 0xD911CF19, 0xDC2BEF03, 0xF8F5EF0D, 0x03FFFF07);
	r1 = D(r1, s0_1_2, 0xF012FDF9, 0xE2FF2209, 0xE515F113, 0xF0FB1AFA);
	r2 = D(r2, s0_1_2, 0xDAEB2308, 0xFB06F805, 0xF3EDF512, 0xF30EFC06);
	r0 = D(r0, s0_2_0, 0x070FF602, 0x00FF00F9, 0xF90106FD, 0x00FB02FA);
	r1 = D(r1, s0_2_0, 0x03FA0702, 0x0101FEFE, 0xF9E70B02, 0x0312E508);
	r2 = D(r2, s0_2_0, 0xFAFD01FF, 0x01000205, 0xFFF1DF0E, 0xFDFFFF04);
	r0 = D(r0, s0_2_1, 0xEAF201EA, 0x02F802F9, 0x00F20AFA, 0x02FD06FB);
	r1 = D(r1, s0_2_1, 0x0ED50D01, 0x0312EE09, 0xF7190605, 0xF018D113);
	r2 = D(r2, s0_2_1, 0x040D0018, 0xFF00FF09, 0xF20D10EF, 0xF616FC08);
	r0 = D(r0, s0_2_2, 0xFC17DE0A, 0x02E90608, 0x05FDFE02, 0x0108FEFE);
	r1 = D(r1, s0_2_2, 0x0403FF04, 0xF7F409F2, 0x08ED05FA, 0x00FCEE09);
	r2 = D(r2, s0_2_2, 0xFEFAF218, 0x0000FEFF, 0xFD0CF707, 0xF704FCF8);
	f0 = vec4(r0) * 6.2000124e-05;
	f0 += vec4(-2.979e-02, -3.780e-02, -1.655e-02, 4.065e-02);
	f0 = max(f0, vec4(0.0));
	imageStore(out_image, opos + ivec2(0, 0), f0);
	f1 = vec4(r1) * 6.2000124e-05;
	f1 += vec4(-7.734e-03, -7.947e-03, -1.569e-02, -3.938e-02);
	f1 = max(f1, vec4(0.0));
	imageStore(out_image, opos + ivec2(1, 0), f1);
	f2 = vec4(r2) * 6.2000124e-05;
	f2 += vec4(-1.976e-02, 2.074e-03, -3.597e-03, 3.522e-03);
	f2 = max(f2, vec4(0.0));
	imageStore(out_image, opos + ivec2(2, 0), f2);
}

//!DESC CuNNy-4x12-DS-out-shuffle
//!HOOK LUMA
//!COMPUTE 16 16 8 8
//!BIND conv4
//!BIND LUMA
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h 2 *
//!COMPONENTS 1
//!WHEN OUTPUT.w LUMA.w / 1.3 > OUTPUT.h LUMA.h / 1.3 > *
#extension GL_EXT_spirv_intrinsics : require
#define l0(x, y) conv4_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(3, 1) + ivec2(0, 0)) + vec2(0.5)) * conv4_pt)
#define l1(x, y) conv4_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(3, 1) + ivec2(1, 0)) + vec2(0.5)) * conv4_pt)
#define l2(x, y) conv4_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(3, 1) + ivec2(2, 0)) + vec2(0.5)) * conv4_pt)
spirv_instruction (extensions = ["SPV_KHR_integer_dot_product"], capabilities = [6019, 6018], id = 4450)
int dp4(int a, int b, spirv_literal int fmt);
#define D(r, s, a, b, c, d) r + ivec4(dp4(s, a, 0), dp4(s, b, 0), dp4(s, c, 0), dp4(s, d, 0))
shared int G[3][10][10];
void hook() {
	ivec2 xy = ivec2(gl_LocalInvocationID.xy);
	ivec2 pos = ivec2(gl_WorkGroupID.xy) * ivec2(8, 8) + xy;
	ivec2 opos = pos * ivec2(2, 2);
	ivec2 sz = ivec2(LUMA_size) - ivec2(1);
	for (int y = 0; y < 10; y += 8) {
		int ay = xy.y + y;
		if (ay >= 10) break;
		for (int x = 0; x < 10; x += 8) {
			int ax = xy.x + x;
			if (ax >= 10) break;
			vec4 v0 = l0(x - 1, y - 1) * 1.0000000e+00;
			vec4 v1 = l1(x - 1, y - 1) * 1.0000000e+00;
			vec4 v2 = l2(x - 1, y - 1) * 1.0000000e+00;
			G[0][ay][ax] = int(packSnorm4x8(v0));
			G[1][ay][ax] = int(packSnorm4x8(v1));
			G[2][ay][ax] = int(packSnorm4x8(v2));
		}
	}
	barrier();
	int s0_0_0, s0_0_1, s0_0_2, s0_1_0, s0_1_1, s0_1_2, s0_2_0, s0_2_1, s0_2_2, s1_0_0, s1_0_1, s1_0_2, s1_1_0, s1_1_1, s1_1_2, s1_2_0, s1_2_1, s1_2_2;
	ivec4 r0;
	vec4 f0;
	r0 = ivec4(0);
	s0_0_0 = G[0][xy.y+0][xy.x+0]; s0_0_1 = G[0][xy.y+0][xy.x+1];
	s0_0_2 = G[0][xy.y+0][xy.x+2]; s0_1_0 = G[0][xy.y+1][xy.x+0];
	s0_1_1 = G[0][xy.y+1][xy.x+1]; s0_1_2 = G[0][xy.y+1][xy.x+2];
	s0_2_0 = G[0][xy.y+2][xy.x+0]; s0_2_1 = G[0][xy.y+2][xy.x+1];
	s0_2_2 = G[0][xy.y+2][xy.x+2]; s1_0_0 = G[1][xy.y+0][xy.x+0];
	s1_0_1 = G[1][xy.y+0][xy.x+1]; s1_0_2 = G[1][xy.y+0][xy.x+2];
	s1_1_0 = G[1][xy.y+1][xy.x+0]; s1_1_1 = G[1][xy.y+1][xy.x+1];
	s1_1_2 = G[1][xy.y+1][xy.x+2]; s1_2_0 = G[1][xy.y+2][xy.x+0];
	s1_2_1 = G[1][xy.y+2][xy.x+1]; s1_2_2 = G[1][xy.y+2][xy.x+2];
	r0 = D(r0, s0_0_0, 0xFC010208, 0xFEFF01FA, 0xFEFE0009, 0x0101FFFC);
	r0 = D(r0, s0_0_1, 0x060E01DF, 0x050B071E, 0xFF00FFF8, 0xFE00FF05);
	r0 = D(r0, s0_0_2, 0xFFFEFF02, 0xFEEAFE05, 0x02030102, 0x000300FE);
	r0 = D(r0, s0_1_0, 0x030AEDFF, 0xFCFC07FF, 0x02050000, 0xFCFD03FC);
	r0 = D(r0, s0_1_1, 0x1EC5F204, 0x1D10C80E, 0x1EF806E1, 0x1C250C26);
	r0 = D(r0, s0_1_2, 0xFA10FD04, 0x011207EF, 0xFA0BFF04, 0x00CEFBFA);
	r0 = D(r0, s0_2_0, 0xFE03FFFF, 0x02FF0100, 0xFC011A00, 0xFFFE0101);
	r0 = D(r0, s0_2_1, 0x000700FF, 0xFD03FFFE, 0x070A0B06, 0x05F125FE);
	r0 = D(r0, s0_2_2, 0x01FCFFFE, 0xFEFDFE03, 0xFEFD02FE, 0xFE1202FF);
	r0 = D(r0, s1_0_0, 0xFCFD0102, 0x01FDFFFF, 0x01FD0000, 0x0100FF00);
	r0 = D(r0, s1_0_1, 0x02F50505, 0xFB15FB05, 0x0606FDF9, 0x01F902FC);
	r0 = D(r0, s1_0_2, 0xFDFEFF01, 0x01FC0103, 0x0000FFFE, 0x03FFFFFC);
	r0 = D(r0, s1_1_0, 0x03031404, 0x00FEFAFF, 0x010A0FFF, 0xFFFCFC02);
	r0 = D(r0, s1_1_1, 0x292B23D0, 0x1DDBCFE8, 0xCCD92431, 0xEB06D519);
	r0 = D(r0, s1_1_2, 0x02F6FB02, 0x0DFD02F4, 0x04FBFC00, 0xEB170213);
	r0 = D(r0, s1_2_0, 0x00FEFEFF, 0xFF030000, 0x030102FC, 0xFF0100FF);
	r0 = D(r0, s1_2_1, 0xF9FAFF06, 0xFD010004, 0xFF0107FA, 0x0307F3FC);
	r0 = D(r0, s1_2_2, 0xFF02FF00, 0xFE01FF01, 0x0001FDFE, 0x02F802FA);
	s0_0_0 = G[2][xy.y+0][xy.x+0]; s0_0_1 = G[2][xy.y+0][xy.x+1];
	s0_0_2 = G[2][xy.y+0][xy.x+2]; s0_1_0 = G[2][xy.y+1][xy.x+0];
	s0_1_1 = G[2][xy.y+1][xy.x+1]; s0_1_2 = G[2][xy.y+1][xy.x+2];
	s0_2_0 = G[2][xy.y+2][xy.x+0]; s0_2_1 = G[2][xy.y+2][xy.x+1];
	s0_2_2 = G[2][xy.y+2][xy.x+2];
	r0 = D(r0, s0_0_0, 0xFB010007, 0x06FE01FF, 0xFFFFFFFB, 0x020000FE);
	r0 = D(r0, s0_0_1, 0x02EA030D, 0xEA0AFC16, 0x06FF01FE, 0x0201FFFE);
	r0 = D(r0, s0_0_2, 0xFE0004FE, 0x081208FC, 0x00FF0000, 0x060000FF);
	r0 = D(r0, s0_1_0, 0x02020709, 0x07FDFBFC, 0xFF0206EF, 0x07FDFC05);
	r0 = D(r0, s0_1_1, 0x08E9C901, 0xF40A0510, 0xF0D7E2F3, 0xD418F9D2);
	r0 = D(r0, s0_1_2, 0x06020501, 0x1907D601, 0x040004FE, 0x0E1CFB05);
	r0 = D(r0, s0_2_0, 0xFFFF03FF, 0x0200FF01, 0xFD000702, 0x05FEFEFF);
	r0 = D(r0, s0_2_1, 0x08FDFF01, 0x0102FEFF, 0x1DFBE505, 0x09FC0406);
	r0 = D(r0, s0_2_2, 0xFE00FF00, 0xFF0007FF, 0xFD0303FF, 0x0AFEEC01);
	f0 = vec4(r0) * 6.2000124e-05;
	f0 += vec4(-8.942e-03, -8.076e-03, -8.820e-03, -7.890e-03);
	f0 = tanh(f0);
	vec2 opt = 0.5 * LUMA_pt;
	vec2 fpos = (vec2(opos) + vec2(0.5)) * opt;
	imageStore(out_image, opos + ivec2(0, 0), vec4(f0.x + LUMA_tex(fpos + vec2(0.0, 0.0) * opt).r, 0.0, 0.0, 1.0));
	imageStore(out_image, opos + ivec2(1, 0), vec4(f0.y + LUMA_tex(fpos + vec2(1.0, 0.0) * opt).r, 0.0, 0.0, 1.0));
	imageStore(out_image, opos + ivec2(0, 1), vec4(f0.z + LUMA_tex(fpos + vec2(0.0, 1.0) * opt).r, 0.0, 0.0, 1.0));
	imageStore(out_image, opos + ivec2(1, 1), vec4(f0.w + LUMA_tex(fpos + vec2(1.0, 1.0) * opt).r, 0.0, 0.0, 1.0));
}
