settings =
  URL: "http://bamboo.io"
  DEBUG: true

dbg = ()-> settings.DEBUG
jsonify = (args...)-> JSON.stringify.apply @, args
ensure_jquery = -> throw new Error("jQuery is not available.") unless $?

bamboo_url = (section="datasets", id, operation, name)->
  pieces = [settings.URL, section]
  if id?
    pieces.push id
    if operation
      pieces.push operation
      if name
        pieces.push name
  pieces.join '/'

allowed_aggregation = ['max',
  'min',
  'mean',
  'median',
  'sum',
  'ratio',
  'count',
  'argmax',
  'newest']

_run_query = (url, async=true, opts={})->
  ensure_jquery()
  opts.url = url
  opts.async = async unless opts.async
  opts.dataType = 'json' unless opts.dataType
  opts.crossDomain = true unless opts.crossDomain
  promise = $.ajax(opts)
  return promise

_create_dataset = (urlOrFile, async)->
  opts =
    data: {url: urlOrFile}
    type: 'POST'
    dataType: 'json'
  return _run_query(bamboo_url('datasets'), async, opts)


_delete_dataset = (dataset_id, async)->
  opts =
    type: 'DELETE'
    dataType: 'json'
  return _run_query(bamboo_url('datasets', dataset_id), async, opts)

_query_info = (dataset_id, async)->
  opts = {}
  return _run_query(bamboo_url('datasets', dataset_id, 'info'), async, opts)

_query = (dataset_id, filter, select, limit, async)->
  opts = {data: {}}
  opts.data.query = JSON.stringify(filter) if filter
  opts.data.select = JSON.stringify(select) if select
  opts.data.limit = limit if limit
  return _run_query(bamboo_url('datasets', dataset_id), async, opts)

_summary = (dataset_id, select="all", group=null, async)->
  select = if typeof select is "string" then select else JSON.stringify(select)
  opts = {data: {}}
  opts.data.select = select
  opts.data.group = group if group
  return _run_query(bamboo_url('datasets', dataset_id, 'summary'), async, opts)

_add_calculation = (dataset_id, name, formula, async)->
  opts = {data: {}}
  opts.data.name = name
  opts.data.formula = formula
  opts.type = 'POST'
  return _run_query(bamboo_url('calculations', dataset_id), async, opts)

_remove_calculation = (dataset_id, name, async)->
  opts = {data: {}}
  opts.type = 'DELETE'
  return _run_query(bamboo_url('datasets', dataset_id, 'calculations', name), async, opts)

_query_calculations = (dataset_id, async)->
  return _run_query(bamboo_url('datasets', dataset_id, 'calculations'), async)

_add_aggregation = (dataset_id, name, formula, groups=null, async)->
  if is_aggregation(formula)
    opts = {data: {}}
    opts.data.name = name
    opts.data.formula = formula
    opts.type = 'POST'
    if groups isnt null
      if groups instanceof Array
        opts.data.group = groups.join()
      else
        throw new Error "group must be an array"
    return _run_query(bamboo_url('calculations', dataset_id), async, opts)
  else
    throw new Error "ill formated aggregation formula, perhaps you are
            looking for calculation instead of aggregation?"

_remove_aggregation = (dataset_id, name, async)->
  opts = {data: {}}
  opts.type = 'DELETE'
  return _run_query(bamboo_url('datasets', dataset_id, 'calculations', name), async, opts)

_query_aggregations = (dataset_id, async)->
  return _run_query(bamboo_url('datasets', dataset_id, 'aggregations'), async)

_update = (dataset_id, rows, async)->
  ###
  Updates this dataset with the rows given in {column: value} format.
  Any unspecified columns will result in n/a values.
  ###
  if not (rows instanceof Array)
    throw new Error "rows must be an array"
  if rows.length is 0
    throw new Error "rows cannot be empty"
  # massage rows
  jsonified_rows = JSON.stringify rows
  data =
    update: jsonified_rows
  opts =
    type: "PUT"
    data: data
  return _run_query bamboo_url('datasets', dataset_id), async, opts

