; RUN: llc -mtriple=x86_64-unknown-unknown -mattr=+sse2 < %s | FileCheck %s --check-prefix=SSE
; RUN: llc -mtriple=x86_64-unknown-unknown -mattr=+avx < %s | FileCheck %s --check-prefix=AVX

; Verify that we're folding the load into the math instruction.

define float @rcpss(float* %a) {
; SSE-LABEL: rcpss:
; SSE:       # BB#0:
; SSE-NEXT:    rcpss (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: rcpss:
; AVX:       # BB#0:
; AVX-NEXT:    vrcpss (%rdi), %xmm0, %xmm0
; AVX-NEXT:    retq
    %ld = load float, float* %a
    %ins = insertelement <4 x float> undef, float %ld, i32 0
    %res = tail call <4 x float> @llvm.x86.sse.rcp.ss(<4 x float> %ins)
    %ext = extractelement <4 x float> %res, i32 0
    ret float %ext
}

define float @rsqrtss(float* %a) {
; SSE-LABEL: rsqrtss:
; SSE:       # BB#0:
; SSE-NEXT:    rsqrtss (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: rsqrtss:
; AVX:       # BB#0:
; AVX-NEXT:    vrsqrtss (%rdi), %xmm0, %xmm0
; AVX-NEXT:    retq
    %ld = load float, float* %a
    %ins = insertelement <4 x float> undef, float %ld, i32 0
    %res = tail call <4 x float> @llvm.x86.sse.rsqrt.ss(<4 x float> %ins)
    %ext = extractelement <4 x float> %res, i32 0
    ret float %ext
}

define float @sqrtss(float* %a) {
; SSE-LABEL: sqrtss:
; SSE:       # BB#0:
; SSE-NEXT:    sqrtss (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: sqrtss:
; AVX:       # BB#0:
; AVX-NEXT:    vsqrtss (%rdi), %xmm0, %xmm0
; AVX-NEXT:    retq
    %ld = load float, float* %a
    %ins = insertelement <4 x float> undef, float %ld, i32 0
    %res = tail call <4 x float> @llvm.x86.sse.sqrt.ss(<4 x float> %ins)
    %ext = extractelement <4 x float> %res, i32 0
    ret float %ext
}

define double @sqrtsd(double* %a) {
; SSE-LABEL: sqrtsd:
; SSE:       # BB#0:
; SSE-NEXT:    sqrtsd (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: sqrtsd:
; AVX:       # BB#0:
; AVX-NEXT:    vsqrtsd (%rdi), %xmm0, %xmm0
; AVX-NEXT:    retq
    %ld = load double, double* %a
    %ins = insertelement <2 x double> undef, double %ld, i32 0
    %res = tail call <2 x double> @llvm.x86.sse2.sqrt.sd(<2 x double> %ins)
    %ext = extractelement <2 x double> %res, i32 0
    ret double %ext
}


declare <4 x float> @llvm.x86.sse.rcp.ss(<4 x float>) nounwind readnone
declare <4 x float> @llvm.x86.sse.rsqrt.ss(<4 x float>) nounwind readnone
declare <4 x float> @llvm.x86.sse.sqrt.ss(<4 x float>) nounwind readnone
declare <2 x double> @llvm.x86.sse2.sqrt.sd(<2 x double>) nounwind readnone

