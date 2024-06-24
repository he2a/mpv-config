// CuNNy 4x16 DS
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


//!DESC CuNNy-4x16-DS-in
//!HOOK LUMA
//!COMPUTE 16 16 8 8
//!BIND LUMA
//!SAVE in
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h 2 *
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
	ivec2 opos = pos * ivec2(2, 2);
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
	V4 r0, r1, r2, r3;
	r0 = V4(0.0); r1 = V4(0.0); r2 = V4(0.0); r3 = V4(0.0);
	s0_0_0 = G[0][xy.y+0][xy.x+0]; s0_0_1 = G[0][xy.y+0][xy.x+1];
	s0_0_2 = G[0][xy.y+0][xy.x+2]; s0_1_0 = G[0][xy.y+1][xy.x+0];
	s0_1_1 = G[0][xy.y+1][xy.x+1]; s0_1_2 = G[0][xy.y+1][xy.x+2];
	s0_2_0 = G[0][xy.y+2][xy.x+0]; s0_2_1 = G[0][xy.y+2][xy.x+1];
	s0_2_2 = G[0][xy.y+2][xy.x+2];
	r0 += V4(3.187e-03, -4.932e-01, -4.183e-02, -4.649e-02) * s0_0_0;
	r1 += V4(9.600e-02, 4.725e-02, 1.197e-02, -5.049e-03) * s0_0_0;
	r2 += V4(1.415e-02, 3.958e-02, 4.265e-02, 3.983e-03) * s0_0_0;
	r3 += V4(1.901e-02, 1.821e-01, -5.304e-02, 3.212e-02) * s0_0_0;
	r0 += V4(3.487e-02, 5.024e-01, -1.334e-02, 4.870e-02) * s0_0_1;
	r1 += V4(-7.142e-02, -1.440e-01, -1.479e-02, 1.233e-02) * s0_0_1;
	r2 += V4(1.016e-02, -2.142e-01, -9.664e-02, -1.203e-03) * s0_0_1;
	r3 += V4(-4.905e-02, -1.979e-01, 3.287e-02, -1.208e-01) * s0_0_1;
	r0 += V4(5.997e-01, -2.265e-02, 5.809e-02, -3.311e-02) * s0_0_2;
	r1 += V4(-5.640e-03, 1.963e-02, -4.166e-03, 5.265e-03) * s0_0_2;
	r2 += V4(-1.767e-01, -3.688e-01, -1.573e-02, -3.874e-03) * s0_0_2;
	r3 += V4(3.137e-02, -3.868e-02, 1.950e-02, 5.126e-03) * s0_0_2;
	r0 += V4(-3.620e-03, -1.499e-01, -6.502e-02, 9.029e-02) * s0_1_0;
	r1 += V4(-6.643e-01, -1.977e-01, 7.423e-03, 1.586e-01) * s0_1_0;
	r2 += V4(-3.944e-02, 5.042e-02, -3.994e-01, 2.056e-02) * s0_1_0;
	r3 += V4(-1.546e-03, 4.683e-01, 5.762e-01, -4.056e-02) * s0_1_0;
	r0 += V4(-2.533e-02, 1.759e-01, -5.232e-01, 1.703e-01) * s0_1_1;
	r1 += V4(2.207e-01, -4.183e-02, -6.093e-01, 3.406e-02) * s0_1_1;
	r2 += V4(4.893e-01, -1.070e+00, 4.261e-02, -2.069e-02) * s0_1_1;
	r3 += V4(5.039e-01, -3.547e-01, 2.996e-02, -7.689e-02) * s0_1_1;
	r0 += V4(-5.957e-01, 1.034e-03, -1.336e-01, 1.196e-01) * s0_1_2;
	r1 += V4(5.728e-02, 3.760e-01, -3.577e-03, 3.105e-02) * s0_1_2;
	r2 += V4(-2.114e-01, -4.896e-01, 1.135e-01, 8.286e-03) * s0_1_2;
	r3 += V4(3.022e-02, -5.639e-02, -4.244e-02, 3.942e-01) * s0_1_2;
	r0 += V4(-3.683e-03, -3.516e-04, 3.056e-01, 1.492e-02) * s0_2_0;
	r1 += V4(2.666e-01, -4.588e-02, -1.262e-02, -2.154e+00) * s0_2_0;
	r2 += V4(1.353e-02, 1.087e-02, -9.089e-02, 5.673e-01) * s0_2_0;
	r3 += V4(-1.425e-01, 2.511e-02, -5.435e-01, 3.493e-03) * s0_2_0;
	r0 += V4(-7.496e-03, -4.073e-02, 3.478e-01, 6.701e-02) * s0_2_1;
	r1 += V4(8.003e-02, -1.568e-01, 6.281e-01, 2.075e-01) * s0_2_1;
	r2 += V4(-7.108e-02, 6.644e-02, 5.117e-01, -5.684e-01) * s0_2_1;
	r3 += V4(-2.675e-01, -7.544e-02, -2.782e-02, 1.929e-01) * s0_2_1;
	r0 += V4(-1.550e-03, 2.402e-02, 6.217e-02, 1.629e-01) * s0_2_2;
	r1 += V4(-1.667e-02, 1.498e-01, 1.700e-03, -2.150e-02) * s0_2_2;
	r2 += V4(2.337e-03, 1.745e-02, -1.037e-01, -3.463e-03) * s0_2_2;
	r3 += V4(-1.195e-01, 4.239e-02, 1.574e-02, -3.975e-01) * s0_2_2;
	r0 += V4(4.930e-03, 1.153e-02, -4.799e-03, -2.682e-01);
	r0 = max(r0, V4(0.0));
	imageStore(out_image, opos + ivec2(0, 0), vec4(r0));
	r1 += V4(-1.646e-02, 1.593e-02, 4.469e-03, 3.194e-02);
	r1 = max(r1, V4(0.0));
	imageStore(out_image, opos + ivec2(1, 0), vec4(r1));
	r2 += V4(-2.028e-03, 6.703e-02, 6.025e-03, -1.079e-03);
	r2 = max(r2, V4(0.0));
	imageStore(out_image, opos + ivec2(0, 1), vec4(r2));
	r3 += V4(7.156e-03, 2.311e-02, -2.472e-02, 1.700e-02);
	r3 = max(r3, V4(0.0));
	imageStore(out_image, opos + ivec2(1, 1), vec4(r3));
}

