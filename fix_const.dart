import 'dart:io';

void main() {
  final dynamicVars = ['kGold', 'kBg', 'kCard', 'kText', 'kMuted', 'kTeal', 'kShubha', 'kAshubha', 'kMadhyama', 'kBorder', 'kCardBorder', 'kPurple', 'appGradientColors'];

  final dir = Directory('lib');
  for (final f in dir.listSync(recursive: true)) {
    if (f is! File || !f.path.endsWith('.dart')) continue;
    var content = f.readAsStringSync();
    var changed = false;

    // Remove 'const' before any expression containing dynamic color vars
    for (final v in dynamicVars) {
      // const TextStyle(...color: kXxx...)
      final r1 = RegExp(r'const\s+(TextStyle\([^)]*' + v + r')');
      if (r1.hasMatch(content)) {
        content = content.replaceAll(r1, r'$1');
        changed = true;
      }
      // const Icon(...color: kXxx...)
      final r2 = RegExp(r'const\s+(Icon\([^)]*' + v + r')');
      if (r2.hasMatch(content)) {
        content = content.replaceAll(r2, r'$1');
        changed = true;
      }
      // const Center(child: CircularProgressIndicator(color: kXxx))
      final r3 = RegExp(r'const\s+(Center\(child:\s*CircularProgressIndicator\([^)]*' + v + r')');
      if (r3.hasMatch(content)) {
        content = content.replaceAll(r3, r'$1');
        changed = true;
      }
      // const SizedBox(...CircularProgressIndicator(...kXxx...))
      final r4 = RegExp(r'const\s+(SizedBox\([^)]*CircularProgressIndicator\([^)]*' + v + r')');
      if (r4.hasMatch(content)) {
        content = content.replaceAll(r4, r'$1');
        changed = true;
      }
      // const ColorScheme.dark/light(...kXxx...)
      final r5 = RegExp(r'const\s+(ColorScheme\.\w+\([^)]*' + v + r')');
      if (r5.hasMatch(content)) {
        content = content.replaceAll(r5, r'$1');
        changed = true;
      }
    }

    if (changed) {
      f.writeAsStringSync(content);
      print('Fixed: ${f.path}');
    }
  }
  print('Done!');
}
