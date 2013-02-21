test_data =
  csv_file : "https://www.dropbox.com/s/0m8smn04oti92gr/sample_dataset_school_survey.csv?dl=1"

callAjax = (xhrSettings) ->
  # call the success function using the expected response as defined in the test_data.urls object
  method = if xhrSettings.type then xhrSettings.type else "GET"
  xhrSettings.success.call(null, mock_data.urls[xhrSettings.url][method])
  return

describe "Bamboo API", ->
  beforeEach ->
    if bamboo.settings.URL.match(/^http/)
      spyOn($, 'ajax').andCallThrough()
    else
      spyOn($, 'ajax').andCallFake(callAjax)
    return

  it "can create from url", ->
    dataset = new bamboo.Dataset({
      url: test_data.csv_file,
      autoload: true
    })
    expect(dataset.id).toBeDefined()
    expect(dataset.query_info().info.id).toBe(dataset.id)
    return

  describe "Query", ->
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

      return

    afterEach ->
      # delete dataset
      deleted = dataset.delete()
      expect(deleted).toBeTruthy()
      return

    it "can query info", ->
      expect(dataset.query_info().info.id).toBe(dataset.id)
      expect(dataset.info.num_rows).toBe(14)
      return

    return

  return