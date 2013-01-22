test_data =
  id : "fdf66b3a8a5b4617bd12f56e70e394a1"
  csv_file : "https://www.dropbox.com/s/0m8smn04oti92gr/sample_dataset_school_survey.csv"
  csv_file_merge: "https://www.dropbox.com/s/5aja0nlcufn65vd/sample_merge.csv"
  csv_file_join: "https://www.dropbox.com/s/haamu5h09b85thp/sample_join.csv"

tmp_ds = "1325a517cc33443bbc2a09b39adae401"

describe "bamboo api works", ->
  beforeEach ->
    @available_opts =
      url: test_data.csv_file
      autoload: false
      id: test_data.id
    @build_dataset = (keys)=>
      new bamboo.Dataset _pick(@available_opts, keys)

  it "can query for a new id", ->
    dataset   = @build_dataset('url', 'autoload')
    expect(dataset.load_status('from_url')).toBe("not_started")

  it "can access dataset info by existing id", ->
    dataset   = @build_dataset('id', 'autoload')

    expect(dataset.id).toBeDefined()
    expect(dataset.query_info().info.id).toBe(dataset.id)
    expect(dataset.info.num_rows).toBe(14)

  it "can query dataset", ->
    dataset   = @build_dataset('id', 'autoload')

    expect(dataset.data).not.toBeDefined()
    dataset.query_dataset()

    expect(dataset.data).toBeDefined()

  it "can select from dataset", ->
    dataset   = @build_dataset('id', 'autoload')

    select = dataset.select({grade:1})
    expect(select.length).toBe(14)

  it "can query from dataset", ->
    dataset   = @build_dataset('id', 'autoload')

    query1 = dataset.query({grade:4})
    expect(query1.length).toBe(7)

    query2 = dataset.query({grade:3})
    expect(query2.length).toBe(2)
  it "can get the summary", ->
    dataset   = @build_dataset('id', 'autoload')

    summary = dataset.summary()
    expect(Object.keys(summary).sort().join(', ')).toBe('grade, income, name, sex') if Object.keys?

  it "can query summary", ->
    dataset = @build_dataset('id', 'autoload')
    ss = dataset.summary()
    expect(dataset.summary_result).toBeDefined()

  it "can create and delete a dataset", ->
    new_set_id = false
    runs ->
      new_dataset = new bamboo.Dataset({url: test_data.csv_file, autoload: true})
      expect(new_dataset.id).toBeTruthy()
      new_set_id = new_dataset.id
      log "Newly created dataset id: '#{new_set_id}'"
      expect(new_dataset.delete()).toBeTruthy()

    waits 2000

    # bamboo.dataset_exists("id") might not work *immediately* after deletion
    runs ->
      expect(bamboo.dataset_exists(new_set_id)).not.toBeTruthy()

    

describe "calculations", ->
  beforeEach ->
    @dataset = new bamboo.Dataset({url: test_data.csv_file, autoload: true})
  afterEach ->
    @dataset.delete()


  it "adds and deletes simple calculation", ->
    waits 3000
    runs ->
      @dataset.add_calculation("above_3rd_grade", "grade > 3")
    waits 3000
    runs ->
      queried_data = @dataset.query_dataset().data
      expect(queried_data[0].above_3rd_grade).toBeDefined()
    waits 100
    runs ->
      @dataset.remove_calculation("above_3rd_grade")
    waits 3000
    runs ->
      queried_data = @dataset.query_dataset().data
      expect(queried_data[0].above_3rd_grade).not.toBeDefined()


  it "can query an added calculation", ->
    waits 3000
    runs ->
      @dataset.add_calculation("above_3rd_grade", "grade > 3")
    waits 3000
    runs ->
      @dataset.query_calculations()
      expect(@dataset.calculations).toBeDefined()
      expect(@dataset.calculations[0]).toBeDefined()
      expect(@dataset.calculations[0].name).toEqual("above_3rd_grade")

describe "aggregations", ->
  beforeEach ->
    @dataset = new bamboo.Dataset({url: test_data.csv_file, autoload: true})
  afterEach ->
    @dataset.delete()

  it "does regex", ->
    true_st = @dataset._is_aggregation "sum(formula)"
    expect(true_st).toBeTruthy()
    false_st = @dataset._is_aggregation "murica"
    expect(false_st).not.toBeTruthy()
    false_st_2 = @dataset._is_aggregation "sum())"
    expect(false_st_2).not.toBeTruthy()

  it "can add and remove aggregation", ->
    waits 2000
    runs ->
      @dataset.add_aggregations("total_income","sum(income)")
    waits 2000
    runs ->
      @dataset.query_aggregations()
      expect(@dataset.aggregations).toBeDefined()
      expect(@dataset.aggregations[""]).toBeDefined()
      @dataset.remove_aggregations("total_income",(err,ret)->
        expect(ret).toContain("deleted calculation: 'total_income' for dataset:")
      )
      
  it "can query aggregations", ->
    waits 2000
    runs ->
      @dataset.add_aggregations("total_income", "sum(income)")
    waits 2000
    runs ->
      # at the moment, this only works because an aggregation has been created above, if there are no calculations, bamboo returns a 400(Bad Request)
      @dataset.query_aggregations()
      expect(@dataset.aggregations).toBeDefined()
      expect(@dataset.aggregations[""]).toBeDefined()

describe "updates, join, merge", ->
  beforeEach ->
    @dataset = new bamboo.Dataset({url: test_data.csv_file, autoload: true})

  afterEach ->
    @dataset.delete()

  it "can update data in an dataset", ->

  it "can merge a few datasets together", ->
    @dataset_merge = new bamboo.Dataset({url: test_data.csv_file_merge, autoload: true})
    datasets =[@dataset.id, @dataset_merge.id]
    

    @dataset_merge.delete()


  it "can join two datasets on a certain column", ->
    @dataset_join = new bamboo.Dataset({url: test_data.csv_file_join, autoload: true})

    @dataset_join.delete()

  return



###
based on underscore.js _.pick
###
_pick = (obj)->
  copy = {}
  keys = Array.prototype.concat.apply(Array.prototype, Array.prototype.slice.call(arguments, 1))
  for key in keys
    copy[key] = obj[key] if obj[key]?
  copy
