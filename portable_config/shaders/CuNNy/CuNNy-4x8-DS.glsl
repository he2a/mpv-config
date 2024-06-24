// CuNNy 4x8 DS
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


//!DESC CuNNy-4x8-DS-in
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
	r0 += V4(1.028e-01, 2.512e-02, 8.578e-02, -2.821e-02) * s0_0_0;
	r1 += V4(1.703e-01, 7.350e-03, 1.088e-03, -6.457e-03) * s0_0_0;
	r0 += V4(5.114e-01, 2.455e-02, -1.421e-01, -5.001e-03) * s0_0_1;
	r1 += V4(-9.386e-03, 9.064e-02, 7.947e-03, 3.190e-02) * s0_0_1;
	r0 += V4(-3.775e-02, -5.971e-02, 4.612e-02, -4.777e-02) * s0_0_2;
	r1 += V4(1.686e-01, 4.203e-02, -1.810e-02, -2.039e-02) * s0_0_2;
	r0 += V4(-8.991e-02, -3.359e-01, -1.076e-01, -6.661e-02) * s0_1_0;
	r1 += V4(1.224e-01, 1.679e-01, -6.295e-02, 1.109e-02) * s0_1_0;
	r0 += V4(-4.078e-01, 4.272e-01, 7.868e-01, 7.402e-01) * s0_1_1;
	r1 += V4(-3.038e+00, -8.268e-01, 3.776e-03, 6.855e-01) * s0_1_1;
	r0 += V4(-1.674e-02, -6.478e-02, -6.570e-01, -7.606e-03) * s0_1_2;
	r1 += V4(1.146e-01, 2.220e-01, -1.378e-02, 3.578e-02) * s0_1_2;
	r0 += V4(-6.323e-02, -4.376e-01, -1.691e-02, 5.675e-02) * s0_2_0;
	r1 += V4(2.538e-02, -4.455e-02, -5.656e-02, -1.435e-02) * s0_2_0;
	r0 += V4(-3.808e-02, 2.900e-01, -1.361e-01, -6.285e-02) * s0_2_1;
	r1 += V4(2.315e-01, 1.217e-01, 2.640e-01, -7.100e-01) * s0_2_1;
	r0 += V4(5.408e-02, 1.397e-01, 1.474e-01, -3.390e-02) * s0_2_2;
	r1 += V4(2.884e-02, 6.614e-03, -4.828e-02, -1.089e-02) * s0_2_2;
	r0 += V4(1.606e-02, 2.347e-02, -1.560e-02, -4.774e-03);
	r0 = max(r0, V4(0.0));
	imageStore(out_image, opos + ivec2(0, 0), vec4(r0));
	r1 += V4(4.254e-02, 9.770e-02, 1.718e-02, 4.489e-04);
	r1 = max(r1, V4(0.0));
	imageStore(out_image, opos + ivec2(1, 0), vec4(r1));
}

