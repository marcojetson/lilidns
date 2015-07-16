var client = new ZeroClipboard($('[data-clipboard-text]'));

client.on('ready', function () {
    client.on('aftercopy', function () {
    	$.createNotification({
    		content: 'Token copied to clipboard',
    		vertical: 'bottom'
    	});
    });
});