_join = (left_dataset_id, right_dataset_id, on_column, async)->
  ###
  Create a new dataset that is the result of a join, where this
  left_dataset is the lefthand side and *right_dataset* is the
  righthand side and *on* is the column on which to join.
  The column that is joined on must be unique in the righthand side
  and must exist in both datasets.
  ###
  data =
    dataset_id: left_dataset_id
    other_dataset_id: right_dataset_id
    on: on_column
  opts =
    type: "POST"
    data: data
  return _run_query bamboo_url("datasets", "join"), async, opts

_merge = (datasets, async)->
  if not (datasets instanceof Array)
    throw new Error "datasets for merging must be an array"
  dataset_ids = JSON.stringify(datasets)
  data =
    dataset_ids: dataset_ids

  opts =
    type: "POST"
    data: data
  return _run_query bamboo_url('datasets','merge'), async, opts

class Dataset
  constructor: (data) ->
    @extend(data)
    @_ls = {}
    @_reqs = {}

    if @url? and !@id? and @autoload
      @load_from_url()

  extend: (obj, override=false) ->
    @[key] = val for key, val of obj when override or !@[key]?

  load_status: (for_what) ->
    @_ls[for_what] or LS.not_started

  load_from_url: (url=false, sync_cb=false) ->
    ensure_jquery()
    @url = url if url
    if !@url?
      throw new Error("Missing URL")
    @_ls.from_url = LS.started
    @_reqs.from_url = $.ajax
      async: !!sync_cb
      data: {url: @url}
      type: 'POST'
      dataType: 'json'
      url: bamboo_url('datasets')
      error: () =>
        @_ls.from_url = LS.failed
        return
      success: (response) =>
        @_ls.from_url = LS.complete
        @extend response
        log "dataset.load_from_url() response", jsonify response if dbg()
        sync_cb.apply(@, arguments) if !!sync_cb
        return
    @

  bamboo_url: () ->
    if !@id?
      throw new Error("Missing dataset ID. " +
                        "Run 'dataset.load_from_url()'.")
    bamboo_url("datasets", @id)

  _run_query: (for_what, url, async, cb, opts={}) ->
    ensure_jquery()
    @_ls[for_what] = LS.started
    opts.async = async unless opts.async?
    opts.url = url
    opts.dataType = 'json' unless opts.dataType?
    opts.success = (response, status, _req) =>
      log "successfully ran #{for_what} query", @ if dbg()
      @_ls[for_what] = LS.complete
      cb.apply(@, [response, status, _req])
    opts.error = (e) =>
      log "failed to ran #{for_what} query", @ if dbg()
      @_ls[for_what] = LS.failed
    @_reqs[for_what] = $.ajax opts
    @

  query_info: (sync_cb=false) ->
    url = "#{@bamboo_url()}/info"
    @_run_query "info", url, !!sync_cb, (response, status, _req)->
      @info = response
      sync_cb.apply @, [response, status, _req] if !!sync_cb
      
  summary: (summary_select="all", group=null, sync_cb=false)->
    summary_select_str = if typeof summary_select is "string" then summary_select else JSON.stringify(summary_select)
    url = "#{@bamboo_url()}/summary?select=#{summary_select_str}"
    url += "&group=#{group}" if group?
    async = !!sync_cb
    summary_tmp_id = "summary_#{summary_select_str}"
    summary_tmp_id += "_#{group}" if group?
    @_summaries = {} unless @_summaries?
    @_run_query summary_tmp_id, url, async, (r, status, _req)->
      @summary_result = r if summary_select is "all"
      @_summaries[summary_tmp_id] = r
      sync_cb.apply @, [r, status, _req] if sync_cb
    if async then @ else @_summaries[summary_tmp_id]

  select: (obj, sync_cb=false) ->
    select_str = jsonify(obj)
    async = !!sync_cb
    url = "#{@bamboo_url()}?select=#{select_str}"
    select_tmp_id = "select_#{select_str}"
    @_selects = {} unless @_selects?
    @_run_query select_tmp_id, url, async, (r, status, _req)->
      @_selects[select_tmp_id] = r
      sync_cb.apply @, [r, status, _req] if sync_cb
    if async then @ else @_selects[select_tmp_id]

  query: (obj, sync_cb=false) ->
    query_str = jsonify(obj)
    async = !!sync_cb
    url = "#{@bamboo_url()}?query=#{query_str}"
    query_tmp_id = "query_#{query_str}"
    @_queries = {} unless @_queries?
    @_run_query query_tmp_id, url, async, (r, status, _req)->
      @_queries[query_tmp_id] = r
      sync_cb.apply @, [r, status, _req] if sync_cb
    if async then @ else @_queries[query_tmp_id]

  query_dataset: (sync_cb=false) ->
    @_run_query "dataset", bamboo_url("datasets", @id), !!sync_cb, (r, status, _req)->
      @data = r
      sync_cb.apply @, arguments if !!sync_cb

  add_calculation: (name, formula, sync_cb=false) ->
    if is_aggregation formula
      throw new Error "Error: this formula indicates it's aggregation
        instead of calculation, please use Dataset.add_aggregation instead"

    calc_id   = _uniqueId("calculation")
    url       = bamboo_url("calculations", @id)
    data =
      name: name
      formula: formula
    @calculations = [] unless @calculations?
    success_cb = (response) ->
      calculation = {
        name: name,
        formula: formula
      }
      @calculations.push(calculation)
      sync_cb.apply @, arguments if sync_cb
      log response.success if dbg()
    opts =
      type: 'POST'
      data: data
    @_run_query "calculation_#{calc_id}", url, false, success_cb, opts

  query_calculations: (sync_cb=false) ->
    @_run_query "calculations", bamboo_url("datasets", @id, "calculations"), false, (r)->
      @calculations = r
      sync_cb.apply @, arguments if !!sync_cb

