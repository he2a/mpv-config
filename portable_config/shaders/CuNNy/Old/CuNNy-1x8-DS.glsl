// CuNNy 1x8 DS
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


//!DESC CuNNy-1x8-DS-in
//!HOOK LUMA
//!COMPUTE 16 8 8 8
//!BIND LUMA
//!SAVE in
//!WIDTH LUMA.w 2 *
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
	ivec2 opos = pos * ivec2(2, 1);
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
	V4 r0, r1;
	r0 = V4(0.0); r1 = V4(0.0);
	s0_0_0 = G[0][xy.y+0][xy.x+0]; s0_0_1 = G[0][xy.y+0][xy.x+1];
	s0_0_2 = G[0][xy.y+0][xy.x+2]; s0_1_0 = G[0][xy.y+1][xy.x+0];
	s0_1_1 = G[0][xy.y+1][xy.x+1]; s0_1_2 = G[0][xy.y+1][xy.x+2];
	s0_2_0 = G[0][xy.y+2][xy.x+0]; s0_2_1 = G[0][xy.y+2][xy.x+1];
	s0_2_2 = G[0][xy.y+2][xy.x+2];
	r0 += V4(-3.504e-02, 2.413e-02, 3.641e-02, 1.635e-01) * s0_0_0;
	r1 += V4(-1.198e-01, 6.456e-02, 3.652e-02, 8.779e-02) * s0_0_0;
	r0 += V4(8.535e-01, -3.708e-01, -2.374e-02, 1.960e-01) * s0_0_1;
	r1 += V4(-2.713e-01, -3.682e-01, 1.196e-01, -5.706e-02) * s0_0_1;
	r0 += V4(-6.657e-02, 5.762e-01, -3.447e-02, 1.752e-02) * s0_0_2;
	r1 += V4(8.911e-02, -3.037e-01, -1.028e-01, -3.405e-02) * s0_0_2;
	r0 += V4(1.583e-02, -4.101e-03, -8.178e-02, -3.186e-03) * s0_1_0;
	r1 += V4(1.234e-02, -1.392e-01, 5.572e-02, -1.293e-01) * s0_1_0;
	r0 += V4(-7.841e-01, 3.845e-01, -7.637e-01, -8.913e-01) * s0_1_1;
	r1 += V4(4.465e-01, 5.262e-01, 5.534e-01, 8.525e-01) * s0_1_1;
	r0 += V4(2.524e-02, -6.812e-01, 8.709e-01, 4.936e-02) * s0_1_2;
	r1 += V4(-1.802e-01, 2.701e-01, 1.257e-01, -6.852e-01) * s0_1_2;
	r0 += V4(1.571e-02, -6.269e-02, 4.084e-02, 2.495e-01) * s0_2_0;
	r1 += V4(1.038e-01, 5.736e-02, -4.945e-02, 2.456e-02) * s0_2_0;
	r0 += V4(-6.527e-02, -5.218e-02, -1.444e-02, 1.938e-01) * s0_2_1;
	r1 += V4(-2.619e-03, -1.277e-01, 9.084e-02, 4.534e-02) * s0_2_1;
	r0 += V4(4.024e-02, 1.904e-01, -3.357e-02, 2.280e-02) * s0_2_2;
	r1 += V4(-5.484e-02, 2.930e-02, -2.042e-02, -7.495e-02) * s0_2_2;
	r0 += V4(-1.375e-03, -8.934e-03, -1.075e-03, 1.100e-02);
	r0 = max(r0, V4(0.0));
	imageStore(out_image, opos + ivec2(0, 0), vec4(r0));
	r1 += V4(-3.660e-03, -1.839e-02, -1.858e-04, -3.118e-02);
	r1 = max(r1, V4(0.0));
	imageStore(out_image, opos + ivec2(1, 0), vec4(r1));
}

