*** Settings ***
Documentation     UI Test - Hello World
...

*** Test Cases ***
Hello World UI Test
    [Tags]    ui    smoke    regression
    Log    Hello, UI World!
