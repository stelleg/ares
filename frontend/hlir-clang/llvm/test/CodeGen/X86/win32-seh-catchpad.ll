; RUN: llc < %s | FileCheck %s

target datalayout = "e-m:x-p:32:32-i64:64-f80:32-n8:16:32-a:0:32-S32"
target triple = "i686-pc-windows-msvc"

define void @try_except() #0 personality i8* bitcast (i32 (...)* @_except_handler3 to i8*) {
entry:
  %__exception_code = alloca i32, align 4
  call void (...) @llvm.localescape(i32* %__exception_code)
  invoke void @f(i32 1) #3
          to label %invoke.cont unwind label %catch.dispatch

catch.dispatch:                                   ; preds = %entry
  %0 = catchpad [i8* bitcast (i32 ()* @try_except_filter_catchall to i8*)] to label %__except.ret unwind label %catchendblock

__except.ret:                                     ; preds = %catch.dispatch
  catchret %0 to label %__except

__except:                                         ; preds = %__except.ret
  call void @f(i32 2)
  br label %__try.cont

__try.cont:                                       ; preds = %__except, %invoke.cont
  call void @f(i32 3)
  ret void

catchendblock:                                    ; preds = %catch.dispatch
  catchendpad unwind to caller

invoke.cont:                                      ; preds = %entry
  br label %__try.cont
}

; CHECK-LABEL: _try_except:
;     Store state #0
; CHECK: movl $0, -[[state:[0-9]+]](%ebp)
; CHECK: movl $1, (%esp)
; CHECK: calll _f
; CHECK: movl $-1, -[[state]](%ebp)
; CHECK: movl $3, (%esp)
; CHECK: calll _f
; CHECK: retl

;   __except
; CHECK: movl $-1, -[[state]](%ebp)
; CHECK: movl $2, (%esp)
; CHECK: calll _f

; CHECK: .section        .xdata,"dr"
; CHECK: L__ehtable$try_except:
; CHECK:         .long   -1
; CHECK:         .long   _try_except_filter_catchall
; CHECK:         .long   LBB0_1

define internal i32 @try_except_filter_catchall() #0 {
entry:
  %0 = call i8* @llvm.frameaddress(i32 1)
  %1 = call i8* @llvm.x86.seh.recoverfp(i8* bitcast (void ()* @try_except to i8*), i8* %0)
  %2 = call i8* @llvm.localrecover(i8* bitcast (void ()* @try_except to i8*), i8* %1, i32 0)
  %__exception_code = bitcast i8* %2 to i32*
  %3 = getelementptr inbounds i8, i8* %0, i32 -20
  %4 = bitcast i8* %3 to i8**
  %5 = load i8*, i8** %4, align 4
  %6 = bitcast i8* %5 to { i32*, i8* }*
  %7 = getelementptr inbounds { i32*, i8* }, { i32*, i8* }* %6, i32 0, i32 0
  %8 = load i32*, i32** %7, align 4
  %9 = load i32, i32* %8, align 4
  store i32 %9, i32* %__exception_code, align 4
  ret i32 1
}

define void @nested_exceptions() #0 personality i8* bitcast (i32 (...)* @_except_handler3 to i8*) {
entry:
  %__exception_code = alloca i32, align 4
  call void (...) @llvm.localescape(i32* %__exception_code)
  invoke void @crash() #3
          to label %__try.cont unwind label %catch.dispatch

catch.dispatch:                                   ; preds = %entry
  %0 = catchpad [i8* bitcast (i32 ()* @nested_exceptions_filter_catchall to i8*)] to label %__except.ret unwind label %catchendblock

__except.ret:                                     ; preds = %catch.dispatch
  catchret %0 to label %__try.cont

__try.cont:                                       ; preds = %entry, %__except.ret
  invoke void @crash() #3
          to label %__try.cont.9 unwind label %catch.dispatch.5

catch.dispatch.5:                                 ; preds = %__try.cont
  %1 = catchpad [i8* bitcast (i32 ()* @nested_exceptions_filter_catchall to i8*)] to label %__except.ret.7 unwind label %catchendblock.6

__except.ret.7:                                   ; preds = %catch.dispatch.5
  catchret %1 to label %__try.cont.9

__try.cont.9:                                     ; preds = %__try.cont, %__except.ret.7
  invoke void @crash() #3
          to label %__try.cont.15 unwind label %catch.dispatch.11

catch.dispatch.11:                                ; preds = %catchendblock, %catchendblock.6, %__try.cont.9
  %2 = catchpad [i8* bitcast (i32 ()* @nested_exceptions_filter_catchall to i8*)] to label %__except.ret.13 unwind label %catchendblock.12

__except.ret.13:                                  ; preds = %catch.dispatch.11
  catchret %2 to label %__try.cont.15

__try.cont.15:                                    ; preds = %__try.cont.9, %__except.ret.13
  invoke void @crash() #3
          to label %__try.cont.35 unwind label %catch.dispatch.17

