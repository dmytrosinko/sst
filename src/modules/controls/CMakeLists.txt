project(controls VERSION 1.0 LANGUAGES CXX)
set_source_files_properties(qml/BackButton.qml PROPERTIES QT_RESOURCE_ALIAS BackButton.qml)
set_source_files_properties(qml/Button.qml PROPERTIES QT_RESOURCE_ALIAS Button.qml)
set_source_files_properties(qml/TextField.qml PROPERTIES QT_RESOURCE_ALIAS TextField.qml)
set_source_files_properties(qml/TextArea.qml PROPERTIES QT_RESOURCE_ALIAS TextArea.qml)
set_source_files_properties(qml/LanguageToggle.qml PROPERTIES QT_RESOURCE_ALIAS LanguageToggle.qml)
set_source_files_properties(qml/Tile.qml PROPERTIES QT_RESOURCE_ALIAS Tile.qml)
set_source_files_properties(qml/CardInput.qml PROPERTIES QT_RESOURCE_ALIAS CardInput.qml)
set_source_files_properties(qml/PhoneInput.qml PROPERTIES QT_RESOURCE_ALIAS PhoneInput.qml)
set_source_files_properties(qml/IbanInput.qml PROPERTIES QT_RESOURCE_ALIAS IbanInput.qml)
set_source_files_properties(qml/NumberInput.qml PROPERTIES QT_RESOURCE_ALIAS NumberInput.qml)
set_source_files_properties(qml/StringInput.qml PROPERTIES QT_RESOURCE_ALIAS StringInput.qml)
set_source_files_properties(qml/NumPad.qml PROPERTIES QT_RESOURCE_ALIAS NumPad.qml)
set_source_files_properties(qml/AlphaKeyboard.qml PROPERTIES QT_RESOURCE_ALIAS AlphaKeyboard.qml)
set_source_files_properties(qml/StringKeyboard.qml PROPERTIES QT_RESOURCE_ALIAS StringKeyboard.qml)
set_source_files_properties(qml/CashValidator.qml PROPERTIES QT_RESOURCE_ALIAS CashValidator.qml)

qt_add_qml_module(${PROJECT_NAME}
    URI modules.${PROJECT_NAME}
    VERSION 1.0
    STATIC
    QML_FILES
        qml/BackButton.qml
        qml/Button.qml
        qml/TextField.qml
        qml/TextArea.qml
        qml/LanguageToggle.qml
        qml/Tile.qml
        qml/CardInput.qml
        qml/PhoneInput.qml
        qml/IbanInput.qml
        qml/NumberInput.qml
        qml/StringInput.qml
        qml/NumPad.qml
        qml/StringKeyboard.qml
        qml/CashValidator.qml
    RESOURCES
        assets/cash_slot.svg
        assets/banknote_1000.svg
        assets/banknote_500.svg
        assets/banknote_5000.svg
)

