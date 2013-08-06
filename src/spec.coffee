test_data =
  csv_file_url : "https://raw.github.com/modilabs/bamboo.js/master/public/csv/sample_dataset_school_survey.csv"
  csv_file_merge_url: "https://raw.github.com/modilabs/bamboo.js/master/public/csv/sample_merge.csv"
  csv_file_join_url: "https://raw.github.com/modilabs/bamboo.js/master/public/csv/sample_join.csv"

# time to wait for bamboo to do its magic in ms
BAMBOO_WAIT_TIME = 8000

# wait time used to
wait_time = BAMBOO_WAIT_TIME

# max number of ready state retries allowed. If you increase this also
# consider increasing the BAMBOO_WAIT_TIME since the ready callback
# waits for BAMBOO_WAIT_TIME/MAX_READY_RETRIES before retrying. Thus
# increasing just this will result in shorter waits
MAX_READY_RETRIES = 4

# the current retry count - always reset to 0 before starting a data_ready_callback sequence
retry_count = 0

callAjax = (xhrSettings) ->
  # call the success function using the expected response as defined in the test_data.urls object
  method = if xhrSettings.type then xhrSettings.type else "GET"
  params = undefined
  if method is "GET"
    params = []
    _.each xhrSettings.data, (val, key)->
      params.push(key + "=" + val)
      return
    params = params.join("&")
  xhrSettings.url += "?" + params if params
  promise =
    then: (successCallback, errorCallBack)->
      if @response
        successCallback.call(null, @response)
      else if @error
        errorCallBack.call(@error)
      return
  try
    response = mock_data.urls[xhrSettings.url][method]
    if response == undefined
      throw new TypeError("urls.#{xhrSettings.url}.#{method} is not defined.")
    promise.response = response
  catch err
    promise.error = err
  return promise

# poll dataset's ready state MAX_READY_RETRIES times
data_ready_callback  = ()->
  if @state is "pending" and retry_count++ < MAX_READY_RETRIES
    # query info again, wait
    setTimeout =>
      promise = bamboo.query_info(@id)
      promise.then (data)=>
        @state = data.state
        data_ready_callback.call(@)
        return
    , Math.round(wait_time/MAX_READY_RETRIES)# distrubute calls by retries and wait time
  else
    # reset retry count
    retry_count = 0
  return

# poll dataset's aggregation state MAX_READY_RETRIES times
aggregations_ready_callback = (response)->
  if JSON.stringify(response) is "{}" and retry_count++ < MAX_READY_RETRIES
    # query aggregations
    setTimeout =>
      @query_aggregations data_ready_callback
    , Math.round(wait_time/MAX_READY_RETRIES)# distrubute calls by retries and wait time
  else
    # reset retry count
    retry_count = 0
  return

most_recent_ajax_call_arg = (arg_index, param)->
  return $.ajax.mostRecentCall.args[arg_index][param]

most_recent_ajax_call_arg_keys = (arg_index, param)->
  return _.keys(most_recent_ajax_call_arg(arg_index, param))

