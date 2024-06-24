// CuNNy 2x8 DS
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


//!DESC CuNNy-2x8-DS-in
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
	r0 += V4(1.233e-01, -1.179e-01, -6.361e-02, 2.039e-02) * s0_0_0;
	r1 += V4(1.113e-02, 6.417e-02, 1.362e-02, -6.204e-02) * s0_0_0;
	r0 += V4(1.216e-01, -1.204e-01, 5.263e-02, -4.695e-01) * s0_0_1;
	r1 += V4(8.582e-01, -1.106e-01, -6.183e-02, 2.316e-02) * s0_0_1;
	r0 += V4(2.113e-01, -1.870e-01, 3.428e-01, -2.123e-01) * s0_0_2;
	r1 += V4(2.591e-03, 4.676e-02, -9.855e-02, 4.499e-02) * s0_0_2;
	r0 += V4(-5.771e-02, 1.297e-01, 2.661e-01, 8.577e-04) * s0_1_0;
	r1 += V4(-4.307e-02, 8.800e-01, 5.968e-02, 7.519e-02) * s0_1_0;
	r0 += V4(-1.900e-01, 4.088e-01, -7.098e-01, -3.113e-01) * s0_1_1;
	r1 += V4(-7.949e-01, -8.371e-01, -4.696e-01, 6.617e-01) * s0_1_1;
	r0 += V4(-7.430e-02, 2.667e-01, -1.901e-01, 9.755e-01) * s0_1_2;
	r1 += V4(-3.041e-02, -5.060e-02, -1.284e-01, -5.453e-02) * s0_1_2;
	r0 += V4(6.695e-02, -1.321e-02, 3.330e-01, -1.619e-02) * s0_2_0;
	r1 += V4(3.258e-02, -2.953e-02, -2.168e-02, -1.743e-02) * s0_2_0;
	r0 += V4(2.382e-03, -7.558e-01, 1.189e-01, -2.021e-02) * s0_2_1;
	r1 += V4(-5.513e-02, 4.202e-02, 2.899e-02, 9.972e-02) * s0_2_1;
	r0 += V4(3.179e-02, 3.927e-01, -1.545e-01, 4.084e-02) * s0_2_2;
	r1 += V4(3.102e-02, -5.136e-03, 3.788e-02, -4.827e-02) * s0_2_2;
	r0 += V4(2.265e-02, 3.440e-05, 1.547e-02, -1.717e-03);
	r0 = max(r0, V4(0.0));
	imageStore(out_image, opos + ivec2(0, 0), vec4(r0));
	r1 += V4(-1.475e-02, -6.411e-07, 6.591e-01, 3.240e-02);
	r1 = max(r1, V4(0.0));
	imageStore(out_image, opos + ivec2(1, 0), vec4(r1));
}

