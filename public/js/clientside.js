
  $(function() {
    $("#login-form").dialog({
      autoOpen: false,
      show: "fade",
      hide: "fade",
      height: 240,
      width: 400,
      modal: true,
      resizable: false,
      buttons: {
        Login: function() {
          return $.get("login", {
            teamname: $("#login_teamname").val(),
            password: Crypto.MD5($("#login_password").val())
          }, function(x) {
            var d;
            d = JSON.parse(x);
            if (d.success) {
              $("#ranking-box div:first-child").text($("#login_teamname").val());
              $("#ranking-box div:last-child").text("\#" + d.rank);
              return $("#login-form").dialog("close");
            } else {
              return $.jAlert("Invalid Teamname / Password!", "error");
            }
          });
        },
        Cancel: function() {
          return $("#login-form").dialog("close");
        }
      }
    });
    $("#login-button").button().click(function() {
      return $("#login-form").dialog("open");
    });
    $("#ranking-box").hover((function() {
      return $(this).addClass("ui-state-hover");
    }), function() {
      return $(this).removeClass("ui-state-hover");
    });
    $("#ranking-box").mousedown(function() {
      return $(this).addClass("ui-state-focus");
    });
    $("#ranking-box").mouseup(function() {
      return $(this).removeClass("ui-state-focus");
    });
    $("#problems-contents div").hover((function() {
      return $(this).addClass("ui-state-hover");
    }), function() {
      return $(this).removeClass("ui-state-hover");
    });
    $("#problems-contents div").mousedown(function() {
      return $(this).addClass("ui-state-focus");
    });
    $("#problems-contents div").mouseup(function() {
      return $(this).removeClass("ui-state-focus");
    });
    $("#problems-contents div:last-child").addClass("ui-corner-bottom");
    $("#scoreboard-data tr th").addClass("ui-widget ui-widget-header");
    $("#scoreboard-data tr td").addClass("ui-widget ui-widget-content");
    return $("#problem-box").toggle();
  });
