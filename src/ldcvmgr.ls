ldcvmgr = (opt={}) ->
  @opt = opt
  @evt-handler = {}
  @path = opt.path or "/modules/cover"
  if typeof(@path) == \string => @path = @path.replace(/\/$/,'')
  @loader = if opt.loader => that else new ldLoader className: "ldld full", auto-z: true
  @covers = {}
  @workers = {}
  @error-handling = false
  @prepare-proxy = proxise (n) ->
  @init!
  @

ldcvmgr.prototype = Object.create(Object.prototype) <<< do
  on: (n, cb) -> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
  error: (n = '', e = {}) ->
    if n == \error => alert "something is wrong; please reload and try again"
    else
      # toggle this so we know that we are handling internal error.
      @error-handling = true
      @toggle \error
    console.log(e.message or e)

  prepare: (n) ->
    if @covers[n] => return Promise.resolve!
    if @workers[n] => return @prepare-proxy(n)
    # @error-handling means that we are toggling `error` due to internal error,
    # so loader might already be triggered ( and just dismissed ).
    # dont wait to make it looks better without blinking effect.
    if @error-handling =>
      @loader.on!
      @error-handling = false
    else @loader.on 1000
    p = if document.querySelector(".ldcvmgr[data-name=#n]") => Promise.resolve(that)
    else
      name = if typeof(@path) == \function => @path(n) else "#{@path}/#n.html"
      @workers[n] = fetch name
        .then (v) ~>
          if !(v and v.ok) => throw new Error("modal '#{if !n => '<no-name>' else n}' load failed.")
          v.text!
        .then ~>
          document.body.appendChild (div = ld$.create name: \div)
          div.innerHTML = it
          ld$.find(div,\script).map ->
            script = ld$.create name: \script, attr: type: \text/javascript
            script.text = it.textContent
            it.parentNode.replaceChild script, it
          root = div.querySelector('.ldcv')
    p
      .finally ~>
        @loader.cancel false
      .then (root) ~>
        @covers[n] = new ldCover root: root, lock: root.getAttribute(\data-lock) == \true
        @prepare-proxy.resolve!
        delete @workers[n]
        # TODO not sure what is this for. to be remove
        # new Promise (res, rej) -> setTimeout (-> res!), 1
      .catch ~>
        @prepare-proxy.reject it
        delete @workers[n]
        throw it
  purge: (n) -> if n? => delete @covers[n] else @covers = {}
  lock: (n, p) ->
    @prepare(n)
      .then ~> @covers[n].lock!
      .then ~> @covers[n].toggle true
      .catch ~> @error(n,it)
  toggle: (n, v, p) ->
    @prepare(n)
      .then ~> @covers[n].toggle v
      .then ~> @fire "#{if @covers[n].is-on! => \on else \off}", {node: @covers[n], param: p, name: n}
      .catch ~> @error(n,it)

  getcover: (n) -> @prepare n .then ~> @covers[n]
  getdom: (n) -> @prepare n .then ~> @covers[n].root
  is-on: (n) -> @covers[n] and @covers[n].is-on!
  set: (n, p) -> @prepare(n).then ~> @covers[n].set p
  get: (n, p) ->
    @prepare(n)
      .then ~> @fire "on", {node: @covers[n], param: p, name: n}
      .then ~> @covers[n].get!
      .catch ~> @error(n,it)
  init: ->
    ld$.find('.ldcvmgr').map (n) ~>
      # only keep the first, named ldcvmgr.
      if !(id = n.getAttribute(\data-name)) or @covers[id] => return
      @covers[id] = new ldCover({root: n, lock: n.getAttribute(\data-lock) == \true})
    ld$.find('[data-ldcv-toggle]').map (n) ~>
      if !(id = n.getAttribute(\data-ldcv-toggle)) => return
      n.addEventListener \click, ~> @toggle id

if module? => module.exports = ldcvmgr
if window? => window.ldcvmgr = ldcvmgr
