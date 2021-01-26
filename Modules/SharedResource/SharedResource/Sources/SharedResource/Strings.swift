// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum Localizable {
  /// Loading text, Please wait. Play back button will be disabled till transcribing ends
  public static let loading = Localizable.tr("Localizable", "loading")
  /// Transcribed will show here. please wait while transcribe begins.
  public static let placeHolderText = Localizable.tr("Localizable", "placeHolderText")
  /// Play
  public static let play = Localizable.tr("Localizable", "play")
  /// Record
  public static let record = Localizable.tr("Localizable", "record")
  /// Stop Recording
  public static let recording = Localizable.tr("Localizable", "recording")
  /// Stop
  public static let stop = Localizable.tr("Localizable", "stop")
  /// 1. Record  2. View transcribed test, 3. Play back audio with text highlighting.
  public static let title = Localizable.tr("Localizable", "title")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension Localizable {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    // swiftlint:disable:next nslocalizedstring_key
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
