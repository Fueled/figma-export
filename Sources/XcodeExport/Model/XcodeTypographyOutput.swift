import Foundation

public enum FontSystem: String, Decodable {
    case uiKit = "UIKit"
    case swiftUI = "SwiftUI"

    var styleExtensionStencilFile: String {
        switch self {
        case .swiftUI:
            return "TextStyle+extension.swift.stencil"
        case .uiKit:
            return "LabelStyle+extension.swift.stencil"
        }
    }

    var styleStencilFile: String {
        switch self {
        case .swiftUI:
            return "TextStyle.swift.stencil"
        case .uiKit:
            return "LabelStyle.swift.stencil"
        }
    }

    var styleFile: String {
        switch self {
        case .swiftUI:
            return "TextStyle.swift"
        case .uiKit:
            return "LabelStyle.swift"
        }
    }
}

public struct XcodeTypographyOutput {
    let fontSystem: FontSystem
    let urls: URLs
    let generateLabels: Bool
    let generateTextStyles: Bool
    let addObjcAttribute: Bool
    let templatesPath: URL?
    
    public struct FontURLs {
        let fontExtensionURL: URL?
        let swiftUIFontExtensionURL: URL?
        public init(
            fontExtensionURL: URL? = nil,
            swiftUIFontExtensionURL: URL? = nil
        ) {
            self.swiftUIFontExtensionURL = swiftUIFontExtensionURL
            self.fontExtensionURL = fontExtensionURL
        }
    }

    public struct LabelURLs {
        let labelsDirectory: URL?
        let labelStyleExtensionsURL: URL?

        public init(
            labelsDirectory: URL? = nil,
            labelStyleExtensionsURL: URL? = nil
        ) {
            self.labelsDirectory = labelsDirectory
            self.labelStyleExtensionsURL = labelStyleExtensionsURL
        }
    }

    public struct TextStyleURLs {
        let textStyleDirectory: URL?
        let textStyleExtensionsURL: URL?

        public init(
            textStyleDirectory: URL? = nil,
            textStyleExtensionsURL: URL? = nil
        ) {
            self.textStyleDirectory = textStyleDirectory
            self.textStyleExtensionsURL = textStyleExtensionsURL
        }
    }

    public struct URLs {
        public let fonts: FontURLs
        public let labels: LabelURLs
        public let textStyles: TextStyleURLs

        public init(
            fonts: FontURLs,
            labels: LabelURLs,
            textStyles: TextStyleURLs
        ) {
            self.fonts = fonts
            self.labels = labels
            self.textStyles = textStyles
        }
    }

    public init(
        fontSystem: FontSystem? = .swiftUI,
        urls: URLs,
        generateLabels: Bool? = false,
        generateTextStyles: Bool? = false,
        addObjcAttribute: Bool? = false,
        templatesPath: URL? = nil
    ) {
        self.fontSystem = fontSystem ?? .swiftUI
        self.urls = urls
        self.generateLabels = generateLabels ?? false
        self.generateTextStyles = generateTextStyles ?? false
        self.addObjcAttribute = addObjcAttribute ?? false
        self.templatesPath = templatesPath
    }
}
