require 'spec_helper'

describe "any_char" do
 it "tests" do
	 expect(true).to eq(true)
 end

 it "any_char gives back first letter of any string" do
	string = "var alpha = 5"
	expect(any_char.parse(string).value.value).to eq("v")
 end

 it "any_char returns a state with string minus first char" do
	string = "var alpha = 5"
	expect(any_char.parse(string).value.string).to eq("ar alpha = 5")
 end

 it "if string is empty we get" do
	 expect(any_char.parse("").value).to eq("Cannot parse empty string")
 end
end

describe "char" do
	it "char parses for given character" do
		string = "var alpha = 5"
		expect(char("v").parse(string).value.value).to eq("v")
	end

	it "char does not parse if given wrong char" do
		string = "bar alpha = 5"
		expect(char("v").parse(string).value).to eq("Given string does not match v")
	end
end

describe "one_of" do
 it "will succeed if given string matches one of given values" do
	string = "var alpha = 5"
	string2= "bar alpha = 5"
	expect(Parser.parse(one_of(char("v"), char("b")), string)).to eq(Result.okay("v"))
	expect(Parser.parse(one_of(char("v"), char("b")), string2)).to eq(Result.okay("b"))
 end

 it "will fail if values do not match" do
	 string = "var alpha = 5"
	 expect(one_of(char("f"), char("b")).parse(string).value).to eq("Given string does not match b")
 end

 it "can take three arguments" do
	string = "var alpha = 5"
	string2= "bar alpha = 5"
	string3 = "car alpha = 5"
	expect(Parser.parse(one_of(char("v"), char("b"), char("c")), string)).to eq(Result.okay("v"))
	expect(Parser.parse(one_of(char("v"), char("b"), char("c")), string2)).to eq(Result.okay("b"))
	expect(Parser.parse(one_of(char("v"), char("b"), char("c")), string3)).to eq(Result.okay("c"))
 end

end

describe "any_int" do
	it "returns okay for integer" do
		expect(Parser.parse(any_int, "1")).to eq(Result.okay(1))
	end

	it "returns error when given non integer" do
		expect(Parser.parse(any_int, "a")).to eq(Result.error("Expected number 1-9. Boo"))
	end

	it "returns okay for two digit int" do
		expect(Parser.parse(any_int, "12")).to eq(Result.okay(12))
	end

	it "errors out if both digits arent digits" do
		expect(Parser.parse(any_int, "1a")).to eq(Result.okay(1))
	end

	it "errors out if both digits arent digits" do
		expect(Parser.parse(any_int, "a1")).to eq(Result.error("Expected number 1-9. Boo"))
	end

	it "can take n number of digits" do
		expect(Parser.parse(any_int, "1442")).to eq(Result.okay(1442))
	end
end

describe "letter" do
	it "checks for empty space" do
		string = " "
		expect(non_space.parse(string).value).to eq("Given string is empty space")
	end
	it "can parse if not empty space" do
		string = "a"
		expect(Parser.parse(non_space, string)).to eq(Result.okay(string))
	end
end

describe "any_word" do
	it "can parse any word" do
		string = "boris"
		expect(Parser.parse(any_word, string)).to eq(Result.okay(string))
	end
end

describe "add_expression" do
	it "can parse an add expression" do
		string = "(add 1 3)"
		output = Expressions.add(Expressions.number(1), Expressions.number(3))

		expect(Parser.parse(add_expression, string)).to eq(Result.okay(output))
	end

	it "breaks with extra spaces" do
		string = "(add  3 36)"
		output = Expressions.add(Expressions.number(3), Expressions.number(36))

		expect(Parser.parse(add_expression, string)).to eq(Result.okay(output))
	end

	it "can parse nested add expresssions" do
		string = "(add  3 (add 3 6))"
		output = Expressions.add(Expressions.number(3), Expressions.add(Expressions.number(3), Expressions.number(6)))

		expect(Parser.parse(add_expression, string)).to eq(Result.okay(output))
	end
end