//!DESC CuNNy-4x8-DS-conv1
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
	r0 = D(r0, s0_0_0, 0xFBF61CE9, 0xFF0AFCFE, 0xF70EE90A, 0xFD0721FB);
	r1 = D(r1, s0_0_0, 0xFD0305FE, 0x02FAF7FF, 0x06F80703, 0x36D909F3);
	r0 = D(r0, s0_0_1, 0x14C64302, 0x08FEF40B, 0x0A06FB06, 0x10FEF0F6);
	r1 = D(r1, s0_0_1, 0xFE01F400, 0x0DFEF7FE, 0x18EB22FC, 0x05ED20EF);
	r0 = D(r0, s0_0_2, 0x19F1F608, 0xFA010EF8, 0x00F75BF6, 0xF7042A0B);
	r1 = D(r1, s0_0_2, 0x05F5F7FE, 0xFF08FDFB, 0xE8051515, 0xF50810FC);
	r0 = D(r0, s0_1_0, 0x0D5AE4DE, 0x0BF104F8, 0x0CE8FAEE, 0xF820E01A);
	r1 = D(r1, s0_1_0, 0xF8030F08, 0x47E407F1, 0xF00CFE09, 0xF537B7C4);
	r0 = D(r0, s0_1_1, 0xA2DDE9D4, 0x5E1F0B12, 0xD0310420, 0x0136EC38);
	r1 = D(r1, s0_1_1, 0xE7000EEA, 0xF400DEF1, 0x30100233, 0x160A10ED);
	r0 = D(r0, s0_1_2, 0x18F8B728, 0x0BF6F1F2, 0x3006220B, 0x22E27F84);
	r1 = D(r1, s0_1_2, 0x10EB3CF3, 0xEF00EFDE, 0x0B053247, 0x1AF9E3F1);
	r0 = D(r0, s0_2_0, 0x15301DF0, 0x050A000C, 0xF3D708F9, 0xD1EF0DEA);
	r1 = D(r1, s0_2_0, 0xDD39EE0F, 0x0C08FB25, 0x04FD0107, 0xA1EA48A6);
	r0 = D(r0, s0_2_1, 0x072BE506, 0x0AF00307, 0xF906F90E, 0x0101EB14);
	r1 = D(r1, s0_2_1, 0xBF81F0CB, 0xBAFD0A6A, 0xBF16FA25, 0xDF183AE1);
	r0 = D(r0, s0_2_2, 0x01FB13EF, 0xFE05FDFD, 0x0111FFDA, 0x1416C408);
	r1 = D(r1, s0_2_2, 0x73FA1A29, 0x02F80D16, 0x0302F326, 0xEBF50DFD);
	r0 = D(r0, s1_0_0, 0x5890020F, 0x0002FB03, 0xFB2CF002, 0xE7CEE1FD);
	r1 = D(r1, s1_0_0, 0xF5F8FD03, 0x05090610, 0x09F1FCFD, 0xF87F49F6);
	r0 = D(r0, s1_0_1, 0xFFD8001A, 0x072DFDF9, 0x21BFF0E6, 0xFF24011D);
	r1 = D(r1, s1_0_1, 0x0F1CFA05, 0x1400070A, 0x9D0FFBFE, 0x0FF440FA);
	r0 = D(r0, s1_0_2, 0xA1FD0505, 0x0C01020C, 0x32F30B1B, 0x2FE00816);
	r1 = D(r1, s1_0_2, 0x0BEB050C, 0x14EDFE00, 0xE4E0F401, 0x19092304);
	r0 = D(r0, s1_1_0, 0x0805F71C, 0x01ED03FC, 0xEC5F03FA, 0x04F4120F);
	r1 = D(r1, s1_1_0, 0xFCEA03FB, 0xE5F2ED16, 0xF9DBF91D, 0x0ECC81EB);
	r0 = D(r0, s1_1_1, 0x32F0237F, 0xF8DF0EE0, 0xE620102F, 0x81382B2F);
	r1 = D(r1, s1_1_1, 0x3F88000A, 0xFDCB040E, 0xD2D616FB, 0x3814D4FF);
	r0 = D(r0, s1_1_2, 0xEC2E1223, 0xFAF0F9F6, 0x1EF0F60D, 0xA6F400E6);
	r1 = D(r1, s1_1_2, 0xCB3D0608, 0x0313F40E, 0x07220203, 0xEF28FC01);
	r0 = D(r0, s1_2_0, 0xF5C803FE, 0xFFF80307, 0x04F7F802, 0x2CEFE9ED);
	r1 = D(r1, s1_2_0, 0x0112F1FF, 0xF117071C, 0xFF12090B, 0xDB818181);
	r0 = D(r0, s1_2_1, 0x0F42D506, 0x0308FEFD, 0xFF000907, 0xE0F20A3A);
	r1 = D(r1, s1_2_1, 0x2134ED17, 0x111E1356, 0x031F082A, 0x2705B581);
	r0 = D(r0, s1_2_2, 0xFF14F2FB, 0xFF160003, 0xF3D6021B, 0xF01BEF26);
	r1 = D(r1, s1_2_2, 0xE7001AF4, 0x00FBF802, 0x0910FDFF, 0x10DFF60B);
	f0 = vec4(r0) * 6.2000124e-05;
	f0 += vec4(3.283e-02, -4.653e-03, -3.161e-02, 1.226e-02);
	f0 = max(f0, vec4(0.0));
	imageStore(out_image, opos + ivec2(0, 0), f0);
	f1 = vec4(r1) * 6.2000124e-05;
	f1 += vec4(-2.399e-04, -8.842e-03, 3.094e-02, 3.055e-02);
	f1 = max(f1, vec4(0.0));
	imageStore(out_image, opos + ivec2(1, 0), f1);
}