//!DESC CuNNy-4x16-DS-conv1
//!HOOK LUMA
//!COMPUTE 16 16 8 8
//!BIND in
//!BIND LUMA
//!SAVE conv1
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h 2 *
//!COMPONENTS 4
//!WHEN OUTPUT.w LUMA.w / 1.3 > OUTPUT.h LUMA.h / 1.3 > *
#extension GL_EXT_spirv_intrinsics : require
spirv_instruction (extensions = ["SPV_KHR_integer_dot_product"], capabilities = [6019, 6018], id = 4450)
int dp4(int a, int b, spirv_literal int fmt);
#define D(r, s, a, b, c, d) r + ivec4(dp4(s, a, 0), dp4(s, b, 0), dp4(s, c, 0), dp4(s, d, 0))
shared int G[4][10][10];
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
			vec2 p;
			vec4 r, g, b, a;
			p = vec2(clamp(pos + ivec2(x - 1, y - 1), ivec2(0), sz) * ivec2(2, 2) + ivec2(1, 1)) * in_pt;
			r = in_gather(p, 0);
			g = in_gather(p, 1);
			b = in_gather(p, 2);
			a = in_gather(p, 3);
			vec4 v0 = vec4(r.w, g.w, b.w, a.w) * 1.0000000e+00;
			vec4 v1 = vec4(r.z, g.z, b.z, a.z) * 1.0000000e+00;
			vec4 v2 = vec4(r.x, g.x, b.x, a.x) * 1.0000000e+00;
			vec4 v3 = vec4(r.y, g.y, b.y, a.y) * 1.0000000e+00;
			G[0][ay][ax] = int(packSnorm4x8(v0));
			G[1][ay][ax] = int(packSnorm4x8(v1));
			G[2][ay][ax] = int(packSnorm4x8(v2));
			G[3][ay][ax] = int(packSnorm4x8(v3));
		}
	}
	barrier();
	int s0_0_0, s0_0_1, s0_0_2, s0_1_0, s0_1_1, s0_1_2, s0_2_0, s0_2_1, s0_2_2, s1_0_0, s1_0_1, s1_0_2, s1_1_0, s1_1_1, s1_1_2, s1_2_0, s1_2_1, s1_2_2;
	ivec4 r0, r1, r2, r3;
	vec4 f0, f1, f2, f3;
	r0 = ivec4(0); r1 = ivec4(0); r2 = ivec4(0); r3 = ivec4(0);
	s0_0_0 = G[0][xy.y+0][xy.x+0]; s0_0_1 = G[0][xy.y+0][xy.x+1];
	s0_0_2 = G[0][xy.y+0][xy.x+2]; s0_1_0 = G[0][xy.y+1][xy.x+0];
	s0_1_1 = G[0][xy.y+1][xy.x+1]; s0_1_2 = G[0][xy.y+1][xy.x+2];
	s0_2_0 = G[0][xy.y+2][xy.x+0]; s0_2_1 = G[0][xy.y+2][xy.x+1];
	s0_2_2 = G[0][xy.y+2][xy.x+2]; s1_0_0 = G[1][xy.y+0][xy.x+0];
	s1_0_1 = G[1][xy.y+0][xy.x+1]; s1_0_2 = G[1][xy.y+0][xy.x+2];
	s1_1_0 = G[1][xy.y+1][xy.x+0]; s1_1_1 = G[1][xy.y+1][xy.x+1];
	s1_1_2 = G[1][xy.y+1][xy.x+2]; s1_2_0 = G[1][xy.y+2][xy.x+0];
	s1_2_1 = G[1][xy.y+2][xy.x+1]; s1_2_2 = G[1][xy.y+2][xy.x+2];
	r0 = D(r0, s0_0_0, 0x04F90102, 0x030E031C, 0xC0E9FD12, 0xFA200914);
	r1 = D(r1, s0_0_0, 0xF3FCFF03, 0x07F8FBFB, 0x08D70213, 0xE7000204);
	r2 = D(r2, s0_0_0, 0x0C57F704, 0xF00201FD, 0x1AFEEEF4, 0x0501FE01);
	r3 = D(r3, s0_0_0, 0xFBF40202, 0xE81C051A, 0x01F7F309, 0xF2FEFDFB);
	r0 = D(r0, s0_0_1, 0x14FD0011, 0x1108F8F8, 0x1BE61806, 0xFFE5FFFA);
	r1 = D(r1, s0_0_1, 0x0C120BF3, 0xFF00FF00, 0x098113FE, 0x0415FEF9);
	r2 = D(r2, s0_0_1, 0xF20AE8F4, 0x0B0B0607, 0xE1D3FB0C, 0x0CF3040E);
	r3 = D(r3, s0_0_1, 0xFF30F802, 0xF445F007, 0xF7C31FFD, 0x15F9010B);
	r0 = D(r0, s0_0_2, 0x020C0302, 0xF835F8ED, 0xEFE30208, 0x05080207);
	r1 = D(r1, s0_0_2, 0x09D81007, 0xF9EE0105, 0xEAB4040E, 0xFBF70301);
	r2 = D(r2, s0_0_2, 0xF438FD00, 0xECFF0602, 0x01E0F902, 0xFBDE0107);
	r3 = D(r3, s0_0_2, 0xEF15FDFD, 0xF0FEE103, 0xFE110F0C, 0x0535FC00);
	r0 = D(r0, s0_1_0, 0x18FFFEFA, 0xF12A114E, 0x0607F5F9, 0x17B5CBFA);
	r1 = D(r1, s0_1_0, 0xFBFC0D19, 0xFECB1AA6, 0xF9D70DFE, 0xE8F60802);
	r2 = D(r2, s0_1_0, 0x0F20DA2B, 0x0F17E39E, 0xFCCA0EEC, 0x050DF028);
	r3 = D(r3, s0_1_0, 0xF8F32208, 0x173EE6E0, 0x05E807F3, 0x0516FC5D);
	r0 = D(r0, s0_1_1, 0x1A090104, 0x070CFAFE, 0xCF2725AD, 0x001F02ED);
	r1 = D(r1, s0_1_1, 0x12061B13, 0x0EFAB11B, 0xF8E01721, 0xCAF5FDDB);
	r2 = D(r2, s0_1_1, 0xFD192F24, 0x06EAE110, 0x0A9CFA37, 0xF8FD030F);
	r3 = D(r3, s0_1_1, 0x1121C916, 0x0CF9C636, 0x01171CDA, 0x0725151D);
	r0 = D(r0, s0_1_2, 0x171AFD02, 0x0327FAED, 0x3CDB1005, 0xFFF23600);
	r1 = D(r1, s0_1_2, 0xF806E6D8, 0xFA0208FE, 0xFF84EF21, 0xE401EAF8);
	r2 = D(r2, s0_1_2, 0x18AA2F0D, 0x0622FEF9, 0x041CD1DF, 0x00E91605);
	r3 = D(r3, s0_1_2, 0x1526FDF9, 0x1A24A3FC, 0x0F1B07FE, 0xEDED45FE);
	r0 = D(r0, s0_2_0, 0x0BFF0BE2, 0xF90DF2F1, 0xADDA16C9, 0x0DD4CB7F);
	r1 = D(r1, s0_2_0, 0x01FD0AC2, 0x12F1E1FB, 0x0EF4079F, 0xF8F7EF2A);
	r2 = D(r2, s0_2_0, 0x00E8EE1A, 0x00021A81, 0xF3DEE72E, 0x03F1F07F);
	r3 = D(r3, s0_2_0, 0x0113DC2E, 0xFDFB0B0A, 0x01F93181, 0x05EAF93E);
	r0 = D(r0, s0_2_1, 0xFDFD2203, 0x0BFF0315, 0xC0111BFC, 0xF80F0CDC);
	r1 = D(r1, s0_2_1, 0xF81423C8, 0xEB01BD05, 0xFCE2EDF9, 0x0708F8EB);
	r2 = D(r2, s0_2_1, 0xEC371661, 0x00CE09B6, 0x0DFBD324, 0x0403FD39);
	r3 = D(r3, s0_2_1, 0x03078132, 0x0CD4FE28, 0xFE2BB930, 0xF1FF00FF);
	r0 = D(r0, s0_2_2, 0xFC0BEC05, 0xF827E80B, 0x2426A910, 0xE910FBF7);
	r1 = D(r1, s0_2_2, 0xFAEF31EF, 0x01FBDE01, 0x0DEED5F8, 0x0609E208);
	r2 = D(r2, s0_2_2, 0x00F8380A, 0xFF1333FA, 0xFFFA21FB, 0x01F4DF14);
	r3 = D(r3, s0_2_2, 0xF805F313, 0xF3F0BDFF, 0xF9EBB00A, 0x07015DED);
	r0 = D(r0, s1_0_0, 0xFD09070A, 0xF20DF4F1, 0xE4A4E3FE, 0xE5E8F12B);
	r1 = D(r1, s1_0_0, 0x04FA080C, 0xF631E2EC, 0xFC25EC12, 0x05190708);
	r2 = D(r2, s1_0_0, 0xFFAA17E6, 0xFEE70914, 0x0AFE17E2, 0x0000F1FA);
	r3 = D(r3, s1_0_0, 0xF80215F0, 0x11D50009, 0xFBEDD017, 0x00FF0406);
	r0 = D(r0, s1_0_1, 0xE83AEE04, 0x1854FC1F, 0x2A3EC2E3, 0xFA24F4CC);
	r1 = D(r1, s1_0_1, 0xEFECFFF1, 0xABF2F828, 0xEC3FE715, 0xF7EFF7F3);
	r2 = D(r2, s1_0_1, 0xE4EDE3C0, 0xE31A00EE, 0xEFF8F41D, 0x0C17FBFD);
	r3 = D(r3, s1_0_1, 0x1CBA031A, 0x53E93919, 0x8C4CEAFA, 0xFFFB1909);
	r0 = D(r0, s1_0_2, 0x8118051E, 0x4AE0FF21, 0x8C3BBE00, 0xF4281DCE);
	r1 = D(r1, s1_0_2, 0x3AF2FF0E, 0x30F80CF8, 0x088A02F1, 0x090D0C0C);
	r2 = D(r2, s1_0_2, 0x02F4E8E0, 0x4EF616D6, 0x81060531, 0xE21EF5FE);
	r3 = D(r3, s1_0_2, 0x1AF10902, 0xE3E206F3, 0x26F70AD7, 0x40E8F3FB);
	r0 = D(r0, s1_1_0, 0xF327170D, 0xF41F12EF, 0x0E8111D5, 0xD6370014);
	r1 = D(r1, s1_1_0, 0x0F060413, 0x1740A041, 0x052E060F, 0xF5060608);
	r2 = D(r2, s1_1_0, 0x08E020E8, 0xFD010DEE, 0x18CED62F, 0x06E4F9F6);
	r3 = D(r3, s1_1_0, 0x0E200208, 0xE0E607F0, 0x06B0FA09, 0xFD05FAF7);
	r0 = D(r0, s1_1_1, 0xF3F424FB, 0xEBC1F8CD, 0xEC811128, 0xF59105D5);
	r1 = D(r1, s1_1_1, 0xEEE3EDF8, 0xF3EE0F9C, 0xE6D418F1, 0x0316F8F6);
	r2 = D(r2, s1_1_1, 0xD2D001DB, 0xFB76F9ED, 0xEEE09D2A, 0xF4EFF624);
	r3 = D(r3, s1_1_1, 0xD5B9DDD1, 0xF9BF0C1D, 0x6F610E29, 0xFCF114E7);
	r0 = D(r0, s1_1_2, 0xD50408E3, 0x19EF0227, 0x311337BD, 0x5C37D028);
	r1 = D(r1, s1_1_2, 0xFD511923, 0xF80B0134, 0xD4940311, 0xFE08FF03);
	r2 = D(r2, s1_1_2, 0x0E030D19, 0xF525F702, 0xF0F2F520, 0x22FC01F3);
	r3 = D(r3, s1_1_2, 0x3004F76A, 0xEEED0D4C, 0xBA0603DF, 0x08FC0DEC);
	r0 = D(r0, s1_2_0, 0x09070107, 0xEE011709, 0xDAE9D010, 0x170D070E);
	r1 = D(r1, s1_2_0, 0x0400F1FF, 0xFBF61108, 0xEB270F0B, 0xFA0CFD04);
	r2 = D(r2, s1_2_0, 0x1B112C04, 0x00F0F0FE, 0xEBEADC2E, 0x050D0C0F);
	r3 = D(r3, s1_2_0, 0xFAE5F3F6, 0x0022F817, 0xEDDD0F0B, 0x010AF60B);
	r0 = D(r0, s1_2_1, 0xFCF608EA, 0x151D2FFF, 0x28E28D06, 0x3AE9E050);
	r1 = D(r1, s1_2_1, 0xFCF7D4FF, 0x0307FDF1, 0xE90E0EE5, 0x01F90108);
	r2 = D(r2, s1_2_1, 0xF1D30700, 0x1034012D, 0xDF370618, 0xDA0AFA18);
	r3 = D(r3, s1_2_1, 0x001522E7, 0xF541260E, 0x2EF0B6F2, 0xFBEAF512);
	r0 = D(r0, s1_2_2, 0x04010812, 0xFEEDFFFA, 0x32E5ED7F, 0x1B0D1803);
	r1 = D(r1, s1_2_2, 0xF41112F2, 0xFC0D000A, 0x05F814F7, 0x060FF9F1);
	r2 = D(r2, s1_2_2, 0x14100641, 0x08E1F8E4, 0x2AF91BBC, 0xFB1805F3);
	r3 = D(r3, s1_2_2, 0xFC0E0702, 0xFB15020A, 0xFF020C1B, 0x17FCFF15);
	s0_0_0 = G[2][xy.y+0][xy.x+0]; s0_0_1 = G[2][xy.y+0][xy.x+1];
	s0_0_2 = G[2][xy.y+0][xy.x+2]; s0_1_0 = G[2][xy.y+1][xy.x+0];
	s0_1_1 = G[2][xy.y+1][xy.x+1]; s0_1_2 = G[2][xy.y+1][xy.x+2];
	s0_2_0 = G[2][xy.y+2][xy.x+0]; s0_2_1 = G[2][xy.y+2][xy.x+1];
	s0_2_2 = G[2][xy.y+2][xy.x+2]; s1_0_0 = G[3][xy.y+0][xy.x+0];
	s1_0_1 = G[3][xy.y+0][xy.x+1]; s1_0_2 = G[3][xy.y+0][xy.x+2];
	s1_1_0 = G[3][xy.y+1][xy.x+0]; s1_1_1 = G[3][xy.y+1][xy.x+1];
	s1_1_2 = G[3][xy.y+1][xy.x+2]; s1_2_0 = G[3][xy.y+2][xy.x+0];
	s1_2_1 = G[3][xy.y+2][xy.x+1]; s1_2_2 = G[3][xy.y+2][xy.x+2];
	r0 = D(r0, s0_0_0, 0x0EFEFAF8, 0xF11D1403, 0x072215FA, 0x2B1913F8);
	r1 = D(r1, s0_0_0, 0x0CDBEF03, 0xFE094807, 0x15FF2916, 0x0DECE500);
	r2 = D(r2, s0_0_0, 0xDF1DCAFE, 0xF202EAE8, 0xD92DFEEA, 0x0D141001);
	r3 = D(r3, s0_0_0, 0xFD0115F7, 0xF204051F, 0xE0F806FD, 0xFAFDF3FE);
	r0 = D(r0, s0_0_1, 0x251D0009, 0xDBF30DD1, 0x417F3919, 0x3513FDF1);
	r1 = D(r1, s0_0_1, 0x0C001BEC, 0x3CF9E607, 0x101CFFE4, 0xFB0B37FF);
	r2 = D(r2, s0_0_1, 0x11B1D24B, 0xDB30E813, 0xBE2707E5, 0x0CF4F7EB);
	r3 = D(r3, s0_0_1, 0xE3170F0F, 0x81F2F1FD, 0xFD2A46EA, 0x39CBD90A);
	r0 = D(r0, s0_0_2, 0x15EF0DF9, 0xC003FCFC, 0x032FFCF4, 0xEBD8FF1A);
	r1 = D(r1, s0_0_2, 0x4AF0EB0A, 0xC3EEDAF7, 0xE3461AFD, 0xEE01EC05);
	r2 = D(r2, s0_0_2, 0x7F193D04, 0xD5E90CFB, 0x0609FA0A, 0x2E0CFC02);
	r3 = D(r3, s0_0_2, 0xBFEDFAF8, 0x81E005FD, 0x5331E511, 0x34042404);
	r0 = D(r0, s0_1_0, 0x06E9D7FB, 0x1709FEEA, 0x7F254BEC, 0x1A7F1AE1);
	r1 = D(r1, s0_1_0, 0xF3EC00F2, 0x26F1C231, 0x1AE2D7F9, 0xF811B910);
	r2 = D(r2, s0_1_0, 0xB91AF505, 0xFC061AE4, 0xD7E0AAF3, 0x091AC4F3);
	r3 = D(r3, s0_1_0, 0xF7EABF25, 0xFF1AF7C6, 0xD5CCEDFF, 0xEA1B1F02);
	r0 = D(r0, s0_1_1, 0xF607A928, 0x2AFE292E, 0x8181E31D, 0xFC2CFCF0);
	r1 = D(r1, s0_1_1, 0x11DE065D, 0xF91421D5, 0x02E61604, 0x030409DD);
	r2 = D(r2, s0_1_1, 0xDAEDB7BA, 0xF81746D1, 0x1E39D03C, 0x1308BD1B);
	r3 = D(r3, s0_1_1, 0x0CA7CBE2, 0xFDF5E731, 0xA319FBE4, 0xED04E6FB);
	r0 = D(r0, s0_1_2, 0x0CF0F30F, 0xDFDB09FC, 0xDEFA13B4, 0xEA1AE5EB);
	r1 = D(r1, s0_1_2, 0x3FE80CF7, 0xDE0407FC, 0xF6F9F525, 0xEEFEFCF4);
	r2 = D(r2, s0_1_2, 0x81278103, 0x673CF0F2, 0x7F30F4EE, 0x073218FB);
	r3 = D(r3, s0_1_2, 0xDDD9F7F8, 0x1BE4CEFE, 0xC42E1FDD, 0xFE13C6FE);
	r0 = D(r0, s0_2_0, 0x01024CEE, 0x1305E4EF, 0xEE22D7E3, 0xF3E9F903);
	r1 = D(r1, s0_2_0, 0xFEFDF4F1, 0xFB0D1501, 0x0FFA0A0B, 0x01FB812F);
	r2 = D(r2, s0_2_0, 0xFBED0CB5, 0xF9010400, 0xF9F82D11, 0x0EF7E9F5);
	r3 = D(r3, s0_2_0, 0xF2140BF1, 0x0DF601FF, 0xF105FE26, 0x04FC0DE0);
	r0 = D(r0, s0_2_1, 0x030FBCF7, 0x17097410, 0x13AEE5D0, 0xF3D3ED1A);
	r1 = D(r1, s0_2_1, 0x0FFE2AF1, 0x05EB3814, 0x0A1ECEFC, 0x0A08C8FD);
	r2 = D(r2, s0_2_1, 0x02CB9DF2, 0x09FAD72D, 0x120D31DA, 0x0FFE0DF9);
	r3 = D(r3, s0_2_1, 0x07F63C18, 0x03ED53D8, 0x10D3182C, 0x0AFFF300);
	r0 = D(r0, s0_2_2, 0x11F52006, 0x02F80EFC, 0x22032881, 0x08EFF9FD);
	r1 = D(r1, s0_2_2, 0x1A08FEFB, 0xFEF9E1FB, 0x013821D5, 0x0BFA1CF1);
	r2 = D(r2, s0_2_2, 0xF6E01C0A, 0xFE2BE614, 0xF8306800, 0x030D2F00);
	r3 = D(r3, s0_2_2, 0xFBECED08, 0xFEE3EE07, 0x0711EF16, 0x110E0AFC);
	r0 = D(r0, s1_0_0, 0xF0FD1D06, 0x2D1904F5, 0xEDFB0811, 0xCDD02720);
	r1 = D(r1, s1_0_0, 0x02FE08EF, 0x291AF715, 0x0C1506F4, 0xF5040905);
	r2 = D(r2, s1_0_0, 0xDDE2EE1A, 0xDADD110F, 0xD5F704DA, 0x0BFE06F6);
	r3 = D(r3, s1_0_0, 0x0E06F509, 0x14031F09, 0xDD06F4D0, 0x03000718);
	r0 = D(r0, s1_0_1, 0x0C0B00D8, 0x08351EF9, 0x5C35E1FF, 0x14DA120E);
	r1 = D(r1, s1_0_1, 0x070AECFB, 0xF7DFFBD2, 0x3C06F607, 0xFAF703CE);
	r2 = D(r2, s1_0_1, 0x10F9ED0D, 0xF32B19D9, 0x000AE61C, 0x0E06FF14);
	r3 = D(r3, s1_0_1, 0xE6EDF2F1, 0xD424EBF1, 0x4B12EF0F, 0xF405FB40);
	r0 = D(r0, s1_0_2, 0xFE151501, 0x0ED0100B, 0x1CF11356, 0x12730BE8);
	r1 = D(r1, s1_0_2, 0x34B71918, 0x002A09E0, 0xC5E60FB5, 0x0F290016);
	r2 = D(r2, s1_0_2, 0x0601D7F6, 0x017FFFFE, 0x32A11212, 0x08BB1B0E);
	r3 = D(r3, s1_0_2, 0x0F23E509, 0xFF0AF906, 0xFB2DDE16, 0xFECB1317);
	r0 = D(r0, s1_1_0, 0xFE14E8DE, 0xEB0B1D07, 0xC50801EC, 0x4B11D7FC);
	r1 = D(r1, s1_1_0, 0xED02F8F8, 0x04FA1316, 0xF70AE609, 0xF904EE09);
	r2 = D(r2, s1_1_0, 0x24E50A13, 0x0810FDE4, 0xE6E9F72E, 0x24F10503);
	r3 = D(r3, s1_1_0, 0x2C04102B, 0xE20FE2F3, 0xE1FD0EFD, 0x0908F9F4);
	r0 = D(r0, s1_1_1, 0xFF0BFD1A, 0xEE071412, 0x34FF055C, 0xF417EE0E);
	r1 = D(r1, s1_1_1, 0xD514FFDD, 0xD95049D8, 0xD7FC04F5, 0x050C03E5);
	r2 = D(r2, s1_1_1, 0xC50CEFE0, 0x1B0AF2BF, 0x0FDD3EFB, 0xF6FB1516);
	r3 = D(r3, s1_1_1, 0xE10651D2, 0xE928B02B, 0x10121DC3, 0x2605DEFB);
	r0 = D(r0, s1_1_2, 0x0312F10D, 0x042C14C9, 0xF7EA16F0, 0x1481E805);
	r1 = D(r1, s1_1_2, 0x181F1F02, 0xF4D43212, 0xF6ED313E, 0xF6F907ED);
	r2 = D(r2, s1_1_2, 0xE6CE0435, 0xF526F510, 0xFC142011, 0xF2FAE7FA);
	r3 = D(r3, s1_1_2, 0xEC051AFB, 0x101B28EE, 0xFB480CE7, 0x0DC1C91F);
	r0 = D(r0, s1_2_0, 0xF2FE040F, 0xF410ECD8, 0xD3E89A32, 0xE8F1DEF6);
	r1 = D(r1, s1_2_0, 0x10FD0210, 0xFAF1E31B, 0x05110804, 0x0B071604);
	r2 = D(r2, s1_2_0, 0xFC0133F9, 0xECFBFE04, 0x30072B37, 0x08FDE513);
	r3 = D(r3, s1_2_0, 0xF8FC15F8, 0xFB0BF0E9, 0xC1F23A1E, 0xFE010FF6);
	r0 = D(r0, s1_2_1, 0xF2F800FC, 0xF513C50A, 0xF42BEC81, 0xE30CFBAA);
	r1 = D(r1, s1_2_1, 0xCCFBF210, 0x11053EEF, 0x36EF1F25, 0xFBFA0BF9);
	r2 = D(r2, s1_2_1, 0x1905FCFD, 0x34FCFDE8, 0x050F0FD4, 0x0705E6FF);
	r3 = D(r3, s1_2_1, 0xEC0D0B14, 0x1D14FC20, 0x220438DD, 0xE51008EF);
	r0 = D(r0, s1_2_2, 0xFD0AE501, 0x0A012BFF, 0xDF3D0C09, 0x0C4E09DF);
	r1 = D(r1, s1_2_2, 0x1CECEB09, 0x04042AF8, 0xF5D5FF1C, 0x05010D00);
	r2 = D(r2, s1_2_2, 0x08F9D3E2, 0x0B23C4DC, 0xF0D7D105, 0xFAF7020D);
	r3 = D(r3, s1_2_2, 0x0CEC2607, 0xFCF1ECEC, 0x02230CDC, 0xFE0EE100);
	f0 = vec4(r0) * 6.2000124e-05;
	f0 += vec4(8.299e-03, -2.547e-02, 6.903e-04, 6.541e-03);
	f0 = max(f0, vec4(0.0));
	imageStore(out_image, opos + ivec2(0, 0), f0);
	f1 = vec4(r1) * 6.2000124e-05;
	f1 += vec4(6.760e-03, -1.248e-02, 2.241e-02, 3.214e-01);
	f1 = max(f1, vec4(0.0));
	imageStore(out_image, opos + ivec2(1, 0), f1);
	f2 = vec4(r2) * 6.2000124e-05;
	f2 += vec4(-1.437e-02, 9.790e-03, -2.381e-02, -1.770e-02);
	f2 = max(f2, vec4(0.0));
	imageStore(out_image, opos + ivec2(0, 1), f2);
	f3 = vec4(r3) * 6.2000124e-05;
	f3 += vec4(2.661e-02, 7.743e-02, -1.190e-03, -7.312e-04);
	f3 = max(f3, vec4(0.0));
	imageStore(out_image, opos + ivec2(1, 1), f3);
}

