project(finance VERSION 1.0 LANGUAGES CXX)

qt_add_qml_module(${PROJECT_NAME}
    URI modules.${PROJECT_NAME}
    VERSION 1.0
    STATIC
    SOURCES
        TransactionStatus.h
        TransactionSession.h
        TransactionSession.cpp
        FinanceBackend.h
        FinanceBackend.cpp
        TransactionController.h
        TransactionController.cpp
)
