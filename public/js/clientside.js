$(document).ready(function() {
	$('#login-form').dialog({
		autoOpen: false,
		show: 'fade',
		hide: 'fade',
		height: 240,
		width: 400,
		modal: true,
		resizable: false,
		buttons: {
			"Login": function() {},
			"Cancel": function() {$('#login-form').dialog('close')}
		}
	});
	$('#login-button').button().click(function() {$('#login-form').dialog('open')});
	
	$('#ranking-box').hover(function() {$(this).addClass('ui-state-hover')}, function() {$(this).removeClass('ui-state-hover')});
	$('#ranking-box').mousedown(function() {$(this).addClass('ui-state-focus')});
	$('#ranking-box').mouseup(function() {$(this).removeClass('ui-state-focus')});
	
	$('#problems-contents div').hover(function() {$(this).addClass('ui-state-hover')}, function() {$(this).removeClass('ui-state-hover')});
	$('#problems-contents div').mousedown(function() {$(this).addClass('ui-state-focus')});
	$('#problems-contents div').mouseup(function() {$(this).removeClass('ui-state-focus')});
	$('#problems-contents div:last-child').addClass('ui-corner-bottom');
	
	$('#scoreboard-data tr th').addClass('ui-widget ui-widget-header');
	$('#scoreboard-data tr td').addClass('ui-widget ui-widget-content');
	
	var editor = ace.edit('editor');
	var JavaScriptMode = require("ace/mode/javascript").Mode;
	editor.getSession().setMode(new JavaScriptMode());
});