//!DESC CuNNy-4x8-DS-conv2
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
	r0 = D(r0, s0_0_0, 0x3FF0EBD0, 0xF707F509, 0x09F6CFE7, 0xFE02FCFF);
	r1 = D(r1, s0_0_0, 0xFEF8FE04, 0x060E0503, 0xFEFCF918, 0xF004310B);
	r0 = D(r0, s0_0_1, 0xF6100ABD, 0x05F70316, 0xD60A1EF8, 0x07000002);
	r1 = D(r1, s0_0_1, 0xF109FB23, 0x0904F8EC, 0xF4020420, 0x10F51BDF);
	r0 = D(r0, s0_0_2, 0x14FBF4FB, 0xFA081205, 0x0AFD0BF4, 0xFF01FB00);
	r1 = D(r1, s0_0_2, 0x0501010E, 0x06FFF504, 0xFA050409, 0xEBFA000C);
	r0 = D(r0, s0_1_0, 0xFAAF1CE3, 0x22FFECF6, 0xE5F72DF4, 0xF7DFE5FC);
	r1 = D(r1, s0_1_0, 0xEE01F10D, 0xFBFA2A15, 0xCE1A060B, 0xFCF30E12);
	r0 = D(r0, s0_1_1, 0x81D720FA, 0x410AF5F7, 0xF8AB0DAB, 0x02050434);
	r1 = D(r1, s0_1_1, 0xE6D34B3D, 0x0FEDB329, 0x02233F1A, 0xFA09D232);
	r0 = D(r0, s0_1_2, 0xDED8C5D4, 0x020FFC07, 0x0FDBE7FA, 0x06FFFF05);
	r1 = D(r1, s0_1_2, 0x0F39F30F, 0x1413F501, 0xFC2CFF19, 0x04C9FF04);
	r0 = D(r0, s0_2_0, 0x2688DCE0, 0x27A6C116, 0x0DE6FAF7, 0xF900DEFF);
	r1 = D(r1, s0_2_0, 0xFC160205, 0xFD252D10, 0xEEE50D14, 0xF52C2F05);
	r0 = D(r0, s0_2_1, 0xEBB20FE4, 0x04E05645, 0x2FDDCC04, 0xFA13C510);
	r1 = D(r1, s0_2_1, 0xEC27F400, 0xEE110CFF, 0x077FAA49, 0xE20CC409);
	r0 = D(r0, s0_2_2, 0x198128C2, 0xFE0C07F6, 0x21EE1A0B, 0x060DF2FF);
	r1 = D(r1, s0_2_2, 0xFF1AFB01, 0x0A0C0403, 0xF92607FE, 0x0404E500);
	r0 = D(r0, s1_0_0, 0xFE1625D4, 0xF6FA000C, 0x00030A24, 0x090A0202);
	r1 = D(r1, s1_0_0, 0x0302F50D, 0xFD0904FF, 0xF9F908CB, 0x0CF4D354);
	r0 = D(r0, s1_0_1, 0xEC0C0035, 0x0DF1F9F0, 0x522A1745, 0xFA0D0FEA);
	r1 = D(r1, s1_0_1, 0xF6210316, 0x37260A07, 0xF2DBFEFF, 0x3300DDCC);
	r0 = D(r0, s1_0_2, 0xF12B3C3C, 0xF7EE02FE, 0x7F06341E, 0x2B06FE02);
	r1 = D(r1, s1_0_2, 0x36DEF9DF, 0x26FEF4E4, 0x7FF3E9EE, 0x8130F120);
	r0 = D(r0, s1_1_0, 0x19310B78, 0x12F8F684, 0xFD151011, 0xF8F9FBFB);
	r1 = D(r1, s1_1_0, 0x01FDFE0B, 0xF80EF61D, 0xF61EF3BE, 0xF0F7FD06);
	r0 = D(r0, s1_1_1, 0xE024FF12, 0x81E08181, 0xFBA5290E, 0xC70AFD05);
	r1 = D(r1, s1_1_1, 0xE81C1406, 0x16EE1509, 0x0024A590, 0x180D0312);
	r0 = D(r0, s1_1_2, 0x00B9035D, 0x810FF1FD, 0xEDEC26E2, 0xECEBFFF5);
	r1 = D(r1, s1_1_2, 0x12FE10EE, 0x2202EFF7, 0xA1DCB6F0, 0xD5F7F202);
	r0 = D(r0, s1_2_0, 0xF39B8B81, 0xFB0EFFF7, 0x01000DF5, 0x03F80204);
	r1 = D(r1, s1_2_0, 0x00FEFF01, 0xFA0BF905, 0xFA35F1FB, 0xFE03FF0A);
	r0 = D(r0, s1_2_1, 0x1DD75634, 0xF17FB1FD, 0xE7C11AF7, 0xF91105F8);
	r1 = D(r1, s1_2_1, 0x060A06FB, 0x17030009, 0x0437D8ED, 0x1A1A08FA);
	r0 = D(r0, s1_2_2, 0xED40DBD8, 0x25F71A06, 0x1B29F8F7, 0xFE05FEF9);
	r1 = D(r1, s1_2_2, 0xFA02FFFE, 0xF9F80202, 0xFE02D605, 0xE6FF0203);
	f0 = vec4(r0) * 6.2000124e-05;
	f0 += vec4(-2.115e-02, -3.244e-02, 4.982e-03, 6.153e-01);
	f0 = max(f0, vec4(0.0));
	imageStore(out_image, opos + ivec2(0, 0), f0);
	f1 = vec4(r1) * 6.2000124e-05;
	f1 += vec4(-1.346e-02, -2.956e-02, -3.543e-03, -1.902e-02);
	f1 = max(f1, vec4(0.0));
	imageStore(out_image, opos + ivec2(1, 0), f1);
}

