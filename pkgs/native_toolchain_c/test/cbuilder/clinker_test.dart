// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('linux')
library;

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_toolchain_c/src/utils/run_process.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  const target = Target.linuxX64;

  final builder = CBuilder.link(
    name: 'mylibname',
    assetId: 'assetId',
    linkInput: Uri.file('test/cbuilder/testfiles/linker/test.a'),
    linkerScript: Uri.file('test/cbuilder/testfiles/linker/symbols.lds'),
    flags: ['-u', 'my_other_func'],
    linkerFlags: ['-strip-debug'],
  );

  test('link test ld', () async {
    final cCompilerConfig = CCompilerConfig(ld: Uri.file('/usr/bin/ld'));

    final tempUri = await tempDirForTest();
    final buildOutput = BuildOutput();

    final buildConfig = getBuildConfig(tempUri, target, cCompilerConfig);
    await builder.run(
      buildConfig: buildConfig,
      buildOutput: buildOutput,
      logger: logger,
    );

    await checkResults(buildOutput);
  });

  test('link test clang', () async {
    final cCompilerConfig = CCompilerConfig(ld: Uri.file('/usr/bin/clang'));

    final tempUri = await tempDirForTest();
    final buildOutput = BuildOutput();

    final buildConfig = getBuildConfig(tempUri, target, cCompilerConfig);
    await builder.run(
      buildConfig: buildConfig,
      buildOutput: buildOutput,
      logger: logger,
    );

    await checkResults(buildOutput);
  });
}

Future<void> checkResults(BuildOutput buildOutput) async {
  final filePath =
      (buildOutput.assets.first.path as AssetAbsolutePath).uri.toFilePath();
  // final filesize = Process.runSync('du', ['-sh', filePath]).stdout;
  final result = await runProcess(
    executable: Uri.file('readelf'),
    arguments: ['-WCs', filePath],
    logger: logger,
  );
  final elf = result.stdout;
  expect(elf, contains('my_other_func'));
  expect(elf, isNot(contains('my_func')));
}

BuildConfig getBuildConfig(
    Uri tempUri, Target target, CCompilerConfig cCompilerConfig) {
  final buildConfig = BuildConfig(
    outDir: tempUri,
    packageName: 'testpackage',
    packageRoot: tempUri,
    targetArchitecture: target.architecture,
    targetOs: target.os,
    buildMode: BuildMode.release,
    linkModePreference: LinkModePreference.dynamic,
    cCompiler: cCompilerConfig,
  );
  return buildConfig;
}
