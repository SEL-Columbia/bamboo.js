// Generated by CoffeeScript 1.3.3
  var bamboo, script;


  bamboo = (function() {

    function bamboo() {}

    bamboo.prototype.Dataset = function(data) {
      if (data.hasOwnProperty('url')) {
        /*
                    USE AJAX TO SEND THE REQUEST
                    HOW TO SOLVE THE Access-Control-Allow-Origin PROBLEM?
        */
        var obj = {url:"http://google.com", type: 'GET', dataType: 'html',  success: function(data, textStatus, xhr) { console.log(data);}};
        $.ajax(obj);

        this.id = 'sjdiofjaosdf';
        return this;
      } else if (data.hasOwnProperty('id')) {

      } else {

      }
    };

    return bamboo;

  })();

