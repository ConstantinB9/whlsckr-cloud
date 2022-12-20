let public_key = atob(getCookie("PublicKey"))



if (public_key == "") {
    fetch("https://nglxbsij4e.execute-api.eu-central-1.amazonaws.com/whlsckr_website/api/auth/key").then(function (resp) {
        return resp.json()
    }).then(function (data) {
        setCookie("PublicKey", btoa(data), 7);
        public_key = data;
    })
}

var encrypt = new JSEncrypt();
encrypt.setPublicKey(public_key.replace('\n', ''));

let encrypt_str = function (obj) {
    return encrypt.encrypt(obj)
}
