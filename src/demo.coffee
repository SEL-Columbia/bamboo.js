fieldsets = []
demo = (name, cb)-> fieldsets.push new DemoFieldset(name, cb)
class DemoFieldset
  constructor: (@name, @launch_cb)-> launch_cb.call @
  build: (into)->
    pre = $('<pre>', {text:@code})
    if @run?
      $('<a>', {href:'#', text:'Run', class: 'btn btn-primary'})
        .css(float: 'right')
        .click((e)=> @run.call(@); e.preventDefault()).appendTo(pre)
    into.append($('<legend>', {text:@name})).append(pre)
$ -> c = $('#main').empty(); fs.build(c) for fs in fieldsets

demo "New Dataset", ()->
  @code = "var dataset = new bamboo.Dataset({id: '8db48e665fdc494ea69ab90d2aefc341'});"

demo "Get info", ()->
  @code = "dataset.query_info();"

demo "Add aggregation calculation(s)", ()->
  @code = """
    // ONLY RUN BELOW ONCE
    //dataset.add_calculation('wp_functional', 'newest(submit_date,functional)', 'wp_id');
    //dataset.add_calculation('latest_submit_date', 'max(submit_date)', 'wp_id');
  """

demo "Now get the aggregated dataset, and check its okay", ()->
  @code = """
    var aggregatedDatasets = dataset.query_aggregations();
    var waterPointDataset = new bamboo.Dataset({id: aggregatedDatasets.aggregations["wp_id"]});
    waterPointDataset.query_info()
    """

demo "And finally.... get the data", ()->
  @code = """
    waterPointDataset.query_dataset()
    console.log(waterPointDataset.data)
    """


