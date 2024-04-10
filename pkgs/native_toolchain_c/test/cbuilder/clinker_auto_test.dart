// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('linux')
library;

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_toolchain_c/src/utils/run_process.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  if (!Platform.isLinux) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  final builder = CBuilder.link(
    name: 'mylibname',
    assetName: 'assetName',
    linkerOptions: LinkerOptions.treeshake(
      linkInput: Uri.file('test/cbuilder/testfiles/linker/test.a'),
      symbols: ['my_other_func'],
    ),
  );

  const architecture = Architecture.x64;
  const os = OS.linux;

  test('link test ld', () async {
    final cCompilerConfig = CCompilerConfig(linker: Uri.file('/usr/bin/ld'));

    final tempUri = await tempDirForTest();
    final buildOutput = BuildOutput();

    final buildConfig = getBuildConfig(
      tempUri,
      os,
      architecture,
      cCompilerConfig,
    );
    await builder.run(
      buildConfig: buildConfig,
      buildOutput: buildOutput,
      logger: logger,
    );

    // Obtained by running
    // /usr/bin/ld -fPIC  --shared -o /tmp/libmylibname_ld_allsymbols.so --strip-debug --gc-sections --whole-archive test/cbuilder/testfiles/linker/test.a
    const maxSize = 13760;
    await checkResults(buildOutput, maxSize);
  });

  test('link test clang', () async {
    final cCompilerConfig = CCompilerConfig(linker: Uri.file('/usr/bin/clang'));

    final tempUri = await tempDirForTest();
    final buildOutput = BuildOutput();

    final buildConfig = getBuildConfig(
      tempUri,
      os,
      architecture,
      cCompilerConfig,
    );
    await builder.run(
      buildConfig: buildConfig,
      buildOutput: buildOutput,
      logger: logger,
    );

    // Obtained by running
    // /usr/bin/clang -fPIC  --shared -o /tmp/libmylibname_clang_allsymbols.so -Wl,--strip-debug -Wl,--gc-sections -Wl,--whole-archive test/cbuilder/testfiles/linker/test.a -Wl,--no-whole-archive
    const sizeWithAllSymbols = 15457;
    await checkResults(buildOutput, sizeWithAllSymbols);
  });
}

Future<void> checkResults(BuildOutput buildOutput, int maxSize) async {
  final filePath = buildOutput.assets.first.file!.toFilePath();

  final readelf = (await runProcess(
    executable: Uri.file('readelf'),
    arguments: ['-WCs', filePath],
    logger: logger,
  ))
      .stdout;
  expect(readelf, contains('my_other_func'));
  expect(readelf, isNot(contains('my_func')));

  final du = Process.runSync('du', ['-sb', filePath]).stdout as String;
  final sizeInBytes = int.parse(du.split('\t')[0]);
  expect(sizeInBytes, lessThan(maxSize));
}

BuildConfig getBuildConfig(
  Uri tempUri,
  OS target,
  Architecture architecture,
  CCompilerConfig cCompilerConfig,
) {
  final buildConfig = BuildConfig.build(
    outputDirectory: tempUri,
    packageName: 'testpackage',
    packageRoot: tempUri,
    targetArchitecture: architecture,
    targetOS: target,
    buildMode: BuildMode.release,
    linkModePreference: LinkModePreference.dynamic,
    cCompiler: cCompilerConfig,
  );
  return buildConfig;
}
