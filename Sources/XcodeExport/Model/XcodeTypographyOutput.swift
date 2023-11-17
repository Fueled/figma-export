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
    let generateStyles: Bool
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
    
    public struct StyleURLs {
        let directory: URL?
        let extensionsURL: URL?

        public init(
            directory: URL? = nil,
            extensionsURL: URL? = nil
        ) {
            self.directory = directory
            self.extensionsURL = extensionsURL
        }
    }
    
    public struct URLs {
        public let fonts: FontURLs
        public let styles: StyleURLs

        public init(
            fonts: FontURLs,
            styles: StyleURLs
        ) {
            self.fonts = fonts
            self.styles = styles
        }
    }

    public init(
        fontSystem: FontSystem? = .swiftUI,
        urls: URLs,
        generateStyles: Bool? = false,
        addObjcAttribute: Bool? = false,
        templatesPath: URL? = nil
    ) {
        self.fontSystem = fontSystem ?? .swiftUI
        self.urls = urls
        self.generateStyles = generateStyles ?? false
        self.addObjcAttribute = addObjcAttribute ?? false
        self.templatesPath = templatesPath
    }
}
