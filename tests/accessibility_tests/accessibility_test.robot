*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem

*** Variables ***
${URL}               https://www.w3.org/WAI/ARIA/apg/example-index/
${AXE_SCRIPT}        ${CURDIR}/../resources/axe.min.js


*** Test Cases ***
Validar Acessibilidade com Axe-Core
    [Documentation]    Executa o axe-core para validar critérios de acessibilidade da WCAG
    Open Browser    ${URL}    chrome
    Carregar Script do Axe
    ${results}=    Executar Axe e Obter Resultados
    Log To Console    ${results}
    Validar Que Não Há Violações
    Close Browser

*** Keywords ***
Carregar Script do Axe
    ${axe_script}=    Get File    ${AXE_SCRIPT}
    Execute JavaScript    ${axe_script}

Executar Axe e Obter Resultados
    ${result}=    Execute Async JavaScript    return await axe.run();
    [Return]    ${result}

Validar Que Não Há Violações
    ${result}=    Set Variable    
    ${violations}=    Set Variable    ${result['violations']}
    ${count}=    Get Length    ${violations}
    Log    Quantidade de violações WCAG encontradas: ${count}
    Should Be Equal As Integers    ${count}    0    msg=Foram encontradas violações de acessibilidade.
    Log    Nenhuma violação de acessibilidade encontrada.