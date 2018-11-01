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

# (define double a
#   (add a a))

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
