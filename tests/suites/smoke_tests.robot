*** Settings ***
Documentation     Smoke Test - Hello World
...

*** Test Cases ***
Hello World Smoke Test
    [Tags]    smoke
    Log    Hello, Smoke World!
