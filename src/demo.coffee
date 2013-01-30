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
  @code = "var dataset = new bamboo.Dataset({url: 'http://bitly.com/ZfzBwP'});"

demo "Check if dataset exists", ()->
  @code = "bamboo.dataset_exists('nonexistentdataset_id');"

demo "Get info", ()->
  @code = "dataset.query_info();"

demo "Add calculation", ()->
  @code = """
    dataset.add_calculation("above_3rd_grade", "grade > 3");
    dataset.query_dataset();
    console.log(dataset.data);
    """