//!DESC CuNNy-4x16-DS-conv2
//!HOOK LUMA
//!COMPUTE 16 16 8 8
//!BIND conv1
//!BIND LUMA
//!SAVE conv2
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h 2 *
//!COMPONENTS 4
//!WHEN OUTPUT.w LUMA.w / 1.3 > OUTPUT.h LUMA.h / 1.3 > *
#extension GL_EXT_spirv_intrinsics : require
spirv_instruction (extensions = ["SPV_KHR_integer_dot_product"], capabilities = [6019, 6018], id = 4450)
int dp4(int a, int b, spirv_literal int fmt);
#define D(r, s, a, b, c, d) r + ivec4(dp4(s, a, 0), dp4(s, b, 0), dp4(s, c, 0), dp4(s, d, 0))
shared int G[4][10][10];
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
			vec2 p;
			vec4 r, g, b, a;
			p = vec2(clamp(pos + ivec2(x - 1, y - 1), ivec2(0), sz) * ivec2(2, 2) + ivec2(1, 1)) * conv1_pt;
			r = conv1_gather(p, 0);
			g = conv1_gather(p, 1);
			b = conv1_gather(p, 2);
			a = conv1_gather(p, 3);
			vec4 v0 = vec4(r.w, g.w, b.w, a.w) * 1.0000000e+00;
			vec4 v1 = vec4(r.z, g.z, b.z, a.z) * 1.0000000e+00;
			vec4 v2 = vec4(r.x, g.x, b.x, a.x) * 1.0000000e+00;
			vec4 v3 = vec4(r.y, g.y, b.y, a.y) * 1.0000000e+00;
			G[0][ay][ax] = int(packSnorm4x8(v0));
			G[1][ay][ax] = int(packSnorm4x8(v1));
			G[2][ay][ax] = int(packSnorm4x8(v2));
			G[3][ay][ax] = int(packSnorm4x8(v3));
		}
	}
	barrier();
	int s0_0_0, s0_0_1, s0_0_2, s0_1_0, s0_1_1, s0_1_2, s0_2_0, s0_2_1, s0_2_2, s1_0_0, s1_0_1, s1_0_2, s1_1_0, s1_1_1, s1_1_2, s1_2_0, s1_2_1, s1_2_2;
	ivec4 r0, r1, r2, r3;
	vec4 f0, f1, f2, f3;
	r0 = ivec4(0); r1 = ivec4(0); r2 = ivec4(0); r3 = ivec4(0);
	s0_0_0 = G[0][xy.y+0][xy.x+0]; s0_0_1 = G[0][xy.y+0][xy.x+1];
	s0_0_2 = G[0][xy.y+0][xy.x+2]; s0_1_0 = G[0][xy.y+1][xy.x+0];
	s0_1_1 = G[0][xy.y+1][xy.x+1]; s0_1_2 = G[0][xy.y+1][xy.x+2];
	s0_2_0 = G[0][xy.y+2][xy.x+0]; s0_2_1 = G[0][xy.y+2][xy.x+1];
	s0_2_2 = G[0][xy.y+2][xy.x+2]; s1_0_0 = G[1][xy.y+0][xy.x+0];
	s1_0_1 = G[1][xy.y+0][xy.x+1]; s1_0_2 = G[1][xy.y+0][xy.x+2];
	s1_1_0 = G[1][xy.y+1][xy.x+0]; s1_1_1 = G[1][xy.y+1][xy.x+1];
	s1_1_2 = G[1][xy.y+1][xy.x+2]; s1_2_0 = G[1][xy.y+2][xy.x+0];
	s1_2_1 = G[1][xy.y+2][xy.x+1]; s1_2_2 = G[1][xy.y+2][xy.x+2];
	r0 = D(r0, s0_0_0, 0x0C29FCE4, 0x080B0DEE, 0x110B14F7, 0x110800FD);
	r1 = D(r1, s0_0_0, 0x27F3FBFC, 0x15071507, 0x08FD0700, 0x08270F00);
	r2 = D(r2, s0_0_0, 0x050404F2, 0x0204FE04, 0xFBFD0906, 0x22EFE714);
	r3 = D(r3, s0_0_0, 0x0F0B05EF, 0xFDF6FE08, 0xFFFC00FF, 0xF37F6C91);
	r0 = D(r0, s0_0_1, 0x1D421506, 0xEEE5FB0D, 0x03EB0615, 0x13FAE703);
	r1 = D(r1, s0_0_1, 0x30F10BF8, 0x01EB1016, 0x0F0BFEF7, 0xE6EDFE0E);
	r2 = D(r2, s0_0_1, 0x0F0D0DE9, 0xFE090201, 0x1A0E08F5, 0x3EF20616);
	r3 = D(r3, s0_0_1, 0x1202040B, 0xFEDDFB0D, 0x150A0CFB, 0x9C230F15);
	r0 = D(r0, s0_0_2, 0x0B31EF01, 0x0ECCF60C, 0x19E1F0FE, 0x1DEFFE0A);
	r1 = D(r1, s0_0_2, 0x1932ED07, 0x2E7FF20C, 0x0EFFFF04, 0xD77F1BFE);
	r2 = D(r2, s0_0_2, 0x122007F7, 0x0608FEF9, 0x071503F5, 0x2A0EFCE7);
	r3 = D(r3, s0_0_2, 0x0DF3F315, 0xF3EC07EB, 0x0508F802, 0x17F70CE7);
	r0 = D(r0, s0_1_0, 0x13F3F8F1, 0xF812F8EC, 0x1600FBFE, 0x070A1FE4);
	r1 = D(r1, s0_1_0, 0x2707F704, 0xFE03FC1F, 0x010704FB, 0x07FB0C18);
	r2 = D(r2, s0_1_0, 0xFB0203F4, 0x0001FCF7, 0x0181F003, 0x14202416);
	r3 = D(r3, s0_1_0, 0x13FA0FF8, 0xF8040812, 0x040616FD, 0x1B5929AE);
	r0 = D(r0, s0_1_1, 0xF9D916DF, 0x0BF2EF29, 0x1410FA0F, 0x02EAD5DD);
	r1 = D(r1, s0_1_1, 0x500F5FFD, 0x2311093B, 0x0F0AED27, 0x17FDF8F8);
	r2 = D(r2, s0_1_1, 0x240B09BC, 0xFC12F41E, 0x24BF0608, 0x26FB43CE);
	r3 = D(r3, s0_1_1, 0x130210DD, 0xEA041930, 0x0512E6EA, 0x0B24BF1B);
	r0 = D(r0, s0_1_2, 0x0D1BF50D, 0x04F71A17, 0x1107BBEA, 0x0F09FE13);
	r1 = D(r1, s0_1_2, 0x27050A00, 0x123F0405, 0x0715FAF7, 0x8130F007);
	r2 = D(r2, s0_1_2, 0x02F6FFEC, 0x050200F8, 0x21DE011E, 0x2B1CEA04);
	r3 = D(r3, s0_1_2, 0x010BF404, 0xF4F1010B, 0x0A131000, 0x1AF6ECE8);
	r0 = D(r0, s0_2_0, 0xFCFCE707, 0x070CF12D, 0x090A10F0, 0xFF010202);
	r1 = D(r1, s0_2_0, 0x100F1B08, 0x0E0118F2, 0x00FBFEFA, 0x13F51CE8);
	r2 = D(r2, s0_2_0, 0x00FF16E1, 0x03051405, 0xFF0DFAF4, 0xDF0A09EE);
	r3 = D(r3, s0_2_0, 0x1404EC06, 0xFC0203F9, 0x0A0211FA, 0x06110B12);
	r0 = D(r0, s0_2_1, 0x02080DF8, 0x180A2F0B, 0x0309ECF2, 0x0AFE0FFB);
	r1 = D(r1, s0_2_1, 0x0D0FE704, 0x1400FB1B, 0x0606FEFB, 0xDE0A1D05);
	r2 = D(r2, s0_2_1, 0x16FA1281, 0x0E0A100C, 0xFCEF240F, 0xF812031C);
	r3 = D(r3, s0_2_1, 0x0407F518, 0xFB00060B, 0x0B090B16, 0x03F5080A);
	r0 = D(r0, s0_2_2, 0x010702FD, 0xF6E8E3BF, 0x0806F819, 0x21F2020C);
	r1 = D(r1, s0_2_2, 0x27E0FC0E, 0x0E0407FA, 0x0AFFFDFD, 0xF1008181);
	r2 = D(r2, s0_2_2, 0x120E27F0, 0x00FFFD05, 0x22DCEEEB, 0x0E040813);
	r3 = D(r3, s0_2_2, 0x05FEFAFD, 0xFEF90AEA, 0x0904F813, 0x0206E712);
	r0 = D(r0, s1_0_0, 0x013907E2, 0x00FFF817, 0xF2E9042B, 0xF3EF04E4);
	r1 = D(r1, s1_0_0, 0xF31FFCD8, 0xAD00080A, 0xF01C0707, 0xE6EEFE30);
	r2 = D(r2, s1_0_0, 0x06F90805, 0xFD03FF0C, 0xFC1213FD, 0xFE30F1BA);
	r3 = D(r3, s1_0_0, 0xFC05FD0F, 0x02F40D13, 0xF7060213, 0xFF81F9A1);
	r0 = D(r0, s1_0_1, 0xF2F931E2, 0x09EFF40F, 0x0200F31E, 0xFF16FC0B);
	r1 = D(r1, s1_0_1, 0x0700F5DC, 0x820D1A03, 0x0A0601FB, 0x0AFBDE2D);
	r2 = D(r2, s1_0_1, 0x010708FF, 0x07FAF7F5, 0xFC0CEF03, 0xFE23DCE7);
	r3 = D(r3, s1_0_1, 0xF2080A01, 0x110A0FF2, 0x03FBFE08, 0x0D05C62A);
	r0 = D(r0, s1_0_2, 0xF0FA1DF9, 0x16FCF8F8, 0x010ED2F8, 0x0AFE14EF);
	r1 = D(r1, s1_0_2, 0x11F5FB0A, 0xB0E10BF3, 0xFF13F800, 0xDFC7EAEB);
	r2 = D(r2, s1_0_2, 0x02F407F4, 0xF4FDFA05, 0xFDE7F3FE, 0x0504EBF7);
	r3 = D(r3, s1_0_2, 0x0901F9FE, 0xFDF9F607, 0x0505F803, 0xF4FD0D09);
	r0 = D(r0, s1_1_0, 0x040B19FA, 0x031AFD01, 0xFC1B06FC, 0xFE080F10);
	r1 = D(r1, s1_1_0, 0x00F102DB, 0xBD0D0CBD, 0xFA260FE9, 0xF920F6E4);
	r2 = D(r2, s1_1_0, 0xEEF70A07, 0x040A0AFB, 0x0F22EF0D, 0x12E80411);
	r3 = D(r3, s1_1_0, 0xF0F0E722, 0x06EDF9EF, 0xF403001D, 0x0E9B0505);
	r0 = D(r0, s1_1_1, 0xE4040BFB, 0xF219E113, 0x0709BDF6, 0x0035EE39);
	r1 = D(r1, s1_1_1, 0xF6E4BB2F, 0x81011F0C, 0x160F180F, 0x50DA0BDA);
	r2 = D(r2, s1_1_1, 0xDC09FD04, 0x0CEFEA06, 0xF904FC00, 0xE9DEF10D);
	r3 = D(r3, s1_1_1, 0x0A09CE0B, 0x16EEF8EC, 0x1DFA0002, 0x09FB7F04);
	r0 = D(r0, s1_1_2, 0x0B00EB0F, 0x0B18ECFD, 0x0112EBFE, 0xFBF5E910);
	r1 = D(r1, s1_1_2, 0xFB0CF70C, 0x81F15A03, 0xFD090D01, 0x05285325);
	r2 = D(r2, s1_1_2, 0xE5F30E03, 0x15FC0B06, 0x0714F710, 0xEDF1B70A);
	r3 = D(r3, s1_1_2, 0x060CE601, 0x09F4FFFD, 0xF50103FE, 0xEBEE020D);
	r0 = D(r0, s1_2_0, 0xF71DF5FC, 0x12DAE0C0, 0x1810EF02, 0x020B080F);
	r1 = D(r1, s1_2_0, 0x14E70421, 0x0EFC1909, 0x0E040523, 0xC4E31AF8);
	r2 = D(r2, s1_2_0, 0x02021616, 0xFDF0FF04, 0xFFEDEFB8, 0x04EA190B);
	r3 = D(r3, s1_2_0, 0x110FF3FC, 0x03F4FFF2, 0x01EC010C, 0xF004F810);
	r0 = D(r0, s1_2_1, 0xF7020DFB, 0xD20B8100, 0xEC0ACC06, 0x01161119);
	r1 = D(r1, s1_2_1, 0x0E09A226, 0xE5F11A09, 0xFF17F122, 0x38EFE833);
	r2 = D(r2, s1_2_1, 0xF70005F9, 0x0CFBEFE7, 0xF80B8119, 0x0EEF5305);
	r3 = D(r3, s1_2_1, 0x04FFEF02, 0xF6F811E8, 0x0CFEEF06, 0x0B28EF0B);
	r0 = D(r0, s1_2_2, 0x0B0E0A00, 0x16F7C710, 0xFD0AC8FE, 0xF4F8110C);
	r1 = D(r1, s1_2_2, 0xEC27DFFA, 0xE90312FC, 0xEC10F902, 0x8C81BC3D);
	r2 = D(r2, s1_2_2, 0xFCFB0EFF, 0xF5FF00FE, 0xFB19D70D, 0xFD220F08);
	r3 = D(r3, s1_2_2, 0xF70BF106, 0x00EE02FD, 0xFEFAFC02, 0xFD15F006);
	s0_0_0 = G[2][xy.y+0][xy.x+0]; s0_0_1 = G[2][xy.y+0][xy.x+1];
	s0_0_2 = G[2][xy.y+0][xy.x+2]; s0_1_0 = G[2][xy.y+1][xy.x+0];
	s0_1_1 = G[2][xy.y+1][xy.x+1]; s0_1_2 = G[2][xy.y+1][xy.x+2];
	s0_2_0 = G[2][xy.y+2][xy.x+0]; s0_2_1 = G[2][xy.y+2][xy.x+1];
	s0_2_2 = G[2][xy.y+2][xy.x+2]; s1_0_0 = G[3][xy.y+0][xy.x+0];
	s1_0_1 = G[3][xy.y+0][xy.x+1]; s1_0_2 = G[3][xy.y+0][xy.x+2];
	s1_1_0 = G[3][xy.y+1][xy.x+0]; s1_1_1 = G[3][xy.y+1][xy.x+1];
	s1_1_2 = G[3][xy.y+1][xy.x+2]; s1_2_0 = G[3][xy.y+2][xy.x+0];
	s1_2_1 = G[3][xy.y+2][xy.x+1]; s1_2_2 = G[3][xy.y+2][xy.x+2];
	r0 = D(r0, s0_0_0, 0x42F80615, 0x0426F9E6, 0x1F1F0FED, 0xFA02F4E5);
	r1 = D(r1, s0_0_0, 0xF8EFE90D, 0xF21221FE, 0xEB1702FC, 0x020300E8);
	r2 = D(r2, s0_0_0, 0xF8FB0FFA, 0xF80D0500, 0xF111FCD2, 0x02FEC25F);
	r3 = D(r3, s0_0_0, 0x25050A1D, 0xF2E8ED05, 0x0304FFF1, 0x811181C4);
	r0 = D(r0, s0_0_1, 0x2FD80F00, 0xE51CEE20, 0x013D19F2, 0x0AB9E3DC);
	r1 = D(r1, s0_0_1, 0x0C1ACB24, 0xDEF22AB5, 0xEE0CF717, 0xF7E6F9EE);
	r2 = D(r2, s0_0_1, 0x070407F6, 0xE30705FD, 0xF7FCFA11, 0xB2CCBC59);
	r3 = D(r3, s0_0_1, 0xF9190D0F, 0xE405EB05, 0x0808FCFF, 0xB2DF50F7);
	r0 = D(r0, s0_0_2, 0xFC00040A, 0xEC1BEED9, 0x0B2B2A10, 0xD404DA2A);
	r1 = D(r1, s0_0_2, 0xEFF1DF01, 0xD41605DF, 0x01FE0403, 0xE12717C4);
	r2 = D(r2, s0_0_2, 0xF905020A, 0xFEFDFC0A, 0x11F7F2FC, 0x02EB1420);
	r3 = D(r3, s0_0_2, 0x060611EC, 0x13DCFD07, 0xFF02F703, 0x1008E5F2);
	r0 = D(r0, s0_1_0, 0xD3061302, 0x1812F7DB, 0xED241AF4, 0xF9EB060D);
	r1 = D(r1, s0_1_0, 0x08B1AF04, 0x1401F407, 0x03F90715, 0x0803F6E4);
	r2 = D(r2, s0_1_0, 0xF60B09F4, 0xE9150102, 0xDADDF6D6, 0xCDECE2E7);
	r3 = D(r3, s0_1_0, 0x1EE61B17, 0x02EBFF0F, 0x1BFF04FF, 0xFFF5F108);
	r0 = D(r0, s0_1_1, 0xDD410C1A, 0xB008DECD, 0x234F1903, 0xF8E8C3FE);
	r1 = D(r1, s0_1_1, 0xA2F881F1, 0x21F7191F, 0x04E504F2, 0x5F060ACD);
	r2 = D(r2, s0_1_1, 0xFAFEEEFA, 0x4AF5FEE1, 0x8105D107, 0x8EEE0D3E);
	r3 = D(r3, s0_1_1, 0xD23A0C2B, 0x06FEE8F0, 0x03E70CE3, 0xDB112305);
	r0 = D(r0, s0_1_2, 0x07040528, 0xC4450BFD, 0xFA2A1312, 0xEA00E60A);
	r1 = D(r1, s0_1_2, 0xFF15E035, 0x120B0BDE, 0xFAFCFC14, 0xAC0A9EA7);
	r2 = D(r2, s0_1_2, 0x15F915EF, 0x0302FDFF, 0xF6000311, 0x1C1C1234);
	r3 = D(r3, s0_1_2, 0x13040910, 0xF901FBDD, 0x0503FD05, 0x0DF8F2FB);
	r0 = D(r0, s0_2_0, 0xEDEC0E1F, 0x154409F4, 0xF11E0FFF, 0x06F4FE0F);
	r1 = D(r1, s0_2_0, 0x1CE8DFFA, 0x0B0BF8F9, 0xFA120505, 0xE425F9E2);
	r2 = D(r2, s0_2_0, 0x05051103, 0xFB0AFEFB, 0x1503E412, 0x28E509F4);
	r3 = D(r3, s0_2_0, 0x0406FD08, 0x03FDF9FE, 0x0211F8FD, 0xE0210004);
	r0 = D(r0, s0_2_1, 0x03110706, 0x261CA930, 0xFD2110F0, 0x06F8FEF0);
	r1 = D(r1, s0_2_1, 0x111F8FC0, 0x070016EC, 0x11FD0BF7, 0x40DF61ED);
	r2 = D(r2, s0_2_1, 0xA9D213DA, 0xFC13FC06, 0x0D3AC915, 0x151C0C1B);
	r3 = D(r3, s0_2_1, 0x0F0F070C, 0xFC11FCFF, 0x0D0A0404, 0xFD1300F9);
	r0 = D(r0, s0_2_2, 0x040B0412, 0x1CF4DEE6, 0x050A0D03, 0x09FCEBFA);
	r1 = D(r1, s0_2_2, 0x2EFE02EC, 0x10FDF8E4, 0xFD0AFD0A, 0x399CEADF);
	r2 = D(r2, s0_2_2, 0x12FB0906, 0x01FDFFFC, 0x0505F2F8, 0x15071708);
	r3 = D(r3, s0_2_2, 0xF8080309, 0x07F9F9F4, 0xFB01FD01, 0xF80CFF0D);
	r0 = D(r0, s1_0_0, 0x01DEFC0F, 0xF4251316, 0x0AF6F416, 0x081CF7F4);
	r1 = D(r1, s1_0_0, 0xF508F1FE, 0x01110911, 0x05FDFFF3, 0xFCF8FC12);
	r2 = D(r2, s1_0_0, 0xFA06FBFB, 0x0C050A03, 0x152110E8, 0xC0DE0C25);
	r3 = D(r3, s1_0_0, 0xE1EF0211, 0x001204DD, 0x02040CFE, 0x81818181);
	r0 = D(r0, s1_0_1, 0xE9C0ED2E, 0x06FB07DD, 0xFFE8F408, 0xF93C2929);
	r1 = D(r1, s1_0_1, 0xFF1E102C, 0xFF0EFEF3, 0x01F6EEF0, 0xFB2525EE);
	r2 = D(r2, s1_0_1, 0x030F1105, 0xF70603F8, 0xF903EFE0, 0xFC10FB04);
	r3 = D(r3, s1_0_1, 0x09E7F919, 0x17200AC0, 0xFC03FDFF, 0xC6EFD9E1);
	r0 = D(r0, s1_0_2, 0x05F1ED0C, 0x1903F8FD, 0xF3E3E939, 0xF40F07E0);
	r1 = D(r1, s1_0_2, 0x0E17F2EC, 0xF20EFBDF, 0xFD06F404, 0x11132112);
	r2 = D(r2, s1_0_2, 0xFE1002FC, 0xF9FE0205, 0x0712060B, 0xFC10F4FC);
	r3 = D(r3, s1_0_2, 0x0BFCF319, 0xFA020926, 0xFBFF0406, 0xF6FF0605);
	r0 = D(r0, s1_1_0, 0xDBE32203, 0x1807150C, 0x04EA09F2, 0x0F08EDF8);
	r1 = D(r1, s1_1_0, 0xA6E4FEE9, 0x0920F319, 0x1401F9F1, 0x2FFEF80C);
	r2 = D(r2, s1_1_0, 0x0600F3FD, 0x21FEFCEB, 0x5F3B310E, 0x810A04E2);
	r3 = D(r3, s1_1_0, 0x81FB2931, 0x06FFFE08, 0xFF09FCFA, 0x2AA9261B);
	r0 = D(r0, s1_1_1, 0x17CF0023, 0xEB08FB01, 0xC8C9FFFA, 0x19160D0A);
	r1 = D(r1, s1_1_1, 0xAF06D7B5, 0xD8F33900, 0xF3EAF703, 0x6645E411);
	r2 = D(r2, s1_1_1, 0x1AEAFA03, 0xFA011708, 0xDC2DF4D3, 0xD1D1D882);
	r3 = D(r3, s1_1_1, 0xD4DAEC3E, 0x072CF31D, 0x1A0DFD19, 0x2609EC20);
	r0 = D(r0, s1_1_2, 0xF0E900E6, 0x18100B3B, 0xD1C026FA, 0x051C47CF);
	r1 = D(r1, s1_1_2, 0xEE2221F4, 0xEE0EF114, 0xF70AE00C, 0x1EF9C6DB);
	r2 = D(r2, s1_1_2, 0xFF08FFE7, 0x05FA13F3, 0x0D00F91D, 0xECF009E9);
	r3 = D(r3, s1_1_2, 0xFDEEEA1B, 0x1010E80D, 0xFF01F3FC, 0x131440E6);
	r0 = D(r0, s1_2_0, 0xE3E20D0B, 0x1F1603F8, 0xECE6010B, 0x1010FAFF);
	r1 = D(r1, s1_2_0, 0x070AFA05, 0xFF0FFEED, 0x0E0108F4, 0x1B09E3D4);
	r2 = D(r2, s1_2_0, 0x09FDF4F3, 0x1A070002, 0xBF1BFF07, 0xFAFC09FA);
	r3 = D(r3, s1_2_0, 0xCCE616F7, 0xFD0B0904, 0x0609FCFA, 0xEDFE1DF7);
	r0 = D(r0, s1_2_1, 0xF9EE0B0F, 0xBE3BECF1, 0xF0E8F000, 0x0F2809F3);
	r1 = D(r1, s1_2_1, 0xCA0EEE0B, 0x0F0D020D, 0x1004FF11, 0xE0C01B19);
	r2 = D(r2, s1_2_1, 0x301E0B20, 0x190ADF06, 0x810014BB, 0xF20707DA);
	r3 = D(r3, s1_2_1, 0xD7DE09EE, 0x190AF9F0, 0x0803E5FF, 0x1015F917);
	r0 = D(r0, s1_2_2, 0xF1ECF8F0, 0xF5182E07, 0xF6E5F50F, 0xFE14F5F7);
	r1 = D(r1, s1_2_2, 0xFE1A10DF, 0xF415E406, 0xF400E90F, 0xDD171B1F);
	r2 = D(r2, s1_2_2, 0x0A0D1905, 0x07FFF808, 0xF8001DF6, 0xD6F2C6F9);
	r3 = D(r3, s1_2_2, 0xEAE80CF4, 0x1415FFFF, 0x02FDFDF7, 0xEBF51F08);
	f0 = vec4(r0) * 6.2000124e-05;
	f0 += vec4(1.333e-01, -1.265e-01, 2.536e-03, 1.094e-02);
	f0 = max(f0, vec4(0.0));
	imageStore(out_image, opos + ivec2(0, 0), f0);
	f1 = vec4(r1) * 6.2000124e-05;
	f1 += vec4(6.674e-02, -2.920e-01, -4.286e-03, -1.788e-02);
	f1 = max(f1, vec4(0.0));
	imageStore(out_image, opos + ivec2(1, 0), f1);
	f2 = vec4(r2) * 6.2000124e-05;
	f2 += vec4(1.422e-01, -6.373e-02, 5.800e-02, 1.247e-01);
	f2 = max(f2, vec4(0.0));
	imageStore(out_image, opos + ivec2(0, 1), f2);
	f3 = vec4(r3) * 6.2000124e-05;
	f3 += vec4(1.091e-02, -8.284e-02, -2.542e-04, 1.450e-02);
	f3 = max(f3, vec4(0.0));
	imageStore(out_image, opos + ivec2(1, 1), f3);
}

