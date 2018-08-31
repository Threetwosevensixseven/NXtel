$(document).ready(function () {
    showPreview();
    $("#export").on("click", "a", function (event) {
        var data = $(this).attr("href");
        if (data.startsWith("http"))
            return;
        event.stopPropagation();
        event.preventDefault();
        var iframe = "<iframe width='100%' height='100%' src='" + data + "'></iframe>"
        var x = window.open();
        x.document.open();
        x.document.write(iframe);
        x.document.close();
    });
    $("#URL").on("keyup", function (event) {
        var data = $.trim($("#URL").val());
        data = data.split("#").pop();
        $("#URL").val(data);
        showPreview();
    });
    $("#EditContent").show();
});

function launchEditor() {
    $(".navbar").hide();
    $(".container").hide();
    $("html").addClass("with-iframe");
    var data = $("#URL").val();
    var editor = new Editor();
    active_editor = editor;
    url_editor = editor;
    editor.set_size(1);
    $("#EditorWrapper").show();
    editor.init_frame("frame");
    editor.set_reveal(1);
    editor.load(data);
}

function backtoNXtel() {
    var data = window.location.hash;
    data = data.split("#").pop();
    $("#URL").val(data);
    showPreview();
    $("#EditorWrapper").hide();
    $("html").removeClass("with-iframe");
    $(".container").show();
    $(".navbar").show();
}

function showPreview() {
    var data = $("#URL").val();
    var editor = new Editor();
    active_editor = null;
    url_editor = null;
    editor.set_size(0.5);
    editor.init_frame("framePreview");
    editor.set_reveal(1);
    editor.load(data);
    document.onkeypress = null;
    document.onkeydown = null;
}