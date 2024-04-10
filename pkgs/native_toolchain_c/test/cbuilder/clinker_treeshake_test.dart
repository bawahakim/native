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

  final linkerManual = CBuilder.link(
    name: 'mylibname',
    assetName: 'assetName',
    linkerOptions: LinkerOptions.manual(
      flags: ['--strip-debug', '-u', 'my_other_func'],
      linkInput: [Uri.file('test/cbuilder/testfiles/linker/test.a')],
      gcSections: true,
      linkerScript: Uri.file('test/cbuilder/testfiles/linker/symbols.lds'),
    ),
  );
  final linkerAuto = CBuilder.link(
    name: 'mylibname',
    assetName: 'assetName',
    linkerOptions: LinkerOptions.treeshake(
      linkInput: [Uri.file('test/cbuilder/testfiles/linker/test.a')],
      symbols: ['my_other_func'],
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

    // Obtained by running
    // /usr/bin/ld -fPIC --shared -o /tmp/libmylibname_ld_allsymbols.so --strip-debug --gc-sections test/cbuilder/testfiles/linker/test.a
    const maxSize = 13760;
    await checkResults(buildOutput, maxSize);
  });

  test('link test clang', () async {
    final cCompilerConfig = CCompilerConfig(linker: Uri.file('/usr/bin/clang'));

    final buildOutput = await _runBuild(
      os,
      architecture,
      cCompilerConfig,
      linkerManual,
    );

    // Obtained by running
    // /usr/bin/clang -fPIC --shared -o /tmp/libmylibname_clang_allsymbols.so -Wl,--strip-debug -Wl,--gc-sections test/cbuilder/testfiles/linker/test.a
    const sizeWithAllSymbols = 15457;
    await checkResults(buildOutput, sizeWithAllSymbols);
  });

  test('link test ld auto', () async {
    final cCompilerConfig = CCompilerConfig(linker: Uri.file('/usr/bin/ld'));

    final buildOutput = await _runBuild(
      os,
      architecture,
      cCompilerConfig,
      linkerAuto,
    );

    // Obtained by running
    // /usr/bin/ld -fPIC --shared -o /tmp/libmylibname_ld_allsymbols.so --strip-debug --gc-sections test/cbuilder/testfiles/linker/test.a
    const maxSize = 13760;
    await checkResults(buildOutput, maxSize);
  });

  test('link test clang auto', () async {
    final cCompilerConfig = CCompilerConfig(linker: Uri.file('/usr/bin/clang'));

    final buildOutput = await _runBuild(
      os,
      architecture,
      cCompilerConfig,
      linkerAuto,
    );

    // Obtained by running
    // /usr/bin/clang -fPIC --shared -o /tmp/libmylibname_clang_allsymbols.so -Wl,--strip-debug -Wl,--gc-sections test/cbuilder/testfiles/linker/test.a
    const sizeWithAllSymbols = 15457;
    await checkResults(buildOutput, sizeWithAllSymbols);
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
