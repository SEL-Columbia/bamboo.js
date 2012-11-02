###
$ = $ || throw new Error('jquery not included')
###
BAMBOO_URL = "http://bamboo.io/datasets"

class Dataset
    constructor: (data, cb) ->
        if 'url' of data
            @load_from_url(data.url)
        else if 'id' of data
            @load_from_id(data.id)
        else if 'path' of data
            @load_from_id(data.path)

    load_from_url: (url)->
        return_value = false
        success_cb = (returned_data)=>
            @id = JSON.parse(returned_data).id
        fail_cb = (a,b,c)-> console.log "Fail", a,b,c
        $.ajax({url:BAMBOO_URL, type:'POST', data:{url: url}, async: false})
            .success(success_cb).fail(fail_cb)

    load_from_id: (id)->
        @id = id        

    load_from_path: (path)->
        #how to submit a local file to the bamboo server?

class getData
    constructor: (columns, querys) ->

@bamboo = {
	Dataset: Dataset
}
