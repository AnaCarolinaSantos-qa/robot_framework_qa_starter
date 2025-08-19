*** Settings ***
Documentation     Exemplos de validação de acessibilidade com axe-core
Library           SeleniumLibrary
Library           OperatingSystem
Library           String
Library           Collections
Library           BuiltIn
Library           ${CURDIR}/../../resources/libraries/a11y_keywords.py

Suite Setup       Preparar Navegador
Suite Teardown    Close All Browsers
Test Teardown     Run Keyword And Ignore Error    Capture Page Screenshot

*** Variables ***
${BROWSER}        chrome
${OUTPUT_DIR}     ${EXECDIR}/results/accessibility
${FAIL_ON}        critical
${URLS_FILE}      ${CURDIR}/../../resources/a11y_urls.txt
${WIN_WIDTH}      1366
${WIN_HEIGHT}     900

${SINGLE_URL}     https://www.w3.org/WAI/ARIA/apg/example-index/
${AXE_SCRIPT}     ${CURDIR}/../../resources/axe.min.js
${AXE_CDN}        https://cdnjs.cloudflare.com/ajax/libs/axe-core/4.9.1/axe.min.js
@{RUN_ONLY_TAGS}  wcag2a    wcag2aa
${MAX_VIOLATIONS}    0

*** Keywords ***
Preparar Navegador
    [Documentation]    Abre navegador em modo headless e ajusta tamanho da janela.
    ${driver_path}=    Evaluate    __import__('webdriver_manager.chrome', fromlist=['ChromeDriverManager']).ChromeDriverManager().install()
    Open Browser    about:blank    ${BROWSER}    options=add_argument("--headless");add_argument("--disable-gpu");add_argument("--no-sandbox");add_argument("--disable-dev-shm-usage")    executable_path=${driver_path}
    Set Window Size    ${WIN_WIDTH}    ${WIN_HEIGHT}
    Register Keyword To Run On Failure    Capture Page Screenshot

Auditar URL
    [Arguments]    ${url}
    Go To    ${url}
    ${safe}=    Replace String Using Regexp    ${url}    [^a-zA-Z0-9\-]    -
    ${res}=    Run Axe And Save    ${OUTPUT_DIR}    ${safe}    ${FAIL_ON}
    Log To Console    \n[AXE] ${url} => ${res}

Carregar Axe (Local Ou CDN)
    ${existe}=    Run Keyword And Return Status    File Should Exist    ${AXE_SCRIPT}
    Run Keyword If    ${existe}    Carregar Axe Local
    ...    ELSE    Carregar Axe Via CDN
    Aguardar Axe Disponivel

Carregar Axe Local
    ${axe_script}=    Get File    ${AXE_SCRIPT}
    Execute JavaScript    ${axe_script}

Carregar Axe Via CDN
    Execute Async JavaScript
    ...    var url = arguments[0];
    ...    var cb = arguments[arguments.length - 1];
    ...    var s = document.createElement('script');
    ...    s.src = url;
    ...    s.onload = function(){ cb(true); };
    ...    s.onerror = function(){ cb(false); };
    ...    document.head.appendChild(s);
    ...    return;
    ...    ${AXE_CDN}

Aguardar Axe Disponivel
    Wait Until Keyword Succeeds    10x    1s    Verificar Axe Disponivel

Verificar Axe Disponivel
    ${ready}=    Execute JavaScript    return !!(window.axe && window.axe.run);
    Should Be True    ${ready}    msg=axe-core não disponível no contexto da página.

Executar Axe E Obter Resultados
    [Arguments]    @{tags}
    ${script}=    Set Variable    return axe.run(document, {\n    ...      runOnly: { type: 'tag', values: arguments[0] },\n    ...      resultTypes: ['violations']\n    ...    });
    ${result}=    Execute Async JavaScript    var cb=arguments[arguments.length-1]; ${script}.then(r=>cb(r)).catch(e=>cb({error: e && e.message || String(e)}));
    Run Keyword If    '${result}'=='None'    Fail    Falha ao executar axe.run (resultado vazio).
    Run Keyword If    'error' in ${result}    Fail    Erro no axe.run: ${result['error']}
    RETURN    ${result}

Imprimir Resumo De Violacoes
    [Arguments]    ${result}
    ${violations}=    Set Variable    ${result['violations']}
    ${count}=         Get Length      ${violations}
    Log To Console    \n===== Resumo de Violações WCAG (total: ${count}) =====
    FOR    ${v}    IN    @{violations}
        ${id}=        Get From Dictionary    ${v}    id
        ${impact}=    Get From Dictionary    ${v}    impact
        ${nodes}=     Get From Dictionary    ${v}    nodes
        ${ncount}=    Get Length    ${nodes}
        Log To Console    - ${id} | impacto: ${impact} | ocorrências: ${ncount}
    END
    Log    ${result}

Validar Que Nao Ha Violacoes
    [Arguments]    ${result}    ${max}
    ${violations}=    Set Variable    ${result['violations']}
    ${count}=         Get Length      ${violations}
    Log    Quantidade de violações WCAG encontradas: ${count}
    Should Be True    ${count} <= ${max}    msg=Foram encontradas ${count} violações de acessibilidade (limite permitido: ${max}).
    Log    Nenhuma violação acima do limite configurado.

*** Test Cases ***
A11y Smoke - Lista de Páginas
    ${raw}=    Get File    ${URLS_FILE}
    @{URLS}=   Split To Lines    ${raw}
    FOR    ${url}    IN    @{URLS}
        Run Keyword If    '${url}'!=''    Auditar URL    ${url}
    END

A11y - Página Única com Injection
    Go To    ${SINGLE_URL}
    Carregar Axe (Local Ou CDN)
    ${results}=        Executar Axe E Obter Resultados    @{RUN_ONLY_TAGS}
    Imprimir Resumo De Violacoes    ${results}
    Validar Que Nao Ha Violacoes    ${results}    ${MAX_VIOLATIONS}
