ldcvmgr = (opt={}) ->
  @opt = opt
  @evt-handler = {}
  @path = opt.path or "/modules/cover"
  if typeof(@path) == \string => @path = @path.replace(/\/$/,'')
  @loader = if opt.loader => that else new ldloader className: "ldld full", auto-z: true
  @mgr = opt.manager or null
  # keeping all block instances here so we can do i18n transform if needed.
  @blocks = {}
  @covers = {}
  @workers = {}
  @error-cover = opt.error-cover or \error
  @error-handling = false
  @prepare-proxy = proxise (n) ->
  if opt.zmgr => @zmgr opt.zmgr
  /*
  originally we use `modal` for base-z if zmgr is provided.
  this scope the zmgr into `modal`, which may have issues if we want to
  manage z-index along with loaders or other elements.
  additionally, user will have to remember to config their manually
  created ldcover with `modal` `base-z`, otherwise the z-index won't
  align.

  this really causes some issue so instead of hard code a default `modal`,
  we use 3000 as default value for user to overwrite.

  there may stlil be issues if we change ldcover's default base-z,
  which is unlikely to happen anyway.
  */
  @base-z = opt.base-z or 3000
  if opt.auto-init => @init!
  if block.i18n.module =>
    # while we have autoTransform option in block, we actually don't attach all block instance
    # so we still transform by ourselves here.
    <~ block.i18n.module.on \languageChanged, _
    for k,v of @blocks => v.transform \i18n

  @

ldcvmgr.prototype = Object.create(Object.prototype) <<< do
  on: (n, cb) -> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
  zmgr: -> if it? => @_zmgr = it else @_zmgr
  error: (n = '', e = {}, p = {}) ->
    # sometimes we use error like 999 (cancel) to skip,
    # however all errors from cover managed by ldcvmgr go here.
    # TODO we probably will want to make it configurable to skip certain errors.
    console.error e
    if n == \error or n == @error-cover or n == @_id(@error-cover) =>
      alert "something is wrong; please reload and try again"
      # we are here because error handler can't properly handler errors.
      # so we return a never-resolved Promise to stop any possible further exceptions
      return new Promise (res, rej) ->
    else
      # identifying we are handling internal error.
      @error-handling = true
      # hint user about ldcvmgr internal error
      @toggle (@error-cover or \error), true, {err: e, param: p}
      # let caller handler this error
      throw e
  _id: (o) -> if typeof(o) == \object => @mgr.id(o) else o
  prepare: (o) ->
    n = @_id o
    if @covers[n] => return Promise.resolve!
    if @workers[n] => return @prepare-proxy(n)
    # @error-handling means that we are toggling `error` due to internal error,
    # so loader might already be triggered ( and just dismissed ).
    # dont wait to make it looks better without blinking effect.
    if @error-handling =>
      @loader.on!
      @error-handling = false
    else @loader.on 1000
    p = if typeof(o) == \object =>
      @workers[n] = @mgr.get o
        .then (bc) -> bc.create!
        .then (bi) ~>
          bi.attach {
            root: document.body
            # we will do i18n ourselves until we make sure it's okay to delegate to block
            # this may need some update in below bc.create related code.
            auto-transform: null
            data: {zmgr: @_zmgr, base-z: @base-z}
          } .then ~>
            @blocks[n] = bi
            @covers[n] = ret = bi.interface!
            bi.dom!
    else if document.querySelector(".ldcvmgr[data-name='#n']") => Promise.resolve(that)
    else
      name = if typeof(@path) == \function => @path(n) else "#{@path}/#n.html"
      @workers[n] = fetch name
        .then (v) ~>
          if v and v.ok => return v.text!
          return Promise.reject(new Error("[ldcvmgr] cover '#{if !n => '<no-name>' else n}' load failed."))
        .then (code) ~>
          bc = new block.class {manager: @mgr, code}
          bc.create {root: document.body}
            .then (bi) ~>
              @blocks[n] = bi
              if itf = bi.interface! => @covers[n] = itf
              bi.dom!
    p
      .finally ~>
        @loader.cancel false
      .then (root) ~>
        if !@covers[n] =>
          @covers[n] = new ldcover({
            root: root
            lock: root.getAttribute(\data-lock) == \true
            zmgr: @_zmgr
            base-z: @base-z
          })
        @prepare-proxy.resolve!
        delete @workers[n]
        # TODO not sure what is this for. to be remove
        # new Promise (res, rej) -> setTimeout (-> res!), 1
      .catch ~>
        @prepare-proxy.reject it
        delete @workers[n]
        throw it
  purge: (o) ->
    n = @_id o
    if n? => delete @covers[n] else @covers = {}
  lock: (o, p) ->
    n = @_id o
    @prepare(o)
      .then ~> @covers[n].lock!
      .then ~>
        @fire "on", {node: @covers[n], param: p, name: n}
        @covers[n].get p
      .catch (e) ~> @error(n,e,p)
  toggle: (o, v, p) ->
    n = @_id o
    @prepare(o)
      .then ~> @covers[n].toggle v, p
      .then ~> @fire "#{if @covers[n].is-on! => \on else \off}", {node: @covers[n], param: p, name: n}
      .catch (e)~> @error(n,e,p)

  getcover: (o) ->
    n = @_id o
    @prepare o .then ~> @covers[n]
  getdom: (o) ->
    n = @_id o
    @prepare o .then ~> @covers[n].root!
  is-on: (o) ->
    n = @_id o
    @covers[n] and @covers[n].is-on!
  set: (o, p) ->
    n = @_id o
    @prepare(o).then ~> @covers[n].set p
  get: (o, p) ->
    n = @_id o
    @prepare(o)
      .then ~>
        @fire "on", {node: @covers[n], param: p, name: n}
        @covers[n].get p
      .catch (e) ~> @error(n,e,p)
  init: (root) ->
    ld$.find(root or document.body, '.ldcvmgr').map (n) ~>
      # only keep the first, named ldcvmgr.
      if !(id = n.getAttribute(\data-name)) or @covers[id] => return
      @covers[id] = new ldcover({
        root: n
        lock: n.getAttribute(\data-lock) == \true
        zmgr: @_zmgr
        base-z: @base-z
      })
    document.body.addEventListener \click, (evt) ~>
      if !(n = ld$.parent evt.target, "[data-ldcvmgr-toggle]") => return
      if !(id = n.getAttribute \data-ldcvmgr-toggle) => return
      @toggle(if /:/.exec(id) => @mgr.id2obj(id) else id)

if module? => module.exports = ldcvmgr
else if window? => window.ldcvmgr = ldcvmgr
