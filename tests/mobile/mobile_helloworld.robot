*** Settings ***
Documentation     Hello World fake para testes Mobile.
Library           BuiltIn

*** Test Cases ***
Mobile Hello World
    [Tags]    mobile
    [Documentation]    Exemplo de teste fake de Mobile (sem Appium, sem APK).
    Log To Console     ===== Iniciando teste Mobile (fake) =====
    Sleep              2s
    Log To Console     Olá, este é um teste de Mobile simulado! 🚀
    Sleep              1s
    Log To Console     ===== Finalizando teste Mobile (fake) =====