//!DESC CuNNy-2x8-DS-conv1
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
	r0 = D(r0, s0_0_0, 0x1400F32A, 0x13F10A13, 0x05FB03F7, 0x03E03994);
	r1 = D(r1, s0_0_0, 0x03DD2504, 0x0800F400, 0x04C9F0D5, 0xED1B0CED);
	r0 = D(r0, s0_0_1, 0x28BB1B7F, 0xFE07C9E9, 0x0A13F125, 0xF802BE4C);
	r1 = D(r1, s0_0_1, 0x0A1681C2, 0x16E9D9ED, 0x08DFF801, 0x03EE12EE);
	r0 = D(r0, s0_0_2, 0x20E7C82C, 0x0110FADB, 0xF81908F4, 0x131024EA);
	r1 = D(r1, s0_0_2, 0xF41C2CD6, 0x18E7DA10, 0x002DE5E3, 0xFDF9F1F2);
	r0 = D(r0, s0_1_0, 0xF8F5F924, 0x7FF22403, 0xCE20E1FB, 0x30194681);
	r1 = D(r1, s0_1_0, 0x55E9DDDE, 0x12F3F8F5, 0x56E5F1EB, 0xFCFA131E);
	r0 = D(r0, s0_1_1, 0x14A3F20E, 0xDFD0101D, 0xECFFEEE1, 0x7FCBF50C);
	r1 = D(r1, s0_1_1, 0x9FDD3D2F, 0x18C3E5DC, 0x1B0FC642, 0x41BC1FEF);
	r0 = D(r0, s0_1_2, 0x16B8F2C2, 0x020F08E9, 0xEA102900, 0x080306CC);
	r1 = D(r1, s0_1_2, 0xF253FCDC, 0x0AE6F3F7, 0x09F6003E, 0x00F6F50B);
	r0 = D(r0, s0_2_0, 0x1DFAFDE3, 0xF6FB0816, 0x0FF8FD11, 0xF70A09D9);
	r1 = D(r1, s0_2_0, 0xB1011400, 0x0DFA0613, 0x44F8FD0A, 0x030604F4);
	r0 = D(r0, s0_2_1, 0x31EC02E3, 0xF9060026, 0x0C0819F6, 0x1DF10F5C);
	r1 = D(r1, s0_2_1, 0x81FB035B, 0x17FA0113, 0xD7FFF9C6, 0x27FA0B36);
	r0 = D(r0, s0_2_2, 0x08F7EBDB, 0x1017F7EB, 0xFAFE1126, 0xF81706A4);
	r1 = D(r1, s0_2_2, 0xFDFB1418, 0xFE030321, 0xF9E8F418, 0xFC10F4D6);
	r0 = D(r0, s1_0_0, 0x44F5F0DE, 0x21D50E13, 0xE3FE07FF, 0x8114330A);
	r1 = D(r1, s1_0_0, 0x0DE80C0C, 0x11FEFD00, 0x1C140EF3, 0xF111FCF1);
	r0 = D(r0, s1_0_1, 0xBF2CB3CA, 0x1D34141B, 0xE9F7F5FC, 0x812C7F65);
	r1 = D(r1, s1_0_1, 0x0732FC29, 0x0A14F7FC, 0x1BCE6B52, 0x16E50FF6);
	r0 = D(r0, s1_0_2, 0xB90DF30E, 0x07010B1B, 0x1508E7E8, 0x51D67FF7);
	r1 = D(r1, s1_0_2, 0xF4E5210B, 0x0BF91A16, 0xF71CE3FF, 0x3B09270D);
	r0 = D(r0, s1_1_0, 0xE7E801F2, 0xF1921926, 0x1501F00F, 0x3809FE0A);
	r1 = D(r1, s1_1_0, 0xFB051719, 0xF40D0305, 0x0BDC1B1C, 0x0607F700);
	r0 = D(r0, s1_1_1, 0xCD11352D, 0x2D814B3D, 0xC2451929, 0x81180639);
	r1 = D(r1, s1_1_1, 0x1DF08181, 0x2BB72630, 0xEEEBC159, 0xCC25197F);
	r0 = D(r0, s1_1_2, 0x57D2474D, 0xE6D13219, 0xD4F3FEEB, 0x92162F08);
	r1 = D(r1, s1_1_2, 0xFC0B81E8, 0xE7373921, 0xE93195EA, 0xE3D32E1C);
	r0 = D(r0, s1_2_0, 0x310FF61A, 0xE6811E0C, 0x0301EE0D, 0x13F100F5);
	r1 = D(r1, s1_2_0, 0xF0140B3E, 0x00F70807, 0x1DFE11F2, 0x04EDFB02);
	r0 = D(r0, s1_2_1, 0x05D80E17, 0x3C97117F, 0x76E1F371, 0x30F4F925);
	r1 = D(r1, s1_2_1, 0xE9E22E81, 0xE3131419, 0xAE4FC798, 0x25FD0AFD);
	r0 = D(r0, s1_2_2, 0xDC20FA07, 0x02EB0615, 0x170B1AF7, 0xDB1AEA0D);
	r1 = D(r1, s1_2_2, 0x1207C6D8, 0xF9FC24E3, 0x1BBCEF1D, 0xEB19E8FE);
	f0 = vec4(r0) * 6.2000124e-05;
	f0 += vec4(6.426e-03, -5.443e-01, -2.382e-01, -2.386e-01);
	f0 = max(f0, vec4(0.0));
	imageStore(out_image, opos + ivec2(0, 0), f0);
	f1 = vec4(r1) * 6.2000124e-05;
	f1 += vec4(3.753e-02, -6.845e-02, 1.499e-02, -8.520e-03);
	f1 = max(f1, vec4(0.0));
	imageStore(out_image, opos + ivec2(1, 0), f1);
}

