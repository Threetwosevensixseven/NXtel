jQuery.fn.outerHTML = function (s) {
    return s
        ? this.before(s).remove()
        : jQuery("<div>").append(this.eq(0).clone()).html();
};

function setUserPreference(key, value) {
    $.getJSON("/UserPreference/Set", { Key: key, Value: value });
}

function allownumbers(e) {
    var key = window.event ? e.keyCode : e.which;
    if (key < 32)
        return true;
    var keychar = String.fromCharCode(key);
    var reg = new RegExp("[0-9]");
    var carok = reg.test(keychar);
    return carok;
}

function allowalphanumeric(e) {
    var key = window.event ? e.keyCode : e.which;
    var keychar = String.fromCharCode(key);
    var reg = new RegExp("[a-zA-Z0-9]");
    var carok = reg.test(keychar);
    return carok;
}

function allowalpha(e) {
    var key = window.event ? e.keyCode : e.which;
    var keychar = String.fromCharCode(key);
    var reg = new RegExp("[a-zA-Z]");
    var carok = reg.test(keychar);
    return carok;
}
