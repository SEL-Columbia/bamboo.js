exec = require('child_process').exec
fs = require('fs')

config =
  output: 'build/bamboo_api.js'
  spec: 'src/test/spec.coffee'
  demo: 'src/demo/demo.coffee'
  input_dir: 'src'

task 'watch', "Watch and compile into #{config.output}", ->
  messages = (data)-> process.stdout.write(data)

  exec("coffee -cw #{config.spec}").stdout.on 'data', messages

  exec("coffee -j #{config.output} -cw #{config.input_dir}/*.coffee").stdout.on 'data', messages

  exec("coffee -cw #{config.demo}").stdout.on 'data', messages