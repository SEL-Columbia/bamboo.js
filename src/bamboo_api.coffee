settings =
  URL: "http://bamboo.io"
  DEBUG: true

dbg = ()-> settings.DEBUG
jsonify = (args...)-> JSON.stringify.apply @, args
ensure_jquery = -> throw new Error("jQuery is not available.") unless $?

bamboo_url = (section = "datasets", id, operation, name)->
  pieces = [settings.URL, section]
  if id?
    pieces.push id
    if operation?
      pieces.push operation
      if name?
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

_run_query = (url, async = true, opts = {})->
  ensure_jquery()
  opts.url = url
  opts.async = async unless opts.async
  opts.dataType = 'json' unless opts.dataType
  opts.crossDomain = true unless opts.crossDomain
  promise = $.ajax(opts)
  return promise

_create_dataset = (urlOrFile, async)->
  opts =
    data:
      {url: urlOrFile}
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

_dataset_exists = (dataset_id, async=true)->
  deferred = $.Deferred()
  exists = false
  ###
  Queries a dataset's info to check its existence
  ###
  bamboo.query_info(dataset_id, async).then (response)=>
    exists = true
    deferred.resolve(true)
    return
  , ()=>
    deferred.resolve(false)
  if async then deferred.promise() else exists

_query = (dataset_id, filter, select, limit, async)->
  opts = {data:
    {}}
  opts.data.query = JSON.stringify(filter) if filter
  opts.data.select = JSON.stringify(select) if select
  opts.data.limit = limit if limit
  return _run_query(bamboo_url('datasets', dataset_id), async, opts)

_summary = (dataset_id, select = "all", group = null, async)->
  select = if typeof select is "string" then select else JSON.stringify(select)
  opts = {data:
    {}}
  opts.data.select = select
  opts.data.group = group if group
  return _run_query(bamboo_url('datasets', dataset_id, 'summary'), async, opts)

_add_calculation = (dataset_id, name, formula, async)->
  if is_aggregation formula
    throw new Error "Error: this formula indicates it's aggregation
                  instead of calculation, please use Dataset.add_aggregation instead"
  opts = {data:
    {}}
  opts.data.name = name
  opts.data.formula = formula
  opts.type = 'POST'
  return _run_query(bamboo_url('calculations', dataset_id), async, opts)

_remove_calculation = (dataset_id, name, async)->
  opts = {data:
    {}}
  opts.type = 'DELETE'
  return _run_query(bamboo_url('datasets', dataset_id, 'calculations', name), async, opts)

_query_calculations = (dataset_id, async)->
  return _run_query(bamboo_url('datasets', dataset_id, 'calculations'), async)

_add_aggregation = (dataset_id, name, formula, groups = null, async)->
  if is_aggregation(formula)
    opts = {data:
      {}}
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
  opts = {data:
    {}}
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
  return _run_query bamboo_url('datasets', 'merge'), async, opts

_reset = (dataset_id, urlToData, async)->
  data =
    url: urlToData
  opts =
    type: "PUT"
    data: data
  return _run_query bamboo_url('datasets', dataset_id, 'reset'), async, opts

_get_row = (dataset_id, row_index, async)->
  opts = {}
  return _run_query bamboo_url('datasets', dataset_id, 'row', row_index), async, opts

_delete_row = (dataset_id, row_index, async)->
  opts =
    type: "DELETE"
  return _run_query bamboo_url('datasets', dataset_id, 'row', row_index), async, opts

_update_row = (dataset_id, row_index, update_data, async)->
  string_data = JSON.stringify(update_data) if typeof update_data isnt "string"
  data =
    data: string_data
  opts =
    type: "PUT",
    data: data
  return _run_query bamboo_url('datasets', dataset_id, 'row', row_index), async, opts

