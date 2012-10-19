class bamboo
    Dataset: (file) ->
        if file.substring(0, 7) is "http://"
            ###
            USE AJAX TO SEND THE REQUEST
            HOW TO SOLVE THE Access-Control-Allow-Origin PROBLEM?
            ###
            alert "csvFile"
        else if file.substring(0, 7) is "file://"
            alert "upload file"
        else
            alert "bamboo ID"





