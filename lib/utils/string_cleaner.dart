import 'dart:convert';
import 'package:http/http.dart' as http;

/// Use this when you get the response from the server
/// Usage: String jsonString = getBody(response);
String getBody(http.Response response) {
  try {
    // directly decodes the raw bytes as utf8
    return utf8.decode(response.bodyBytes);
  } catch (e) {
    // if decoding fails, return original body as fallback
    return response.body;
  }
}

/// Use this if you already have a string that looks like "ââ"
/// Usage: String cleanTitle = fixMojibake(item.title);
String fixMojibake(String text) {
  try {
    // this trick works by encoding back to latin1 bytes 
    // and then re-decoding correctly as utf8
    return utf8.decode(latin1.encode(text));
  } catch (e) {
    return text;
  }
}