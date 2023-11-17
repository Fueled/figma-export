//  swiftlint:disable all
//
//  The code generated using FigmaExport — Command line utility to export
//  colors, typography, icons and images from Figma to Xcode project.
//
//  https://github.com/RedMadRobot/figma-export
//
//  Don’t edit this code manually to avoid runtime crashes
//

import UIKit

public extension UIFont {
    static let body: UIFont = customFont("PTSans-Regular", size: 16.0, textStyle: .body)
    static let caption: UIFont = customFont("PTSans-Regular", size: 14.0, textStyle: .footnote)
    static let header: UIFont = customFont("PTSans-Bold", size: 20.0)
    static let largeTitle: UIFont = customFont("PTSans-Bold", size: 34.0, textStyle: .largeTitle)
    static let uppercased: UIFont = customFont("PTSans-Regular", size: 14.0)

    private static func customFont(
        _ name: String,
        size: CGFloat,
        textStyle: UIFont.TextStyle? = nil
    ) -> UIFont {
        guard let font = UIFont(name: name, size: size) else {
            print("Warning: Font \(name) not found.")
            return UIFont.systemFont(ofSize: size, weight: .regular)
        }

        if let textStyle {
            let metrics = UIFontMetrics(forTextStyle: textStyle)
            return metrics.scaledFont(for: font)
        }

        return font
    }

    internal func lineSpacing(lineHeight customLineHeight: CGFloat) -> CGFloat {
        max(0, customLineHeight - self.lineHeight)
    }
}
