import Foundation
import FigmaExportCore
import Stencil

final public class XcodeTypographyExporter: XcodeExporterBase {
    private enum Error: LocalizedError {
        case missingFont
        case missingUIFont

        var errorDescription: String? {
            switch self {
            case .missingFont:
                return "swiftUIFontExtensionURL required when using SwiftUI fontSystem"
            case .missingUIFont:
                return "fontExtensionURL required when using UIKit or SwiftUI fontSystem"
            }
        }
    }

    private let output: XcodeTypographyOutput

    public init(output: XcodeTypographyOutput) {
        self.output = output
    }

    public func export(textStyles: [TextStyle]) throws -> [FileContents] {
        var files: [FileContents] = []

        // UIKit UIFont extension
        guard let url = output.urls.fonts.fontExtensionURL else {
            throw Error.missingUIFont
        }
        files.append(try makeUIFontExtension(textStyles: textStyles, fontExtensionURL: url))

        // SwiftUI Font extension
        if output.fontSystem == .swiftUI {
            guard let url = output.urls.fonts.swiftUIFontExtensionURL else {
                throw Error.missingFont
            }
            files.append(try makeFontExtension(textStyles: textStyles, swiftUIFontExtensionURL: url))
        }

        // UIKit Labels
        if output.generateLabels, let labelsDirectory = output.urls.labels.labelsDirectory  {
            // Label.swift
            files.append(try makeLabel(
                textStyles: textStyles,
                labelsDirectory: labelsDirectory,
                separateStyles: output.urls.labels.labelStyleExtensionsURL != nil
            ))

            // LabelStyle.swift
            files.append(try makeLabelStyle(labelsDirectory: labelsDirectory))

            // LabelStyle extensions
            if let url = output.urls.labels.labelStyleExtensionsURL {
                files.append(try makeStyleExtensionFileContents(
                    fontSystem: .uiKit,
                    textStyles: textStyles,
                    styleExtensionURL: url
                ))
            }
        }

        // TextStyles
        if output.generateTextStyles, let textStylesDirectory = output.urls.textStyles.textStyleDirectory  {
            // TextStyle.swift
            files.append(try makeTextStyle(fontSystem: output.fontSystem, directory: textStylesDirectory))

            // TextStyle extensions
            if let url = output.urls.textStyles.textStyleExtensionsURL {
                files.append(try makeStyleExtensionFileContents(
                    fontSystem: .swiftUI,
                    textStyles: textStyles,
                    styleExtensionURL: url
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

    private func makeLabel(textStyles: [TextStyle], labelsDirectory: URL, separateStyles: Bool) throws -> FileContents {
        let dict = textStyles.map { style -> [String: Any] in
            let type: String = style.fontStyle?.textStyleName ?? ""
            return [
                "className": style.name.first!.uppercased() + style.name.dropFirst(),
                "varName": style.name,
                "size": style.fontSize,
                "supportsDynamicType": style.fontStyle != nil,
                "type": type,
                "tracking": style.letterSpacing.floatingPointFixed,
                "lineHeight": style.lineHeight ?? 0,
                "textCase": style.textCase.rawValue
            ]}
        let env = makeEnvironment(templatesPath: output.templatesPath)
        let contents = try env.renderTemplate(name: "Label.swift.stencil", context: [
            "styles": dict,
            "separateStyles": separateStyles
        ])
        return try makeFileContents(for: contents, directory: labelsDirectory, file: URL(string: "Label.swift")!)
    }

    private func makeLabelStyle(labelsDirectory: URL) throws -> FileContents {
        let env = makeEnvironment(templatesPath: output.templatesPath)
        let labelStyleSwiftContents = try env.renderTemplate(name: "LabelStyle.swift.stencil")
        return try makeFileContents(for: labelStyleSwiftContents, directory: labelsDirectory, file: URL(string: "LabelStyle.swift")!)
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

    private func makeStyleExtensionFileContents(fontSystem: FontSystem, textStyles: [TextStyle], styleExtensionURL: URL) throws -> FileContents {
        let dict = textStyles.map { style -> [String: Any] in
            let type: String = style.fontStyle?.textStyleName ?? ""
            let textCase: String = {
                switch fontSystem {
                case .swiftUI:
                    switch style.textCase {
                    case .lowercased:
                        return "lowercase"
                    case .uppercased:
                        return "uppercase"
                    case .original:
                        return "original"
                    }
                case .uiKit:
                    return style.textCase.rawValue
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
        let contents = try env.renderTemplate(name: fontSystem.styleExtensionStencilFile, context: ["styles": dict])

        let stylesSwiftExtension = try makeFileContents(for: contents, url: styleExtensionURL)
        return stylesSwiftExtension
    }

    private func makeTextStyle(fontSystem: FontSystem, directory: URL) throws -> FileContents {
        let env = makeEnvironment(templatesPath: output.templatesPath)
        let textStyleSwiftContents = try env.renderTemplate(name: fontSystem.styleStencilFile)
        return try makeFileContents(for: textStyleSwiftContents, directory: directory, file: URL(string: fontSystem.styleFile)!)
    }
}
