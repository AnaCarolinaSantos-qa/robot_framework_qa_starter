*** Settings ***
Documentation    Exemplo mínimo de teste mobile no BrowserStack (Android)
Library          AppiumLibrary
Suite Setup      Abrir Sessao
Suite Teardown   Close All Applications

*** Variables ***
${BROWSERSTACK_USER}    %{BROWSERSTACK_USERNAME}
${BROWSERSTACK_KEY}     %{BROWSERSTACK_ACCESS_KEY}
${REMOTE_URL}           http://${BROWSERSTACK_USER}:${BROWSERSTACK_KEY}@hub-cloud.browserstack.com/wd/hub

# A variável BS_APP virá do workflow (robot -v BS_APP:"bs://...").
# Caso não seja passada, este valor padrão será usado (ajuste se quiser rodar local).
${BS_APP}               bs://DUMMY_APP_ID

${DEVICE}               Google Pixel 7
${OS_VERSION}           13.0

&{CAPS}
...    platformName=Android
...    app=${BS_APP}
...    deviceName=${DEVICE}
...    platformVersion=${OS_VERSION}
...    automationName=UIAutomator2
...    bstack:options={"projectName":"PoC QA","buildName":"Robot PoC","sessionName":"Login flow","appiumVersion":"2.0.0"}

*** Keywords ***
Abrir Sessao
    Open Application    ${REMOTE_URL}    &{CAPS}

*** Test Cases ***
Abrir App e Validar Tela Inicial
    [Documentation]    Espera elemento genérico da tela inicial (ajuste os seletores conforme seu app)
    Wait Until Page Contains Element    xpath=//android.view.View    10s
    # Exemplos:
    # Click Element    id=com.seu.app:id/btnLogin
    # Page Should Contain Element    id=com.seu.app:id/inputEmail
