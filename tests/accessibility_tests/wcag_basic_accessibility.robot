*** Settings ***
Documentation     Verifica regras básicas de acessibilidade inspiradas na WCAG.
Library           OperatingSystem
Library           String
Library           Collections
Library           ${CURDIR}/../../resources/libraries/a11y_wcag_checker.py

*** Variables ***
${WCAG_PAGES}     ${CURDIR}/../../resources/a11y_wcag_pages.txt
${BAD_PAGE}       ${CURDIR}/../../resources/pages/non_accessible.html

*** Test Cases ***
Paginas Acessiveis Passam nas Regras Basicas
    ${raw}=    Get File    ${WCAG_PAGES}
    @{pages}=  Split To Lines    ${raw}
    FOR    ${p}    IN    @{pages}
        ${clean}=    Strip String    ${p}
        Run Keyword If    '${clean}' != '' and not '${clean}'.startswith('#')    Verificar Pagina WCAG    ${clean}
    END

Pagina Ruim Exibe Problemas
    ${report}=    Generate Accessibility Report    ${BAD_PAGE}
    Log    ${report}
    ${res}=    Analyze Page Accessibility    ${BAD_PAGE}
    Should Not Be Empty    ${res['missing_alt']}
    Should Be True    not ${res['has_title']}
    Should Be True    not ${res['has_h1']}
    Should Be True    not ${res['has_lang']}

*** Keywords ***
Verificar Pagina WCAG
    [Arguments]    ${pagina}
    ${report}=    Generate Accessibility Report    ${pagina}
    Log    ${report}
    Assert Wcag Basic    ${pagina}