catch.dispatch.17:                                ; preds = %catchendblock.12, %__try.cont.15
  %3 = catchpad [i8* bitcast (i32 ()* @nested_exceptions_filter_catchall to i8*)] to label %__except.ret.19 unwind label %catchendblock.18

__except.ret.19:                                  ; preds = %catch.dispatch.17
  catchret %3 to label %__except.20

__except.20:                                      ; preds = %__except.ret.19
  invoke void @crash() #3
          to label %__try.cont.27 unwind label %catch.dispatch.23

catch.dispatch.23:                                ; preds = %__except.20
  %4 = catchpad [i8* bitcast (i32 ()* @nested_exceptions_filter_catchall to i8*)] to label %__except.ret.25 unwind label %catchendblock.24

__except.ret.25:                                  ; preds = %catch.dispatch.23
  catchret %4 to label %__try.cont.27

__try.cont.27:                                    ; preds = %__except.20, %__except.ret.25
  invoke void @crash() #3
          to label %__try.cont.35 unwind label %catch.dispatch.30

catch.dispatch.30:                                ; preds = %__try.cont.27
  %5 = catchpad [i8* bitcast (i32 ()* @nested_exceptions_filter_catchall to i8*)] to label %__except.ret.32 unwind label %catchendblock.31

__except.ret.32:                                  ; preds = %catch.dispatch.30
  catchret %5 to label %__try.cont.35

__try.cont.35:                                    ; preds = %__try.cont.15, %__try.cont.27, %__except.ret.32
  ret void

catchendblock.31:                                 ; preds = %catch.dispatch.30
  catchendpad unwind to caller

catchendblock.24:                                 ; preds = %catch.dispatch.23
  catchendpad unwind to caller

catchendblock.18:                                 ; preds = %catch.dispatch.17
  catchendpad unwind to caller

catchendblock.12:                                 ; preds = %catch.dispatch.11
  catchendpad unwind label %catch.dispatch.17

catchendblock.6:                                  ; preds = %catch.dispatch.5
  catchendpad unwind label %catch.dispatch.11

catchendblock:                                    ; preds = %catch.dispatch
  catchendpad unwind label %catch.dispatch.11
}

; This table is equivalent to the one produced by MSVC, even if it isn't in
; quite the same order.

; CHECK-LABEL: _nested_exceptions:
; CHECK: L__ehtable$nested_exceptions:
; CHECK:         .long   -1
; CHECK:         .long   _nested_exceptions_filter_catchall
; CHECK:         .long   LBB
; CHECK:         .long   -1
; CHECK:         .long   _nested_exceptions_filter_catchall
; CHECK:         .long   LBB
; CHECK:         .long   -1
; CHECK:         .long   _nested_exceptions_filter_catchall
; CHECK:         .long   LBB
; CHECK:         .long   2
; CHECK:         .long   _nested_exceptions_filter_catchall
; CHECK:         .long   LBB
; CHECK:         .long   3
; CHECK:         .long   _nested_exceptions_filter_catchall
; CHECK:         .long   LBB
; CHECK:         .long   3
; CHECK:         .long   _nested_exceptions_filter_catchall
; CHECK:         .long   LBB

declare void @crash() #0

define internal i32 @nested_exceptions_filter_catchall() #0 {
entry:
  %0 = call i8* @llvm.frameaddress(i32 1)
  %1 = call i8* @llvm.x86.seh.recoverfp(i8* bitcast (void ()* @nested_exceptions to i8*), i8* %0)
  %2 = call i8* @llvm.localrecover(i8* bitcast (void ()* @nested_exceptions to i8*), i8* %1, i32 0)
  %__exception_code3 = bitcast i8* %2 to i32*
  %3 = getelementptr inbounds i8, i8* %0, i32 -20
  %4 = bitcast i8* %3 to i8**
  %5 = load i8*, i8** %4, align 4
  %6 = bitcast i8* %5 to { i32*, i8* }*
  %7 = getelementptr inbounds { i32*, i8* }, { i32*, i8* }* %6, i32 0, i32 0
  %8 = load i32*, i32** %7, align 4
  %9 = load i32, i32* %8, align 4
  store i32 %9, i32* %__exception_code3, align 4
  ret i32 1
}

; Function Attrs: nounwind readnone
declare i8* @llvm.frameaddress(i32) #1

; Function Attrs: nounwind readnone
declare i8* @llvm.x86.seh.recoverfp(i8*, i8*) #1

; Function Attrs: nounwind readnone
declare i8* @llvm.localrecover(i8*, i8*, i32) #1

declare void @f(i32) #0

declare i32 @_except_handler3(...)

; Function Attrs: nounwind
declare void @llvm.localescape(...) #2

attributes #0 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-realign-stack" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind }
attributes #3 = { noinline }
