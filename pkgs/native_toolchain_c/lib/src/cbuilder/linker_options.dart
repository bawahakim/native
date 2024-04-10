// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import '../native_toolchain/clang.dart';
import '../native_toolchain/gcc.dart';
import '../tool/tool.dart';

/// Options to pass to the linker.
///
/// These can be manually set via the [LinkerOptions.manual] constructor.
/// Alternatively, if the goal of the linking is to treeshake unused symbols,
/// the [LinkerOptions.treeshake] constructor can be used.
class LinkerOptions {
  /// The flags to be passed to the linker. As they depend on the linker being
  /// invoked, the actual usage is via the [flags] method.
  final List<String> _flags;

  /// The input files to the linker.
  final List<Uri> linkInput;

  /// Enable garbage collection of unused input sections.
  ///
  /// See also the `ld` man page at https://linux.die.net/man/1/ld.
  final bool gcSections;

  /// The linker script to be passed via `--version-script`.
  ///
  /// See also the `ld` man page at https://linux.die.net/man/1/ld.
  final Uri? linkerScript;

  /// Create linking options manually for fine-grained control.
  LinkerOptions.manual({
    required this.linkInput,
    List<String>? flags,
    bool? gcSections,
    this.linkerScript,
  })  : _flags = flags ?? [],
        gcSections = gcSections ?? true;

  /// Create linking options to tree-shake symbols from the input files. The
  /// [symbols] specify the symbols which should be kept.
  LinkerOptions.treeshake({
    required this.linkInput,
    List<String>? flags,
    required List<String> symbols,
  })  : _flags = <String>{
          ...flags ?? [],
          '--strip-debug',
          ...symbols.expand((e) => ['-u', e]),
        }.toList(),
        gcSections = true,
        linkerScript = _createLinkerScript(symbols);

  /// Get the linker flags for the specified [linker].
  ///
  /// Throws if the [linker] is not supported.
  Iterable<String> flags(Tool linker) {
    final flagList = [
      ..._flags,
      if (gcSections) '--gc-sections',
      if (linkerScript != null)
        '--version-script=${linkerScript!.toFilePath()}',
    ];

    if (linker == clang) {
      return flagList.map((e) => '-Wl,$e');
    } else if (linker == gnuLinker) {
      return flagList;
    } else {
      throw UnsupportedError('Linker flags for $linker are not supported');
    }
  }

  static Uri _createLinkerScript(List<String> symbols) {
    final tempDir = Directory.systemTemp.createTempSync();
    final symbolsFileUri = tempDir.uri.resolve('symbols.lds');
    final symbolsFile = File.fromUri(symbolsFileUri)..createSync();
    symbolsFile.writeAsStringSync('''
{
  global:
    ${symbols.map((e) => '$e;').join('\n    ')}
  local:
    *;
};
''');
    return symbolsFileUri;
  }
}