//!DESC CuNNy-2x8-DS-conv2
//!HOOK LUMA
//!COMPUTE 16 8 8 8
//!BIND conv1
//!BIND LUMA
//!SAVE conv2
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h
//!COMPONENTS 4
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
	r0 = D(r0, s0_0_0, 0x0EFC3E24, 0x00F80E01, 0x00000309, 0x0D0513F0);
	r1 = D(r1, s0_0_0, 0x0CE10217, 0x00F60CFD, 0x06060C03, 0x0107EFFA);
	r0 = D(r0, s0_0_1, 0x0A416DF4, 0x0AEEF604, 0xFFD81007, 0x0337BBF0);
	r1 = D(r1, s0_0_1, 0x27148120, 0x03070E04, 0x0D0704FA, 0x06FA140B);
	r0 = D(r0, s0_0_2, 0x05F92905, 0xFB0F0F0F, 0xFB0B0C09, 0xFACF3EFB);
	r1 = D(r1, s0_0_2, 0xFB210B12, 0x040C1100, 0x07F8F6FE, 0x000310FE);
	r0 = D(r0, s0_1_0, 0xF8041BF1, 0x04080E18, 0x080F11F3, 0x03EC1EE5);
	r1 = D(r1, s0_1_0, 0xF9121DA1, 0x09F110D5, 0xFFFF10FB, 0x0808F202);
	r0 = D(r0, s0_1_1, 0x81FD40EF, 0x18EB81D9, 0x184081F2, 0x1114C819);
	r1 = D(r1, s0_1_1, 0x24FD1ECA, 0x0D42D0FA, 0x2C35DC1D, 0xFEF24DDD);
	r0 = D(r0, s0_1_2, 0x04FF1C00, 0xFBFE300F, 0x00FD0305, 0x0B07E0E1);
	r1 = D(r1, s0_1_2, 0x03E30605, 0xF4E0FDF2, 0x0E03EBFD, 0x14FA810B);
	r0 = D(r0, s0_2_0, 0xF8FFFF04, 0x06FB012C, 0x0400090A, 0xF804F5E7);
	r1 = D(r1, s0_2_0, 0x01FBF139, 0xFC03FCDC, 0x070106FD, 0x1BFBFE12);
	r0 = D(r0, s0_2_1, 0xFAFF0500, 0x1EEE1BBF, 0x2FF2FF03, 0x16FE0809);
	r1 = D(r1, s0_2_1, 0xD2F9F41D, 0x18EB2715, 0x3AFB0F01, 0xD3021A09);
	r0 = D(r0, s0_2_2, 0x050104FB, 0xF404021C, 0x04FD17FA, 0x03F703E7);
	r1 = D(r1, s0_2_2, 0x0701EEF6, 0xFE11E8D6, 0x22FC13F9, 0x0AFC00FF);
	r0 = D(r0, s1_0_0, 0x0A03FBFE, 0xF00B18E4, 0xFDFFFEFD, 0x14FA1EDD);
	r1 = D(r1, s1_0_0, 0x29F6C581, 0xFC000CF9, 0x020109F8, 0x00FEF309);
	r0 = D(r0, s1_0_1, 0xFBEB0FD4, 0x0BF8F3BF, 0xFD06EAF5, 0x37BED5E4);
	r1 = D(r1, s1_0_1, 0x36FCA381, 0x0EFDF3F8, 0x0FFD0AEB, 0x09FD14F7);
	r0 = D(r0, s1_0_2, 0xFE000309, 0xFF03070A, 0xF70B0502, 0xD40414F3);
	r1 = D(r1, s1_0_2, 0xF70EF7F6, 0xFCFB0B00, 0x0EF2F8F4, 0x04B40DD4);
	r0 = D(r0, s1_1_0, 0x18FE0A02, 0x05FE43CA, 0x14FF1AE7, 0xF7FCECFE);
	r1 = D(r1, s1_1_0, 0x021F4D04, 0x09FBFEF8, 0xFEFF11F1, 0xF004C811);
	r0 = D(r0, s1_1_1, 0x1704FCFF, 0x1CCBA9C4, 0x3AE6FEE5, 0x19EC0BBC);
	r1 = D(r1, s1_1_1, 0xB603520C, 0x32E203D9, 0x0303EDFA, 0x04F843EE);
	r0 = D(r0, s1_1_2, 0xFC0D0101, 0xEB0C1115, 0x01F3F9F4, 0x18DADDE1);
	r1 = D(r1, s1_1_2, 0xE6F90113, 0xFDCEEDDD, 0x0417FFEE, 0x1281F7A4);
	r0 = D(r0, s1_2_0, 0xFAFD00FD, 0xFFE6FCDC, 0xFB03FFF8, 0x1503F806);
	r1 = D(r1, s1_2_0, 0xD800ECFA, 0x0FFFF30E, 0x04FD05FF, 0x0101F5FD);
	r0 = D(r0, s1_2_1, 0xFD070102, 0x19FF09FB, 0xE80EEDE3, 0xF0E7F7F8);
	r1 = D(r1, s1_2_1, 0xF70CF706, 0xEBF000EC, 0xF901F8F3, 0x08F709F4);
	r0 = D(r0, s1_2_2, 0x05F8FDFB, 0xE012FF04, 0xFE0FFF04, 0x0FFBF6FC);
	r1 = D(r1, s1_2_2, 0x080308FF, 0x2CD7D3DF, 0x03F5FBFD, 0xF402F9D3);
	f0 = vec4(r0) * 6.2000124e-05;
	f0 += vec4(6.403e-03, -1.358e-02, 6.989e-03, 4.792e-03);
	f0 = max(f0, vec4(0.0));
	imageStore(out_image, opos + ivec2(0, 0), f0);
	f1 = vec4(r1) * 6.2000124e-05;
	f1 += vec4(-2.744e-02, 2.829e-03, 1.314e-02, -9.844e-03);
	f1 = max(f1, vec4(0.0));
	imageStore(out_image, opos + ivec2(1, 0), f1);
}

