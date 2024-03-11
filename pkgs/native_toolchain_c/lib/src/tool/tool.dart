// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'tool_resolver.dart';

class Tool {
  final String name;

  ToolResolver? defaultResolver;

  Flavor? flavor;

  Tool({
    required this.name,
    this.flavor,
    this.defaultResolver,
  });

  @override
  bool operator ==(Object other) =>
      other is Tool && name == other.name && flavor == other.flavor;

  @override
  int get hashCode => Object.hash(name, flavor?.index, 133709);

  @override
  String toString() => 'Tool($name)';
}

enum Flavor {
  clang,
  mscv,
}
