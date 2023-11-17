import Foundation
import FigmaExportCore
import Stencil

final public class XcodeTypographyExporter: XcodeExporterBase {
    private let output: XcodeTypographyOutput

    public init(output: XcodeTypographyOutput) {
        self.output = output
    }

    public func export(textStyles: [TextStyle]) throws -> [FileContents] {
        var files: [FileContents] = []

        // UIKit UIFont extension
        if let url = output.urls.fonts.fontExtensionURL {
            files.append(try makeUIFontExtension(textStyles: textStyles, fontExtensionURL: url))
        }

        // SwiftUI Font extension
        if let url = output.urls.fonts.swiftUIFontExtensionURL {
            files.append(try makeFontExtension(textStyles: textStyles, swiftUIFontExtensionURL: url))
        }

        // SwiftUI TextStyles
        if output.generateTextStyles, let textStylesDirectory = output.urls.textStyles.textStylesDirectory  {
            // TextStyle.swift
            files.append(try makeTextStyle(textStylesDirectory: textStylesDirectory))

            // TextStyle extensions
            if let url = output.urls.textStyles.textStyleExtensionsURL {
                files.append(try makeTextStyleExtensionFileContents(
                    textStyles: textStyles,
                    textStyleExtensionURL: url
                ))
            }
        }

        return files
    }
    
    private func makeUIFontExtension(textStyles: [TextStyle], fontExtensionURL: URL) throws -> FileContents {
        let textStyles: [[String: Any]] = textStyles.map {
            [
                "name": $0.name,
                "fontName": $0.fontName,
                "fontSize": $0.fontSize,
                "supportsDynamicType": $0.fontStyle != nil,
                "type": $0.fontStyle?.textStyleName ?? ""
            ]
        }
        let env = makeEnvironment(templatesPath: output.templatesPath)
        let contents = try env.renderTemplate(name: "UIFont+extension.swift.stencil", context: [
            "textStyles": textStyles,
            "addObjcPrefix": output.addObjcAttribute
        ])
        return try makeFileContents(for: contents, url: fontExtensionURL)
    }
    
    private func makeFontExtension(textStyles: [TextStyle], swiftUIFontExtensionURL: URL) throws -> FileContents {
        let textStyles: [[String: Any]] = textStyles.map {
            [
                "name": $0.name,
                "fontName": $0.fontName,
                "fontSize": $0.fontSize,
                "supportsDynamicType": $0.fontStyle != nil,
                "type": $0.fontStyle?.textStyleName ?? ""
            ]
        }
        let env = makeEnvironment(templatesPath: output.templatesPath)
        let contents = try env.renderTemplate(name: "Font+extension.swift.stencil", context: [
            "textStyles": textStyles,
        ])
        return try makeFileContents(for: contents, url: swiftUIFontExtensionURL)
    }

    private func makeTextStyleExtensionFileContents(textStyles: [TextStyle], textStyleExtensionURL: URL) throws -> FileContents {
        let dict = textStyles.map { style -> [String: Any] in
            let type: String = style.fontStyle?.textStyleName ?? ""
            let textCase: String = {
                switch style.textCase {
                case .lowercased:
                    return "lowercase"
                case .uppercased:
                    return "uppercase"
                case .original:
                    return "original"
                }
            }()
            return [
                "className": style.name.first!.uppercased() + style.name.dropFirst(),
                "varName": style.name,
                "size": style.fontSize,
                "supportsDynamicType": style.fontStyle != nil,
                "type": type,
                "tracking": style.letterSpacing.floatingPointFixed,
                "lineHeight": style.lineHeight ?? 0,
                "textCase": textCase
            ]
        }
        let env = makeEnvironment(templatesPath: output.templatesPath)
        let contents = try env.renderTemplate(name: "TextStyle+extension.swift.stencil", context: ["styles": dict])

        let textStylesSwiftExtension = try makeFileContents(for: contents, url: textStyleExtensionURL)
        return textStylesSwiftExtension
    }

    private func makeTextStyle(textStylesDirectory: URL) throws -> FileContents {
        let env = makeEnvironment(templatesPath: output.templatesPath)
        let textStyleSwiftContents = try env.renderTemplate(name: "TextStyle.swift.stencil")
        return try makeFileContents(for: textStyleSwiftContents, directory: textStylesDirectory, file: URL(string: "TextStyle.swift")!)
    }
}