//!DESC CuNNy-1x8-DS-conv1
//!HOOK LUMA
//!COMPUTE 16 8 8 8
//!BIND in
//!BIND LUMA
//!SAVE conv1
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h
//!COMPONENTS 4
//!WHEN OUTPUT.w LUMA.w / 1.3 > OUTPUT.h LUMA.h / 1.3 > *
#extension GL_EXT_spirv_intrinsics : require
#define l0(x, y) in_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(2, 1) + ivec2(0, 0)) + vec2(0.5)) * in_pt)
#define l1(x, y) in_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(2, 1) + ivec2(1, 0)) + vec2(0.5)) * in_pt)
spirv_instruction (extensions = ["SPV_KHR_integer_dot_product"], capabilities = [6019, 6018], id = 4450)
int dp4(int a, int b, spirv_literal int fmt);
#define D(r, s, a, b, c, d) r + ivec4(dp4(s, a, 0), dp4(s, b, 0), dp4(s, c, 0), dp4(s, d, 0))
shared int G[2][10][10];
void hook() {
	ivec2 xy = ivec2(gl_LocalInvocationID.xy);
	ivec2 pos = ivec2(gl_WorkGroupID.xy) * ivec2(8, 8) + xy;
	ivec2 opos = pos * ivec2(2, 1);
	ivec2 sz = ivec2(LUMA_size) - ivec2(1);
	for (int y = 0; y < 10; y += 8) {
		int ay = xy.y + y;
		if (ay >= 10) break;
		for (int x = 0; x < 10; x += 8) {
			int ax = xy.x + x;
			if (ax >= 10) break;
			vec4 v0 = l0(x - 1, y - 1) * 1.0000000e+00;
			vec4 v1 = l1(x - 1, y - 1) * 1.0000000e+00;
			G[0][ay][ax] = int(packSnorm4x8(v0));
			G[1][ay][ax] = int(packSnorm4x8(v1));
		}
	}
	barrier();
	int s0_0_0, s0_0_1, s0_0_2, s0_1_0, s0_1_1, s0_1_2, s0_2_0, s0_2_1, s0_2_2, s1_0_0, s1_0_1, s1_0_2, s1_1_0, s1_1_1, s1_1_2, s1_2_0, s1_2_1, s1_2_2;
	ivec4 r0, r1;
	vec4 f0, f1;
	r0 = ivec4(0); r1 = ivec4(0);
	s0_0_0 = G[0][xy.y+0][xy.x+0]; s0_0_1 = G[0][xy.y+0][xy.x+1];
	s0_0_2 = G[0][xy.y+0][xy.x+2]; s0_1_0 = G[0][xy.y+1][xy.x+0];
	s0_1_1 = G[0][xy.y+1][xy.x+1]; s0_1_2 = G[0][xy.y+1][xy.x+2];
	s0_2_0 = G[0][xy.y+2][xy.x+0]; s0_2_1 = G[0][xy.y+2][xy.x+1];
	s0_2_2 = G[0][xy.y+2][xy.x+2]; s1_0_0 = G[1][xy.y+0][xy.x+0];
	s1_0_1 = G[1][xy.y+0][xy.x+1]; s1_0_2 = G[1][xy.y+0][xy.x+2];
	s1_1_0 = G[1][xy.y+1][xy.x+0]; s1_1_1 = G[1][xy.y+1][xy.x+1];
	s1_1_2 = G[1][xy.y+1][xy.x+2]; s1_2_0 = G[1][xy.y+2][xy.x+0];
	s1_2_1 = G[1][xy.y+2][xy.x+1]; s1_2_2 = G[1][xy.y+2][xy.x+2];
	r0 = D(r0, s0_0_0, 0xFF2918EE, 0x06EFFC06, 0x0811F10C, 0xF2D3F7F9);
	r1 = D(r1, s0_0_0, 0x0407F0FA, 0xEE07D5F9, 0x19F4F4EB, 0x09E407E7);
	r0 = D(r0, s0_0_1, 0xFFDBD9E1, 0x05010400, 0xF0270B1E, 0xE824F918);
	r1 = D(r1, s0_0_1, 0xF71C000B, 0x0535060D, 0x1A080BEF, 0x46C2EED6);
	r0 = D(r0, s0_0_2, 0xF6DBF5E5, 0x070305FD, 0x03F901F4, 0x0F04F5FE);
	r1 = D(r1, s0_0_2, 0xFC02FC01, 0x17FEFFF1, 0x14FC03F5, 0x11F7FFF2);
	r0 = D(r0, s0_1_0, 0x06EFEF0C, 0xF234F609, 0x0D7FF225, 0xF8DD09C8);
	r1 = D(r1, s0_1_0, 0xF2F2D506, 0xFBE7E1FD, 0xE0390867, 0xEA09FA19);
	r0 = D(r0, s0_1_1, 0xEB7FCC48, 0xF2E70C06, 0x6E7FC57F, 0xB97FA21A);
	r1 = D(r1, s0_1_1, 0xE63EE439, 0x0231D066, 0xC13DF353, 0x9A41041B);
	r0 = D(r0, s0_1_2, 0x0D090348, 0xFC07FEF7, 0xF50C0A30, 0x0ED90762);
	r1 = D(r1, s0_1_2, 0x2DE5F4E3, 0x15FEF21D, 0xF008F501, 0xE90AFD02);
	r0 = D(r0, s0_2_0, 0xFFEDCFF5, 0x04EEF527, 0x0A18EF0C, 0xEEFBE2F3);
	r1 = D(r1, s0_2_0, 0xFE130609, 0xF5F6D9FC, 0xF1C586FB, 0x0CE7E023);
	r0 = D(r0, s0_2_1, 0x09030511, 0x05EE0328, 0x05420C7F, 0x07F4EAE9);
	r1 = D(r1, s0_2_1, 0xF307F21F, 0x090B0D13, 0x1BBB22FC, 0xF40F214D);
	r0 = D(r0, s0_2_2, 0x08F00106, 0x01FFFE07, 0x0F0A0203, 0x0DFDF0EA);
	r1 = D(r1, s0_2_2, 0x18F7EECF, 0xFFFFF4EB, 0xDFFCF6EC, 0xFAFC010A);
	r0 = D(r0, s1_0_0, 0xF0F814FD, 0x1EDCF6FB, 0x07DF040A, 0x1C401B0C);
	r1 = D(r1, s1_0_0, 0x17F10702, 0x2500180D, 0xEDE420F9, 0xD906FBF9);
	r0 = D(r0, s1_0_1, 0x1CEE639C, 0x0114FF17, 0xF4841EE7, 0xDBDB04C0);
	r1 = D(r1, s1_0_1, 0xE3F402E0, 0xFBE116B9, 0xE8122AB5, 0x1C07FC25);
	r0 = D(r0, s1_0_2, 0x0929D9C2, 0xFE0F0009, 0x1FE709F8, 0xEDC704DE);
	r1 = D(r1, s1_0_2, 0xEA110104, 0x0707F8E6, 0x0501F6D9, 0x0B34F41C);
	r0 = D(r0, s1_1_0, 0x042318DF, 0x5016F812, 0x2F24E5E8, 0x12CE191A);
	r1 = D(r1, s1_1_0, 0x5B03E3F7, 0x5909FA12, 0x15FBBBFD, 0x30CE99ED);
	r0 = D(r0, s1_1_1, 0xE7063BCD, 0x181C01ED, 0x8181D30D, 0xFF09A131);
	r1 = D(r1, s1_1_1, 0xA2EDE1D1, 0xB64ED30A, 0xAFEA23C8, 0xC7AF9B81);
	r0 = D(r0, s1_1_2, 0x04C00CA4, 0xF8120610, 0x0A810DFA, 0x223B0DBA);
	r1 = D(r1, s1_1_2, 0x1B122930, 0xF8BF0FE5, 0xF9B70DDB, 0xF1BEF4D3);
	r0 = D(r0, s1_2_0, 0x09E607FE, 0x2A0AFCF2, 0x10CB1BF6, 0xE60C22F7);
	r1 = D(r1, s1_2_0, 0x1F0BED13, 0x0DEFF51F, 0xEB24341F, 0xFD323706);
	r0 = D(r0, s1_2_1, 0xE9240D08, 0x1C2D03F3, 0xDE263BED, 0x13FEF518);
	r1 = D(r1, s1_2_1, 0xE7170BEC, 0x041F2F09, 0x592645E6, 0xF6685917);
	r0 = D(r0, s1_2_2, 0x10001BF1, 0x0B1004E9, 0x03C70113, 0x0704EEFB);
	r1 = D(r1, s1_2_2, 0xF1E6FEFE, 0x0DF3F7EF, 0x0E260300, 0x03E903FE);
	f0 = vec4(r0) * 6.2000124e-05;
	f0 += vec4(-1.756e-02, -8.720e-01, 1.257e-02, -1.041e-02);
	f0 = max(f0, vec4(0.0));
	imageStore(out_image, opos + ivec2(0, 0), f0);
	f1 = vec4(r1) * 6.2000124e-05;
	f1 += vec4(-1.007e-02, -1.328e-02, -7.095e-03, -1.014e-02);
	f1 = max(f1, vec4(0.0));
	imageStore(out_image, opos + ivec2(1, 0), f1);
}

