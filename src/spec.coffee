test_data =
  csv_file : "https://www.dropbox.com/s/0m8smn04oti92gr/sample_dataset_school_survey.csv?dl=1"
  csv_file_merge: "https://www.dropbox.com/s/5aja0nlcufn65vd/sample_merge.csv?dl=1"
  csv_file_join: "https://www.dropbox.com/s/haamu5h09b85thp/sample_join.csv?dl=1"

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
  try
    response = mock_data.urls[xhrSettings.url][method]
    if response == undefined
      throw new TypeError("urls.#{xhrSettings.url}.#{method} is not defined.")
    xhrSettings.success.call(null, response)
  catch err
    xhrSettings.error.call()
  return

# poll dataset's ready state MAX_READY_RETRIES times
data_ready_callback = (response)->
  if response.state isnt "ready" and retry_count++ < MAX_READY_RETRIES
    # query info again, wait
    setTimeout =>
      @query_info data_ready_callback
    , Math.round(wait_time/MAX_READY_RETRIES)# distrubute calls by retries and wait time
  else
    # reset retry count
    retry_count = 0
  return

most_recent_ajax_call_arg = (arg_index, param)->
  return $.ajax.mostRecentCall.args[arg_index][param]

most_recent_ajax_call_arg_keys = (arg_index, param)->
  return _.keys(most_recent_ajax_call_arg(arg_index, param))

