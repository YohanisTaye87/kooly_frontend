String buildImageUrl(String base, String? path) {
  if ((path ?? '').isEmpty) return '';
  final p = path!.trim();
  if (p.startsWith('http://') || p.startsWith('https://')) return p;

  final b = base.trim().replaceAll(RegExp(r'/+$'), '');
  final pp = p.replaceAll(RegExp(r'^/+'), '');
  return '$b/$pp';
}
