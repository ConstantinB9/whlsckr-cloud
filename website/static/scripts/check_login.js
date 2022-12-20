function checkLogin() {
    let auth_cookie = getCookie("x-whlsckr-auth")

    if (auth_cookie == "") {
        window.location.replace("/login.html");
    }
}