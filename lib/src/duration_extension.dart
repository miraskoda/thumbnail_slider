/// Extension on [Duration] to provide time formatting functionality.
extension DurationExtension on Duration {
  /// Formats the duration as a time string.
  ///
  /// Returns:
  /// - `MM:SS` format for durations less than 1 hour
  /// - `H:MM:SS` format for durations 1 hour or longer
  ///
  /// Example:
  /// ```dart
  /// Duration(minutes: 5, seconds: 30).formatTime() // "05:30"
  /// Duration(hours: 1, minutes: 30).formatTime() // "1:30:00"
  /// ```
  String formatTime() {
    String digits(int n) => n.toString().padLeft(2, '0');
    final String hours = inHours > 0 ? '$inHours:' : '';
    final String minutes = digits(inMinutes.remainder(60));
    final String seconds = digits(inSeconds.remainder(60));
    return '$hours$minutes:$seconds';
  }
}
