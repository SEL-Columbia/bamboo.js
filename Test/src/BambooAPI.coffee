script = document.createElement('script')
script.src = 'http://jqueryjs.googlecode.com/files/jquery-1.2.6.min.js'
script.type = 'text/javascript'
document.getElementsByTagName('head')[0].appendChild(script)

class bamboo
    constructor: () ->

    Dataset: (data) ->
        if data.hasOwnProperty('url')
            ###
            USE AJAX TO SEND THE REQUEST
            HOW TO SOLVE THE Access-Control-Allow-Origin PROBLEM?
            ###
            this.id = 'sjdiofjaosdf'
            this
        else if data.hasOwnProperty('id')
        else




