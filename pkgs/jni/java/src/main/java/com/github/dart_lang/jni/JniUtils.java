package com.github.dart_lang.jni;

public class JniUtils {
  /// Creates a new global reference from [o] and returns its address.
  public static native long globalReferenceAddressOf(Object o);
}
