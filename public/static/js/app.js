var client = new ZeroClipboard($('[data-clipboard-text]'));

client.on('ready', function () {
    client.on('aftercopy', function () {
        alert('Token copied to clipboard');
    });
});
