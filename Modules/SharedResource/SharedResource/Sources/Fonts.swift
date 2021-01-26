// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSFont
  public typealias Font = NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIFont
  public typealias Font = UIFont
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Fonts

// swiftlint:disable identifier_name line_length type_body_length
public enum FontFamily {
  public enum NunitoSans {
    public static let black = FontConvertible(name: "NunitoSans-Black", family: "Nunito Sans", path: "NunitoSans-Black.ttf")
    public static let blackItalic = FontConvertible(name: "NunitoSans-BlackItalic", family: "Nunito Sans", path: "NunitoSans-BlackItalic.ttf")
    public static let bold = FontConvertible(name: "NunitoSans-Bold", family: "Nunito Sans", path: "NunitoSans-Bold.ttf")
    public static let boldItalic = FontConvertible(name: "NunitoSans-BoldItalic", family: "Nunito Sans", path: "NunitoSans-BoldItalic.ttf")
    public static let extraBold = FontConvertible(name: "NunitoSans-ExtraBold", family: "Nunito Sans", path: "NunitoSans-ExtraBold.ttf")
    public static let extraBoldItalic = FontConvertible(name: "NunitoSans-ExtraBoldItalic", family: "Nunito Sans", path: "NunitoSans-ExtraBoldItalic.ttf")
    public static let extraLight = FontConvertible(name: "NunitoSans-ExtraLight", family: "Nunito Sans", path: "NunitoSans-ExtraLight.ttf")
    public static let extraLightItalic = FontConvertible(name: "NunitoSans-ExtraLightItalic", family: "Nunito Sans", path: "NunitoSans-ExtraLightItalic.ttf")
    public static let italic = FontConvertible(name: "NunitoSans-Italic", family: "Nunito Sans", path: "NunitoSans-Italic.ttf")
    public static let light = FontConvertible(name: "NunitoSans-Light", family: "Nunito Sans", path: "NunitoSans-Light.ttf")
    public static let lightItalic = FontConvertible(name: "NunitoSans-LightItalic", family: "Nunito Sans", path: "NunitoSans-LightItalic.ttf")
    public static let regular = FontConvertible(name: "NunitoSans-Regular", family: "Nunito Sans", path: "NunitoSans-Regular.ttf")
    public static let semiBold = FontConvertible(name: "NunitoSans-SemiBold", family: "Nunito Sans", path: "NunitoSans-SemiBold.ttf")
    public static let semiBoldItalic = FontConvertible(name: "NunitoSans-SemiBoldItalic", family: "Nunito Sans", path: "NunitoSans-SemiBoldItalic.ttf")
    public static let all: [FontConvertible] = [black, blackItalic, bold, boldItalic, extraBold, extraBoldItalic, extraLight, extraLightItalic, italic, light, lightItalic, regular, semiBold, semiBoldItalic]
  }
  public static let allCustomFonts: [FontConvertible] = [NunitoSans.all].flatMap { $0 }
  public static func registerAllCustomFonts() {
    allCustomFonts.forEach { $0.register() }
  }
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

public struct FontConvertible {
  public let name: String
  public let family: String
  public let path: String

  public func font(size: CGFloat) -> Font! {
    return Font(font: self, size: size)
  }

  public func register() {
    // swiftlint:disable:next conditional_returns_on_newline
    guard let url = url else { return }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }

  fileprivate var url: URL? {
    let bundle = Bundle(for: BundleToken.self)
    return bundle.url(forResource: path, withExtension: nil)
  }
}

public extension Font {
  convenience init!(font: FontConvertible, size: CGFloat) {
    #if os(iOS) || os(tvOS) || os(watchOS)
    if !UIFont.fontNames(forFamilyName: font.family).contains(font.name) {
      font.register()
    }
    #elseif os(OSX)
    if let url = font.url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
      font.register()
    }
    #endif

    self.init(name: font.name, size: size)
  }
}

private final class BundleToken {}
