#type Expression 
#  = Number Int
#  | Add Expression Expression	
#
#	{
#		type: 'number',
#		value: 5
#	}
#
#	{
#		type: 'add',
#		left: ...,
#		right: ...
#	}
#
#	simple = Number 5
#	  = 5
#		output 5
#	complex = Add (Number 5) (Number 3)
#	  = (add 5 3)
#		output (5 + 3)
#	superComplex = Add (Add (Number 5) (Number 3)) (Number 8)
#	  = (add (add 5 3) 8)
#		output ((5 + 3) + 8)
#
#
#add(number(5), number(7))

module Expressions
  class << self
		def number(num)
			{
				type: "number",
				value: num
			}
		end

		def add(expression1, expression2)
			{
				type: "add",
				left: expression1,
				right: expression2
			}
		end

		def variable(name)
			{
				type: "variable",
				name: name
			}
		end

		def function(name, args, expression)
			{
				type: "function",
				name: name,
				args: args,
				expression: expression
			}
		end
	end
end
class State
	def initialize(string, value)
		@string = string
		@value = value
	end

	attr_reader :string, :value
end
class Parser
	def initialize(&block)
		@block = block
	end

	def parse(string)
		@block.call(string)
	end
end

def char(character)
	Parser.new do |string|
	  result = any_char.parse(string)
		result.bind do |state|
			if state.value == character
				Result.okay(state)
			else
			  Result.error("Given string does not match #{character}")	
			end
		end
	end
end

def any_char
	Parser.new do |string|
		if string.chr != "" 
			new_string = string.dup
			new_string[0] = ""
			Result.okay(State.new(new_string, string.chr))
		else
			Result.error("Cannot parse empty string")
		end
	end
end

def one_of(option1, option2)
  Parser.new do |string|
		if option1.parse(string).type == :okay
			option1.parse(string)
		else	
		  option2.parse(string)
		end
	end	
end

class Result
	def initialize(type, value)
		@type = type
		@value = value
	end
	
	def self.okay(value)
		new(:okay, value)
	end

	def self.error(value)
		new(:error, value)
	end

	def bind(&block)
		if @type == :okay
			block.call(@value)
		else
			self
		end
	end

	attr_reader :type, :value
end
#state = "var alpha = 5"
#step_1 =  one_of(char("v"), char("b")).parse(state)
#step_2 = raise any_char.parse(step_1.string).inspect

module OldParser
	class << self
		def parse(string)
			if string.match(/^\(define/)
				parse_function_expression(string)
			elsif string.match(/^\(add/)
				parse_add_expression(string)
			elsif string.match(/^\w+$/)
				parse_variable_expression(string)
			else
				raise "We don't know how to parse: " + string
			end
		end

		def parse_variable_expression(string)
			Expressions.variable(string)
		end

		def parse_add_expression(string)
			elements = string.split.map { |e| e.gsub("(", "") }
			Expressions.add(Parser.parse(elements[1]), Parser.parse(elements[2]))
		end

		def parse_function_expression(string)
			elements = string.split("(", 3).flat_map.with_index { |e, i| i==1 ? e.split  : e  }
			expressionString = "(" + elements.last.gsub(")", "")
			expression = Parser.parse(expressionString)
			Expressions.function(elements[2], elements[3..-2], expression)
		end
	end
end

# (define funcName arg1 arg2 arg (...))
#   (add (add a a) (add b b)))
# (define double a
#   (add a a))
#
# (double 5 7)

module Javascript
	class << self
		def compile(expression)
			case expression[:type]
			when "number"
				expression[:value].to_s
			when "add"
				"(#{(compile(expression[:left]))} + #{(compile(expression[:right]))})"				
			when "variable"
				expression[:name]
			when "function"
				"var #{expression[:name]} = function(#{expression[:args].join(',')}) {\n" +
				"  return #{compile(expression[:expression])} \n" +
				"}"
			end
		end
	end
end
