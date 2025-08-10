*** Settings ***
Library    AppiumLibrary

*** Variables ***
${APPIUM_SERVER_URL}    %{APPIUM_SERVER_URL}
${APPIUM_CAPS_JSON}     %{APPIUM_CAPS_JSON}

*** Keywords ***
Open App
    ${caps}=    Evaluate    __import__('json').loads(r'''${APPIUM_CAPS_JSON}''')
    Open Application    ${APPIUM_SERVER_URL}    ${caps}

*** Test Cases ***
Abrir aplicativo e fechar
    Open App
    Sleep    2s
    Close Application
