(function() {
  var fLogin, fLogout, fProblem, fProblems, fScoreboard, fState;

  Array.prototype.select = function(fun) {
    var ret;
    ret = [];
    this.forEach(function(item) {
      return ret.push(fun(item));
    });
    return ret;
  };

  Array.prototype.where = function(fun) {
    var ret;
    ret = [];
    this.forEach(function(item) {
      if (fun(item) === true) return ret.push(item);
    });
    return ret;
  };

  Array.prototype.first = function(fun) {
    if (this.length === 0) {
      return null;
    } else if (fun) {
      return this.where(fun).first();
    } else {
      return this[0];
    }
  };

  Array.prototype.last = function(fun) {
    if (this.length === 0) {
      return null;
    } else if (fun) {
      return this.where(fun).last();
    } else {
      return this[this.length - 1];
    }
  };

  Array.prototype.contains = function(item) {
    return this.where(function(x) {
      return x === item;
    }).length > 0;
  };

  Array.prototype.any = function(fun) {
    return this.where(fun).length > 0;
  };

  Array.prototype.sum = function(fun) {
    var ret;
    if (fun) return this.where(fun).sum();
    ret = 0;
    this.forEach(function(x) {
      return ret += x;
    });
    return ret;
  };

  Array.prototype.except = function(arr) {
    var ret;
    ret = [];
    this.forEach(function(x) {
      if (!arr.contains(x)) return ret.push(x);
    });
    return ret;
  };

  Array.prototype.flatten = function() {
    var ret;
    ret = [];
    this.forEach(function(x) {
      return x.forEach(function(y) {
        return ret.push(y);
      });
    });
    return ret;
  };

  Array.prototype.selectMany = function(fun) {
    return this.select(fun).flatten();
  };

  Array.prototype.groupBy = function(fun) {
    var g1, g2, _results;
    g1 = this.select(function(x) {
      return {
        key: fun(x),
        value: x
      };
    });
    _results = [];
    while (g1.length !== 0) {
      g2 = g1.where(function(x) {
        return x.key === g1.first().key;
      });
      g1 = g1.except(g1.where(function(x) {
        return x.key === g1.first().key;
      }));
      _results.push({
        key: g2.first().key,
        values: g2.select(function(x) {
          return x.value;
        })
      });
    }
    return _results;
  };

  Array.prototype.orderBy = function(fun) {
    var ret;
    ret = this.select(function(x) {
      return x;
    });
    ret.sort(function(a, b) {
      return fun(a) - fun(b);
    });
    return ret;
  };

  Array.prototype.orderByDesc = function(fun) {
    var ret;
    ret = this.select(function(x) {
      return x;
    });
    ret.sort(function(a, b) {
      return fun(b) - fun(a);
    });
    return ret;
  };

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
          return fLogin({
            teamname: $("#login_teamname").val(),
            password: Crypto.MD5($("#login_password").val())
          });
        },
        Cancel: function() {
          return $("#login-form").dialog("close");
        }
      }
    });
    $("#login-button").button().click(function() {
      if ($(this).text() === "Login") {
        return $("#login-form").dialog("open");
      } else {
        return fLogout();
      }
    });
    $("#ranking-box").click(fScoreboard);
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
    $("#problems-contents div:last-child").addClass("ui-corner-bottom");
    $("#scoreboard-data tr th").addClass("ui-widget ui-widget-header");
    $("#scoreboard-data tr td").addClass("ui-widget ui-widget-content");
    return fState();
  });

  fState = function() {
    return $.get("state", function(d) {
      if (d.loggedin) {
        $("#ranking-box div:first-child").text(d.teamname);
        $("#ranking-box div:last-child").text(d.rank === "Unranked" ? "Unranked" : "#" + d.rank);
        $("#login-button span.ui-button-text").text("Logout");
      }
      return fProblems();
    });
  };

  fLogin = function(auth) {
    return $.get("login", auth, function(d) {
      if (d.success) {
        $("#ranking-box div:first-child").text($("#login_teamname").val());
        $("#ranking-box div:last-child").text(d.rank === "Unranked" ? "Unranked" : "#" + d.rank);
        $("#login-form").dialog("close");
        $("#login-button span.ui-button-text").text("Logout");
        return fProblems();
      } else {
        return $.jAlert("Invalid Teamname / Password!", "error");
      }
    });
  };

  fLogout = function() {
    return $.get("logout", function(d) {
      $("#ranking-box div:first-child").text("Scoreboard");
      $("#ranking-box div:last-child").text("");
      $("#login-button span.ui-button-text").text("Login");
      if (!d.success) {
        return $.jAlert("There are no active sessions.", "highlight");
      }
    });
  };

  fProblems = function() {
    return $.get("problems", function(d) {
      var i, _ref;
      d = d.sort();
      $("#problems-contents").html("");
      for (i = 0, _ref = d.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
        $("#problems-contents").append("<div><span>" + (i + 1) + "</span><span>" + d[i].title + "</span>" + (d[i].done ? "<span>&#10004;</span>" : void 0));
      }
      $("#problems-contents div").addClass("ui-button ui-widget ui-widget-content ui-state-normal ui-button-text-only");
      $("#problems-contents div").click(function() {
        return fProblem($(this).children("span:nth-child(2)").text());
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
      return $("#problems-contents").prepend("<div class=\"ui-widget ui-widget-content ui-corner-bottom\"></div>");
    });
  };

  fProblem = function(p) {
    return $.get("problems/" + p, function(d) {
      $("#problem-header span:first-child").text(p);
      $("#problem-header span:nth-child(2)").text("" + d.points + " Point" + (d.points === 1 ? "" : "s"));
      $("#problem-container").html("");
      $("#problem-container").append("<div class=\"desc\">" + d.description + "</div>");
      $("#scoreboard-box").hide();
      return $("#problem-box").show();
    });
  };

  fScoreboard = function() {
    return $.get("scoreboard", function(d) {
      var h, qs, _i, _len, _ref, _ref2;
      d = d.sort(function(a, b) {
        return a.rank - b.rank;
      });
      $("#scoreboard-data thead tr").html("");
      _ref = ["Rank", "Success Kid", "Score", "Penalty"];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        h = _ref[_i];
        $("#scoreboard-data thead tr").append("<th>" + h + "</th>");
      }
      for (h = 1, _ref2 = $("#problems-contents div span:nth-child(2)").length; 1 <= _ref2 ? h <= _ref2 : h >= _ref2; 1 <= _ref2 ? h++ : h--) {
        $("#scoreboard-data thead tr").append("<th>" + h + "</th>");
      }
      $("#scoreboard-data tbody").html("");
      d.forEach(function(t) {
        var h, _j, _k, _len2, _len3, _ref3, _ref4, _results;
        $("#scoreboard-data tbody").append("<tr></tr>");
        _ref3 = [t.rank, t.team, t.score, t.penalty];
        for (_j = 0, _len2 = _ref3.length; _j < _len2; _j++) {
          h = _ref3[_j];
          $("#scoreboard-data tbody tr:last-child").append("<td>" + h + "</td>");
        }
        _ref4 = $("#problems-contents div span:nth-child(2)").select(function(j) {
          return $(j);
        });
        _results = [];
        for (_k = 0, _len3 = _ref4.length; _k < _len3; _k++) {
          h = _ref4[_k];
          _results.push($("#scoreboard-data tbody tr:last-child").append("<td>" + (t.problemsdone.any(function(x) {
            return x.problem === h && x.done;
          }) ? "$#10004;" : "") + "</td>"));
        }
        return _results;
      });
      qs = $("#problems-contents div span:nth-child(2)");
      $("#problem-box").hide();
      return $("#scoreboard-box").show();
    });
  };

}).call(this);
