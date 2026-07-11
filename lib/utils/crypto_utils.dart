import 'dart:typed_data';

class CryptoUtils {
  static const List<int> _k = [
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
  ];

  /// Returns the SHA-256 hash of the input string as a hexadecimal string.
  static String sha256(String input) {
    List<int> bytes = _utf8Encode(input);
    int originalLengthInBits = bytes.length * 8;

    // Padding
    List<int> padded = List.from(bytes)..add(0x80);
    while ((padded.length * 8 + 64) % 512 != 0) {
      padded.add(0);
    }
    
    // Add length in bits as 64-bit big-endian integer
    var lengthBytes = ByteData(8);
    lengthBytes.setUint64(0, originalLengthInBits);
    padded.addAll(lengthBytes.buffer.asUint8List());

    // Initialize hash values:
    int h0 = 0x6a09e667;
    int h1 = 0xbb67ae85;
    int h2 = 0x3c6ef372;
    int h3 = 0xa54ff53a;
    int h4 = 0x510e527f;
    int h5 = 0x9b05688c;
    int h6 = 0x1f83d9ab;
    int h7 = 0x5be0cd19;

    // Process the message in successive 512-bit chunks
    for (int i = 0; i < padded.length; i += 64) {
      List<int> chunk = padded.sublist(i, i + 64);
      var w = List<int>.filled(64, 0);
      var view = ByteData.sublistView(Uint8List.fromList(chunk));
      for (int t = 0; t < 16; t++) {
        w[t] = view.getUint32(t * 4);
      }

      for (int t = 16; t < 64; t++) {
        int s0 = _rotr(w[t - 15], 7) ^ _rotr(w[t - 15], 18) ^ (w[t - 15] >> 3);
        int s1 = _rotr(w[t - 2], 17) ^ _rotr(w[t - 2], 19) ^ (w[t - 2] >> 10);
        w[t] = (w[t - 16] + s0 + w[t - 7] + s1) & 0xFFFFFFFF;
      }

      int a = h0;
      int b = h1;
      int c = h2;
      int d = h3;
      int e = h4;
      int f = h5;
      int g = h6;
      int h = h7;

      for (int t = 0; t < 64; t++) {
        int s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
        int ch = (e & f) ^ (~e & g);
        int temp1 = (h + s1 + ch + _k[t] + w[t]) & 0xFFFFFFFF;
        int s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
        int maj = (a & b) ^ (a & c) ^ (b & c);
        int temp2 = (s0 + maj) & 0xFFFFFFFF;

        h = g;
        g = f;
        f = e;
        e = (d + temp1) & 0xFFFFFFFF;
        d = c;
        c = b;
        b = a;
        a = (temp1 + temp2) & 0xFFFFFFFF;
      }

      h0 = (h0 + a) & 0xFFFFFFFF;
      h1 = (h1 + b) & 0xFFFFFFFF;
      h2 = (h2 + c) & 0xFFFFFFFF;
      h3 = (h3 + d) & 0xFFFFFFFF;
      h4 = (h4 + e) & 0xFFFFFFFF;
      h5 = (h5 + f) & 0xFFFFFFFF;
      h6 = (h6 + g) & 0xFFFFFFFF;
      h7 = (h7 + h) & 0xFFFFFFFF;
    }

    return _toHex(h0) + _toHex(h1) + _toHex(h2) + _toHex(h3) + _toHex(h4) + _toHex(h5) + _toHex(h6) + _toHex(h7);
  }

  static int _rotr(int val, int amt) {
    return ((val >> amt) | (val << (32 - amt))) & 0xFFFFFFFF;
  }

  static List<int> _utf8Encode(String input) {
    List<int> bytes = [];
    for (int i = 0; i < input.length; i++) {
      int code = input.codeUnitAt(i);
      if (code < 0x80) {
        bytes.add(code);
      } else if (code < 0x800) {
        bytes.add(0xC0 | (code >> 6));
        bytes.add(0x80 | (code & 0x3F));
      } else if (code < 0x10000) {
        bytes.add(0xE0 | (code >> 12));
        bytes.add(0x80 | ((code >> 6) & 0x3F));
        bytes.add(0x80 | (code & 0x3F));
      } else {
        bytes.add(0xF0 | (code >> 18));
        bytes.add(0x80 | ((code >> 12) & 0x3F));
        bytes.add(0x80 | ((code >> 6) & 0x3F));
        bytes.add(0x80 | (code & 0x3F));
      }
    }
    return bytes;
  }

  static String _toHex(int val) {
    return val.toRadixString(16).padLeft(8, '0');
  }
}
