checkLogin();

let auth_cookie = getCookie("x-whlsckr-auth");
let cookie_name = "x-whlsckr-user-data";
let api_url = "https://c1hls2l1pl.execute-api.eu-central-1.amazonaws.com/whlsckr"
buildPage();

function getUserId() {
    auth_data = parseJwt(auth_cookie);
    return auth_data["uid"]
}

async function getUserData() {
    let resp = await fetch(`https://c1hls2l1pl.execute-api.eu-central-1.amazonaws.com/whlsckr/user_data?token=${auth_cookie}`);
    let data = await resp.json();
    setCookie(cookie_name, JSON.stringify(data), 1);
    return data;
}

async function buildPage() {
    let user_data = getCookie(cookie_name);
    if (user_data == "") {
        user_data = getUserData();
    } else {
        user_data = JSON.parse(user_data);
    }
    console.log(user_data);
    let dropbox_card = document.getElementById("dropbox-card");
    getDropboxDiv(true);
    getStravaDiv(true);
    setStravaCredentialsSet(true)

}

function getDropboxDiv(activated) {
    let is_connected_div = document.getElementById("dropbox-connected");
    let is_not_connected_div = document.getElementById("dropbox-not-connected");

    if (activated) {
        is_connected_div.style.display = 'block';
        is_not_connected_div.style.display = 'none';

    } else {
        is_connected_div.style.display = 'none';
        is_not_connected_div.style.display = 'block';
    }
}


function getStravaDiv(activated) {
    let is_connected_div = document.getElementById("strava-connected");
    let is_not_connected_div = document.getElementById("strava-not-connected");

    if (activated) {
        is_connected_div.style.display = 'block';
        is_not_connected_div.style.display = 'none';

    } else {
        is_connected_div.style.display = 'none';
        is_not_connected_div.style.display = 'block';
    }

}

function setStravaCredentialsSet(cred_set) {
    if (cred_set) {
        document.getElementById("strava-credentials-acc-header").innerHTML += `<i class="bi bi-check-circle ms-2" style="color: green;"></i>`
        document.getElementById("strava-credential-submit-btn").innerHTML = "Update"
        document.getElementById("strava-privacy-settings").style.display = "block"
    }
    else {
        document.getElementById("strava-privacy-settings").style.display = "none"
    }
}