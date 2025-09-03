*** Settings ***
Documentation     Verifica atributos alt em imagens de páginas HTML locais.
Library           OperatingSystem
Library           Collections
Library           String
Library           ${CURDIR}/../../resources/libraries/a11y_alt_checker.py

*** Variables ***
${URLS_FILE}      ${CURDIR}/../../resources/a11y_urls.txt

*** Test Cases ***
Todas as imagens possuem texto alternativo
    [Tags]    accessibility    a11y    smoke
    ${raw}=    Get File    ${URLS_FILE}
    @{pages}=  Split To Lines    ${raw}
    FOR    ${p}    IN    @{pages}
        ${limpa}=    Strip String    ${p}
        Run Keyword If    '${limpa}' != '' and not '${limpa}'.startswith('#')    Verificar Pagina    ${limpa}
    END

*** Keywords ***
Verificar Pagina
    [Arguments]    ${pagina}
    ${total}=    Assert No Missing Alts    ${pagina}
    Log    Verificados ${total} elementos img em ${pagina}

