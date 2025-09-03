*** Settings ***
Documentation     Executa axe-core via Selenium em uma lista de URLs e salva JSON por página.
Library           SeleniumLibrary
Library           OperatingSystem
Library           String
Library           ${CURDIR}/../../resources/libraries/a11y_keywords.py

Suite Setup       Preparar Navegador
Suite Teardown    Close All Browsers

*** Variables ***
${BROWSER}        chrome
${OUTPUT_DIR}     ${EXECDIR}/results/accessibility
${FAIL_ON}        serious
${URLS_FILE}      ${CURDIR}/../../resources/a11y_urls.txt
${WIN_WIDTH}      1366
${WIN_HEIGHT}     900

*** Keywords ***
Preparar Navegador
    Open Browser       about:blank    ${BROWSER}    headless=True
    Set Window Size    ${WIN_WIDTH}   ${WIN_HEIGHT}

Auditar URL
    [Arguments]    ${url}
    Go To    ${url}
    ${safe}=    Replace String Using Regexp    ${url}    [^a-zA-Z0-9\-]    -
    ${res}=    Run Axe And Save    ${OUTPUT_DIR}    ${safe}    ${FAIL_ON}
    Log To Console    \n[AXE] ${url} => ${res}

*** Test Cases ***
A11y Smoke - Lista de Páginas
    [Tags]    a11y    smoke    regression
    ${raw}=    Get File    ${URLS_FILE}
    @{URLS}=   Split To Lines    ${raw}
    FOR    ${url}    IN    @{URLS}
        Run Keyword If    '${url}'!=''    Auditar URL    ${url}
    END
