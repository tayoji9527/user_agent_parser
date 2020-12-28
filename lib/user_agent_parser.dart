library user_agent_parser;

class Result {
  Browser browser;
  Result({
    this.browser,
  });
}

class Browser {
  String name;
  String version;
  List<String> _regexes;
  String parsedWithRegex;

  Browser({this.name, this.version, this.parsedWithRegex});
  Browser._withRegexes({this.name, regexes}) {
    this._regexes = regexes;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Browser &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          version == other.version &&
          _regexes == other._regexes &&
          parsedWithRegex == other.parsedWithRegex;

  @override
  int get hashCode => name.hashCode ^ version.hashCode;
}

class UserAgentParser {
  /// Parse a [Result] from the [userAgent] string.
  ///
  /// TODO: Add other types (engine, os, device, cpu) into [Result]
  Result parseResult(String userAgent) {
    return Result(
      browser: parseBrowser(userAgent),
    );
  }

  /// Parse a [Browser] from the [userAgent] string.
  ///
  /// Returns `null` if no match.
  Browser parseBrowser(String userAgent) {
    for (Browser browser in _browsers) {
      for (String regex in browser._regexes) {
        RegExp regExp = new RegExp(regex, caseSensitive: false);

        if (regExp.hasMatch(userAgent)) {
          Iterable<RegExpMatch> matches = regExp.allMatches(userAgent);
          String version = matches.first.namedGroup('version');

          return Browser(
            name: browser.name,
            version: version,
            parsedWithRegex: regex,
          );
        }
      }
    }

    return null;
  }

  /// Identifies the different browsers that can be parsed from a user agent string.
  ///
  /// Each regex guarantees the following:
  ///    - A named group called 'name' identifies the browser name.
  ///    - A named group called 'version' identifies the browser version.
  ///
  ///  TODO: Add support for Konqueror, Netscape
  ///  TODO: Test that the 'name' group is being parsed correctly
  List<Browser> _browsers = [
    Browser._withRegexes(
      name: 'Opera',
      regexes: [
        r'(?<name>opera\smini)\/(?<version>[\w\.-]+)', // Opera Mini
        r'(?<name>opera\s[mobiletab]{3,6}).+version\/(?<version>[\w\.-]+)', // Opera Mobile/Tablet
        r'(?<name>opera).+version\/(?<version>[\w\.]+)', // Opera > 9.80
        r'(?<name>opera)[\/\s]+(?<version>[\w\.]+)', //Opera < 9.80
        r'(?<name>opios)[\/\s]+(?<version>[\w\.]+)', // Opera Mini for iOS Webkit
        r'\s(?<name>opr)\/(?<version>[\w\.]+)', // Opera Webkit
      ],
    ),
    Browser._withRegexes(
      name: "IE",
      regexes: [
        r'(?<name>iemobile)(?:browser)?[\/\s]?(?<version>[\w\.]*)', // IEMobile
        r'(?:ms|\()(?<name>ie)\s(?<version>[\w\.]+)', // Internet Explorer
        r'(?<name>trident).+rv[:\s](?<version>[\w\.]{1,9}).+like\sgecko', // IE11
      ],
    ),
    Browser._withRegexes(
      name: "Edge",
      regexes: [
        r'(?<name>edge|edgios|edga|edg)\/(?<version>(\d+)?[\w\.]+)', // Edge
      ],
    ),
    Browser._withRegexes(
      name: 'Chrome',
      regexes: [
        r'(?<name>chrome)\/v?(?<version>[\w\.]+)', // Chrome
        r'(?<name>android.+crmo|crios)\/(?<version>[\w\.]+)', // Chrome for iOS/iPad/Some Android
      ],
    ),
    Browser._withRegexes(
      name: 'Safari',
      regexes: [
        r'version\/(?<version>[\w\.]+)\s.*(?<name>mobile\s?safari|safari)', // Safari & Safari Mobile
      ],
    ),
    Browser._withRegexes(
      name: 'Firefox',
      regexes: [
        r'fxios\/(?<version>[\w\.-]+)', // Firefox for iOS
        r'(?<name>firefox)\/(?<version>[\w\.-]+)$', // Firefox
      ],
    ),
  ];
}