//!DESC CuNNy-4x8-DS-conv3
//!HOOK LUMA
//!COMPUTE 16 8 8 8
//!BIND conv2
//!BIND LUMA
//!SAVE conv3
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h
//!COMPONENTS 4
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
	r0 = D(r0, s0_0_0, 0x0BF711F7, 0x13FCD4F7, 0xF1FEF4FE, 0xFD050803);
	r1 = D(r1, s0_0_0, 0x18FBDA0B, 0xFCF3D111, 0xDF09F9F9, 0xFC0410F4);
	r0 = D(r0, s0_0_1, 0xF0F2CD24, 0x610ACF02, 0x0BF0E2FA, 0xF8F0E3FE);
	r1 = D(r1, s0_0_1, 0xD6DEB0F1, 0x110A81E6, 0x8112FC04, 0x1A1EECFB);
	r0 = D(r0, s0_0_2, 0xFB00E4F8, 0x1DF8DB06, 0x03FE01F8, 0x0B0AE302);
	r1 = D(r1, s0_0_2, 0x10EA0909, 0xED11EB0D, 0xBF020106, 0xFBFA1A05);
	r0 = D(r0, s0_1_0, 0xD9E41FF4, 0xDEFB07F0, 0x0AE8D810, 0x0C04FEFE);
	r1 = D(r1, s0_1_0, 0x170AED20, 0x1301E818, 0xFAFFFC09, 0x01E5EC02);
	r0 = D(r0, s0_1_1, 0xD3E3813E, 0x9D05EBFD, 0x1A1DCA29, 0xEAEEF510);
	r1 = D(r1, s0_1_1, 0xE826F200, 0xC21AD1F9, 0x9907FAFB, 0xF6D49116);
	r0 = D(r0, s0_1_2, 0x2EF495E0, 0xEDFBEAFB, 0xE112DD0A, 0x1B29D8FE);
	r1 = D(r1, s0_1_2, 0x04090207, 0x260A18FE, 0xBA130C00, 0xFC1FD917);
	r0 = D(r0, s0_2_0, 0x23CA0BF8, 0x0506F7F3, 0x21180308, 0xF6FFFFFF);
	r1 = D(r1, s0_2_0, 0x09F90DEC, 0xF414F30E, 0xFAFCFE01, 0x00FD1605);
	r0 = D(r0, s0_2_1, 0xAC1FEB16, 0x06100FFA, 0xC7EE0DF8, 0x060DFEF8);
	r1 = D(r1, s0_2_1, 0x0EDEF9ED, 0x25F0FBFA, 0xF6090200, 0xF740DCFD);
	r0 = D(r0, s0_2_2, 0x56CC8BE6, 0x04FF0B01, 0x180234FF, 0x0AEAEEF9);
	r1 = D(r1, s0_2_2, 0xF1F702F9, 0xF4070204, 0x03F808FD, 0x0CE9E0F3);
	r0 = D(r0, s1_0_0, 0xFAF6FD02, 0x09E6F502, 0xFE24F804, 0xFD000203);
	r1 = D(r1, s1_0_0, 0xF5E60B1C, 0xF402E909, 0xFAF61A04, 0x0EF602E6);
	r0 = D(r0, s1_0_1, 0x10FB0E0B, 0x1C07E911, 0xEAE0FB02, 0xFAFBE70D);
	r1 = D(r1, s1_0_1, 0x0206F006, 0xECBB1011, 0xFCF71B0F, 0x0D1404DC);
	r0 = D(r0, s1_0_2, 0xF6FC0B07, 0x0E12EB07, 0x00000304, 0xF8F312FB);
	r1 = D(r1, s1_0_2, 0x0102F5F7, 0x071000F5, 0xFAFB200A, 0x100CFAF4);
	r0 = D(r0, s1_1_0, 0x03F60903, 0xE017092B, 0xFFEB08F9, 0x0301F8F7);
	r1 = D(r1, s1_1_0, 0xEBFB22DE, 0xE3F8EA29, 0xF6FBFE14, 0x09FCE029);
	r0 = D(r0, s1_1_1, 0xF3E431DD, 0xC8C827D6, 0xEDD64BF2, 0xD8F0F958);
	r1 = D(r1, s1_1_1, 0x1AEADB64, 0xFFF456D4, 0x03ECAA73, 0x24DFA051);
	r0 = D(r0, s1_1_2, 0x15050B0F, 0xF2DA1200, 0xFFDFFE08, 0x09E01B18);
	r1 = D(r1, s1_1_2, 0x01F3F718, 0x07DCC00F, 0x00F8231E, 0xFAEF0402);
	r0 = D(r0, s1_2_0, 0x0A1406FA, 0x030DE9F4, 0xF50223E2, 0xFD04FD0E);
	r1 = D(r1, s1_2_0, 0x010405EF, 0xF8F207F3, 0xFEF90A01, 0xF7FD0B08);
	r0 = D(r0, s1_2_1, 0x1CE0C4D2, 0xED2AE33D, 0xBDE0EE37, 0xEC0211F8);
	r1 = D(r1, s1_2_1, 0x080014DF, 0xEFFD180B, 0x0CEF0205, 0xE6FF1CE4);
	r0 = D(r0, s1_2_2, 0x17042506, 0xF414E9F7, 0xF6CAE708, 0x06030101);
	r1 = D(r1, s1_2_2, 0x1106FFFE, 0x14FBE6F2, 0x0AFA0007, 0x0301F112);
	f0 = vec4(r0) * 6.2000124e-05;
	f0 += vec4(1.920e-02, -5.958e-02, -1.191e-02, -9.380e-02);
	f0 = max(f0, vec4(0.0));
	imageStore(out_image, opos + ivec2(0, 0), f0);
	f1 = vec4(r1) * 6.2000124e-05;
	f1 += vec4(-4.704e-02, -7.940e-03, -7.160e-02, -4.566e-02);
	f1 = max(f1, vec4(0.0));
	imageStore(out_image, opos + ivec2(1, 0), f1);
}

