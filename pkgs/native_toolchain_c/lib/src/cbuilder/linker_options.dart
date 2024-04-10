// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import '../native_toolchain/clang.dart';
import '../native_toolchain/gcc.dart';
import '../tool/tool.dart';

class LinkerOptions {
  final List<String> _flags;

  final Uri linkInput;

  final bool gcSections;

  final Uri? linkerScript;

  LinkerOptions.manual({
    required List<String> flags,
    required this.linkInput,
    required this.gcSections,
    required this.linkerScript,
  }) : _flags = flags;

  ///
  LinkerOptions.treeshake({
    List<String>? flags,
    required List<String> symbols,
    required this.linkInput,
  })  : _flags = <String>{
          ...flags ?? [],
          '--strip-debug',
          ...symbols.expand((e) => ['-u', e]),
        }.toList(),
        gcSections = true,
        linkerScript = createLinkerScript(symbols);

  Iterable<String> flags(Tool linker) {
    final flagList = List<String>.from(_flags);
    if (gcSections) {
      flagList.add('--gc-sections');
    }
    if (linkerScript != null) {
      flagList.add('--version-script=${linkerScript!.toFilePath()}');
    }
    if (linker == clang) {
      return flagList.map((e) => '-Wl,$e');
    } else if (linker == gnuLinker) {
      return flagList;
    } else {
      throw UnsupportedError('Linker flags for $linker are not supported');
    }
  }

  static Uri createLinkerScript(List<String> symbols) {
    final tempDir = Directory.systemTemp.createTempSync();
    final symbolsFileUri = tempDir.uri.resolve('symbols.lds');
    final symbolsFile = File.fromUri(symbolsFileUri);
    symbolsFile.createSync();
    final contents = '''
{
  global:
    ${symbols.map((e) => '$e;').join('\n    ')}
  local:
    *;
};
''';
    symbolsFile.writeAsStringSync(contents);
    return symbolsFileUri;
  }
}
