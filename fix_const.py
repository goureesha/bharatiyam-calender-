import os, re

# Remove const from any widget constructor in files that use dynamic theme vars
# This is aggressive but safe - Flutter analyzer will add const back where appropriate
dynamic_vars = ['kGold','kBg','kCard','kText','kMuted','kTeal','kShubha','kAshubha','kMadhyama','kBorder','kCardBorder','appGradientColors']

widget_patterns = [
    'const SnackBar(',
    'const InputDecoration(',
    'const BorderSide(',
    'const Border(',
    'const BoxDecoration(',
    'const LinearGradient(',
    'const ColorScheme.',
]

for root, dirs, files in os.walk('lib'):
    for fn in files:
        if not fn.endswith('.dart'): continue
        fp = os.path.join(root, fn)
        with open(fp, 'r', encoding='utf-8') as f:
            content = f.read()
        # Only process files that use dynamic vars
        if not any(v in content for v in dynamic_vars): continue
        orig = content
        for pat in widget_patterns:
            content = content.replace(pat, pat.replace('const ', '', 1))
        if content != orig:
            with open(fp, 'w', encoding='utf-8') as f:
                f.write(content)
            print('Fixed: ' + fn)

print('Done!')
