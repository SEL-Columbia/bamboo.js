exec = require('child_process').exec
fs = require('fs')

config =
  input_dir: 'src'
  output_dir: 'lib'

task 'watch', "Watch and compile into #{config.output}", ->
  messages = (data)-> process.stdout.write(data)

  exec("coffee -o #{config.output_dir} -cw #{config.input_dir}/*.coffee").stdout.on 'data', messages