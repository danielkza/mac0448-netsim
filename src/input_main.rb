require_relative 'input'

path = File.expand_path('../../test.ns', __FILE__)
Input::run_input File.read(path)
