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
	expect(one_of(char("v"), char("b")).parse(string).value.value).to eq("v")
	expect(one_of(char("v"), char("b")).parse(string2).value.value).to eq("b")
 end

 it "will fail if values do not match" do
	 string = "var alpha = 5"
	 expect(one_of(char("f"), char("b")).parse(string).value).to eq("Given string does not match b")
 end
end