//!DESC CuNNy-1x8-DS-out-shuffle
//!HOOK LUMA
//!COMPUTE 16 16 8 8
//!BIND conv1
//!BIND LUMA
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h 2 *
//!COMPONENTS 1
//!WHEN OUTPUT.w LUMA.w / 1.3 > OUTPUT.h LUMA.h / 1.3 > *
#extension GL_EXT_spirv_intrinsics : require
#define l0(x, y) conv1_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(2, 1) + ivec2(0, 0)) + vec2(0.5)) * conv1_pt)
#define l1(x, y) conv1_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(2, 1) + ivec2(1, 0)) + vec2(0.5)) * conv1_pt)
spirv_instruction (extensions = ["SPV_KHR_integer_dot_product"], capabilities = [6019, 6018], id = 4450)
int dp4(int a, int b, spirv_literal int fmt);
#define D(r, s, a, b, c, d) r + ivec4(dp4(s, a, 0), dp4(s, b, 0), dp4(s, c, 0), dp4(s, d, 0))
shared int G[2][10][10];
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
			G[0][ay][ax] = int(packSnorm4x8(v0));
			G[1][ay][ax] = int(packSnorm4x8(v1));
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
	r0 = D(r0, s0_0_0, 0x00FBF0F2, 0x040305FA, 0x000407FF, 0xFFFE0002);
	r0 = D(r0, s0_0_1, 0x08E660F7, 0x0BE607F2, 0xF605FF00, 0x0509FEFF);
	r0 = D(r0, s0_0_2, 0xFD03FFFE, 0xF9FE3CFE, 0x00FD0400, 0xFF030200);
	r0 = D(r0, s0_1_0, 0x13EA031E, 0x15040509, 0x05E6E6F4, 0x0D090DFF);
	r0 = D(r0, s0_1_1, 0x2CB472F4, 0x9EC40A22, 0x33BB7FF0, 0xD8B6F2E6);
	r0 = D(r0, s0_1_2, 0xF3090205, 0x0EE770F2, 0xF80AEFFF, 0xFCE97F00);
	r0 = D(r0, s0_2_0, 0xF003FF01, 0xFC0100FE, 0x03FF1316, 0x0A01FCFD);
	r0 = D(r0, s0_2_1, 0xFE0BF4FE, 0x0606FCFE, 0x02E62409, 0xD2E9262F);
	r0 = D(r0, s0_2_2, 0x03FE0100, 0x0003F402, 0xFD0316FE, 0x0BFC1EF4);
	r0 = D(r0, s1_0_0, 0x03FFF813, 0xFD0002FC, 0x070203FB, 0xFFFF0002);
	r0 = D(r0, s1_0_1, 0x00240DE0, 0x0F0A0021, 0x0CF7030C, 0x10FF0006);
	r0 = D(r0, s1_0_2, 0x02FC010A, 0xFB1600FA, 0xFC01FF02, 0x00FE00F9);
	r0 = D(r0, s1_1_0, 0x0107EA1F, 0xFBFD03F5, 0xF105E039, 0x0DFB06ED);
	r0 = D(r0, s1_1_1, 0x46A60EB9, 0x36EDB635, 0xB32F1194, 0xAA26CF49);
	r0 = D(r0, s1_1_2, 0xF305FD0A, 0x09CB2AF8, 0x0F04FF10, 0x001716FF);
	r0 = D(r0, s1_2_0, 0xFD02FDFC, 0x000006FF, 0x03FBFDF8, 0xFFFF0601);
	r0 = D(r0, s1_2_1, 0xEF0B1007, 0xF20608F8, 0x05F71A00, 0x10F9F0FB);
	r0 = D(r0, s1_2_2, 0x0304FDFE, 0xFD0AFEFF, 0x03FAFDFF, 0xFDF711F9);
	f0 = vec4(r0) * 6.2000124e-05;
	f0 += vec4(-3.938e-09, -4.456e-09, -5.536e-09, -7.682e-09);
	f0 = tanh(f0);
	vec2 opt = 0.5 * LUMA_pt;
	vec2 fpos = (vec2(opos) + vec2(0.5)) * opt;
	imageStore(out_image, opos + ivec2(0, 0), vec4(f0.x + LUMA_tex(fpos + vec2(0.0, 0.0) * opt).r, 0.0, 0.0, 1.0));
	imageStore(out_image, opos + ivec2(1, 0), vec4(f0.y + LUMA_tex(fpos + vec2(1.0, 0.0) * opt).r, 0.0, 0.0, 1.0));
	imageStore(out_image, opos + ivec2(0, 1), vec4(f0.z + LUMA_tex(fpos + vec2(0.0, 1.0) * opt).r, 0.0, 0.0, 1.0));
	imageStore(out_image, opos + ivec2(1, 1), vec4(f0.w + LUMA_tex(fpos + vec2(1.0, 1.0) * opt).r, 0.0, 0.0, 1.0));
}