//!DESC CuNNy-4x8-DS-conv4
//!HOOK LUMA
//!COMPUTE 16 8 8 8
//!BIND conv3
//!BIND LUMA
//!SAVE conv4
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h
//!COMPONENTS 4
//!WHEN OUTPUT.w LUMA.w / 1.3 > OUTPUT.h LUMA.h / 1.3 > *
#extension GL_EXT_spirv_intrinsics : require
#define l0(x, y) conv3_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(2, 1) + ivec2(0, 0)) + vec2(0.5)) * conv3_pt)
#define l1(x, y) conv3_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(2, 1) + ivec2(1, 0)) + vec2(0.5)) * conv3_pt)
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
	r0 = D(r0, s0_0_0, 0x00FFFFFD, 0xFAEAFB60, 0xBBEFF8EB, 0x0002FEFC);
	r1 = D(r1, s0_0_0, 0xFDFDFE00, 0x06FAFCF9, 0xFAE30138, 0xF8CBFAFE);
	r0 = D(r0, s0_0_1, 0x01F50147, 0xEEF90608, 0xD3DAF9ED, 0x07EC014C);
	r1 = D(r1, s0_0_1, 0xFD14FD53, 0x023AEFFB, 0xED21FF4C, 0xFACC0AF8);
	r0 = D(r0, s0_0_2, 0x00030202, 0xF408FCF9, 0x0904F6FD, 0x000CFCFB);
	r1 = D(r1, s0_0_2, 0xFC010100, 0x00060400, 0xF6E304F5, 0xFDFC00FF);
	r0 = D(r0, s0_1_0, 0x1AFCFDF8, 0xB10A000D, 0xED0304F9, 0x130401FD);
	r1 = D(r1, s0_1_0, 0xFF0A0601, 0x10EAF70B, 0xB1D7FF06, 0x0B0813FA);
	r0 = D(r0, s0_1_1, 0x19060B2D, 0x16F20AF7, 0xF1EF0019, 0x0D131B0C);
	r1 = D(r1, s0_1_1, 0x16F42E0C, 0xD48163FE, 0x4534F9F5, 0x12205B08);
	r0 = D(r0, s0_1_2, 0xFF0F01F7, 0x0CFDFDFB, 0xEDFFF312, 0x02020401);
	r1 = D(r1, s0_1_2, 0x01FC0505, 0xF7ED0705, 0x06E10411, 0x06FAF3F1);
	r0 = D(r0, s0_2_0, 0x100404FE, 0xEBFDF803, 0xBBEE0EFD, 0x07FFFFFF);
	r1 = D(r1, s0_2_0, 0x00010300, 0xF2FC00FA, 0xF7F7FC03, 0xFEFC04FF);
	r0 = D(r0, s0_2_1, 0xF40832FF, 0x060703F7, 0xE7F1E7EF, 0xFBFFFEFF);
	r1 = D(r1, s0_2_1, 0xFC03F802, 0x0B010502, 0x030504F9, 0xEEFCF1FE);
	r0 = D(r0, s0_2_2, 0x04020100, 0xFEFCFCFC, 0xB4F202E4, 0x010104FF);
	r1 = D(r1, s0_2_2, 0xFB0102FF, 0x0100F701, 0xECF9F800, 0xF9FC0D05);
	r0 = D(r0, s1_0_0, 0xFF0000FD, 0xF6EEECFB, 0xE8FE0704, 0xFF0001FD);
	r1 = D(r1, s1_0_0, 0x03030000, 0x1002EAF9, 0xFBFAFC05, 0x04FF08F9);
	r0 = D(r0, s1_0_1, 0x071001FB, 0x04131F0B, 0x05110CFB, 0x070FFFF8);
	r1 = D(r1, s1_0_1, 0xFB0D0002, 0x17FEF51D, 0xE312EF0D, 0x351E10F0);
	r0 = D(r0, s1_0_2, 0x020A0403, 0xFF010B0A, 0xF1FAFAF1, 0x05090107);
	r1 = D(r1, s1_0_2, 0x040A0501, 0xFD07FAEE, 0xFB09050A, 0x0C06F5E1);
	r0 = D(r0, s1_1_0, 0x0407FFFD, 0x0A8105F4, 0xF400EBFC, 0x010800FE);
	r1 = D(r1, s1_1_0, 0x0109FEFE, 0xFD0A0F07, 0x08CEF101, 0xF9F4EE0A);
	r0 = D(r0, s1_1_1, 0xF1F5DE0E, 0x012BD847, 0xE4FFE5FF, 0xE2DDEE02);
	r1 = D(r1, s1_1_1, 0x142FFA05, 0x3CF5E3F0, 0xE2F96B20, 0xB381F726);
	r0 = D(r0, s1_1_2, 0x06140B12, 0xF90109DF, 0xF0F300EF, 0xFCE60901);
	r1 = D(r1, s1_1_2, 0x02140BFB, 0x02030711, 0xE92C1300, 0x0614FD2A);
	r0 = D(r0, s1_2_0, 0xF7060000, 0x07FF13FF, 0xD006FD00, 0xFC0301FF);
	r1 = D(r1, s1_2_0, 0xFE0407FF, 0x040EE8FE, 0x0007F502, 0x00110500);
	r0 = D(r0, s1_2_1, 0x0CBB1DE4, 0xF909EC15, 0xFB0609EF, 0x02FB11F5);
	r1 = D(r1, s1_2_1, 0xFE1A070A, 0xF123E9FA, 0xF9FCF4FB, 0x13F6E1EF);
	r0 = D(r0, s1_2_2, 0xFCF2E7FE, 0x0006F4F9, 0xE503040D, 0xFD0FF402);
	r1 = D(r1, s1_2_2, 0x010601FE, 0xFA01F8FD, 0xFE1E1B27, 0x09FAE3F8);
	f0 = vec4(r0) * 6.2000124e-05;
	f0 += vec4(-2.352e-03, -1.219e-02, -1.447e-01, -1.701e-03);
	f0 = max(f0, vec4(0.0));
	imageStore(out_image, opos + ivec2(0, 0), f0);
	f1 = vec4(r1) * 6.2000124e-05;
	f1 += vec4(2.451e-04, -1.566e-02, -8.174e-03, -1.612e-02);
	f1 = max(f1, vec4(0.0));
	imageStore(out_image, opos + ivec2(1, 0), f1);
}

