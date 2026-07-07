/// Utilities for sanitizing HTML content for display as plain text.
class HtmlUtils {
  HtmlUtils._();

  /// Strips HTML tags and decodes common entities.
  /// e.g. "<p>Hello&nbsp;World</p>" → "Hello World"
  static String stripHtml(String html) {
    if (html.isEmpty) return html;
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
