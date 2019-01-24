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

	def self.parse(parser, string)
		parser.parse(string).map do |state| 
			state.value
		end
	end

	def map(&block)
		Parser.new do |string|
			parse(string).map do |state|
				block.call(state)
			end
		end
	end

	def map_error(&block)
		Parser.new do |string|
			parse(string).map_error do |state|
				block.call(state)
			end
		end
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

#for add we want to find a left paren then any_word then any_int then any_int then closing paren

def one_of(*options)
  Parser.new do |string|
		options.inject(Result.error("no options given")) do |result, option| 
			if result.type == :okay
				result
			else	
				option.parse(string)
			end
		end
	end	
end

def any_int
	one_or_more(digit) { |digit1, digit2| digit1 * 10 + digit2}
end

def any_word
	one_or_more(non_space) { |letter1, letter2| letter1 + letter2 }
end

def one_or_more(parser, &block)
	Parser.new do |string|
		result = parser.parse(string)
		result.bind do |state|
			one_or_more_helper(state, parser, &block)
		end
	end	
end

def one_or_more_helper(state, parser, &block)
	result = parser.parse(state.string)
	result.bind do |state2|
		one_or_more_helper(State.new(state2.string, block.call(state.value, state2.value)), parser, &block)
	end.bind_error do |error_string|
		Result.okay(state)	
	end
end

def non_space
	Parser.new do |string|
	  result = any_char.parse(string)
		result.bind do |state|
			if state.value !=  " "
				Result.okay(state)
			else
			  Result.error("Given string is empty space")	
			end
		end
	end
end

def add_expression
	Parser.new do |string|
		char('(').parse(string).bind do |state|
			any_word.parse(state.string).bind do |state2|
				one_or_more(char(" ")) { |x, y| x + y }.parse(state2.string).bind do |state3|
					expression.parse(state3.string).bind do |state4|
						char(" ").parse(state4.string).bind do |state5|
							expression.parse(state5.string).bind do |state6|
								char(")").parse(state6.string).bind do |state7|
									Result.okay(State.new(state7.string, Expressions.add(state4.value, state6.value)))
								end
							end
						end
					end
				end
			end
		end
	end
end

def expression
	one_of(add_expression, number_expression)
end

def number_expression
	any_int.map do |state|
		State.new(state.string, Expressions.number(state.value))
	end
end


#Next Time zero or more - abstract word helper + int helper. reduce duplication. One or more helper which will work similarly to zero or more - require at least first one to match. pass parser and a way to join values.  

def digit
	one_of(char("1"), char("2"), char("3"), char("4"), char("5"), char("6"), char("7"), char("8"), char("9"), char("0")).map do |state|
		State.new(state.string, state.value.to_i)		
	end.map_error do |error_string|
		"Expected number 1-9. Boo"
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

	def map(&block) 
		if @type == :okay
			Result.okay(block.call(@value))
		else
			self		
		end
	end

	def map_error(&block)
		if @type == :error
			Result.error(block.call(@value))
		else
			self
		end
	end

	def bind_error(&block)
		if @type == :error
			block.call(@value)
		else
			self
		end
	end

	def ==(other)
		other.type == self.type && other.value == self.value
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