describe "Bamboo API", ->
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

  describe "Datasets", ->
    it "can create from url", ->
      dataset = new bamboo.Dataset({
        url: test_data.csv_file,
        autoload: true
      })
      expect(dataset.id).toBeDefined()
      expect(dataset.query_info().info.id).toBe(dataset.id)
      return

    it "can delete by dataset id", ->
      dataset = new bamboo.Dataset({
        url: test_data.csv_file,
        autoload: true
      })
      expect(dataset.id).toBeDefined()
      deleted = dataset.delete()
      expect(deleted).toBeTruthy()
      return

    it "can check if dataset exists", ->
      dataset = new bamboo.Dataset({
        url: test_data.csv_file,
        autoload: true
      })
      expect(dataset.id).toBeDefined()
      exists = bamboo.dataset_exists(dataset.id)
      expect(exists).toBeTruthy()

      exists = bamboo.dataset_exists("some-none-existsent-id")
      expect(exists).toBeFalsy()
      return

    return

  describe "Data APIs", ->
    loaded = false
    dataset = undefined

    beforeEach ->
      dataset = new bamboo.Dataset({
        url: test_data.csv_file,
        autoload: false
      })

      runs ->
        loaded = false
        dataset.load_from_url(false, ->
          loaded = true
        )
        return

      waitsFor ()->
        return loaded
      , "dataset to load", 1000

      runs ->
        expect(dataset.id).toBeDefined()

      return

    afterEach ->
      # delete dataset
      deleted = dataset.delete()
      expect(deleted).toBeTruthy()
      return

    describe "Query API", ->
      it "can query info", ->
        expect(dataset.query_info().info.id).toBe(dataset.id)
        expect(dataset.info.num_rows).toBe(14)
        return

      it "can query data", ->
        expect(dataset.data).not.toBeDefined()
        dataset.query_dataset()
        expect(dataset.data).toBeDefined()
        return

      it "can select from dataset", ->
        select = dataset.select({grade:1})
        expect(select.length).toBe(14)
        return

      it "can run a filter query", ->
        query1 = dataset.query({grade:4})
        expect(query1.length).toBe(7)
        return

      it "can get the summary", ->
        summary = dataset.summary()
        expect(dataset.summary_result).toBeDefined()

        # summary with a select
        select = {"grade": 1}
        summary = dataset.summary(select)
        expect(dataset._summaries["summary_#{JSON.stringify(select)}"]).toBeDefined()

        #summary with a select and group
        group = "sex"
        summary = dataset.summary(select, group)
        expect(dataset._summaries["summary_#{JSON.stringify(select)}_#{group}"]).toBeDefined()
        return

      return

    describe "Calculations API", ->
      it "can add and remove simple calculation", ->
        loaded = false
        calculation_name = "above_3rd_grade"
        waits wait_time

        runs ->
          dataset.add_calculation calculation_name, "grade > 3", () ->
            loaded = true
          return

        waitsFor ->
          return loaded
        , "calculation to be ready", 1000

        runs ->
          expect(dataset.calculations).toBeDefined()
          found_calculation = _.find dataset.calculations, (calculation) ->
            return calculation.name is calculation_name
          expect(found_calculation).toBeDefined()
          return

        # wait for calculation to be ready, does it need to be ready before we delete
        waits wait_time

        runs ->
          dataset.remove_calculation(calculation_name)
          found_calculation = _.find dataset.calculations, (calculation) ->
            return calculation.name is calculation_name
          expect(found_calculation).not.toBeDefined()
          return

        return

      it "can query calculations", ->
        loaded = false

        waits wait_time

        runs ->
          expect(dataset.calculations).not.toBeDefined()
          dataset.query_calculations ->
            loaded = true
            return
          return

        waitsFor ->
          return loaded
        , "calculation's query to return", 1000

        runs ->
          expect(dataset.calculations).toBeDefined()
          return

        return

      return

    describe "Aggreations API", ->
      beforeEach ->
        loaded = false
        response = undefined

        waits wait_time

        runs ->
          expect(dataset.aggregations).not.toBeDefined()
          dataset.add_aggregations "total_income", "sum(income)", null, (r)->
            response = r
            loaded = true
            return
          return

        waitsFor ->
          return loaded
        , "add_aggregations to return", 1000

        runs ->
          expect(response.success).toContain("created calculation")
          return

        return

      afterEach ->
        response = undefined
        runs ->
          dataset.remove_aggregations "total_income", (r)->
            response = r
            return
          expect(response.success).toContain("deleted calculation: 'total_income'")
          return
        return

      it "can query aggregations", ->
        loaded = false
        runs ->
          dataset.query_aggregations ->
            loaded = true
            return
          return

        waitsFor ->
          return loaded
        , "query_aggregations to return", 1000

        runs ->
          expect(dataset.aggregations).toBeDefined()
          return

        return

      return

    describe "Updates, joins and merges", ->
      it "can update data in an dataset", ->
        response = undefined
        update_data =
          name: "new_student"
          grade: 1
          income: 30
          sex: "M"

        runs ->
          dataset.update [update_data], (r)->
            response = r
            return
          return

        waitsFor ->
          return response isnt undefined
        , "update call to return", 1000

        runs ->
          #bamboo returns the dataset id after an update
          expect(response.id).toBeDefined()
          return

        return

      it "can merge datasets", ->
        loaded = false
        merged_dataset = undefined
        # create the second dataset
        dataset_for_merge = new bamboo.Dataset()
        runs ->
          dataset_for_merge.load_from_url test_data.csv_file_merge, ->
            loaded = true
            return

        waitsFor ->
          return loaded
        , "load_from_url to return", 2000

        runs ->
          retry_count = 0
          expect(dataset_for_merge.id).toBeDefined()
          data_ready_callback.call(dataset_for_merge, {state: "pending"})
          return

        waitsFor ->
          return dataset_for_merge.info and dataset_for_merge.info.state is "ready"
        , "dataset to be ready", BAMBOO_WAIT_TIME

        runs ->
          dataset.merge [dataset.id, dataset_for_merge.id], (result)->
            merged_dataset = result
          expect(most_recent_ajax_call_arg_keys(0, "data")).toContain("dataset_ids")
          return

        waitsFor ->
          return merged_dataset isnt undefined
        , "merge to return", 2000

        runs ->
          expect(merged_dataset.id).toBeDefined()
          expect(dataset_for_merge.delete()).toBeTruthy()
          expect(merged_dataset.delete()).toBeTruthy()
          return

        return

      it "can join two datasets on a certain column", ->
        loaded = false
        joined_dataset = undefined
        # create the second dataset
        dataset_for_join = new bamboo.Dataset()
        runs ->
          dataset_for_join.load_from_url test_data.csv_file_join, ->
            loaded = true
            return

        waitsFor ->
          return loaded
        , "load_from_url to return", 2000

        # poll the dataset's ready state
        runs ->
          # todo: remove the need to re-init this by reseting it after successful poll
          retry_count = 0
          data_ready_callback.call(dataset_for_join, {state: "pending"})
          return

        # wait for dataset to be ready
        waitsFor ->
          return dataset_for_join.info and dataset_for_join.info.state is "ready"
        , "dataset to be ready", BAMBOO_WAIT_TIME

        runs ->
          dataset.join dataset.id, dataset_for_join.id, "name", (result)->
            joined_dataset = result
          params = most_recent_ajax_call_arg(0, "data")
          expect(params.dataset_id).toEqual(dataset.id)
          expect(params.other_dataset_id).toEqual(dataset_for_join.id)
          expect(params.on).toEqual("name")
          return

        waitsFor ->
          return joined_dataset isnt undefined
        , "join to return", 2000

        runs ->
          expect(joined_dataset.id).toBeDefined()
          expect(dataset_for_join.delete()).toBeTruthy()
          expect(joined_dataset.delete()).toBeTruthy()
          return

        return

      return

    return

  return