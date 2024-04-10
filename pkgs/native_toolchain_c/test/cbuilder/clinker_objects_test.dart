// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('linux')
library;

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  if (!Platform.isLinux) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  final linkerManual = CBuilder.link(
    name: 'mylibname',
    assetName: 'assetName',
    linkerOptions: LinkerOptions.manual(
      flags: ['--strip-debug'],
      linkInput: [Uri.file('test/cbuilder/testfiles/linker/test.a')],
      gcSections: true,
      linkerScript: Uri.file('test/cbuilder/testfiles/linker/symbols.lds'),
    ),
  );
  const architecture = Architecture.x64;
  const os = OS.linux;

  test('link test ld', () async {
    final cCompilerConfig = CCompilerConfig(linker: Uri.file('/usr/bin/ld'));

    final buildOutput = await _runBuild(
      os,
      architecture,
      cCompilerConfig,
      linkerManual,
    );
  });

  test('link test clang', () async {
    final cCompilerConfig = CCompilerConfig(linker: Uri.file('/usr/bin/clang'));

    final buildOutput = await _runBuild(
      os,
      architecture,
      cCompilerConfig,
      linkerManual,
    );
  });
}

Future<BuildOutput> _runBuild(
  OS os,
  Architecture architecture,
  CCompilerConfig cCompilerConfig,
  CBuilder cbuilder,
) async {
  final tempUri = await tempDirForTest();
  final buildOutput = BuildOutput();

  final buildConfig = BuildConfig.build(
    outputDirectory: tempUri,
    packageName: 'testpackage',
    packageRoot: tempUri,
    targetArchitecture: architecture,
    targetOS: os,
    buildMode: BuildMode.release,
    linkModePreference: LinkModePreference.dynamic,
    cCompiler: cCompilerConfig,
  );
  await cbuilder.run(
    buildConfig: buildConfig,
    buildOutput: buildOutput,
    logger: logger,
  );
  return buildOutput;
}
