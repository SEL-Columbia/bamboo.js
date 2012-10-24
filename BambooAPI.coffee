class bamboo
    Dataset: (data) ->
        if data.hasOwnProperty('url')
            ###
            USE AJAX TO SEND THE REQUEST
            HOW TO SOLVE THE Access-Control-Allow-Origin PROBLEM?
            ###
            alert "csvFile"
        else if data.hasOwnProperty('id')
            alert "bamboo ID"
        else
            alert "upload file"





