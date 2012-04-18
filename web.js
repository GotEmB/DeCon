// Generated by CoffeeScript 1.3.1
(function() {
  var Sync, db, express, fs, md, md5, problems, roundStart, server, url;

  express = require("express");

  url = require("url");

  db = require("mongojs").connect(process.env.MONGOLAB_URI, ["Teams", "FileDump"]);

  md5 = require("MD5");

  fs = require("fs.extra");

  md = require("node-markdown").Markdown;

  Sync = require("sync");

  problems = void 0;

  roundStart = void 0;

  Object.prototype.toDictionary = function() {
    var key, ret;
    ret = [];
    for (key in this) {
      if (key !== "__proto__" && key !== "toDictionary") {
        ret.push({
          key: key,
          value: this[key]
        });
      }
    }
    return ret;
  };

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
      if (fun(item) === true) {
        return ret.push(item);
      }
    });
    return ret;
  };

  Array.prototype.first = function(fun) {
    var ret;
    if (!fun) {
      return this[0];
    }
    ret = this.where(fun);
    if (ret.length !== 0) {
      return ret[0];
    } else {
      return null;
    }
  };

  Array.prototype.contains = function(item) {
    return this.where(function(x) {
      return x === item;
    }) > 0;
  };

  Array.prototype.any = function(fun) {
    return this.where(fun).length > 0;
  };

  Array.prototype.sum = function(fun) {
    var ret;
    if (fun) {
      return this.where(fun).sum();
    }
    ret = 0;
    this.forEach(function(x) {
      return ret += x;
    });
    return ret;
  };

  JSON.parseWithDate = function(json) {
    var reISO, reMsAjax;
    reISO = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)Z$/;
    reMsAjax = /^\/Date\((d|-|.*)\)\/$/;
    return JSON.parse(json, function(key, value) {
      var a, b;
      if (typeof value === "string") {
        a = reISO.exec(value);
        if (a) {
          return new Date(Date.UTC(+a[1], +a[2] - 1, +a[3], +a[4], +a[5], +a[6]));
        }
        a = reMsAjax.exec(value);
        if (a) {
          b = a[1].split(/[-,.]/);
          return new Date(+b[0]);
        }
      }
      return value;
    });
  };

  server = express.createServer(express.logger(), express.cookieParser(), express.session({
    key: "auth.sid",
    secret: "badampam-pshh!h34uhif3"
  }), express.bodyParser(), express["static"]("" + __dirname + "/public"));

  server.get("/*", function(req, res, next) {
    return Sync(function() {
      return next();
    });
  });

  server.get("/problems", function(req, res, next) {
    req.ret = problems.toDictionary().select(function(x) {
      return {
        title: x.key
      };
    });
    return next();
  });

  server.get("/problems/:p", function(req, res, next) {
    var p;
    req.ret = {};
    p = problems[req.params.p];
    req.ret.description = md(fs.readFileSync("problems/" + p.folder + "/description.md", "utf8"));
    req.ret.points = p.points;
    return next();
  });

  server.get("/scoreboard", function(req, res, next) {
    req.ret = (this.t1 = db.Teams).find.sync(t1).select(function(x) {
      return {
        team: x.teamname,
        problemsdone: problems.toDictionary().select(function(y) {
          return {
            problem: y.key,
            done: x.problemsdone.toDictionary().any(function(z) {
              return z.key === y.key;
            })
          };
        }),
        score: x.problemsdone.toDictionary().select(function(y) {
          return problems[y.key].points;
        }).sum(),
        penalty: new Date(x.problemsdone.toDictionary().select(function(y) {
          return (y.value.getTime() - roundStart.getTime()) * (1.0 / problems[y.key].points);
        }).sum())
      };
    });
    return res.send(JSON.stringify(req.ret));
  });

  server.get("/*", function(req, res, next) {
    var lurl, setUpFileDump, value;
    setUpFileDump = function(teamname) {
      var problemTitle, _results;
      _results = [];
      for (problemTitle in problems) {
        if (problemTitle !== "__proto__" && problemTitle !== "toDictionary") {
          _results.push(problems[problemTitle].editable.forEach(function(fileName) {
            if ((this.t1 = db.FileDump.find({
              team: teamname,
              problem: problemTitle,
              file: fileName
            })).count.sync(this.t1) === 0) {
              return (this.t2 = db.FileDump).save.sync(this.t2, {
                team: teamname,
                problem: problemTitle,
                file: fileName,
                data: fs.readFileSync("problems/" + problems[problemTitle].folder + "/editable/" + fileName, "utf8")
              });
            }
          }));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };
    lurl = url.parse(req.url, true);
    if (lurl.pathname === "/logout") {
      req.session.destroy();
      return res.send("You will be remembered.");
    } else if (lurl.pathname === "/login") {
      value = (this.t1 = db.Teams.find({
        teamname: decodeURIComponent(req.query.teamname),
        password: decodeURIComponent(req.query.password)
      })).count.sync(this.t1);
      if (value === 1) {
        req.session.auth = true;
        req.session.teamname = decodeURIComponent(req.query.teamname);
        setUpFileDump(decodeURIComponent(req.query.teamname));
        return res.send("A new beginning.");
      } else {
        return res.send("You trick me bro?<br>403! Joor-Zah-Frul !!!");
      }
    } else if (req.session && req.session.auth === true) {
      return next();
    } else if (req.ret) {
      return res.send(JSON.stringify(req.ret));
    } else {
      return res.send("Who d'ya think you are?<br>403! Joor-Zah-Frul !!!");
    }
  });

  server.get("/problems", function(req, res, next) {
    var teaminfo;
    teaminfo = (this.t1 = db.Teams).find.sync(this.t1, {
      teamname: req.session.teamname
    }).first();
    req.ret.forEach(function(x) {
      return x.done = teaminfo.problemsdone.toDictionary().any(function(y) {
        return y.key === x.title;
      });
    });
    return res.send(JSON.stringify(req.ret));
  });

  server.get("/problems/:p", function(req, res, next) {
    var editables, stdiop;
    stdiop = function(file) {
      if (file === "stdout") {
        return "Standard Output";
      } else {
        if (file === "stdin") {
          return "Standard Input";
        }
      }
    };
    editables = (this.t1 = db.FileDump).find.sync(this.t1, {
      team: req.session.teamname,
      problem: req.params.p
    });
    req.ret.editables = [];
    editables.forEach(function(x) {
      return req.ret.editables.push({
        file: stdiop(x.file),
        data: x.data,
        language: problems[req.params.p].files[x.file]
      });
    });
    if (problems[req.params.p].sample) {
      req.ret.sample = [];
      fs.readdir.sync(null, "problems/" + problems[req.params.p].folder + "/sample/before").forEach(function(x) {
        return req.ret.sample.push({
          file: stdiop(x),
          data_before: fs.readFile.sync(null)
        }, "problems/" + problems[req.params.p].folder + "/sample/before/" + x, "utf8", {
          language: problems[req.params.p].files[x]
        });
      });
      fs.readdir.sync(null, "problems/" + problems[req.params.p].folder + "/sample/after").forEach(function(x) {
        if (req.ret.sample.any(function(y) {
          return y.file;
        }) === x) {
          return req.ret.sample.first(function(y) {
            return y.file === x;
          }).data_after = fs.readFile.sync(null, "problems/" + problems[req.params.p].folder + "/sample/after/" + x, "utf8");
        } else {
          return req.ret.sample.push({
            file: stdiop(x),
            data_after: fs.readFile.sync(null)
          }, "problems/" + problems[req.params.p].folder + "/sample/after/" + x, "utf8", {
            language: problems[req.params.p].files[x]
          });
        }
      });
    }
    return res.send(JSON.stringify(req.ret));
  });

  server.get("/problems/:p/run/:dcase", function(req, res, next) {
    var folder;
    folder = "/sandbox/" + md5(req.session.teamname + req.params.p + req.params.dcase + (new Date()).getTime());
    fs.mkdir.sync(null, folder, "0777");
    return fs.readdir.sync(null, "problems/" + problems[req.params.p].folder + "/" + req.params.dcase + "/before").forEach(function(x) {
      return fs.copy.sync(null, "problems/" + problems[req.params.p].folder + "/" + req.params.dcase + "/before/" + x, folder + "/" + x);
    });
  });

  server.get("/*", function(req, res) {
    return res.send("You hack me bro?<br>404! Fus-Ro-Dah !!!");
  });

  Sync(function() {
    var port;
    problems = JSON.parseWithDate(fs.readFile.sync(null, "problems/index.json", "utf8")).first(function(x) {
      return x.start <= new Date() && x.end >= new Date();
    }).problems;
    roundStart = JSON.parseWithDate(fs.readFile.sync(null, "problems/index.json", "utf8")).first(function(x) {
      return x.start <= new Date() && x.end >= new Date();
    }).start;
    port = process.env.PORT || 5000;
    return server.listen(port, function() {
      return console.log("Listening on port " + port);
    });
  });

}).call(this);
