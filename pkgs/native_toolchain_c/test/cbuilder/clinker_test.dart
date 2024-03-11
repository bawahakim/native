// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  test('link test', () async {
    const target = Target.linuxX64;

    final builder = CBuilder.link(
      name: 'mylibname',
      assetId: 'assetId',
      staticArchive: Uri.file('test/cbuilder/testfiles/linker/test.a'),
      linkerScript: Uri.file('test/cbuilder/testfiles/linker/symbols.lds'),
      flags: ['-u', 'my_other_func'],
      linkerFlags: ['-strip-debug'],
    );

    final tempUri = await tempDirForTest();
    final buildConfig = BuildConfig(
      outDir: tempUri,
      packageName: 'testpackage',
      packageRoot: tempUri,
      targetArchitecture: target.architecture,
      targetOs: target.os,
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.dynamic,
    );
    final buildOutput = BuildOutput();

    await builder.run(
      buildConfig: buildConfig,
      buildOutput: buildOutput,
      logger: logger,
    );

    final filePath =
        (buildOutput.assets.first.path as AssetAbsolutePath).uri.toFilePath();
    // final filesize = Process.runSync('du', ['-sh', filePath]).stdout;
    final elf = Process.runSync('readelf', ['-WCs', filePath]).stdout;
    expect(elf, contains('my_other_func'));
    expect(elf, isNot(contains('my_func')));
  });
}