#  remove_calculation: (name) ->
#    url = bamboo_url("calculations", @id)
#    data =
#      name: name
#    success_cb = (response)-> log response.success if dbg()
#    opts =
#      type: 'DELETE'
#      data: data
#    @_run_query "delete calculation under name #{name} in dataset #{@id}",
#      url, false, success_cb, opts

  remove_calculation: (name) ->
    url = bamboo_url("datasets", @id, "calculations", name)
    success_cb = (response) ->
      # find the named calculation and remove it from our list
      calculation = _.find @calculations, (calculation) ->
        return calculation.name is name
      @calculations.pop(calculation) if calculation
      log response.success if dbg()
    opts =
      type: 'DELETE'
    @_run_query "delete calculation under name #{name} in dataset #{@id}",
      url, false, success_cb, opts

  add_aggregations:(name, formula, groups=null, sync_cb=false)->
    if is_aggregation(formula)
      agg_id = _uniqueId "aggregation"
      url = bamboo_url("calculations", @id)
      data =
        name: name
        formula: formula
      if groups isnt null
        if groups instanceof Array
          data['group'] = groups.join()
        else
          throw new Error "group must be an array"

      success_cb = (response)->
        sync_cb.apply(@, arguments) if sync_cb
        log response.success if dbg()
      opts =
        type: 'POST'
        data: data
      @_run_query "aggregation_#{agg_id}", url, false, success_cb, opts

    else
      throw new Error "ill formated aggregation formula, perhaps you are
        looking for calculation instead of aggregation?"

  query_aggregations: (sync_cb=false) ->
    @_run_query "aggregations", bamboo_url("datasets", @id, "aggregations"), !!sync_cb, (r)->
      @aggregations = r
      sync_cb.apply @, arguments if !!sync_cb

  remove_aggregations: (name, sync_cb=false) ->
    url = bamboo_url("datasets", @id, "calculations", name)
    success_cb = (response) ->
      sync_cb.apply(@, arguments) if !!sync_cb
      log response.success if dbg()
    opts =
      type: 'DELETE'
    @_run_query "delete aggregation under name #{name} in dataset #{@id}",
    url, false, success_cb, opts

  join: (left, right, on_column, cb)->
    ###
    Create a new dataset that is the result of a join, where this
    left_dataset is the lefthand side and *right_dataset* is the
    righthand side and *on* is the column on which to join.
    The column that is joined on must be unique in the righthand side
    and must exist in both datasets.
    ###
    url = bamboo_url("datasets","join")
    data =
      dataset_id: left
      other_dataset_id: right
      on: on_column
    success_cb = (response)->
      joined = new bamboo.Dataset(id:response.id)
      cb.call null, joined
      log response.success if dbg()
    opts =
      type: "POST"
      data: data
    @_run_query "joined datasets #{left} and #{right}", url, false, success_cb, opts
      

  merge:(datasets,cb)->
    ###
    Create a new dataset that is a row-wise merge of those in *datasets*.
    Returns the new merged dataset.
    ###
    if not (datasets instanceof Array)
      throw new Error "datasets for merging must be an array"
    url = bamboo_url('datasets','merge')
    dataset_ids = JSON.stringify(datasets)
    data =
      dataset_ids: dataset_ids
    success_cb = (response)->
      merged = new bamboo.Dataset(id:response.id)
      console.log "merged id is #{merged.id}"
      cb(merged)

    opts =
      type: "POST"
      data: data
    @_run_query "merging datasets #{datasets}", url, false, success_cb, opts

  update: (rows, sync_cb=false)->
    ###
    Updates this dataset with the rows given in {column: value} format.
    Any unspecified columns will result in n/a values.
    ###
    if not (rows instanceof Array)
      throw new Error "rows must be an array"
    if rows.length is 0
      throw new Error "rows cannot be empty"
    url = bamboo_url('datasets', @id)
    # massage rows
    jsonified_rows = JSON.stringify rows
    data =
      update: jsonified_rows
    success_cb = (response)->
      sync_cb.apply @, arguments if sync_cb
      log response.success if dbg()
    opts =
      type: "PUT"
      data: data
    @_run_query "updating dataset #{@id}", url, !!sync_cb, success_cb, opts

  delete: ()->
    complete = false
    $.ajax
      type: "DELETE"
      url: @bamboo_url()
      async: false
      success: -> complete = true
      error: -> complete = false
    complete

