/// OpenAPI `VibeStatus`. Fixed presets only — never free text or a place name.
enum Vibe {
  ngopi('NGOPI', 'Ngopi', 'Ngopi'),
  diskusi('DISKUSI', 'Diskusi', 'Diskusi'),
  kegiatan('KEGIATAN', 'Kegiatan', 'Kegiatan'),
  openToSayHi('OPEN_TO_SAY_HI', 'Say hi', 'Open to say hi');

  const Vibe(this.apiValue, this.shortLabel, this.label);

  final String apiValue;

  /// One word on the Radar avatar.
  final String shortLabel;

  /// Fuller phrase on the member card.
  final String label;

  static Vibe? fromApi(Object? value) {
    if (value is! String) return null;
    for (final vibe in Vibe.values) {
      if (vibe.apiValue == value) return vibe;
    }
    return null;
  }
}
