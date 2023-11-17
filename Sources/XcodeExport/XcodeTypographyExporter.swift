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

        // UIKit & SwiftUI UIFont extension
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

        // Styles
        if output.generateStyles, let stylesDirectory = output.urls.styles.directory  {
            files.append(try makeStyle(fontSystem: output.fontSystem, directory: stylesDirectory))

            if let url = output.urls.styles.extensionsURL {
                files.append(try makeStyleExtensionFileContents(
                    fontSystem: output.fontSystem,
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

    private func makeStyleExtensionFileContents(fontSystem: FontSystem, textStyles: [TextStyle], textStyleExtensionURL: URL) throws -> FileContents {
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

        let textStylesSwiftExtension = try makeFileContents(for: contents, url: textStyleExtensionURL)
        return textStylesSwiftExtension
    }

    private func makeStyle(fontSystem: FontSystem, directory: URL) throws -> FileContents {
        let env = makeEnvironment(templatesPath: output.templatesPath)
        let textStyleSwiftContents = try env.renderTemplate(name: fontSystem.styleStencilFile)
        return try makeFileContents(for: textStyleSwiftContents, directory: directory, file: URL(string: fontSystem.styleFile)!)
    }
}
