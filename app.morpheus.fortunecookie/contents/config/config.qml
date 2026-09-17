import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: "General"
        icon: "settings-configure"
        source: "configGeneral.qml"
    }

    ConfigCategory {
        name: "Appearance"
        icon: "preferences-desktop-theme"
        source: "configAppearance.qml"
    }

    ConfigCategory {
        name: "Advanced"
        icon: "preferences-other"
        source: "configAdvanced.qml"
    }
}
