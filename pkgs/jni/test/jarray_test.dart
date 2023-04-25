// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jni/jni.dart';
import 'package:test/test.dart';

import 'test_util/test_util.dart';

void main() {
  // Don't forget to initialize JNI.
  if (!Platform.isAndroid) {
    checkDylibIsUpToDate();
    Jni.spawnIfNotExists(dylibDir: "build/jni_libs", jvmOptions: ["-Xmx128m"]);
  }
  run(testRunner: test);
}

void run({required TestRunnerCallback testRunner}) {
  testRunner("Java boolean array", () {
    using((arena) {
      final array = JArray(JBoolean.type, 3)..deletedIn(arena);
      expect(array.length, 3);
      array[0] = true;
      array[1] = false;
      array[2] = false;
      expect(array[0], true);
      expect(array[1], false);
      expect(array[2], false);
      array.setRange(0, 3, [false, true, true, true], 1);
      expect(array[0], true);
      expect(array[1], true);
      expect(array[2], true);
      expect(() {
        final _ = array[-1];
      }, throwsRangeError);
      expect(() {
        array[-1] = false;
      }, throwsRangeError);
      expect(() {
        array[3] = false;
      }, throwsRangeError);
    });
  });
  testRunner("Java char array", () {
    using((arena) {
      final array = JArray(JChar.type, 3)..deletedIn(arena);
      expect(array.length, 3);
      array[0] = 'ح';
      array[1] = '2';
      array[2] = '3';
      expect(array[0], 'ح');
      expect(array[1], '2');
      expect(array[2], '3');
      array.setRange(0, 3, ['4', '5', '6', '7'], 1);
      expect(array[0], '5');
      expect(array[1], '6');
      expect(array[2], '7');
      expect(() {
        final _ = array[-1];
      }, throwsRangeError);
      expect(() {
        array[-1] = '4';
      }, throwsRangeError);
      expect(() {
        array[3] = '4';
      }, throwsRangeError);
    });
  });
  testRunner("Java byte array", () {
    using((arena) {
      final array = JArray(JByte.type, 3)..deletedIn(arena);
      expect(array.length, 3);
      array[0] = 1;
      array[1] = 2;
      array[2] = 3 + 256 * 5; // truncates the input;
      expect(array[0], 1);
      expect(array[1], 2);
      expect(array[2], 3);
      array.setRange(0, 3, [4, 5, 6, 7], 1);
      expect(array[0], 5);
      expect(array[1], 6);
      expect(array[2], 7);
      expect(() {
        final _ = array[-1];
      }, throwsRangeError);
      expect(() {
        array[-1] = 4;
      }, throwsRangeError);
      expect(() {
        array[3] = 4;
      }, throwsRangeError);
    });
  });
  testRunner("Java short array", () {
    using((arena) {
      final array = JArray(JShort.type, 3)..deletedIn(arena);
      expect(array.length, 3);
      array[0] = 1;
      array[1] = 2;
      array[2] = 3 + 256 * 256 * 5; // truncates the input
      expect(array[0], 1);
      expect(array[1], 2);
      expect(array[2], 3);
      array.setRange(0, 3, [4, 5, 6, 7], 1);
      expect(array[0], 5);
      expect(array[1], 6);
      expect(array[2], 7);
      expect(() {
        final _ = array[-1];
      }, throwsRangeError);
      expect(() {
        array[-1] = 4;
      }, throwsRangeError);
      expect(() {
        array[3] = 4;
      }, throwsRangeError);
    });
  });
  testRunner("Java int array", () {
    using((arena) {
      final array = JArray(JInt.type, 3)..deletedIn(arena);
      expect(array.length, 3);
      array[0] = 1;
      array[1] = 2;
      array[2] = 3 + 256 * 256 * 256 * 256 * 5; // truncates the input
      expect(array[0], 1);
      expect(array[1], 2);
      expect(array[2], 3);
      array.setRange(0, 3, [4, 5, 6, 7], 1);
      expect(array[0], 5);
      expect(array[1], 6);
      expect(array[2], 7);
      expect(() {
        final _ = array[-1];
      }, throwsRangeError);
      expect(() {
        array[-1] = 4;
      }, throwsRangeError);
      expect(() {
        array[3] = 4;
      }, throwsRangeError);
    });
  });
  const epsilon = 1e-6;
  testRunner("Java float array", () {
    using((arena) {
      final array = JArray(JFloat.type, 3)..deletedIn(arena);
      expect(array.length, 3);
      array[0] = 0.5;
      array[1] = 2;
      array[2] = 3;
      expect(array[0], closeTo(0.5, epsilon));
      expect(array[1], closeTo(2, epsilon));
      expect(array[2], closeTo(3, epsilon));
      array.setRange(0, 3, [4, 5, 6, 7], 1);
      expect(array[0], closeTo(5, epsilon));
      expect(array[1], closeTo(6, epsilon));
      expect(array[2], closeTo(7, epsilon));
      expect(() {
        final _ = array[-1];
      }, throwsRangeError);
      expect(() {
        array[-1] = 4;
      }, throwsRangeError);
      expect(() {
        array[3] = 4;
      }, throwsRangeError);
    });
  });
  testRunner("Java double array", () {
    using((arena) {
      final array = JArray(JDouble.type, 3)..deletedIn(arena);
      expect(array.length, 3);
      array[0] = 0.5;
      array[1] = 2;
      array[2] = 3;
      expect(array[0], closeTo(0.5, epsilon));
      expect(array[1], closeTo(2, epsilon));
      expect(array[2], closeTo(3, epsilon));
      array.setRange(0, 3, [4, 5, 6, 7], 1);
      expect(array[0], closeTo(5, epsilon));
      expect(array[1], closeTo(6, epsilon));
      expect(array[2], closeTo(7, epsilon));
      expect(() {
        final _ = array[-1];
      }, throwsRangeError);
      expect(() {
        array[-1] = 4;
      }, throwsRangeError);
      expect(() {
        array[3] = 4;
      }, throwsRangeError);
    });
  });
  testRunner("Java string array", () {
    using((arena) {
      final array = JArray(JString.type, 3)..deletedIn(arena);
      expect(array.length, 3);
      array[0] = "حس".toJString()..deletedIn(arena);
      array[1] = "\$".toJString()..deletedIn(arena);
      array[2] = "33".toJString()..deletedIn(arena);
      expect(array[0].toDartString(deleteOriginal: true), "حس");
      expect(array[1].toDartString(deleteOriginal: true), "\$");
      expect(array[2].toDartString(deleteOriginal: true), "33");
      array.setRange(
        0,
        3,
        [
          "44".toJString()..deletedIn(arena),
          "55".toJString()..deletedIn(arena),
          "66".toJString()..deletedIn(arena),
          "77".toJString()..deletedIn(arena),
        ],
        1,
      );
      expect(array[0].toDartString(deleteOriginal: true), "55");
      expect(array[1].toDartString(deleteOriginal: true), "66");
      expect(array[2].toDartString(deleteOriginal: true), "77");
      expect(() {
        final _ = array[-1];
      }, throwsRangeError);
      expect(() {
        array[-1] = "44".toJString()..deletedIn(arena);
      }, throwsRangeError);
      expect(() {
        array[3] = "44".toJString()..deletedIn(arena);
      }, throwsRangeError);
    });
  });
  testRunner("Java object array", () {
    using((arena) {
      final array = JArray(JObject.type, 3)..deletedIn(arena);
      expect(array.length, 3);
      expect(array[0].reference, nullptr);
      expect(array[1].reference, nullptr);
      expect(array[2].reference, nullptr);
    });
  });
  testRunner("Java 2d array", () {
    using((arena) {
      final array = JArray(JInt.type, 3)..deletedIn(arena);
      array[0] = 1;
      array[1] = 2;
      array[2] = 3;
      final twoDimArray = JArray(JArray.type(JInt.type), 3)..deletedIn(arena);
      expect(twoDimArray.length, 3);
      twoDimArray[0] = array;
      twoDimArray[1] = array;
      twoDimArray[2] = array;
      for (var i = 0; i < 3; ++i) {
        expect(twoDimArray[i][0], 1);
        expect(twoDimArray[i][1], 2);
        expect(twoDimArray[i][2], 3);
      }
      twoDimArray[2][2] = 4;
      expect(twoDimArray[2][2], 4);
    });
  });
  testRunner("JArray.filled", () {
    using((arena) {
      final string = "abc".toJString()..deletedIn(arena);
      final array = JArray.filled(3, string)..deletedIn(arena);
      expect(
        () {
          final _ = JArray.filled(3, JString.fromRef(nullptr))
            ..deletedIn(arena);
        },
        throwsA(isA<AssertionError>()),
      );
      expect(array.length, 3);
      expect(array[0].toDartString(deleteOriginal: true), "abc");
      expect(array[1].toDartString(deleteOriginal: true), "abc");
      expect(array[2].toDartString(deleteOriginal: true), "abc");
    });
  });
}