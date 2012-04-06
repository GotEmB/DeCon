$(document).ready(function() {
	$('#login-form').dialog({
		autoOpen: true,
		height: 240,
		width: 400,
		modal: true,
		resizable: false,
		buttons: {
			"Login": function() {},
			"Cancel": function() {}
		}
	});
});