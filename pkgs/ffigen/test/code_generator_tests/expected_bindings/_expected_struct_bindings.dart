// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

/// Just a test struct
/// heres another line
class NoMember extends ffi.Opaque {}

class WithPrimitiveMember extends ffi.Struct {
  @ffi.Int32()
  external int a;

  @ffi.Double()
  external double b;

  @ffi.Uint8()
  external int c;
}

class WithPointerMember extends ffi.Struct {
  external ffi.Pointer<ffi.Int32> a;

  external ffi.Pointer<ffi.Pointer<ffi.Double>> b;

  @ffi.Uint8()
  external int c;
}

class WithIntPtrUintPtr extends ffi.Struct {
  external ffi.Pointer<ffi.UintPtr> a;

  external ffi.Pointer<ffi.Pointer<ffi.IntPtr>> b;
}
