// ignore_for_file: non_constant_identifier_names,

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

class A extends ffi.Struct {
  @ffi.Int()
  external int a;
}

class B extends ffi.Struct {
  @ffi.Int()
  external int B1;

  @ffi.Int()
  external int A;
}

class C extends ffi.Struct {
  external A A1;

  external B B1;
}

class D extends ffi.Struct {
  external B A1;

  external A B1;
}