dataset_exists = (id)->
  ###
  Not perfect, but this could be a nice way to determine if a dataset exists.
  It returns a boolean value.
  ###
  existence = undefined
  ds = new Dataset({id:id})
  success_cb  = (a,b,c,d,e) ->
    existence = true
    return
  fail_cb     = ->
    existence = false
    return
  opts = {
    error: fail_cb
  }
  ds._run_query "existence", "#{ds.bamboo_url()}", false, success_cb, opts
  existence

is_aggregation = (formula)->
  keyword_sel = allowed_aggregation.join "|"
  regex_str = "^(#{keyword_sel})\\([^\\)]+\\)$"
  regex = new RegExp(regex_str)
  if formula.match(regex) isnt null
    return true
  return false


# load statuses object has key == value. It's an easy-to-reference dictionary
# used only within this file.
LS =
  not_started:    "not_started"
  queued:         "queued"
  started:        "started"
  complete:       "complete"
  failed:         "failed"

@bamboo =
  bamboo_url: bamboo_url
  dataset_exists: dataset_exists
  settings: settings
  is_aggregation: is_aggregation
  create_dataset: _create_dataset
  delete_dataset: _delete_dataset
  query_info: _query_info
  summary: _summary
  query: _query
  add_calculation: _add_calculation
  remove_calculation: _remove_calculation
  query_calculations: _query_calculations
  add_aggregation: _add_aggregation
  remove_aggregation: _remove_aggregation
  query_aggregations: _query_aggregations
  join: _join
  merge: _merge
  update: _update

noop = ->
_uniqueIdCount = 0
_uniqueId = (str)->
  "#{str}_#{_uniqueIdCount++}"

###
This is a shortcut for "console.log" that prevents
the call from breaking in browsers where console is
not defined.
###

@log = (args...)->
  console.log.apply console, args if console? and console.log?
