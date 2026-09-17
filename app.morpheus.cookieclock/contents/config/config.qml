import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: "General"
        icon: "settings-configure"
        source: "configStyle.qml"
    }

    ConfigCategory {
        name: "Appearance"
        icon: "preferences-desktop-theme"
        source: "configAppearance.qml"
    }

    ConfigCategory {
        name: "World Clock"
        icon: "globe"
        source: "configWorldClocks.qml"
    }
}