describe "Bamboo JS", ->
  beforeEach ->
    if bamboo.settings.URL.match(/^http/)
      spyOn($, 'ajax').andCallThrough()
    else
      spyOn($, 'ajax').andCallFake(callAjax)
      wait_time = 0
    return

  it "distinguishes aggregations from calculations", ->
    true_st = bamboo.is_aggregation "sum(formula)"
    expect(true_st).toBeTruthy()
    false_st = bamboo.is_aggregation "murica"
    expect(false_st).not.toBeTruthy()
    false_st_2 = bamboo.is_aggregation "sum())"
    expect(false_st_2).not.toBeTruthy()
    return

  describe "URLs", ->
    it "generates a /<section> url when section is the only param", ->
      expect(bamboo.bamboo_url('datasets')).toEqual(bamboo.settings.URL + "/datasets")
      return
    return

  describe "_run_query", ->
    it "runs asynchronously by default", ->
      #todo: revise to use a simpler call, perhaps a /info
      promise = bamboo.create_dataset(test_data.csv_file_url)
      async_arg = most_recent_ajax_call_arg(0, 'async')
      expect(async_arg).toBeTruthy()
      return

    it "run synchronously if requested", ->
      #todo: revise to use a simpler call, perhaps a /info
      promise = bamboo.create_dataset(test_data.csv_file_url, false)
      async_arg = most_recent_ajax_call_arg(0, 'async')
      expect(async_arg).toBeFalsy()
      return
    return

  describe "Create", ->
    it "can create dataset from a URL, query for its info and delete it", ->
      dataset_id = undefined
      dataset_info = undefined
      runs ->
        promise = bamboo.create_dataset(test_data.csv_file_url)
        promise.then (data)->
          dataset_id = data.id
        return

      waitsFor ()->
        return !!dataset_id
      , "dataset to be created", 2000

      runs ->
        promise = bamboo.query_info(dataset_id)
        promise.then (response)->
          dataset_info = response
        return

      waitsFor ()->
        return !!dataset_info
      , "the dataset's info", 2000

      runs ->
        expect(dataset_info.state).toBeDefined()
        expect(dataset_id).toBeDefined()
        promise = bamboo.delete_dataset(dataset_id)
        promise.then ()->
          dataset_id = undefined
        return

      waitsFor ()->
        return !dataset_id
      , "dataset to be deleted", 2000

      return
    return

  describe "Manage", ->
    dataset_id = undefined
    dataset_info = undefined

    beforeEach ->
      runs ->
        promise = bamboo.create_dataset(test_data.csv_file_url)
        promise.then (data)->
          dataset_id = data.id
        return

      waitsFor ()->
        return !!dataset_id
      , "dataset to be created", 2000

      # poll the dataset's ready state
      runs ->
        retry_count = 0
        expect(dataset_id).toBeDefined()
        dataset_info = {id: dataset_id, state: "pending"}
        data_ready_callback.call(dataset_info)
        return

      waitsFor ->
        return dataset_info isnt undefined and dataset_info.state isnt "pending"
      , "dataset to be ready", BAMBOO_WAIT_TIME

      return

    afterEach ->
      runs ->
        expect(dataset_id).toBeDefined()
        promise = bamboo.delete_dataset(dataset_id)
        promise.then (response)->
          dataset_id = undefined
        return

      waitsFor ()->
        return !dataset_id
      , "dataset to be deleted", 2000

      runs ->
        expect(dataset_id).toBeUndefined();

      return

    describe "Query", ->
      it "can query for all the data", ->
        data = undefined
        runs ->
          promise = bamboo.query(dataset_id)
          promise.then (response)->
            data = response
            return
          return

        waitsFor ->
          return !!data

        runs ->
          expect(data.length).toEqual(14)
          return

        return

      it "can query with a filter", ->
        data = undefined
        runs ->
          promise = bamboo.query(dataset_id, {grade: 4})
          promise.then (response)->
            data = response
            return
          return

        waitsFor ->
          return !!data

        runs ->
          expect(data.length).toEqual(7)
          return

        return

      it "can select specific fields", ->
        data = undefined
        runs ->
          promise = bamboo.query(dataset_id, null, {grade: 1})
          promise.then (response)->
            data = response
            return
          return

        waitsFor ->
          return !!data

        runs ->
          expect(data.length).toEqual(14)
          expect(data[0].grade).toBeDefined()
          expect(data[0].sex).toBeUndefined()
          return

        return

      it "can apply a limit", ->
        data = undefined
        runs ->
          promise = bamboo.query(dataset_id, null, null, 3)
          promise.then (response)->
            data = response
            return
          return

        waitsFor ->
          return !!data

        runs ->
          expect(data.length).toEqual(3)
          expect(data[0].grade).toBeDefined()
          expect(data[0].sex).toBeDefined()
          return

        return

      it "can select specific fields and apply a filter", ->
        data = undefined
        runs ->
          promise = bamboo.query(dataset_id, {grade: 4}, {grade: 1})
          promise.then (response)->
            data = response
            return
          return

        waitsFor ->
          return !!data

        runs ->
          expect(data.length).toEqual(7)
          expect(data[0].grade).toBeDefined()
          expect(data[0].sex).toBeUndefined()
          return

        return

      it "can select specific fields, apply a filter and apply a limit", ->
        data = undefined
        runs ->
          promise = bamboo.query(dataset_id, {grade: 4}, {grade: 1}, 3)
          promise.then (response)->
            data = response
            return
          return

        waitsFor ->
          return !!data

        runs ->
          expect(data.length).toEqual(3)
          expect(data[0].grade).toBeDefined()
          expect(data[0].sex).toBeUndefined()
          return

        return

      return

    describe "Summary", ->
      it "can query the datasets summary for all fields", ->
        summary = undefined
        runs ->
          promise = bamboo.summary(dataset_id)
          promise.then (response)->
            summary = response
            return
          return

        waitsFor ->
          return !!summary
        , "summary to load"

        runs ->
          expect(summary.name).toBeDefined()
          expect(summary.grade).toBeDefined()
          return

        return

      it "can query the datasets summary for specified fields", ->
        summary = undefined
        runs ->
          promise = bamboo.summary(dataset_id, {grade: 1})
          promise.then (response)->
            summary = response
            return
          return

        waitsFor ->
          return !!summary
        , "summary to load"

        runs ->
          expect(summary.grade).toBeDefined()
          expect(summary.name).toBeUndefined()
          return

        return

      it "can query the datasets summary with a grouping", ->
        summary = undefined
        runs ->
          promise = bamboo.summary(dataset_id, {grade: 1}, "sex")
          promise.then (response)->
            summary = response
            return
          return

        waitsFor ->
          return !!summary
        , "summary to load"

        runs ->
          expect(summary.sex.M.grade).toBeDefined()
          expect(summary.sex.F.grade).toBeDefined()
          return

        return

      return

    describe "Calculations", ->
      it "can create and remove a calculation", ->
        message = undefined
        runs ->
          promise = bamboo.add_calculation(dataset_id, "above_3rd_grade", "grade > 3")
          promise.then (response)->
            message = response
            return
          , ()->
            return
          return

        waitsFor ->
          return !!message
        , "Calculation to be added", 2000

        runs ->
          expect(message).toBeDefined()
          message = undefined
          promise = bamboo.remove_calculation(dataset_id, "above_3rd_grade")
          promise.then (response)->
            message = response
            return
          , ()->
            return

        waitsFor ->
          return !!message
        , "Calculation to be removed", 2000

        runs ->
          expect(message.success).toBeDefined()
          return

        return

      it "can query for calculations", ->
        calculations = undefined
        runs ->
          promise = bamboo.query_calculations(dataset_id)
          promise.then (response)->
            calculations = response
            return
          , ()->
            return
          return

        waitsFor ->
          return !!calculations
        , "Calculations to be retrieved", 2000

        runs ->
          expect(calculations).toBeDefined()
          return

        return

      return

    describe "Aggregations", ->
      it "can add and remove an aggregation without groups", ->
        message = undefined
        runs ->
          promise = bamboo.add_aggregation(dataset_id, "total_income", "sum(income)", null)
          promise.then (response)->
            message = response
            return
          , ()->
            return
          return

        waitsFor ->
          return !!message
        , "Aggregation to be added", 2000

        runs ->
          expect(message).toBeDefined()
          message = undefined
          promise = bamboo.remove_aggregation(dataset_id, "total_income")
          promise.then (response)->
            message = response
            return
          , ()->
            return

        waitsFor ->
          return !!message
        , "Aggregation to be removed", 2000

        runs ->
          expect(message.success).toBeDefined()
          return

        return

      it "can add and remove an aggregation with groups", ->
        message = undefined
        timedout = false
        runs ->
          promise = bamboo.add_aggregation(dataset_id, "total_income", "sum(income)", ['sex'])
          promise.then (response)->
            data = most_recent_ajax_call_arg(0, 'data')
            expect(data).toBeDefined()
            expect(data.group).toBeDefined()
            message = response
            return
          , ()->
            return
          return

        waitsFor ->
          return !!message
        , "Aggregation to be added", 2000

        # wait a bit before deleting
        waitsFor ->
          setTimeout ()->
            timedout = true
            return
          , 1000
          return timedout
        , "timeout", 1000


        runs ->
          expect(message).toBeDefined()
          message = undefined
          promise = bamboo.remove_aggregation(dataset_id, "total_income")
          promise.then (response)->
            message = response
            return
          , ()->
            return

        waitsFor ->
          return !!message
        , "Aggregation to be removed", 2000

        runs ->
          expect(message.success).toBeDefined()
          return

        return

      it "can query for aggregations", ->
        aggregations = undefined
        runs ->
          promise = bamboo.query_aggregations(dataset_id)
          promise.then (response)->
            aggregations = response
            return
          , ()->
            return
          return

        waitsFor ->
          return !!aggregations
        , "Aggregations to load", 2000

        runs ->
          expect(aggregations).toBeDefined()

        return

      return

    return

  return