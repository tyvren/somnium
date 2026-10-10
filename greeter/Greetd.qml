import QtQuick
import Quickshell
import Quickshell.Services.Greetd

Connections {
    target: Greetd

    function onStateChanged() {
        switch (Greetd.state) {
        case GreetdState.Inactive:
            errorMessageText.text = ""
            break
        case GreetdState.Authenticating:
            errorMessageText.text = "Authenticating..."
            break
        case GreetdState.ReadyToLaunch:
            Greetd.launch([sessionDropdown.currentExecCommand])
            break
        case GreetdState.Launching:
            errorMessageText.text = "Starting session..."
            break
        case GreetdState.Launched:
            errorMessageText.text = ""
            break
        }
    }

    function onAuthMessage(message, error, responseRequired, echoResponse) {
        if (responseRequired) {
            Greetd.respond(passwordField.text)
        }
    }

    function onAuthFailure(message) {
        errorMessageText.text = message
    }

    function onError(message) {
        errorMessageText.text = message
    }
}
