test_data =
  csv_file : "https://www.dropbox.com/s/0m8smn04oti92gr/sample_dataset_school_survey.csv?dl=1"

available_opts =
  url: test_data.csv_file
  autoload: true

build_dataset = (keys)=>
  new bamboo.Dataset _pick(available_opts, keys)

bamboo.settings.URL = "http://localhost:8080"

describe "Bamboo API", ->
  dataset = null

  beforeEach ->
    done  = false
    runs ->
      if dataset?
        done  = true
      else
        dataset = build_dataset(['url'])
        dataset.load_from_url false, ->
          done = true

    waitsFor(->
      return done
    , 1000)

    runs ->
      expect(dataset.id).toBeDefined()

  afterEach ->
    #complete = dataset.delete()
    #expect(complete).toBeTruthy()

  it "wount autoload if not requested", ->
    temp_dataset = build_dataset(['url'])
    expect(temp_dataset.load_status('from_url')).toBe("not_started")

  describe "Dataset API", ->
    it "can query info synchronously", ->
        temp_dataset = build_dataset(['url', 'autoload'])
        temp_dataset.query_info()
        expect(temp_dataset.info.id).toBe(temp_dataset.id)

    it "can query info async", ->
      done  = false
      info = null
      runs ->
        dataset.query_info (data) ->
          info = data
          done = true

      waitsFor(->
        return done
      , 1000)

      runs ->
        expect(info.id).toBe(dataset.id)

    it "can select from dataset", ->
      done  = false
      select = {grade:1}

      # wait for the dataset to be ready before selecting
      #waits 3000

      runs ->
        dataset.select select, (data)->
          done = true

      waitsFor(->
        return done
      , 1000)

      runs ->
        select_key = "select_" + JSON.stringify(select)
        expect(dataset._selects[select_key]).toBeDefined()
        #expect(dataset._selects[select_key].length).toBe(14)

    it "can query from dataset", ->
      done  = false
      query = {grade: 4}

      # wait for the dataset to be ready before selecting
      #waits 3000

      runs ->
        dataset.query query, (data)->
          done = true

      waitsFor(->
        return done
      , 1000)

      runs ->
        query_key = "query_" + JSON.stringify(query)
        expect(dataset._queries[query_key]).toBeDefined()
        #expect(dataset._queries[query_key].length).toBe(7)

  describe "Summaries", ->
    it "can get the summary for all", ->
      done = false
      select = "all"

      # wait for the dataset to be ready before selecting
      waits 10000

      runs ->
        dataset.summary "all", null, (data)->
          done = true

      waitsFor(->
        return done
      , 1000)

      runs ->
        summary_key = "summary_" + select
        expect(dataset._summaries[summary_key]).toBeDefined()

    it "can get the summary with select and group", ->
      done = false
      select = {"income":1}
      group = "sex"
      # wait for the dataset to be ready before selecting
      waits 5000

      runs ->
        dataset.summary select, group, (data)->
          done = true

      waitsFor(->
        return done
      , 1000)

      runs ->
        summary_key = "summary_" + JSON.stringify(select)
        expect(dataset._summaries[summary_key]).toBeDefined()
        expect(dataset._summaries[summary_key][group]).toBeDefined()

  describe "Calculations", ->
    it "can add and query calculations", ->
      # wait for the dataset to be ready for adding calculations
      waits 8000
      runs ->
        dataset.add_calculation("above_3rd_grade", "grade > 3")

      # wait for calculation to be ready
      waits 3000

      runs ->
        dataset.query_calculations()
        expect(dataset.calculations).toBeDefined()
        expect(dataset.calculations[0]).toBeDefined()
        expect(dataset.calculations[0].name).toEqual("above_3rd_grade")

    it "can add and query aggregations", ->
      waits 8000
      runs ->
        dataset.add_calculation("total_income", "sum(income)")

      waits 3000
      runs ->
        # at the moment, this only works because an aggregation has been created above, if there are no calculations, bamboo returns a 400(Bad Request)
        dataset.query_aggregations()
        expect(dataset.aggregations).toBeDefined()
        expect(dataset.aggregations[""]).toBeDefined()

###
based on underscore.js _.pick
###
_pick = (obj)->
  copy = {}
  keys = Array.prototype.concat.apply(Array.prototype, Array.prototype.slice.call(arguments, 1))
  for key in keys
    copy[key] = obj[key] if obj[key]?
  copy
