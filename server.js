var express = require("express"),
    app = express(),
    http = require('http'),
    server = http.createServer(app),
    PORT = process.env.PORT || 8000;

server.listen(PORT);

app.configure(function(){
    app.set('views', __dirname);
    app.use(express.static(__dirname));
});

//routing
app.get('/', function(req, res, err) {
    res.sendfile(__dirname + '/index.html');
});
app.get('/test.html', function(req, res, err) {
    res.sendfile(__dirname + '/views/test.html');
});
//app.get('/demo', function(req, res) {
//    res.sendfile(__dirname + '/views/demo.html');
//});
