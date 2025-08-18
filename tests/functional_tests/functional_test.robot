*** Settings ***
Documentation     Functional Test - Hello World
...

*** Test Cases ***
Hello World Functional Test
    [Tags]    functional    smoke    regression
    Log    Hello, Functional World!
