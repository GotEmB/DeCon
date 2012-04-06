$(document).ready(function() {
	$('#login-form').dialog({
		autoOpen: false,
		height: 240,
		width: 400,
		modal: true,
		resizable: false,
		buttons: {
			"Login": function() {},
			"Cancel": function() {}
		}
	});
	
	$('#ranking-box').hover(function() {$(this).addClass('ui-state-hover')}, function() {$(this).removeClass('ui-state-hover')});
	$('#ranking-box').mousedown(function() {$(this).addClass('ui-state-focus')});
	$('#ranking-box').mouseup(function() {$(this).removeClass('ui-state-focus')});
});