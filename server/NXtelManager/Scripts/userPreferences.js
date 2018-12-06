function setUserPreference(key, value) {
    $.getJSON("/UserPreference/Set", { Key: key, Value: value });
}