//!DESC CuNNy-4x16-DS-conv3
//!HOOK LUMA
//!COMPUTE 16 16 8 8
//!BIND conv2
//!BIND LUMA
//!SAVE conv3
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h 2 *
//!COMPONENTS 4
//!WHEN OUTPUT.w LUMA.w / 1.3 > OUTPUT.h LUMA.h / 1.3 > *
#extension GL_EXT_spirv_intrinsics : require
spirv_instruction (extensions = ["SPV_KHR_integer_dot_product"], capabilities = [6019, 6018], id = 4450)
int dp4(int a, int b, spirv_literal int fmt);
#define D(r, s, a, b, c, d) r + ivec4(dp4(s, a, 0), dp4(s, b, 0), dp4(s, c, 0), dp4(s, d, 0))
shared int G[4][10][10];
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
			vec2 p;
			vec4 r, g, b, a;
			p = vec2(clamp(pos + ivec2(x - 1, y - 1), ivec2(0), sz) * ivec2(2, 2) + ivec2(1, 1)) * conv2_pt;
			r = conv2_gather(p, 0);
			g = conv2_gather(p, 1);
			b = conv2_gather(p, 2);
			a = conv2_gather(p, 3);
			vec4 v0 = vec4(r.w, g.w, b.w, a.w) * 1.0000000e+00;
			vec4 v1 = vec4(r.z, g.z, b.z, a.z) * 1.0000000e+00;
			vec4 v2 = vec4(r.x, g.x, b.x, a.x) * 1.0000000e+00;
			vec4 v3 = vec4(r.y, g.y, b.y, a.y) * 1.0000000e+00;
			G[0][ay][ax] = int(packSnorm4x8(v0));
			G[1][ay][ax] = int(packSnorm4x8(v1));
			G[2][ay][ax] = int(packSnorm4x8(v2));
			G[3][ay][ax] = int(packSnorm4x8(v3));
		}
	}
	barrier();
	int s0_0_0, s0_0_1, s0_0_2, s0_1_0, s0_1_1, s0_1_2, s0_2_0, s0_2_1, s0_2_2, s1_0_0, s1_0_1, s1_0_2, s1_1_0, s1_1_1, s1_1_2, s1_2_0, s1_2_1, s1_2_2;
	ivec4 r0, r1, r2, r3;
	vec4 f0, f1, f2, f3;
	r0 = ivec4(0); r1 = ivec4(0); r2 = ivec4(0); r3 = ivec4(0);
	s0_0_0 = G[0][xy.y+0][xy.x+0]; s0_0_1 = G[0][xy.y+0][xy.x+1];
	s0_0_2 = G[0][xy.y+0][xy.x+2]; s0_1_0 = G[0][xy.y+1][xy.x+0];
	s0_1_1 = G[0][xy.y+1][xy.x+1]; s0_1_2 = G[0][xy.y+1][xy.x+2];
	s0_2_0 = G[0][xy.y+2][xy.x+0]; s0_2_1 = G[0][xy.y+2][xy.x+1];
	s0_2_2 = G[0][xy.y+2][xy.x+2]; s1_0_0 = G[1][xy.y+0][xy.x+0];
	s1_0_1 = G[1][xy.y+0][xy.x+1]; s1_0_2 = G[1][xy.y+0][xy.x+2];
	s1_1_0 = G[1][xy.y+1][xy.x+0]; s1_1_1 = G[1][xy.y+1][xy.x+1];
	s1_1_2 = G[1][xy.y+1][xy.x+2]; s1_2_0 = G[1][xy.y+2][xy.x+0];
	s1_2_1 = G[1][xy.y+2][xy.x+1]; s1_2_2 = G[1][xy.y+2][xy.x+2];
	r0 = D(r0, s0_0_0, 0x07FE03FD, 0xF2F9F801, 0xF7010600, 0xFEFFFD00);
	r1 = D(r1, s0_0_0, 0xFAFD1C07, 0xFC070D02, 0xE6F507FD, 0xF9FD0103);
	r2 = D(r2, s0_0_0, 0x08FB0100, 0x04FB0803, 0x06FD06F8, 0xD103FFF6);
	r3 = D(r3, s0_0_0, 0x03FD0F03, 0xFBFF02FD, 0x050008FF, 0xF308F703);
	r0 = D(r0, s0_0_1, 0xF900E104, 0x03FBEDF7, 0xFB050BFF, 0x00FDFF02);
	r1 = D(r1, s0_0_1, 0x0F0500F7, 0xF9FF15FC, 0xC50ED60D, 0xFAF1E0F9);
	r2 = D(r2, s0_0_1, 0x06001300, 0x1AF6DAF5, 0x0A071006, 0xD6D1CBF4);
	r3 = D(r3, s0_0_1, 0x0C0008F1, 0xFC000D00, 0x0905FFEF, 0x02FAE8FA);
	r0 = D(r0, s0_0_2, 0xFEFBF801, 0xFD0F060B, 0xF90408FF, 0x01FAE8FD);
	r1 = D(r1, s0_0_2, 0x0D2A0A05, 0x000115F5, 0x03FE0DEF, 0x090E00FA);
	r2 = D(r2, s0_0_2, 0x000EFF04, 0x0710F8FA, 0x07100C06, 0xF2200FEA);
	r3 = D(r3, s0_0_2, 0x02EB03F2, 0xFDFE0CFF, 0x03F70100, 0x00FC0DFD);
	r0 = D(r0, s0_1_0, 0xF3070000, 0xFFFFFFFD, 0xFAFF01FD, 0x00FE0804);
	r1 = D(r1, s0_1_0, 0x0209F9FF, 0xFAF70907, 0xF708FDF8, 0x04F3FD07);
	r2 = D(r2, s0_1_0, 0x04FE0AFE, 0x0204FBFB, 0xFAEB0403, 0xE305FD08);
	r3 = D(r3, s0_1_0, 0x05F800FB, 0xFB060502, 0x07DD100B, 0xE405000D);
	r0 = D(r0, s0_1_1, 0xF2F6ECFC, 0x03FD0BEA, 0xFF01FE04, 0xFFF10609);
	r1 = D(r1, s0_1_1, 0xF7DFF7EF, 0x0A0917F1, 0xE6CD07DE, 0x10EBF8EE);
	r2 = D(r2, s0_1_1, 0x2203000A, 0x0EF6020B, 0x03D2D2EB, 0x20EE08BD);
	r3 = D(r3, s0_1_1, 0xE8F514FA, 0xF3040C02, 0xFC1C02E4, 0xFDF4F9EC);
	r0 = D(r0, s0_1_2, 0xFE0204F8, 0x0207FB10, 0xFFF409FA, 0xFEFB07EB);
	r1 = D(r1, s0_1_2, 0xF1C808F4, 0xEC150105, 0xFBF11BF0, 0xF4EC02F7);
	r2 = D(r2, s0_1_2, 0xEC2D022A, 0xFCDDE4E0, 0x01E90502, 0xEFF7F407);
	r3 = D(r3, s0_1_2, 0x09F3FDEF, 0x0AEE18EF, 0x0AEDFEF3, 0xFC12FCFD);
	r0 = D(r0, s0_2_0, 0xEC0801FE, 0x01ED03FB, 0x02010103, 0xF80BFD04);
	r1 = D(r1, s0_2_0, 0xBEE00814, 0xFF1403FB, 0x04030F08, 0x11F4FFFC);
	r2 = D(r2, s0_2_0, 0xF1F70005, 0x0A1B01FA, 0xFB03FEFD, 0x04E0F426);
	r3 = D(r3, s0_2_0, 0x0208FF08, 0x06F90104, 0xFCFDFF02, 0xEE0B0405);
	r0 = D(r0, s0_2_1, 0xEDFC03E0, 0x0410FF08, 0xF6FC0A0F, 0xF7FEFFF5);
	r1 = D(r1, s0_2_1, 0xBC020EF7, 0x030DFBEA, 0xFC110922, 0x0206041A);
	r2 = D(r2, s0_2_1, 0x19FEFDE3, 0x00E6FF01, 0xCBD700FC, 0xB91803CA);
	r3 = D(r3, s0_2_1, 0x1117F905, 0x07060722, 0xF2F4F7E1, 0xDF06FAE3);
	r0 = D(r0, s0_2_2, 0xE8FFFE00, 0xF9F9FC06, 0x040B0108, 0xFBFD0102);
	r1 = D(r1, s0_2_2, 0xD62001CD, 0xFFF7FFF4, 0x1111F5FF, 0x0706040F);
	r2 = D(r2, s0_2_2, 0x00E209F1, 0x1610060A, 0x15FE03F8, 0xF3000F0F);
	r3 = D(r3, s0_2_2, 0x0A0600F7, 0x02060408, 0x0B0D03FE, 0xF4F3030A);
	r0 = D(r0, s1_0_0, 0x0701FFFA, 0x070113F4, 0x0E080008, 0x0A010A03);
	r1 = D(r1, s1_0_0, 0x0814F806, 0x03EDF80B, 0x3FFEFC07, 0x10F20BEB);
	r2 = D(r2, s1_0_0, 0x0707E815, 0xF7140A06, 0x06F205F0, 0xF716151E);
	r3 = D(r3, s1_0_0, 0xFDFF0B12, 0x0FF602F9, 0x1801F914, 0x0DF6FCF8);
	r0 = D(r0, s1_0_1, 0x09FA08F1, 0xF50A16FB, 0xFB010B04, 0x1100160A);
	r1 = D(r1, s1_0_1, 0x042510D7, 0x11FAF41F, 0x122022FA, 0x0F090FF8);
	r2 = D(r2, s1_0_1, 0xE105F512, 0x10E50BE0, 0xED22FE03, 0x2AD7FEE1);
	r3 = D(r3, s1_0_1, 0x12FE001A, 0x0404000C, 0xF5FCF608, 0x05EFFEE2);
	r0 = D(r0, s1_0_2, 0x06F703EF, 0xFBFCFD03, 0x03000505, 0x03F919F3);
	r1 = D(r1, s1_0_2, 0x03070FEF, 0x02FA000A, 0x08E001F6, 0x02070008);
	r2 = D(r2, s1_0_2, 0xF300EA13, 0x02120DF6, 0xFF07F104, 0xFD402BD5);
	r3 = D(r3, s1_0_2, 0x07FC08FD, 0x09FE0201, 0x0AFE06F5, 0xFD05FFF9);
	r0 = D(r0, s1_1_0, 0x0D0206E7, 0x081C0AF7, 0xFDFB14FF, 0x02FC16FB);
	r1 = D(r1, s1_1_0, 0x1CE51DFA, 0xFA010A0D, 0x1B091C0A, 0x0911FCFB);
	r2 = D(r2, s1_1_0, 0x06FEFB0A, 0xFAFF0A0A, 0x1FF011FF, 0x0F2809F7);
	r3 = D(r3, s1_1_0, 0xF8020D0D, 0xF7F8F602, 0x210F210F, 0x0CEBFFD2);
	r0 = D(r0, s1_1_1, 0x0AD602F4, 0xEAF70D00, 0x0EFB3004, 0x17084804);
	r1 = D(r1, s1_1_1, 0x16DED804, 0xE707420A, 0x07E492E2, 0x10E8FADA);
	r2 = D(r2, s1_1_1, 0xFD1C3F23, 0x1BE4A4E6, 0x06EDF1EC, 0x06E5DCE5);
	r3 = D(r3, s1_1_1, 0x0AF21D0C, 0x0721E70E, 0x001E1EF4, 0x0627F4FF);
	r0 = D(r0, s1_1_2, 0xFC0913E8, 0x02F8F206, 0x00FE08F5, 0x020C2AEC);
	r1 = D(r1, s1_1_2, 0xFFF7F12F, 0xFB0A0806, 0x04F1F0E7, 0xFE0F15FF);
	r2 = D(r2, s1_1_2, 0x05FCFC0B, 0xF90F0D0D, 0x09F00FF3, 0xE70C16D6);
	r3 = D(r3, s1_1_2, 0xFC0CE51D, 0x00F9FD07, 0xFDF6FE00, 0xFC1C0CF2);
	r0 = D(r0, s1_2_0, 0x08001002, 0x00020F03, 0x00FA07F7, 0x00010608);
	r1 = D(r1, s1_2_0, 0x25DFFA0E, 0x00FD0405, 0x14F803F9, 0x01FB0605);
	r2 = D(r2, s1_2_0, 0x1504F206, 0xF702FFF6, 0x06F2120A, 0x0B27D3C1);
	r3 = D(r3, s1_2_0, 0xFB02FFF7, 0xFBF7F602, 0x080613FC, 0x03F91301);
	r0 = D(r0, s1_2_1, 0xFF1111F4, 0xF8040AF2, 0xFEFA0AED, 0x03FF1109);
	r1 = D(r1, s1_2_1, 0xFBC806E3, 0xFAFA0506, 0xF8F90AE2, 0x00E705F5);
	r2 = D(r2, s1_2_1, 0x07EC030E, 0x0DFA1D0F, 0x06011409, 0xF31C28ED);
	r3 = D(r3, s1_2_1, 0x0400FE08, 0x04F2EAFC, 0x051E2612, 0xF3240E00);
	r0 = D(r0, s1_2_2, 0xFE060D00, 0x03F20606, 0x02FB07F4, 0xFC131DFE);
	r1 = D(r1, s1_2_2, 0xFDF017F5, 0xFFFB0608, 0x05070501, 0xFFFAFCEE);
	r2 = D(r2, s1_2_2, 0x00F20C18, 0xFCF205DC, 0xFC03F5ED, 0x08E8DA0A);
	r3 = D(r3, s1_2_2, 0xFEF9FD11, 0xFFFCF1FC, 0xFDFDFF03, 0x07F2F909);
	s0_0_0 = G[2][xy.y+0][xy.x+0]; s0_0_1 = G[2][xy.y+0][xy.x+1];
	s0_0_2 = G[2][xy.y+0][xy.x+2]; s0_1_0 = G[2][xy.y+1][xy.x+0];
	s0_1_1 = G[2][xy.y+1][xy.x+1]; s0_1_2 = G[2][xy.y+1][xy.x+2];
	s0_2_0 = G[2][xy.y+2][xy.x+0]; s0_2_1 = G[2][xy.y+2][xy.x+1];
	s0_2_2 = G[2][xy.y+2][xy.x+2]; s1_0_0 = G[3][xy.y+0][xy.x+0];
	s1_0_1 = G[3][xy.y+0][xy.x+1]; s1_0_2 = G[3][xy.y+0][xy.x+2];
	s1_1_0 = G[3][xy.y+1][xy.x+0]; s1_1_1 = G[3][xy.y+1][xy.x+1];
	s1_1_2 = G[3][xy.y+1][xy.x+2]; s1_2_0 = G[3][xy.y+2][xy.x+0];
	s1_2_1 = G[3][xy.y+2][xy.x+1]; s1_2_2 = G[3][xy.y+2][xy.x+2];
	r0 = D(r0, s0_0_0, 0x00FDFD04, 0xFDF30820, 0x0405FDF5, 0xFD0600F4);
	r1 = D(r1, s0_0_0, 0x0012F8FF, 0x021601FD, 0x170716F4, 0x00FF080A);
	r2 = D(r2, s0_0_0, 0xFD05F8F7, 0x0103F108, 0xFEED1008, 0xEA05F106);
	r3 = D(r3, s0_0_0, 0xF609FAF6, 0x09020D0A, 0xF813F4F6, 0x0803F90A);
	r0 = D(r0, s0_0_1, 0x0612F306, 0x06E5FA2C, 0xFAED02F9, 0xEEF9FFEE);
	r1 = D(r1, s0_0_1, 0xFCF80122, 0xF31315D8, 0xDA0019A0, 0xE8FF15D4);
	r2 = D(r2, s0_0_1, 0xF106EE2D, 0xF6EC25FF, 0x04E6FE1E, 0xE220E8BC);
	r3 = D(r3, s0_0_1, 0xF8FBF4BC, 0x0D0808F1, 0xF6FF03CC, 0x020AFAD2);
	r0 = D(r0, s0_0_2, 0x01FF02FC, 0x02FEF912, 0xFD0404FE, 0xF70DF8E7);
	r1 = D(r1, s0_0_2, 0xFEFBF1F6, 0xF90D09F7, 0xEC000A00, 0x01F4FC01);
	r2 = D(r2, s0_0_2, 0xFA09F5FE, 0xF1FCE7F3, 0xFE03F1FD, 0xE613F3E1);
	r3 = D(r3, s0_0_2, 0xFC130BF7, 0x06060908, 0xFD0BFCFF, 0xFA031305);
	r0 = D(r0, s0_1_0, 0x0304FD0C, 0xF6F9FF00, 0xF6061105, 0xFF050100);
	r1 = D(r1, s0_1_0, 0xFEF008F6, 0xFC050A05, 0xE3090C07, 0x0009EAF9);
	r2 = D(r2, s0_1_0, 0xF70310F8, 0x06FEFDFB, 0x03071701, 0xF80FEDE7);
	r3 = D(r3, s0_1_0, 0xF303FE0D, 0x03070813, 0xF103F4F8, 0x00FDEC09);
	r0 = D(r0, s0_1_1, 0xFE0213F4, 0x03EBDD18, 0xF10339F0, 0xF10C11E7);
	r1 = D(r1, s0_1_1, 0xF0E60995, 0x0D1208F8, 0xEBD2E509, 0xEB001A0C);
	r2 = D(r2, s0_1_1, 0xFE0B33C6, 0xF700C410, 0x01F5E2E1, 0xF2111C0D);
	r3 = D(r3, s0_1_1, 0xFFFC0900, 0xEFFC0409, 0xDFFE1EE9, 0xEC063200);
	r0 = D(r0, s0_1_2, 0x070A0E09, 0x08FA0001, 0xF6FEF1FC, 0xF60BE6FD);
	r1 = D(r1, s0_1_2, 0x00FD2AEE, 0x040DE0FD, 0xE8E4F7FC, 0xF5022100);
	r2 = D(r2, s0_1_2, 0x080EE4F5, 0xDFEE25F1, 0x060004FA, 0xE92DE30B);
	r3 = D(r3, s0_1_2, 0xF503EB05, 0x00F6F404, 0x000BF5FB, 0xF91AF6FE);
	r0 = D(r0, s0_2_0, 0xFA010301, 0xFEF5FC05, 0xFA02F8FF, 0x07FEFC08);
	r1 = D(r1, s0_2_0, 0xD71A1A0C, 0x00FFF9FE, 0xEF0BFF02, 0x07030201);
	r2 = D(r2, s0_2_0, 0xFA010102, 0x0602FD01, 0xEEF20504, 0xF5D7E9F7);
	r3 = D(r3, s0_2_0, 0xFE06F300, 0x0106FC02, 0xFA06F504, 0xFDFBFB04);
	r0 = D(r0, s0_2_1, 0x02071C0A, 0xF900FD02, 0xFBFFEC02, 0xFEF9FB02);
	r1 = D(r1, s0_2_1, 0x0D1C2A00, 0x090609FD, 0xFA11EDFD, 0xF7020000);
	r2 = D(r2, s0_2_1, 0x1000110A, 0xFA0206FB, 0xF9FA0904, 0xF801FF06);
	r3 = D(r3, s0_2_1, 0xFC03F200, 0xFA05DB04, 0xF3070D03, 0xFEFF0705);
	r0 = D(r0, s0_2_2, 0xF905FE02, 0x0C000005, 0xF802F802, 0xFAFAF000);
	r1 = D(r1, s0_2_2, 0xE927E00B, 0x09FEF703, 0xF912F200, 0xF608F401);
	r2 = D(r2, s0_2_2, 0x10F81808, 0xF2F9FEFC, 0xF902F109, 0xF0F51700);
	r3 = D(r3, s0_2_2, 0x09F1F0F7, 0xFD08F600, 0xF8F7F603, 0xFDFC11FC);
	r0 = D(r0, s1_0_0, 0x00FAFD09, 0x00150D0A, 0xFEFBFCFD, 0xFDF7FCFB);
	r1 = D(r1, s1_0_0, 0xFDF80C05, 0xFC08FF07, 0x09090EFC, 0x010F060A);
	r2 = D(r2, s1_0_0, 0xFDF9FB03, 0x02FA17FF, 0xF90D0806, 0x070EDDFF);
	r3 = D(r3, s1_0_0, 0x00100AED, 0xFCFBFB05, 0xFA0AF4FF, 0xFBFFFE09);
	r0 = D(r0, s1_0_1, 0xFAF9F8FF, 0x040FF900, 0x01F8FEF9, 0x05FBFBFF);
	r1 = D(r1, s1_0_1, 0xF8F811E7, 0x0D21F5FE, 0x090CFCF8, 0x030A0A06);
	r2 = D(r2, s1_0_1, 0x09E2FA06, 0x0805E6F7, 0x00E8FE01, 0x0B22D62A);
	r3 = D(r3, s1_0_1, 0x0A00F312, 0xF9F503FD, 0x030EFC0F, 0xFE02F811);
	r0 = D(r0, s1_0_2, 0x020C0906, 0x04E507EF, 0x0004FB02, 0xFB030003);
	r1 = D(r1, s1_0_2, 0xFCED04DD, 0x0A10F402, 0x0E1B0307, 0x010303F6);
	r2 = D(r2, s1_0_2, 0xFAECF7F6, 0xFA0218F0, 0xFAED02E7, 0x1308F5FC);
	r3 = D(r3, s1_0_2, 0x0810FA25, 0x040DFC0A, 0x0D08090A, 0x0C0FFB0C);
	r0 = D(r0, s1_1_0, 0x011EF7F3, 0x13FA020C, 0xFCF90A0C, 0xFA060CFC);
	r1 = D(r1, s1_1_0, 0xEA12E307, 0x120901F1, 0xF9E1E625, 0x100101F2);
	r2 = D(r2, s1_1_0, 0xF5010F06, 0x00FCEF04, 0x062304EA, 0xFAD7C626);
	r3 = D(r3, s1_1_0, 0x06E8FA03, 0xFCF20501, 0x0EF6F000, 0xFD1F08F0);
	r0 = D(r0, s1_1_1, 0x114BF600, 0x3636E301, 0xF4E30209, 0xF9DD1417);
	r1 = D(r1, s1_1_1, 0x050CC829, 0x0CAB0FE9, 0x18F7E114, 0x21D8DFF5);
	r2 = D(r2, s1_1_1, 0xDDF0150E, 0x1F0D10E5, 0x1B17D9F0, 0x162CB901);
	r3 = D(r3, s1_1_1, 0xFCBB2E16, 0xEEE60CE3, 0x110C11E8, 0x0E06EBDB);
	r0 = D(r0, s1_1_2, 0x0A020011, 0xEED50CFE, 0x151002FC, 0x31440611);
	r1 = D(r1, s1_1_2, 0xEE22ED51, 0x16F50A00, 0x5519D41B, 0x1D01F9FD);
	r2 = D(r2, s1_1_2, 0xD6D122C1, 0x0FEBFC03, 0xDFD7FDFA, 0xF0072BD1);
	r3 = D(r3, s1_1_2, 0x1E2C00F3, 0x1221F422, 0x1C13EA0D, 0x09E604EB);
	r0 = D(r0, s1_2_0, 0x03F90505, 0xF60304FA, 0x0F08F9FB, 0x08020DF9);
	r1 = D(r1, s1_2_0, 0x1AF405F3, 0xE90702F3, 0x070F07F1, 0xF3F40A11);
	r2 = D(r2, s1_2_0, 0x070505F9, 0xF9000109, 0x04F608FC, 0x173B17F7);
	r3 = D(r3, s1_2_0, 0x010109F5, 0x08050105, 0xF417F0E3, 0xF91902EA);
	r0 = D(r0, s1_2_1, 0x12D31516, 0x0301FE09, 0x252607EC, 0x03F2ECFD);
	r1 = D(r1, s1_2_1, 0x0FF024F3, 0xF4F1E308, 0x12270CDA, 0xF51CF8DE);
	r2 = D(r2, s1_2_1, 0x2AFFB018, 0xE7EC100A, 0x32EB1317, 0x28EAC6FC);
	r3 = D(r3, s1_2_1, 0xDB0B0601, 0x0C3813DB, 0x13E51CFF, 0xEFDAF418);
	r0 = D(r0, s1_2_2, 0x32F10201, 0x29F40BF4, 0x54FDFF0E, 0x81160401);
	r1 = D(r1, s1_2_2, 0xD60EFAF0, 0x810806F5, 0x13F8FE0F, 0x250B1703);
	r2 = D(r2, s1_2_2, 0xB822EC01, 0x810FFCDD, 0x2A2E070F, 0x81FBCD04);
	r3 = D(r3, s1_2_2, 0x81071004, 0x7F07ED04, 0x7F0DF804, 0x1CF6FCFE);
	f0 = vec4(r0) * 6.2000124e-05;
	f0 += vec4(-1.910e-02, 3.408e-03, -7.577e-03, -1.867e-02);
	f0 = max(f0, vec4(0.0));
	imageStore(out_image, opos + ivec2(0, 0), f0);
	f1 = vec4(r1) * 6.2000124e-05;
	f1 += vec4(-2.751e-02, 2.096e-03, -2.473e-02, -8.007e-04);
	f1 = max(f1, vec4(0.0));
	imageStore(out_image, opos + ivec2(1, 0), f1);
	f2 = vec4(r2) * 6.2000124e-05;
	f2 += vec4(-9.611e-03, -1.536e-02, 1.748e-02, -6.275e-02);
	f2 = max(f2, vec4(0.0));
	imageStore(out_image, opos + ivec2(0, 1), f2);
	f3 = vec4(r3) * 6.2000124e-05;
	f3 += vec4(-2.670e-02, 4.852e-02, -3.634e-02, -5.461e-03);
	f3 = max(f3, vec4(0.0));
	imageStore(out_image, opos + ivec2(1, 1), f3);
}

