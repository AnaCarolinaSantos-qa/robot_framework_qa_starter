*** Settings ***
Documentation     Executa axe-core via Selenium em uma lista de URLs e salva JSON por página.
Library           SeleniumLibrary
Library           OperatingSystem
Library           String
Library           ../../resources/libraries/a11y_keywords.py    WITH NAME    A11y


Suite Setup       Preparar Navegador
Suite Teardown    Close All Browsers

*** Variables ***
${BROWSER}        chrome
${OUTPUT_DIR}     ${EXECDIR}/results/accessibility
${FAIL_ON}        serious
${URLS_FILE}      ${EXECDIR}/resources/a11y_urls.txt
${WIN_SIZE}       1366,900

*** Keywords ***
Preparar Navegador
    ${opts}=    Set Variable    add_argument=--headless=new;add_argument=--disable-gpu;add_argument=--no-sandbox;add_argument=--disable-dev-shm-usage;add_argument=--window-size=${WIN_SIZE}
    Open Browser    about:blank    ${BROWSER}    options=${opts}

Auditar URL
    [Arguments]    ${url}
    Go To    ${url}
    ${safe}=    Replace String Using Regexp    ${url}    [^a-zA-Z0-9\-]    -
    ${res}=    A11y.Run Axe And Save    ${OUTPUT_DIR}    ${safe}    ${FAIL_ON}
    Log To Console    \n[AXE] ${url} => ${res}

*** Test Cases ***
A11y Smoke - Lista de Páginas
    ${raw}=    Get File    ${URLS_FILE}
    @{URLS}=   Split To Lines    ${raw}
    FOR    ${url}    IN    @{URLS}
        Run Keyword If    '${url}'!=''    Auditar URL    ${url}
    END
