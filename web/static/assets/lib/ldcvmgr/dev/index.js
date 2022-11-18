// Generated by LiveScript 1.6.0
var ldcvmgr;
ldcvmgr = function(opt){
  var that;
  opt == null && (opt = {});
  this.opt = opt;
  this.evtHandler = {};
  this.path = opt.path || "/modules/cover";
  if (typeof this.path === 'string') {
    this.path = this.path.replace(/\/$/, '');
  }
  this.loader = (that = opt.loader)
    ? that
    : new ldloader({
      className: "ldld full",
      autoZ: true
    });
  this.mgr = opt.manager || null;
  this.covers = {};
  this.workers = {};
  this.errorCover = opt.errorCover || 'error';
  this.errorHandling = false;
  this.prepareProxy = proxise(function(n){});
  if (opt.zmgr) {
    this.zmgr(opt.zmgr);
  }
  this.baseZ = opt.baseZ || (opt.zmgr ? 'modal' : 3000);
  if (opt.autoInit) {
    this.init();
  }
  return this;
};
ldcvmgr.prototype = import$(Object.create(Object.prototype), {
  on: function(n, cb){
    var ref$;
    return ((ref$ = this.evtHandler)[n] || (ref$[n] = [])).push(cb);
  },
  fire: function(n){
    var v, res$, i$, to$, ref$, len$, cb, results$ = [];
    res$ = [];
    for (i$ = 1, to$ = arguments.length; i$ < to$; ++i$) {
      res$.push(arguments[i$]);
    }
    v = res$;
    for (i$ = 0, len$ = (ref$ = this.evtHandler[n] || []).length; i$ < len$; ++i$) {
      cb = ref$[i$];
      results$.push(cb.apply(this, v));
    }
    return results$;
  },
  zmgr: function(it){
    if (it != null) {
      return this._zmgr = it;
    } else {
      return this._zmgr;
    }
  },
  error: function(n, e, p){
    n == null && (n = '');
    e == null && (e = {});
    p == null && (p = {});
    if (n === 'error' || n === this.errorCover || n === this._id(this.errorCover)) {
      alert("something is wrong; please reload and try again");
    } else {
      this.errorHandling = true;
      this.toggle(this.errorCover || 'error', true, {
        err: e,
        param: p
      });
    }
    return console.log(e.message || e);
  },
  _id: function(o){
    if (typeof o === 'object') {
      return this.mgr.id(o);
    } else {
      return o;
    }
  },
  prepare: function(o){
    var n, p, that, name, this$ = this;
    n = this._id(o);
    if (this.covers[n]) {
      return Promise.resolve();
    }
    if (this.workers[n]) {
      return this.prepareProxy(n);
    }
    if (this.errorHandling) {
      this.loader.on();
      this.errorHandling = false;
    } else {
      this.loader.on(1000);
    }
    p = typeof o === 'object'
      ? this.workers[n] = this.mgr.get(o).then(function(bc){
        return bc.create();
      }).then(function(bi){
        return bi.attach({
          root: document.body,
          data: {
            zmgr: this$._zmgr,
            baseZ: this$.baseZ
          }
        }).then(function(){
          var ret;
          this$.covers[n] = ret = bi['interface']();
          return bi.dom();
        });
      })
      : (that = document.querySelector(".ldcvmgr[data-name='" + n + "']"))
        ? Promise.resolve(that)
        : (name = typeof this.path === 'function'
          ? this.path(n)
          : this.path + "/" + n + ".html", this.workers[n] = fetch(name).then(function(v){
          if (!(v && v.ok)) {
            throw new Error("modal '" + (!n ? '<no-name>' : n) + "' load failed.");
          }
          return v.text();
        }).then(function(it){
          var div, root;
          document.body.appendChild(div = ld$.create({
            name: 'div'
          }));
          div.innerHTML = it;
          ld$.find(div, 'script').map(function(it){
            var script;
            script = ld$.create({
              name: 'script',
              attr: {
                type: 'text/javascript'
              }
            });
            script.text = it.textContent;
            return it.parentNode.replaceChild(script, it);
          });
          return root = div.querySelector('.ldcv');
        }));
    return p['finally'](function(){
      return this$.loader.cancel(false);
    }).then(function(root){
      var ref$, ref1$;
      if (!this$.covers[n]) {
        this$.covers[n] = new ldcover({
          root: root,
          lock: root.getAttribute('data-lock') === 'true',
          zmgr: this$._zmgr,
          baseZ: this$.baseZ
        });
      }
      this$.prepareProxy.resolve();
      return ref1$ = (ref$ = this$.workers)[n], delete ref$[n], ref1$;
    })['catch'](function(it){
      this$.prepareProxy.reject(it);
      delete this$.workers[n];
      throw it;
    });
  },
  purge: function(o){
    var n, ref$, ref1$;
    n = this._id(o);
    if (n != null) {
      return ref1$ = (ref$ = this.covers)[n], delete ref$[n], ref1$;
    } else {
      return this.covers = {};
    }
  },
  lock: function(o, p){
    var n, this$ = this;
    n = this._id(o);
    return this.prepare(o).then(function(){
      return this$.covers[n].lock();
    }).then(function(){
      return this$.covers[n].toggle(true, p);
    })['catch'](function(e){
      return this$.error(n, e, p);
    });
  },
  toggle: function(o, v, p){
    var n, this$ = this;
    n = this._id(o);
    return this.prepare(o).then(function(){
      return this$.covers[n].toggle(v, p);
    }).then(function(){
      return this$.fire((this$.covers[n].isOn() ? 'on' : 'off') + "", {
        node: this$.covers[n],
        param: p,
        name: n
      });
    })['catch'](function(e){
      return this$.error(n, e, p);
    });
  },
  getcover: function(o){
    var n, this$ = this;
    n = this._id(o);
    return this.prepare(o).then(function(){
      return this$.covers[n];
    });
  },
  getdom: function(o){
    var n, this$ = this;
    n = this._id(o);
    return this.prepare(o).then(function(){
      return this$.covers[n].root();
    });
  },
  isOn: function(o){
    var n;
    n = this._id(o);
    return this.covers[n] && this.covers[n].isOn();
  },
  set: function(o, p){
    var n, this$ = this;
    n = this._id(o);
    return this.prepare(o).then(function(){
      return this$.covers[n].set(p);
    });
  },
  get: function(o, p){
    var n, this$ = this;
    n = this._id(o);
    return this.prepare(o).then(function(){
      this$.fire("on", {
        node: this$.covers[n],
        param: p,
        name: n
      });
      return this$.covers[n].get(p);
    })['catch'](function(e){
      return this$.error(n, e, p);
    });
  },
  init: function(root){
    var this$ = this;
    ld$.find(root || document.body, '.ldcvmgr').map(function(n){
      var id;
      if (!(id = n.getAttribute('data-name')) || this$.covers[id]) {
        return;
      }
      return this$.covers[id] = new ldcover({
        root: n,
        lock: n.getAttribute('data-lock') === 'true',
        zmgr: this$._zmgr,
        baseZ: this$.baseZ
      });
    });
    return document.body.addEventListener('click', function(evt){
      var n, id;
      if (!(n = ld$.parent(evt.target, "[data-ldcvmgr-toggle]"))) {
        return;
      }
      if (!(id = n.getAttribute('data-ldcvmgr-toggle'))) {
        return;
      }
      return this$.toggle(/:/.exec(id) ? this$.mgr.id2obj(id) : id);
    });
  }
});
if (typeof module != 'undefined' && module !== null) {
  module.exports = ldcvmgr;
} else if (typeof window != 'undefined' && window !== null) {
  window.ldcvmgr = ldcvmgr;
}
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}
