
let login_button = document.getElementById("login-button");
let password_input = document.getElementById("login-password-input");
let email_input = document.getElementById("login-email-input");


login_button.addEventListener('click', async function () {
    let email = email_input.value;
    let pw = password_input.value;

    if (email == "" || pw == "") {
        let alert_placeholder = document.getElementById("CredentialAlertPlaceholder")
        alert_placeholder.innerHTML = [
            `<div class="alert alert-warning  alert-dismissible" role="alert">`,
            `   <div>Pleas enter Username and Password</div>`,
            '   <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>',
            '</div>'
        ].join('')
        return;
    }
    console.log(encrypt_str(pw))
    let resp = await fetch(`https://c1hls2l1pl.execute-api.eu-central-1.amazonaws.com/whlsckr/auth?email=${email}&password=${encrypt_str(pw)}`,
        { mode: 'cors' }
    )
    try {
        let body = await resp.json();
        for (var prop in body) {
            if (Object.prototype.hasOwnProperty.call(body, prop)) {
                setCookie(prop, body[prop], exdays = 7)
            }
        }
        window.location.replace("/index.html");
    } catch (error) {
        email_input.value = "";
        password_input.value = "";
        let alert_placeholder = document.getElementById("CredentialAlertPlaceholder")
        alert_placeholder.innerHTML = [
            `<div class="alert alert-danger  alert-dismissible" role="alert">`,
            `   <div>Username or Password are invalid!</div>`,
            '   <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>',
            '</div>'
        ].join('')
        console.log("Invalid Credentials")
    }
    console.log("Login Attempt");
})