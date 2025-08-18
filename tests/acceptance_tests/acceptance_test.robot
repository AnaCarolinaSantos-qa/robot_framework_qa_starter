*** Settings ***
Documentation     Acceptance Test - Hello World
...

*** Test Cases ***
Hello World Acceptance Test
    [Tags]    acceptance    smoke    regression
    Log    Hello, Acceptance World!
