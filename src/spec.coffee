test_data =
  csv_file : "https://www.dropbox.com/s/0m8smn04oti92gr/sample_dataset_school_survey.csv?dl=1"

# time to wait for bamboo to do its magic in ms
bamboo_wait_time = 0

callAjax = (xhrSettings) ->
  # call the success function using the expected response as defined in the test_data.urls object
  method = if xhrSettings.type then xhrSettings.type else "GET"
  try
    response = mock_data.urls[xhrSettings.url][method]
    xhrSettings.success.call(null, response)
  catch err
    xhrSettings.error.call()
  return

describe "Bamboo API", ->
  beforeEach ->
    if bamboo.settings.URL.match(/^http/)
      spyOn($, 'ajax').andCallThrough()
      bamboo_wait_time = 3000
    else
      spyOn($, 'ajax').andCallFake(callAjax)
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
        calculation_name = "above_3rd_grade"
        waits bamboo_wait_time

        runs ->
          dataset.add_calculation(calculation_name, "grade > 3")
          return

        runs ->
          expect(dataset.calculations).toBeDefined()
          found_calculation = _.find dataset.calculations, (calculation) ->
            return calculation.name is calculation_name
          expect(found_calculation).toBeDefined()
          return

        runs ->
          dataset.remove_calculation(calculation_name)
          return

        runs ->
          found_calculation = _.find dataset.calculations, (calculation) ->
            return calculation.name is calculation_name
          expect(found_calculation).not.toBeDefined()
          return

        return

      it "", ->


      return

    return

  return