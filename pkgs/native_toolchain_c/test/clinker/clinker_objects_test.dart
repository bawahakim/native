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

Future<void> main() async {
  if (!Platform.isLinux) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }
  const architecture = Architecture.x64;
  const os = OS.linux;
  const name = 'mylibname';

  for (final precompiled in [true, false]) {
    final ldConfig = CCompilerConfig(linker: Uri.file('/usr/bin/ld'));
    final clangConfig = CCompilerConfig(linker: Uri.file('/usr/bin/clang'));
    for (final cCompilerConfig in [ldConfig, clangConfig]) {
      final linkerName = cCompilerConfig.linker!.pathSegments.last;
      final objectSource = precompiled ? 'pre compiled' : 'freshly built';
      test('link two objects with $linkerName and $objectSource objects',
          () async {
        final buildOutput = BuildOutput();
        final tempUri = await tempDirForTest();

        final objectFiles = await _objectFiles(
          tempUri,
          precompiled,
          os,
          architecture,
        );
        expect(objectFiles, hasLength(2));
        logger.info(objectFiles);

        await CBuilder.link(
          name: name,
          assetName: 'assetName',
          linkerOptions: LinkerOptions.manual(
            linkInput: objectFiles,
            gcSections: false,
          ),
        ).run(
          buildConfig: BuildConfig.build(
            outputDirectory: tempUri,
            packageName: 'testpackage',
            packageRoot: tempUri,
            targetArchitecture: architecture,
            targetOS: os,
            buildMode: BuildMode.release,
            linkModePreference: LinkModePreference.dynamic,
            cCompiler: cCompilerConfig,
          ),
          buildOutput: buildOutput,
          logger: logger,
        );

        expect(buildOutput.assets, hasLength(1));
        final asset = buildOutput.assets.first;
        expect(asset, isA<NativeCodeAsset>());
        final filePath = (asset as NativeCodeAsset).file!.toFilePath();
        expect(
          filePath,
          endsWith(os.dylibFileName(name)),
        );
        final readelf = (await runProcess(
          executable: Uri.file('readelf'),
          arguments: ['-WCs', filePath],
          logger: logger,
        ))
            .stdout;
        expect(readelf, contains('my_other_func'));
        expect(readelf, contains('my_func'));
      });
    }
  }
}

Future<List<Uri>> _objectFiles(
  Uri tempUri,
  bool preCompiled,
  OS os,
  Architecture architecture,
) async {
  if (preCompiled) {
    return [
      Uri.file('test/clinker/testfiles/linker/test1.o'),
      Uri.file('test/clinker/testfiles/linker/test2.o'),
    ];
  } else {
    final buildOutput = BuildOutput();
    await CBuilder.library(
      name: 'test1',
      assetName: 'assetName1',
      dartBuildFiles: [],
      sources: [
        packageUri
            .resolve('test/clinker/testfiles/linker/test1.c')
            .toFilePath(),
        packageUri
            .resolve('test/clinker/testfiles/linker/test2.c')
            .toFilePath(),
      ],
      linkModePreference: LinkModePreference.static,
    ).run(
      buildConfig: BuildConfig.build(
        outputDirectory: tempUri,
        packageName: 'testpackage',
        packageRoot: tempUri,
        targetArchitecture: architecture,
        targetOS: os,
        buildMode: BuildMode.release,
        linkModePreference: LinkModePreference.dynamic,
        cCompiler: CCompilerConfig(compiler: cc),
      ),
      buildOutput: buildOutput,
      logger: logger,
    );

    return buildOutput.assets.map((e) => e.file!).toList();
  }
}
