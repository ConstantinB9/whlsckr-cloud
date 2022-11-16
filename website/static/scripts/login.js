
let login_button = document.getElementById("login-button");
let password_input = document.getElementById("login-password-input");
let email_input = document.getElementById("login-email-input");

function setCookie(cname, cvalue, exdays) {
    const d = new Date();
    d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
    let expires = "expires=" + d.toUTCString();
    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}

login_button.addEventListener('click', async function () {
    let email = email_input.value;
    let pw = password_input.value;
    let resp = await fetch(`https://c1hls2l1pl.execute-api.eu-central-1.amazonaws.com/whlsckr/auth?email=${email}&password=${pw}`,
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
        console.log("Invalid Credentials")
    }
    console.log("Login Attempt");
})