import '../native_toolchain/clang.dart';
import '../native_toolchain/gcc.dart';
import '../tool/tool.dart';

class LinkerOptions {
  final List<String> _flags;

  final Uri linkInput;

  final bool gcSections;

  final Uri? linkerScript;

  LinkerOptions({
    required List<String> flags,
    required this.linkInput,
    required this.gcSections,
    required this.linkerScript,
  }) : _flags = flags;

  Iterable<String> flags(Tool linker) {
    final flagList = List<String>.from(_flags);
    if (gcSections) {
      flagList.add('--gc-sections');
    }
    if (linkerScript != null) {
      flagList.add('--version-script=$linkerScript');
    }
    if (linker == clang) {
      return flagList.map((e) => '-Wl,$e');
    } else if (linker == gnuLinker) {
      return flagList;
    } else {
      throw UnsupportedError('Linker flags for $linker are not supported');
    }
  }
}