//!DESC CuNNy-2x8-DS-out-shuffle
//!HOOK LUMA
//!COMPUTE 16 16 8 8
//!BIND conv2
//!BIND LUMA
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h 2 *
//!COMPONENTS 1
//!WHEN OUTPUT.w LUMA.w / 1.3 > OUTPUT.h LUMA.h / 1.3 > *
#extension GL_EXT_spirv_intrinsics : require
#define l0(x, y) conv2_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(2, 1) + ivec2(0, 0)) + vec2(0.5)) * conv2_pt)
#define l1(x, y) conv2_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(2, 1) + ivec2(1, 0)) + vec2(0.5)) * conv2_pt)
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
	r0 = D(r0, s0_0_0, 0x121AFB00, 0x06FB0000, 0xF9030100, 0xFA000100);
	r0 = D(r0, s0_0_1, 0xFEFC09FF, 0x031D0D00, 0x000A0A01, 0xF901F901);
	r0 = D(r0, s0_0_2, 0xFF020900, 0xFE00EDFE, 0xFF010200, 0xFF0A0000);
	r0 = D(r0, s0_1_0, 0x02210EFF, 0x01FAFF00, 0x06050900, 0x0101FC01);
	r0 = D(r0, s0_1_1, 0x0BFEB817, 0xAF2A060B, 0x1DACD1FC, 0x0AC13C01);
	r0 = D(r0, s0_1_2, 0xFE0A06FF, 0x0D0B1009, 0x01081002, 0xFEF5EEFC);
	r0 = D(r0, s0_2_0, 0x08FCFFFC, 0xF2FBFE00, 0x2D1005FD, 0xF4F7FEFE);
	r0 = D(r0, s0_2_1, 0xF9F4031A, 0x18F9FF14, 0xED02F733, 0xF018F923);
	r0 = D(r0, s0_2_2, 0xFE0101FA, 0xFFFDFBFD, 0xFB03FEFC, 0x0604090B);
	r0 = D(r0, s1_0_0, 0xF104A7FF, 0xFAFF1000, 0x01000C00, 0x00FF1400);
	r0 = D(r0, s1_0_1, 0x00071000, 0x120E07FE, 0xFE01EF00, 0xFD011C00);
	r0 = D(r0, s1_0_2, 0x010001FE, 0xFEFEFEFF, 0xFFFF0000, 0xFF01FF00);
	r0 = D(r0, s1_1_0, 0x31C21FFE, 0xE9051200, 0x16F9C1FF, 0xD80425FF);
	r0 = D(r0, s1_1_1, 0xEDEB0104, 0x06900301, 0xF0FD18FD, 0x29F4CCFE);
	r0 = D(r0, s1_1_2, 0x01FD0004, 0xFE0D0108, 0x020303FE, 0xFF0003FD);
	r0 = D(r0, s1_2_0, 0x000CFB03, 0xFB0B0000, 0x0CE7FF04, 0xF70B02FC);
	r0 = D(r0, s1_2_1, 0x0204FCC4, 0x0304FBE9, 0xFE020020, 0xFCDB0420);
	r0 = D(r0, s1_2_2, 0x0100000B, 0x0002FDEA, 0x00FCFF00, 0xFE02030A);
	f0 = vec4(r0) * 6.2000124e-05;
	f0 += vec4(-1.304e-08, -1.472e-08, -1.632e-08, -2.787e-08);
	f0 = tanh(f0);
	vec2 opt = 0.5 * LUMA_pt;
	vec2 fpos = (vec2(opos) + vec2(0.5)) * opt;
	imageStore(out_image, opos + ivec2(0, 0), vec4(f0.x + LUMA_tex(fpos + vec2(0.0, 0.0) * opt).r, 0.0, 0.0, 1.0));
	imageStore(out_image, opos + ivec2(1, 0), vec4(f0.y + LUMA_tex(fpos + vec2(1.0, 0.0) * opt).r, 0.0, 0.0, 1.0));
	imageStore(out_image, opos + ivec2(0, 1), vec4(f0.z + LUMA_tex(fpos + vec2(0.0, 1.0) * opt).r, 0.0, 0.0, 1.0));
	imageStore(out_image, opos + ivec2(1, 1), vec4(f0.w + LUMA_tex(fpos + vec2(1.0, 1.0) * opt).r, 0.0, 0.0, 1.0));
}
