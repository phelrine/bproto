
$(document).ready(function(){
    $('#myModal').modal({show: false});
    $('li.user-list img').tooltip({placement: "bottom"});
    $('#mainTab a').click(function (e) {
        e.preventDefault();
        $(this).tab('show');
    });

    $("img").error(function(){
        $(this).hide();
        return true;
    });

    $('#subTab a').click(function (e) {
        e.preventDefault();
        $(this).tab('show');
    });

    $('#logoutButton').click(function(){
        $('#logoutForm').submit();
    });

    $('#bookmarkForm').submit(function(){
        var form = $(this);
        $.ajax({
            method: 'POST',
            url: form.attr('action'),
            data: form.serialize(),
            datatype: 'html',
            success: function(data) {
                location.href = '/';
                return false;
            },
            error: function bookmarkCallback() {
                $('#bookmarkForm').get(0).reset();
                $('#myModal').modal('hide');
                $('#bookmarkLoading').hide();
            }
        });
        $('#bookmarkLoading').show();

        return false;
    });


    $('.bookmark-remove-btn').click(function(){
        var form = $($(this).parent().get(0));
        var loading = $("img.loading", form).show();
        console.log(form.attr('action'));
        console.log(form.serialize());
        $.post(form.attr('action'), form.serialize(), function() {
            loading.hide();
            location.href = '/';
        });
    });
});