//!DESC CuNNy-4x16-DS-conv4
//!HOOK LUMA
//!COMPUTE 16 16 8 8
//!BIND conv3
//!BIND LUMA
//!SAVE conv4
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h 2 *
//!COMPONENTS 4
//!WHEN OUTPUT.w LUMA.w / 1.3 > OUTPUT.h LUMA.h / 1.3 > *
#extension GL_EXT_spirv_intrinsics : require
spirv_instruction (extensions = ["SPV_KHR_integer_dot_product"], capabilities = [6019, 6018], id = 4450)
int dp4(int a, int b, spirv_literal int fmt);
#define D(r, s, a, b, c, d) r + ivec4(dp4(s, a, 0), dp4(s, b, 0), dp4(s, c, 0), dp4(s, d, 0))
shared int G[4][10][10];
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
			vec2 p;
			vec4 r, g, b, a;
			p = vec2(clamp(pos + ivec2(x - 1, y - 1), ivec2(0), sz) * ivec2(2, 2) + ivec2(1, 1)) * conv3_pt;
			r = conv3_gather(p, 0);
			g = conv3_gather(p, 1);
			b = conv3_gather(p, 2);
			a = conv3_gather(p, 3);
			vec4 v0 = vec4(r.w, g.w, b.w, a.w) * 1.0000000e+00;
			vec4 v1 = vec4(r.z, g.z, b.z, a.z) * 1.0000000e+00;
			vec4 v2 = vec4(r.x, g.x, b.x, a.x) * 1.0000000e+00;
			vec4 v3 = vec4(r.y, g.y, b.y, a.y) * 1.0000000e+00;
			G[0][ay][ax] = int(packSnorm4x8(v0));
			G[1][ay][ax] = int(packSnorm4x8(v1));
			G[2][ay][ax] = int(packSnorm4x8(v2));
			G[3][ay][ax] = int(packSnorm4x8(v3));
		}
	}
	barrier();
	int s0_0_0, s0_0_1, s0_0_2, s0_1_0, s0_1_1, s0_1_2, s0_2_0, s0_2_1, s0_2_2, s1_0_0, s1_0_1, s1_0_2, s1_1_0, s1_1_1, s1_1_2, s1_2_0, s1_2_1, s1_2_2;
	ivec4 r0, r1, r2, r3;
	vec4 f0, f1, f2, f3;
	r0 = ivec4(0); r1 = ivec4(0); r2 = ivec4(0); r3 = ivec4(0);
	s0_0_0 = G[0][xy.y+0][xy.x+0]; s0_0_1 = G[0][xy.y+0][xy.x+1];
	s0_0_2 = G[0][xy.y+0][xy.x+2]; s0_1_0 = G[0][xy.y+1][xy.x+0];
	s0_1_1 = G[0][xy.y+1][xy.x+1]; s0_1_2 = G[0][xy.y+1][xy.x+2];
	s0_2_0 = G[0][xy.y+2][xy.x+0]; s0_2_1 = G[0][xy.y+2][xy.x+1];
	s0_2_2 = G[0][xy.y+2][xy.x+2]; s1_0_0 = G[1][xy.y+0][xy.x+0];
	s1_0_1 = G[1][xy.y+0][xy.x+1]; s1_0_2 = G[1][xy.y+0][xy.x+2];
	s1_1_0 = G[1][xy.y+1][xy.x+0]; s1_1_1 = G[1][xy.y+1][xy.x+1];
	s1_1_2 = G[1][xy.y+1][xy.x+2]; s1_2_0 = G[1][xy.y+2][xy.x+0];
	s1_2_1 = G[1][xy.y+2][xy.x+1]; s1_2_2 = G[1][xy.y+2][xy.x+2];
	r0 = D(r0, s0_0_0, 0x01FC0101, 0xCE2FF5F6, 0xFEFFFE00, 0xFFFFFEF9);
	r1 = D(r1, s0_0_0, 0xFD08F1E7, 0xF0F8F124, 0xFB000106, 0xFFFDFC00);
	r2 = D(r2, s0_0_0, 0xFE03FF00, 0xF703FC01, 0x0402FE01, 0x06FFFB04);
	r3 = D(r3, s0_0_0, 0x0DEB00F9, 0xFCFDFAF9, 0x040001F0, 0xFAFD0000);
	r0 = D(r0, s0_0_1, 0x01FE0203, 0xFB24FD1C, 0x0505FFF6, 0x002CEF1C);
	r1 = D(r1, s0_0_1, 0x18EEFC2C, 0x07CECE03, 0xFF0705F9, 0xEF5AF01F);
	r2 = D(r2, s0_0_1, 0xE95AE628, 0xFA0A023C, 0xF93CED1D, 0x160CF953);
	r3 = D(r3, s0_0_1, 0xF40F0AFB, 0x0BEF0311, 0xFFFD0B14, 0xED0107AE);
	r0 = D(r0, s0_0_2, 0x01FDFE03, 0xF423F40A, 0xFA0401FE, 0xFB150504);
	r1 = D(r1, s0_0_2, 0xFCF004FD, 0xF415F0F6, 0x0103FC04, 0xF713040C);
	r2 = D(r2, s0_0_2, 0xF9040A03, 0xFD0DFA01, 0xFC090801, 0x030BF4FA);
	r3 = D(r3, s0_0_2, 0x01FEFEFB, 0xFCFA06FE, 0xFC00E8ED, 0xFFF60C04);
	r0 = D(r0, s0_1_0, 0xFE22FC02, 0x46E3FF1B, 0x03FD05FD, 0x181103F6);
	r1 = D(r1, s0_1_0, 0x16F004FB, 0x0804FDFC, 0x08F7FA0A, 0x1608020C);
	r2 = D(r2, s0_1_0, 0x0E08FA20, 0xFF08FA10, 0xFB16FA09, 0x0AF8030B);
	r3 = D(r3, s0_1_0, 0x1CF2F5F5, 0xF4FB0200, 0xEDF8FDFC, 0xFA0301FE);
	r0 = D(r0, s0_1_1, 0xF92B0208, 0x1703810D, 0xFBFDEE0A, 0xEBF4F30D);
	r1 = D(r1, s0_1_1, 0x1DABE0FE, 0x0D0FF6F9, 0xE021E825, 0x01CDFE12);
	r2 = D(r2, s0_1_1, 0x04D81A08, 0xF51DF7DE, 0xF9EC0F24, 0x304ED2B3);
	r3 = D(r3, s0_1_1, 0x12F61C00, 0x3DDAF720, 0x0D0515F3, 0xDABD4557);
	r0 = D(r0, s0_1_2, 0xFE13FE03, 0x2EFCDA0D, 0xFF0B2DE4, 0x0AFC1102);
	r1 = D(r1, s0_1_2, 0xEB25FBD3, 0x190C00FA, 0x00F50D0A, 0x10F91B03);
	r2 = D(r2, s0_1_2, 0x06FCFE01, 0xFBF70A00, 0xFE01F801, 0xFBF818F6);
	r3 = D(r3, s0_1_2, 0xFB09FDFD, 0x04F5F7DE, 0xFA0509FF, 0xFF08010A);
	r0 = D(r0, s0_2_0, 0xFFFD01FF, 0xE60BFAF7, 0x0608FFF6, 0x0705FF05);
	r1 = D(r1, s0_2_0, 0x13FD0200, 0xFBFF04FC, 0x02020408, 0xF40302FF);
	r2 = D(r2, s0_2_0, 0xEE0701F8, 0x000007FF, 0xFFFC030F, 0x000503FE);
	r3 = D(r3, s0_2_0, 0x110EF6F8, 0xF108FE04, 0xF8FF0205, 0x07FCFA07);
	r0 = D(r0, s0_2_1, 0x02E70401, 0x19E1D02B, 0xFBF60304, 0xFB0606FF);
	r1 = D(r1, s0_2_1, 0xEAC7EDFE, 0xFFF90107, 0x0DFFFFF9, 0xFA09FFFA);
	r2 = D(r2, s0_2_1, 0xFF03F608, 0x08F90204, 0xFF06FCFE, 0x06010405);
	r3 = D(r3, s0_2_1, 0x03F41AFA, 0x49FAF4EA, 0x030501FB, 0xFB04F3FB);
	r0 = D(r0, s0_2_2, 0x00FF07FF, 0xFBF7EDF4, 0xF8FD12FA, 0xFF06FFFC);
	r1 = D(r1, s0_2_2, 0xD912F3EC, 0xF4010701, 0x05FF0A06, 0xF902FB00);
	r2 = D(r2, s0_2_2, 0xFA0201FA, 0xFF0401FB, 0x03F90501, 0x02FAF407);
	r3 = D(r3, s0_2_2, 0xFD030100, 0xFEDD81DE, 0xF900F902, 0x040208F6);
	r0 = D(r0, s1_0_0, 0xFFFDFEFB, 0x1AFBEE17, 0xFA010206, 0x04000300);
	r1 = D(r1, s1_0_0, 0xEE02F904, 0x281DEAE4, 0xFC0101F8, 0x03FE03FF);
	r2 = D(r2, s1_0_0, 0x0CF900FC, 0x0508060A, 0x06FEFFF2, 0x060E0700);
	r3 = D(r3, s1_0_0, 0xF1FE05F9, 0xF003FD09, 0xFCF7F7FB, 0xFCEFF706);
	r0 = D(r0, s1_0_1, 0x03FD00FD, 0x0C1F05D1, 0xEEFDFCBF, 0xF5F2EFF3);
	r1 = D(r1, s1_0_1, 0x13EC09EA, 0x4F33D8F2, 0xFE00F7DA, 0x05EDE712);
	r2 = D(r2, s1_0_1, 0xF5FCE51D, 0x0108F5F9, 0xF2F1EFE5, 0xEFF9EBFB);
	r3 = D(r3, s1_0_1, 0xFD05FBE0, 0xFC010C00, 0x0D03FF08, 0x16061709);
	r0 = D(r0, s1_0_2, 0xFEFD0400, 0xF4F7FE2E, 0x05FE0903, 0xFC02F8F4);
	r1 = D(r1, s1_0_2, 0x070A050A, 0x0D0BFF13, 0xFDFA0001, 0xFA01EF11);
	r2 = D(r2, s1_0_2, 0x04FDFE09, 0xFB0001FE, 0xFFFEFF01, 0xFF0005FA);
	r3 = D(r3, s1_0_2, 0xFE000701, 0xFB0DF7E2, 0xF9060BF8, 0x03F9F802);
	r0 = D(r0, s1_1_0, 0x0BFBF305, 0x09F3CCE6, 0x01F402F8, 0x070AFB02);
	r1 = D(r1, s1_1_0, 0xF60EEC0C, 0x14FA1BFB, 0x00F90208, 0x020DFCFD);
	r2 = D(r2, s1_1_0, 0xF623E6F1, 0x0B11FFF8, 0x0814E60A, 0x15F90BFB);
	r3 = D(r3, s1_1_0, 0xF2F9F70C, 0xF309FD07, 0xF000F70B, 0xEC08F0FA);
	r0 = D(r0, s1_1_1, 0x1505F007, 0xF1D3A029, 0xFC0BC11A, 0x1926E4FE);
	r1 = D(r1, s1_1_1, 0x48E0B123, 0xE6E1F913, 0xFD14E60D, 0xF9199BE0);
	r2 = D(r2, s1_1_1, 0x28DCC2DE, 0x14150C18, 0x2518C703, 0x2302D2FF);
	r3 = D(r3, s1_1_1, 0x0DF0C709, 0x08EF11FF, 0x1B07EFFF, 0xE9F72DFB);
	r0 = D(r0, s1_1_2, 0xFEFD0002, 0x04C3CFF7, 0x08DE0206, 0x1102F5FD);
	r1 = D(r1, s1_1_2, 0xDE1D18FA, 0xF4E30FF1, 0x02FEEB08, 0x19E803F5);
	r2 = D(r2, s1_1_2, 0x030308FF, 0x020302F8, 0x03F80205, 0xF0021B00);
	r3 = D(r3, s1_1_2, 0xFD0506FE, 0xF91ADD02, 0xFB060EFE, 0x14FFDFFC);
	r0 = D(r0, s1_2_0, 0x0205EEFF, 0xF71E01FE, 0x02FD0207, 0xFF07FBFE);
	r1 = D(r1, s1_2_0, 0x040C0106, 0xFA07FF06, 0x0607FFF8, 0xFF000501);
	r2 = D(r2, s1_2_0, 0x02FD0A06, 0xF7FC02F9, 0x0005F6F6, 0xFFFD00FD);
	r3 = D(r3, s1_2_0, 0x0416FC06, 0xFE030107, 0xFF01FFFE, 0x02080101);
	r0 = D(r0, s1_2_1, 0x12E9E002, 0x531701E8, 0xF020DCFF, 0xFCFEF901);
	r1 = D(r1, s1_2_1, 0x24CFE104, 0x0509F8FF, 0x13FEF401, 0x00080D07);
	r2 = D(r2, s1_2_1, 0xF9160600, 0xE8EEEEFC, 0x05F8FA00, 0x07F40C02);
	r3 = D(r3, s1_2_1, 0x14E5F301, 0x31DBF504, 0x09030202, 0x040EF1FE);
	r0 = D(r0, s1_2_2, 0x03FF00FC, 0x3A1A2217, 0x19F00803, 0xFC0902FF);
	r1 = D(r1, s1_2_2, 0x05111512, 0x020B0009, 0x030004FD, 0xF7030100);
	r2 = D(r2, s1_2_2, 0xFAFB0002, 0xF4FBF901, 0x040302FD, 0xFCFE01FE);
	r3 = D(r3, s1_2_2, 0x000202FE, 0xEA10D00B, 0xFDFF0001, 0x0904FE01);
	s0_0_0 = G[2][xy.y+0][xy.x+0]; s0_0_1 = G[2][xy.y+0][xy.x+1];
	s0_0_2 = G[2][xy.y+0][xy.x+2]; s0_1_0 = G[2][xy.y+1][xy.x+0];
	s0_1_1 = G[2][xy.y+1][xy.x+1]; s0_1_2 = G[2][xy.y+1][xy.x+2];
	s0_2_0 = G[2][xy.y+2][xy.x+0]; s0_2_1 = G[2][xy.y+2][xy.x+1];
	s0_2_2 = G[2][xy.y+2][xy.x+2]; s1_0_0 = G[3][xy.y+0][xy.x+0];
	s1_0_1 = G[3][xy.y+0][xy.x+1]; s1_0_2 = G[3][xy.y+0][xy.x+2];
	s1_1_0 = G[3][xy.y+1][xy.x+0]; s1_1_1 = G[3][xy.y+1][xy.x+1];
	s1_1_2 = G[3][xy.y+1][xy.x+2]; s1_2_0 = G[3][xy.y+2][xy.x+0];
	s1_2_1 = G[3][xy.y+2][xy.x+1]; s1_2_2 = G[3][xy.y+2][xy.x+2];
	r0 = D(r0, s0_0_0, 0xFE01FE04, 0x094BEADF, 0xFDFC04FD, 0xFBF30000);
	r1 = D(r1, s0_0_0, 0xEC0C12E3, 0xEEED00B9, 0xFE04FFFD, 0xFAF60FF5);
	r2 = D(r2, s0_0_0, 0x09041CCF, 0xF0F026CA, 0x05020AFD, 0x00F00FF6);
	r3 = D(r3, s0_0_0, 0xFC0906EB, 0x01060501, 0x010DE9FA, 0x010FE50F);
	r0 = D(r0, s0_0_1, 0xFE070403, 0xDE16E6F1, 0xF62F0CE9, 0x0703FB0C);
	r1 = D(r1, s0_0_1, 0x1EFEF709, 0xCD1EC5E7, 0x0413FCFB, 0xF534F6B4);
	r2 = D(r2, s0_0_1, 0xE622F9E9, 0xF715EBA0, 0xEF020309, 0x040E0221);
	r3 = D(r3, s0_0_1, 0xFCF8FEF8, 0x000404F7, 0xF9F8F8F0, 0xFBE601D0);
	r0 = D(r0, s0_0_2, 0xFC0304FD, 0x17270514, 0x1306FDFB, 0x05FC0402);
	r1 = D(r1, s0_0_2, 0xD30FF4ED, 0xC60EEC05, 0xFF010301, 0x0F030601);
	r2 = D(r2, s0_0_2, 0x0103FFFD, 0xD3FD00FB, 0x060203FE, 0xFEFDFFF3);
	r3 = D(r3, s0_0_2, 0xFE070000, 0xFD02F704, 0xEE0D0606, 0x0407FA13);
	r0 = D(r0, s0_1_0, 0x020A23F3, 0xFEF1E7FE, 0x04F8E1F9, 0x0AFAF0FA);
	r1 = D(r1, s0_1_0, 0xF4E7D6E6, 0x110801FC, 0x00FDFBE8, 0x0AF8FCF6);
	r2 = D(r2, s0_1_0, 0xE8EFF8E4, 0xFA0614F9, 0xF4FE12ED, 0xFDFB08FD);
	r3 = D(r3, s0_1_0, 0x0BE131D9, 0x00F80800, 0xFFFCF401, 0x0300F803);
	r0 = D(r0, s0_1_1, 0x0B01F2F8, 0x08B8FF9A, 0xD9F933CA, 0xE3091BFB);
	r1 = D(r1, s0_1_1, 0xFE19E3D8, 0x0AF207DE, 0xDD1D13D8, 0xF1E630F0);
	r2 = D(r2, s0_1_1, 0x0EF01CEF, 0xF0F0230A, 0x0E190AE8, 0xDDF9E3FA);
	r3 = D(r3, s0_1_1, 0x1F15EBF5, 0xFAD6FBEA, 0x3303EFFA, 0x29002EFF);
	r0 = D(r0, s0_1_2, 0x01040405, 0x1A2FFEDE, 0x0EF6FD0F, 0xFE05F6F8);
	r1 = D(r1, s0_1_2, 0xE10D1BF9, 0xE9FF0FE4, 0x0215FD00, 0xEE0FF8F6);
	r2 = D(r2, s0_1_2, 0xFC0B0000, 0x19070201, 0xF50D0102, 0xFDFD0C05);
	r3 = D(r3, s0_1_2, 0xF8F60305, 0xDC1E00E2, 0x0BF30505, 0x06F7F3FE);
	r0 = D(r0, s0_2_0, 0xF3F6E2FD, 0x02F7BFF0, 0x1406FF02, 0xFFF8FDFF);
	r1 = D(r1, s0_2_0, 0xD5FA01FB, 0x1601FAFD, 0x050009FD, 0xFF0009FE);
	r2 = D(r2, s0_2_0, 0x0E060A01, 0x03FA0203, 0x06FBF301, 0xF904F302);
	r3 = D(r3, s0_2_0, 0xE0FC01EA, 0xF6F6F9F8, 0xFDFEF8FE, 0x06F80FFF);
	r0 = D(r0, s0_2_1, 0xE9081501, 0xCA13E412, 0xFBF432EE, 0x0DFEF2FC);
	r1 = D(r1, s0_2_1, 0x0B081AF0, 0x0A04F403, 0x00FF09EE, 0x0808F7FC);
	r2 = D(r2, s0_2_1, 0xEAFE04F9, 0x02F708FF, 0xE3F21400, 0x0A050F00);
	r3 = D(r3, s0_2_1, 0x070801F0, 0x0C1707ED, 0x06FEFDFF, 0xEBF7F0FF);
	r0 = D(r0, s0_2_2, 0xF705FF02, 0x810CD203, 0xF9FDEF04, 0xF00003FF);
	r1 = D(r1, s0_2_2, 0x04F40108, 0xFA020204, 0xF60C01F7, 0xFB0202FD);
	r2 = D(r2, s0_2_2, 0x05FFFFFE, 0xF5070204, 0x0108FDFE, 0x03F9FCFD);
	r3 = D(r3, s0_2_2, 0x00FA0300, 0xDCF730D3, 0x05FEFE00, 0xEF080205);
	r0 = D(r0, s1_0_0, 0xFFFE0601, 0xEA0EDAFC, 0xFB04FC01, 0xFFFB0206);
	r1 = D(r1, s1_0_0, 0xF938EAF2, 0xDB13EC0F, 0xFB07FE00, 0x04FA020B);
	r2 = D(r2, s1_0_0, 0x0BF9FE05, 0xF9FEF30A, 0x05F80304, 0xF200E408);
	r3 = D(r3, s1_0_0, 0xF80802F8, 0xFE08FD01, 0x0D0304FC, 0x0E011BFB);
	r0 = D(r0, s1_0_1, 0xFF0406FD, 0xA7BBC431, 0xF51007DF, 0x0CFF0C02);
	r1 = D(r1, s1_0_1, 0xFD0C06E4, 0xC7CBF735, 0xFD00FE03, 0xFDEFFFFA);
	r2 = D(r2, s1_0_1, 0x01D9FD0C, 0x12DEFB07, 0x0FF60700, 0x11FF3D00);
	r3 = D(r3, s1_0_1, 0x01FC0AFE, 0xF8FB0B07, 0x04F0F4EB, 0xEB02BEFB);
	r0 = D(r0, s1_0_2, 0x060801FB, 0xE1E1FB0B, 0x0A1700FC, 0xFCF80604);
	r1 = D(r1, s1_0_2, 0xDF060306, 0xDFF5040D, 0x070404FD, 0x04EE0215);
	r2 = D(r2, s1_0_2, 0x05F90308, 0x0EFDFF06, 0x05F90503, 0x02FAF2FF);
	r3 = D(r3, s1_0_2, 0xFC0D00F9, 0xE51509FF, 0x0D1502F4, 0xFF070DFF);
	r0 = D(r0, s1_1_0, 0x07040400, 0x24F43214, 0x08F2010C, 0x0CFC00FF);
	r1 = D(r1, s1_1_0, 0xFD04EDF9, 0xF9FD02F3, 0x0AF8051E, 0x09FD0209);
	r2 = D(r2, s1_1_0, 0xFC00FB0C, 0x0DFA040D, 0xFE02FCFF, 0x0AFB1B07);
	r3 = D(r3, s1_1_0, 0x0B110406, 0xFC10FCF6, 0xFD06FCFF, 0xFC04E5F8);
	r0 = D(r0, s1_1_1, 0x04EC0609, 0x4F5C1BE9, 0xEF32F997, 0xE9F40CEE);
	r1 = D(r1, s1_1_1, 0x1E0E1CC1, 0x04FDF307, 0xE7FFF5E3, 0x100B01F1);
	r2 = D(r2, s1_1_1, 0x1C1001A9, 0xEC2105F9, 0x00E404E5, 0x230092F7);
	r3 = D(r3, s1_1_1, 0x3CE90508, 0xFC041008, 0x24FFFEF8, 0xD9056D0D);
	r0 = D(r0, s1_1_2, 0x120300FE, 0xE60DF38E, 0x2C2501F3, 0x0BF3FEF8);
	r1 = D(r1, s1_1_2, 0xD926F0EE, 0x10FCF0E5, 0x04EBFC0C, 0xFF05FED5);
	r2 = D(r2, s1_1_2, 0xF603FFF8, 0xE204FB0B, 0xFE050101, 0xDAFF0FF7);
	r3 = D(r3, s1_1_2, 0xFB00FEFC, 0x110303E2, 0xF208F702, 0x3106F20C);
	r0 = D(r0, s1_2_0, 0xF707FB02, 0xD319F815, 0x080003FE, 0x00FD0001);
	r1 = D(r1, s1_2_0, 0xF4090BF8, 0xFE00FF0B, 0x08FD000A, 0x0200FF04);
	r2 = D(r2, s1_2_0, 0x0402FDFD, 0xFF01FFF7, 0x08FCFD05, 0xFCFEFDFE);
	r3 = D(r3, s1_2_0, 0xF708FFF8, 0xFA0807FF, 0x01010004, 0x04010302);
	r0 = D(r0, s1_2_1, 0x07F403F9, 0xB0FDF4DD, 0xF908F9F4, 0x0EFAFDFE);
	r1 = D(r1, s1_2_1, 0x170703ED, 0xF105FF03, 0x0D10FF12, 0xF804FD07);
	r2 = D(r2, s1_2_1, 0xF7FFFE12, 0x0DFC03FE, 0x0808FCFD, 0xF0050608);
	r3 = D(r3, s1_2_1, 0x080DFCE1, 0x0F0BFDF7, 0x0901FC02, 0x11F7F6F8);
	r0 = D(r0, s1_2_2, 0x050501F8, 0xA1F7F002, 0x0C08FDFA, 0x0000FDFC);
	r1 = D(r1, s1_2_2, 0xF42BF7F7, 0xFE02FD14, 0xF208FCF4, 0x0100FF0C);
	r2 = D(r2, s1_2_2, 0x01FE0107, 0x0302FD02, 0xFCF901F5, 0x03020102);
	r3 = D(r3, s1_2_2, 0xFE0700FF, 0x132110C3, 0x0107FFFF, 0xFEFBFEFF);
	f0 = vec4(r0) * 6.2000124e-05;
	f0 += vec4(-1.443e-02, -3.674e-02, -1.286e-02, -1.959e-02);
	f0 = max(f0, vec4(0.0));
	imageStore(out_image, opos + ivec2(0, 0), f0);
	f1 = vec4(r1) * 6.2000124e-05;
	f1 += vec4(-2.789e-02, -1.352e-02, -3.953e-03, -1.043e-02);
	f1 = max(f1, vec4(0.0));
	imageStore(out_image, opos + ivec2(1, 0), f1);
	f2 = vec4(r2) * 6.2000124e-05;
	f2 += vec4(-9.124e-03, -6.012e-03, -1.645e-02, 1.682e-02);
	f2 = max(f2, vec4(0.0));
	imageStore(out_image, opos + ivec2(0, 1), f2);
	f3 = vec4(r3) * 6.2000124e-05;
	f3 += vec4(-2.387e-02, -5.407e-02, 6.800e-03, -2.056e-02);
	f3 = max(f3, vec4(0.0));
	imageStore(out_image, opos + ivec2(1, 1), f3);
}