class Dataset
  constructor: (data) ->
    @extend(data)
    @_ls = {}
    @_reqs = {}

    if @url? and !@id? and @autoload
      @load_from_url()

  extend: (obj, override = false) ->
    @[key] = val for key, val of obj when override or !@[key]?

  load_status: (for_what) ->
    @_ls[for_what] or LS.not_started

  on_success: (for_what, response, sync_cb=false)->
    log "successfully ran #{for_what} query", @ if dbg()
    @_ls[for_what] = LS.complete
    sync_cb.apply @, [response] if !!sync_cb
    return

  on_failure: (for_what, error, sync_cb=false)->
    # todo: remove sync_cb arg from here and callers
    log "failed to ran #{for_what} query", @ if dbg()
    @_ls[for_what] = LS.failed
    return

  load_from_url: (url = null, sync_cb = false) ->
    ensure_jquery()
    @url = url if url
    if !@url?
      throw new Error("Missing URL")
    @_ls.from_url = LS.started

    bamboo.create_dataset(@url, !!sync_cb).then (response)=>
        @_ls.from_url = LS.complete
        @extend response
        @on_success("from_url", response, sync_cb)
        return
    , ()=>
        @on_failure("from_url", e, sync_cb)
        return
    return @

  query_info: (sync_cb = false) ->
    # using bamboo.query_info because of the way we test with spies
    async = !!sync_cb
    bamboo.query_info(@id, !!sync_cb).then (response)=>
      @info = response
      @on_success("info", response, sync_cb)
      return
    , (e)->
      @on_failure("info", e, sync_cb)
      return
    if async then @ else @info

  summary: (summary_select = "all", group = null, sync_cb = false)->
    summary_select_str = if typeof summary_select is "string" then summary_select else JSON.stringify(summary_select)
    summary_tmp_id = "summary_#{summary_select_str}"
    summary_tmp_id += "_#{group}" if group?
    @_summaries = {} unless @_summaries?
    bamboo.summary(@id, summary_select, group, !!sync_cb).then (response)=>
      @summary_result = response if summary_select is "all"
      @_summaries[summary_tmp_id] = response
      @on_success(summary_tmp_id, response, sync_cb)
      return
    , (e)=>
      @on_failure(summary_tmp_id, e, sync_cb)
      return
    if !!sync_cb then @ else @_summaries[summary_tmp_id]

  select: (obj, sync_cb = false) ->
    select_str = jsonify(obj)
    async = !!sync_cb
    select_tmp_id = "select_#{select_str}"
    @_selects = {} unless @_selects?
    bamboo.query(@id, undefined, obj, undefined, async).then (response)=>
      @_selects[select_tmp_id] = response
      @on_success(select_tmp_id, response, sync_cb)
      return
    , (e)=>
      @on_failure(select_tmp_id, e, sync_cb)
      return
    if async then @ else @_selects[select_tmp_id]

  query: (obj, sync_cb = false) ->
    query_str = jsonify(obj)
    async = !!sync_cb
    query_tmp_id = "query_#{query_str}"
    @_queries = {} unless @_queries?
    bamboo.query(@id, obj, undefined, undefined, async).then (response)=>
      @_queries[query_tmp_id] = response
      @on_success(query_tmp_id, response, sync_cb)
      return
    , (e)=>
      @on_failure(query_tmp_id, e, sync_cb)
      return
    if async then @ else @_queries[query_tmp_id]

  query_dataset: (sync_cb = false) ->
    async = !!sync_cb
    bamboo.query(@id, undefined, undefined, undefined, async).then (response)=>
      @data = response
      @on_success("dataset", response, sync_cb)
      return
    , (e)=>
      @on_failure("dataset", e, sync_cb)
      return
    if async then @ else @data

  add_calculation: (name, formula, sync_cb = false) ->
    @_calculations = [] unless @_calculations?
    async = !!sync_cb
    for_what = "calculation_#{name}"
    bamboo.add_calculation(@id, name, formula, async).then (response)=>
      @_calculations.push(name)
      @on_success(for_what, response, sync_cb)
      return
    , (e)=>
      @on_failure(for_what, e, sync_cb)
      return
    if async then @ else name

  query_calculations: (sync_cb = false) ->
    async = !!sync_cb
    for_what = "calculations"
    bamboo.query_calculations(@id, async).then (response)=>
      @_calculations = response
      @on_success(for_what, response, sync_cb)
      return
    , (e)=>
      @on_failure(for_what, e, sync_cb)
      return
    if async then @ else @_calculations

  remove_calculation: (name, sync_cb = false) ->
    async = !!sync_cb
    for_what = "delete calculation with name #{name} in dataset #{@id}"
    @_calculations = [] unless @_calculations?
    bamboo.remove_calculation(@id, name, async).then (response)=>
      calculation = _.find @_calculations, (calc) ->
        return calc.name is name
      @calculations.pop(calculation) if calculation
      @on_success(for_what, response, sync_cb)
      return
    , (e)=>
      @on_failure(for_what, e, sync_cb)
      return
    if async then @ else @_calculations

  add_aggregations: (name, formula, groups = null, sync_cb = false)->
    async = !!sync_cb
    for_what = "aggregation_#{name}"
    bamboo.add_aggregation(@id, name, formula, groups, async).then (response)=>
      @on_success(for_what, response, sync_cb)
      return
    , (e)=>
      @on_failure(for_what, e, sync_cb)
      return
    if async then @ else name

  query_aggregations: (sync_cb = false) ->
    async = !!sync_cb
    for_what = "aggregations"
    @aggregations = {} unless @aggregations?
    bamboo.query_aggregations(@id, async).then (response)=>
      @aggregations = response
      @on_success(for_what, response, sync_cb)
      return
    , (e)=>
      @on_failure(for_what, e, sync_cb)
      return
    if async then @ else @aggregations

  remove_aggregations: (name, sync_cb = false) ->
    async = !!sync_cb
    for_what = "delete aggregation under name #{name} in dataset #{@id}"
    @aggregations = {} unless @aggregations?
    bamboo.remove_aggregation(@id, name, async).then (response)=>
      delete @aggregations[name] if @aggregations[name]
      @on_success(for_what, response, sync_cb)
      return
    , (e)=>
      @on_failure(for_what, e, sync_cb)
      return
    if async then @ else @aggregations

  join: (right, on_column, sync_cb=false)->
    ###
    Create a new dataset that is the result of a join, where this
    left_dataset is the lefthand side and *right_dataset* is the
    righthand side and *on* is the column on which to join.
    The column that is joined on must be unique in the righthand side
    and must exist in both datasets.
    ###
    async = !!sync_cb
    for_what = "joined datasets #{@id} and #{right}"
    @joins = [] unless @joins?
    bamboo.join(@id, right, on_column, async).then (response)=>
      @joins.push response.id
      @on_success(for_what, response, sync_cb)
      return
    , (e)=>
      @on_failure(for_what, e, sync_cb)
      return
    if async then @ else @joins

  merge: (datasets, sync_cb=false)->
    ###
    Create a new dataset that is a row-wise merge of those in *datasets*.
    Returns the new merged dataset.
    ###
    async = !!sync_cb
    for_what = "merging datasets #{datasets}"
    bamboo.merge(datasets, async).then (response)=>
      @on_success(for_what, response, sync_cb)
      return
    , (e)=>
      @on_failure(for_what, e, sync_cb)
      return
    return @

  update: (rows, sync_cb = false)->
    ###
    Updates this dataset with the rows given in {column: value} format.
    Any unspecified columns will result in n/a values.
    ###
    async = !!sync_cb
    for_what = "updating dataset #{@id}"
    bamboo.update(@id, rows, async).then (response)=>
      @on_success(for_what, response, sync_cb)
      return
    , (e)=>
      @on_failure(for_what, e, sync_cb)
      return
    return @

  delete: (sync_cb=false)->
    async = !!sync_cb
    for_what = "deleting dataset #{@id}"
    deleted = false
    bamboo.delete_dataset(@id, async).then (response)=>
      deleted = true
      @on_success(for_what, response, sync_cb)
      return
    , (e)=>
      @on_failure(for_what, e, sync_cb)
      return
    if async then @ else deleted

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
  not_started: "not_started"
  queued: "queued"
  started: "started"
  complete: "complete"
  failed: "failed"

@bamboo =
  bamboo_url: bamboo_url
  settings: settings
  Dataset: Dataset
  is_aggregation: is_aggregation
  create_dataset: _create_dataset
  delete_dataset: _delete_dataset
  query_info: _query_info
  dataset_exists: _dataset_exists
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
  reset: _reset
  get_row: _get_row
  delete_row: _delete_row
  update_row: _update_row

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