//!DESC CuNNy-4x8-DS-out-shuffle
//!HOOK LUMA
//!COMPUTE 16 16 8 8
//!BIND conv4
//!BIND LUMA
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h 2 *
//!COMPONENTS 1
//!WHEN OUTPUT.w LUMA.w / 1.3 > OUTPUT.h LUMA.h / 1.3 > *
#extension GL_EXT_spirv_intrinsics : require
#define l0(x, y) conv4_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(2, 1) + ivec2(0, 0)) + vec2(0.5)) * conv4_pt)
#define l1(x, y) conv4_tex((vec2(clamp(pos + ivec2(x, y), ivec2(0), sz) * ivec2(2, 1) + ivec2(1, 0)) + vec2(0.5)) * conv4_pt)
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
	r0 = D(r0, s0_0_0, 0x3C0502CF, 0xFBE10107, 0x00F30009, 0x08FCFFF8);
	r0 = D(r0, s0_0_1, 0xF413F7DF, 0x40EEF981, 0x0E12FDE6, 0x0803FF02);
	r0 = D(r0, s0_0_2, 0x070C03F9, 0xF1E30C0C, 0xFD060102, 0xFE110405);
	r0 = D(r0, s0_1_0, 0xA520FB19, 0x010D0206, 0xC1FEFDFF, 0x11FD03FF);
	r0 = D(r0, s0_1_1, 0x251046FA, 0xF319F511, 0x01212002, 0x8106F201);
	r0 = D(r0, s0_1_2, 0x030F1201, 0x01F4C4FF, 0x00F00F00, 0x0501DB01);
	r0 = D(r0, s0_2_0, 0xFD1E0000, 0xFE0A0000, 0xF5080000, 0xFFF20100);
	r0 = D(r0, s0_2_1, 0xFEEAFF00, 0xF015FDFF, 0xF1231A02, 0xEEFCFA00);
	r0 = D(r0, s0_2_2, 0x0003F800, 0x02FD0601, 0x0111FD00, 0x021CF100);
	r0 = D(r0, s1_0_0, 0xF30504F9, 0xFDFCFCFD, 0x020402FC, 0x0100FF02);
	r0 = D(r0, s1_0_1, 0x0FDAEC4D, 0x0C1D042A, 0x0503FA02, 0xFFFD00F9);
	r0 = D(r0, s1_0_2, 0x000705F7, 0x01F8F812, 0x0201FE02, 0x02FCFB01);
	r0 = D(r0, s1_1_0, 0x22050810, 0xFEFD00FC, 0xF805F50D, 0x04F901F5);
	r0 = D(r0, s1_1_1, 0x13EDC70A, 0x2F19EE22, 0xC8BF3858, 0xCC330369);
	r0 = D(r0, s1_1_2, 0xFE0006FE, 0x00FBEDFA, 0x040500F6, 0xFFFF25FF);
	r0 = D(r0, s1_2_0, 0xF70000FD, 0xFF000000, 0x030100FE, 0xFFFEFE00);
	r0 = D(r0, s1_2_1, 0x01FE0302, 0xFC010001, 0x0804FD01, 0x06050200);
	r0 = D(r0, s1_2_2, 0xFF01FE01, 0x00020000, 0xFF000001, 0x01FEFE00);
	f0 = vec4(r0) * 6.2000124e-05;
	f0 += vec4(-1.655e-04, -1.569e-04, -1.713e-04, -1.756e-04);
	f0 = tanh(f0);
	vec2 opt = 0.5 * LUMA_pt;
	vec2 fpos = (vec2(opos) + vec2(0.5)) * opt;
	imageStore(out_image, opos + ivec2(0, 0), vec4(f0.x + LUMA_tex(fpos + vec2(0.0, 0.0) * opt).r, 0.0, 0.0, 1.0));
	imageStore(out_image, opos + ivec2(1, 0), vec4(f0.y + LUMA_tex(fpos + vec2(1.0, 0.0) * opt).r, 0.0, 0.0, 1.0));
	imageStore(out_image, opos + ivec2(0, 1), vec4(f0.z + LUMA_tex(fpos + vec2(0.0, 1.0) * opt).r, 0.0, 0.0, 1.0));
	imageStore(out_image, opos + ivec2(1, 1), vec4(f0.w + LUMA_tex(fpos + vec2(1.0, 1.0) * opt).r, 0.0, 0.0, 1.0));
}