//!DESC CuNNy-4x16-DS-out-shuffle
//!HOOK LUMA
//!COMPUTE 16 16 8 8
//!BIND conv4
//!BIND LUMA
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h 2 *
//!COMPONENTS 1
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
shared V4 G[4][10][10];
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
			vec2 p;
			p = vec2(clamp(pos + ivec2(x - 1, y - 1), ivec2(0), sz) * ivec2(2, 2) + ivec2(1, 1)) * conv4_pt;
			V4 sr0 = V4(conv4_gather(p, 0));
			V4 sg0 = V4(conv4_gather(p, 1));
			V4 sb0 = V4(conv4_gather(p, 2));
			V4 sa0 = V4(conv4_gather(p, 3));
			G[0][ay][ax] = V4(sr0.w, sg0.w, sb0.w, sa0.w);
			G[1][ay][ax] = V4(sr0.z, sg0.z, sb0.z, sa0.z);
			G[2][ay][ax] = V4(sr0.x, sg0.x, sb0.x, sa0.x);
			G[3][ay][ax] = V4(sr0.y, sg0.y, sb0.y, sa0.y);
		}
	}
	barrier();
	V4 s0_0_0, s0_0_1, s0_0_2, s0_1_0, s0_1_1, s0_1_2, s0_2_0, s0_2_1, s0_2_2, s1_0_0, s1_0_1, s1_0_2, s1_1_0, s1_1_1, s1_1_2, s1_2_0, s1_2_1, s1_2_2;
	V4 r0;
	r0 = V4(0.0);
	s0_0_0 = G[0][xy.y+0][xy.x+0]; s0_0_1 = G[0][xy.y+0][xy.x+1];
	s0_0_2 = G[0][xy.y+0][xy.x+2]; s0_1_0 = G[0][xy.y+1][xy.x+0];
	s0_1_1 = G[0][xy.y+1][xy.x+1]; s0_1_2 = G[0][xy.y+1][xy.x+2];
	s0_2_0 = G[0][xy.y+2][xy.x+0]; s0_2_1 = G[0][xy.y+2][xy.x+1];
	s0_2_2 = G[0][xy.y+2][xy.x+2]; s1_0_0 = G[1][xy.y+0][xy.x+0];
	s1_0_1 = G[1][xy.y+0][xy.x+1]; s1_0_2 = G[1][xy.y+0][xy.x+2];
	s1_1_0 = G[1][xy.y+1][xy.x+0]; s1_1_1 = G[1][xy.y+1][xy.x+1];
	s1_1_2 = G[1][xy.y+1][xy.x+2]; s1_2_0 = G[1][xy.y+2][xy.x+0];
	s1_2_1 = G[1][xy.y+2][xy.x+1]; s1_2_2 = G[1][xy.y+2][xy.x+2];
	r0 += M4(5.432e-02, 4.395e-03, 3.531e-02, -1.883e-03, 3.489e-02, 2.237e-02, -3.160e-02, -7.412e-03, 8.918e-02, -1.040e-02, 2.030e-02, -4.717e-03, -4.308e-02, 2.716e-02, -1.421e-02, 1.331e-02) * s0_0_0;
	r0 += M4(-3.239e-01, -8.887e-02, -1.784e-01, -9.888e-02, -7.048e-03, 2.749e-02, -4.077e-03, -3.231e-02, 9.106e-02, -2.026e-01, 1.704e-02, 9.154e-03, -1.595e-01, -1.302e-01, -6.105e-03, 1.961e-02) * s0_0_1;
	r0 += M4(3.603e-02, -1.005e-01, 2.079e-02, -4.553e-02, -9.248e-03, -1.563e-02, -1.836e-03, 2.751e-03, -1.349e-02, 4.142e-02, -1.019e-02, 2.332e-02, -4.756e-03, 3.811e-02, 3.304e-03, 1.723e-02) * s0_0_2;
	r0 += M4(-8.969e-03, -5.481e-03, 3.552e-02, 5.728e-03, -7.486e-02, -1.470e-02, 4.802e-02, -1.014e-02, 7.797e-02, -4.743e-04, 1.473e-01, -1.753e-02, 1.214e-03, 1.941e-02, -1.025e-01, 5.446e-02) * s0_1_0;
	r0 += M4(3.258e-02, -1.757e-02, 2.582e-02, 7.036e-02, -8.918e-02, -1.725e-01, 1.208e-01, 1.568e-01, 9.009e-02, -7.850e-02, 1.349e-01, -3.208e-01, 2.065e-01, 1.861e-01, 4.306e-02, -4.569e-01) * s0_1_1;
	r0 += M4(1.450e-02, 4.315e-02, 4.286e-02, 3.782e-02, -2.920e-03, -1.019e-02, -1.281e-02, 7.045e-03, -5.396e-03, 9.395e-03, -1.072e-02, 1.999e-02, -1.429e-03, 5.185e-02, -1.083e-02, 8.395e-02) * s0_1_2;
	r0 += M4(2.169e-03, -5.074e-05, -4.563e-03, -8.496e-04, -2.424e-03, -2.434e-03, 2.257e-02, 1.026e-05, 6.451e-03, 1.132e-02, 4.811e-03, 1.783e-02, -6.227e-03, 3.407e-03, 4.142e-03, -9.302e-03) * s0_2_0;
	r0 += M4(-1.078e-03, -4.567e-06, -1.559e-02, -1.638e-02, 1.527e-03, -2.275e-03, -1.836e-02, 3.574e-02, 8.648e-04, -1.576e-02, 5.120e-03, -1.570e-03, 6.622e-03, 4.946e-03, 8.788e-02, 1.079e-01) * s0_2_1;
	r0 += M4(-2.265e-04, 3.229e-04, 1.641e-02, 1.236e-02, 3.997e-03, 6.256e-03, 2.425e-03, -1.706e-02, -1.390e-03, 2.018e-03, -7.167e-03, -8.998e-04, 1.081e-03, -1.218e-03, -5.684e-03, 1.438e-02) * s0_2_2;
	r0 += M4(6.814e-02, -1.598e-02, 1.866e-02, -3.968e-03, 7.511e-03, 2.432e-03, -5.693e-04, 3.542e-03, -6.518e-02, 1.616e-02, -5.299e-03, 9.227e-03, -2.016e-02, -1.115e-02, 2.161e-03, -9.856e-03) * s1_0_0;
	r0 += M4(-1.497e-01, 7.681e-02, -2.117e-02, 2.147e-02, 5.609e-03, 2.179e-03, 2.939e-03, -3.598e-06, 1.281e-01, 2.095e-01, -3.573e-03, 4.162e-02, 1.902e-02, 5.863e-02, -1.471e-02, -8.559e-03) * s1_0_1;
	r0 += M4(1.000e-02, 2.285e-02, -1.642e-03, 1.695e-03, -1.134e-03, 3.646e-03, -1.842e-04, -6.492e-04, -3.198e-03, 2.166e-02, 1.494e-03, -1.055e-02, 5.273e-04, 1.016e-02, 2.481e-04, -7.632e-03) * s1_0_2;
	r0 += M4(-9.256e-03, -1.955e-02, 4.903e-02, -1.834e-02, -4.553e-02, 2.805e-02, -2.508e-03, -1.163e-02, 7.181e-03, 1.498e-02, -1.324e-01, 2.413e-02, 7.498e-03, 2.051e-02, 4.213e-02, 8.041e-03) * s1_1_0;
	r0 += M4(-2.109e-01, 2.723e-01, -2.745e-01, 2.744e-01, 6.864e-02, -8.918e-02, 3.597e-02, 3.356e-02, -5.763e-02, -3.523e-02, 1.013e-01, -3.994e-01, 3.275e-02, -5.955e-01, 7.835e-02, 2.573e-01) * s1_1_1;
	r0 += M4(1.171e-02, -6.674e-02, 2.144e-02, -9.455e-03, 1.411e-03, 6.733e-02, -6.793e-03, 1.738e-02, -8.457e-03, 1.985e-02, -1.918e-02, 7.847e-02, -8.402e-03, 2.166e-02, 2.603e-03, 2.834e-02) * s1_1_2;
	r0 += M4(-5.144e-03, -1.151e-03, -1.623e-02, -1.145e-02, 1.757e-02, -2.385e-02, -1.363e-02, 1.334e-02, 8.522e-03, 1.165e-05, 8.155e-03, 9.558e-03, -2.344e-02, 9.322e-03, 7.299e-03, 5.905e-03) * s1_2_0;
	r0 += M4(1.109e-02, 5.489e-03, -4.115e-02, 5.375e-02, 2.035e-01, 2.003e-01, -3.252e-01, -2.181e-01, 1.175e-02, 2.001e-02, -4.138e-02, -1.120e-02, -1.718e-02, 3.643e-02, 8.998e-03, 1.329e-01) * s1_2_1;
	r0 += M4(1.022e-02, -4.001e-03, 3.875e-03, -4.902e-02, 2.162e-02, 5.688e-02, 5.110e-03, -1.049e-01, 5.619e-03, -2.954e-03, 1.359e-02, 5.460e-04, 1.514e-03, 1.612e-03, 9.225e-03, 8.879e-03) * s1_2_2;
	s0_0_0 = G[2][xy.y+0][xy.x+0]; s0_0_1 = G[2][xy.y+0][xy.x+1];
	s0_0_2 = G[2][xy.y+0][xy.x+2]; s0_1_0 = G[2][xy.y+1][xy.x+0];
	s0_1_1 = G[2][xy.y+1][xy.x+1]; s0_1_2 = G[2][xy.y+1][xy.x+2];
	s0_2_0 = G[2][xy.y+2][xy.x+0]; s0_2_1 = G[2][xy.y+2][xy.x+1];
	s0_2_2 = G[2][xy.y+2][xy.x+2]; s1_0_0 = G[3][xy.y+0][xy.x+0];
	s1_0_1 = G[3][xy.y+0][xy.x+1]; s1_0_2 = G[3][xy.y+0][xy.x+2];
	s1_1_0 = G[3][xy.y+1][xy.x+0]; s1_1_1 = G[3][xy.y+1][xy.x+1];
	s1_1_2 = G[3][xy.y+1][xy.x+2]; s1_2_0 = G[3][xy.y+2][xy.x+0];
	s1_2_1 = G[3][xy.y+2][xy.x+1]; s1_2_2 = G[3][xy.y+2][xy.x+2];
	r0 += M4(1.486e-02, 5.938e-03, 1.974e-03, 3.635e-03, -1.232e-02, -2.475e-03, -1.770e-03, 2.338e-04, 2.416e-02, -1.228e-02, 4.604e-03, -4.129e-03, 1.828e-02, 1.950e-03, 4.606e-04, 7.268e-04) * s0_0_0;
	r0 += M4(1.575e-02, -1.349e-02, -1.378e-02, 6.531e-03, -2.961e-02, -2.675e-02, 1.929e-03, -8.082e-04, 9.350e-02, 3.095e-02, 5.183e-02, -1.172e-02, 4.535e-02, 4.676e-02, 6.676e-05, 4.564e-04) * s0_0_1;
	r0 += M4(9.030e-03, 8.391e-03, -4.510e-03, -4.898e-03, -8.644e-03, -2.171e-02, 2.044e-04, 1.779e-03, 1.669e-02, -6.318e-02, 4.984e-03, 2.957e-03, -3.292e-03, 1.118e-02, -3.850e-04, -3.072e-03) * s0_0_2;
	r0 += M4(3.466e-04, -1.855e-02, -4.204e-04, 1.297e-02, -1.148e-02, 4.899e-03, -4.748e-02, -3.355e-03, 6.067e-02, -9.401e-05, 6.272e-02, -2.945e-02, 4.772e-02, 5.505e-03, 5.162e-02, 6.244e-03) * s0_1_0;
	r0 += M4(-5.038e-01, 9.007e-02, 3.170e-01, 6.054e-02, 2.016e-01, 4.868e-02, -5.701e-02, -1.135e-01, 1.607e-01, 1.030e-01, -5.340e-01, -8.306e-03, 1.430e-01, 1.372e-01, 1.422e-01, 1.431e-01) * s0_1_1;
	r0 += M4(5.849e-03, 3.925e-02, -3.900e-04, 2.550e-02, -1.499e-02, 3.625e-02, -2.128e-02, -2.440e-02, -2.877e-03, 5.272e-02, 3.414e-02, -1.013e-01, 1.517e-03, 4.505e-02, 4.899e-04, 4.553e-02) * s0_1_2;
	r0 += M4(6.005e-04, -7.080e-03, -1.023e-02, -9.081e-03, -1.989e-02, -5.784e-03, 5.056e-02, -2.228e-03, -1.004e-02, -2.458e-04, 1.327e-02, -1.502e-03, -2.347e-03, 5.502e-05, 1.444e-02, 2.835e-03) * s0_2_0;
	r0 += M4(2.395e-02, -1.217e-02, 8.812e-02, -2.970e-02, -2.776e-02, -5.529e-02, -8.156e-03, 1.368e-01, -1.553e-02, -2.180e-02, 7.170e-02, 3.655e-02, 1.210e-03, -1.404e-03, 4.736e-02, 4.386e-02) * s0_2_1;
	r0 += M4(8.279e-03, -3.746e-02, -5.781e-03, -2.741e-02, 1.398e-02, -1.289e-02, -1.473e-02, -7.237e-03, -8.090e-03, -3.269e-03, -1.866e-02, 1.953e-03, 1.560e-05, -1.503e-03, -9.311e-04, 1.664e-02) * s0_2_2;
	r0 += M4(-1.168e-02, 9.777e-03, -4.914e-03, 3.716e-03, 2.448e-01, -2.748e-01, 1.490e-01, -1.239e-01, 9.065e-03, -1.278e-03, 4.469e-03, 2.737e-04, -1.156e-02, -2.236e-03, -5.539e-04, -1.311e-03) * s1_0_0;
	r0 += M4(-1.884e-01, 1.461e-02, 1.884e-02, -9.820e-03, -1.775e-02, 1.938e-02, -1.033e-02, -9.135e-03, 6.790e-02, 4.169e-02, -7.929e-04, 3.888e-03, -4.166e-02, -4.089e-02, 9.892e-05, 7.548e-04) * s1_0_1;
	r0 += M4(-7.010e-03, 1.550e-01, 2.326e-03, 3.962e-02, 4.717e-04, -8.951e-03, 6.770e-05, -6.208e-03, 1.076e-03, -1.886e-02, -6.373e-04, -5.908e-03, 1.242e-03, -1.002e-02, 1.638e-06, 1.264e-03) * s1_0_2;
	r0 += M4(1.378e-02, -1.885e-03, 5.139e-03, 3.200e-03, 8.693e-03, -2.555e-02, 1.007e-01, -1.266e-01, 9.607e-02, -1.148e-03, 3.474e-02, 1.563e-03, -4.050e-02, 8.839e-04, -4.003e-02, 1.506e-03) * s1_1_0;
	r0 += M4(-7.368e-02, 2.890e-02, -3.429e-01, 6.092e-02, -1.411e-02, 1.203e-02, -2.195e-02, 3.856e-02, -2.532e-01, 2.725e-01, -3.908e-03, 1.870e-01, -1.275e-01, -1.294e-01, -1.305e-01, -1.294e-01) * s1_1_1;
	r0 += M4(-1.225e-02, 1.329e-01, -1.757e-02, 2.193e-01, -7.060e-04, -6.908e-03, 1.819e-04, -9.051e-03, 1.778e-02, -1.475e-01, -6.203e-03, -1.008e-01, 1.795e-03, -3.704e-02, 1.997e-03, -4.285e-02) * s1_1_2;
	r0 += M4(1.379e-03, 3.991e-04, 4.018e-03, 1.362e-04, 1.178e-02, -2.937e-03, 2.273e-02, -8.646e-03, 5.750e-02, -2.121e-03, 1.184e-01, -5.654e-03, 8.235e-04, 5.427e-05, -1.291e-02, -1.289e-05) * s1_2_0;
	r0 += M4(-1.372e-02, 2.727e-03, 3.771e-02, -3.165e-03, 3.982e-03, -7.894e-04, 3.496e-03, -4.302e-03, -8.503e-03, -5.625e-02, -2.094e-01, 6.322e-02, 7.409e-04, 4.066e-03, -4.212e-02, -4.509e-02) * s1_2_1;
	r0 += M4(-7.540e-03, -1.420e-02, -9.805e-03, 1.206e-02, -2.836e-04, 7.777e-04, -1.050e-03, -9.304e-04, 8.275e-03, 2.812e-02, 3.028e-02, -4.430e-02, -1.331e-04, 2.169e-03, -1.090e-04, -9.435e-03) * s1_2_2;
	r0 += V4(-1.432e-08, -1.429e-08, -6.701e-09, -1.213e-08);
	r0 = tanh(r0);
	vec2 opt = 0.5 * LUMA_pt;
	vec2 fpos = (vec2(opos) + vec2(0.5)) * opt;
	imageStore(out_image, opos + ivec2(0, 0), vec4(r0.x + LUMA_tex(fpos + vec2(0.0, 0.0) * opt).r, 0.0, 0.0, 1.0));
	imageStore(out_image, opos + ivec2(1, 0), vec4(r0.y + LUMA_tex(fpos + vec2(1.0, 0.0) * opt).r, 0.0, 0.0, 1.0));
	imageStore(out_image, opos + ivec2(0, 1), vec4(r0.z + LUMA_tex(fpos + vec2(0.0, 1.0) * opt).r, 0.0, 0.0, 1.0));
	imageStore(out_image, opos + ivec2(1, 1), vec4(r0.w + LUMA_tex(fpos + vec2(1.0, 1.0) * opt).r, 0.0, 0.0, 1.0));
}
