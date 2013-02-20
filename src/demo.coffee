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
  @code = "var dataset = new bamboo.Dataset({id: 'fa871c15b7cd4ab69f7c3bff83ac6107'});"

demo "Get info", ()->
  @code = "dataset.query_info();"

demo "Add aggregation calculation(s)", ()->
  @code = """
    dataset.query_calculations();
    if(dataset.calculations.length == 0) {
        // ONLY ADD THE AGGREGATIONS ONCE
        dataset.add_aggregations('ratio_polls_open', 'ratio(a_a in ["1"], 1)', ['governorate']);
        dataset.add_aggregations('ballots_counted', 'ratio(b_e in ["1"],1)', ['governorate']);
        dataset.add_aggregations('ballot_boxes_empty_before_voting', 'ratio(b_g in ["1"],1)', ['governorate']);
        dataset.add_aggregations('ballot_boxes_closed_with_HEC_seal', 'ratio(b_h in ["1"],1)', ['governorate']);
        dataset.add_aggregations('polling_center_handycap_accessible', 'ratio(b_j in ["1"],1)', ['governorate']);
        dataset.add_aggregations('polling_center_have_indelible_ink', 'ratio(b_k in ["1"],1)', ['governorate']);

    }
  """

demo "Now get the aggregated dataset, and check its okay", ()->
  @code = """
    var aggregatedDatasets = dataset.query_aggregations();
    var electionDataset = new bamboo.Dataset({id: aggregatedDatasets.aggregations["governorate"]});
    """

