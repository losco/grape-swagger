require 'spec_helper'

describe "helpers" do

  before(:all) do
    class HelperTestAPI < Grape::API
      add_swagger_documentation
    end

    @api = Object.new
    # after injecting grape-swagger into the Test API we get the helper methods
    # back from the first endpoint's class (the API mounted by grape-swagger
    # to serve the swagger_doc
    @api.extend HelperTestAPI.endpoints.first.options[:app].helpers

  end

  context "parsing parameters" do
    it "should parse params as query strings for a GET" do
      params = {
        name: {type: 'String', :desc => "A name", required: true },
        level: 'max'
      }
      path = "/coolness"
      method = "GET"
      @api.parse_params(params, path, method).should ==
        [
          {paramType: "query", name: :name, description:"A name", dataType: "String", required: true},
          {paramType: "query", name: :level, description:"", dataType: "String", required: false}
      ]
    end

    it "should parse params as body for a POST" do
      params = {
        name: {type: 'String', :desc =>"A name", required: true },
        level: 'max'
      }
      path = "/coolness"
      method = "POST"
      @api.parse_params(params, path, method).should ==
        [
          {paramType: "body", name: :name, description:"A name", dataType: "String", required: true},
          {paramType: "body", name: :level, description:"", dataType: "String", required: false}
      ]
    end
  end

  context "parsing the path" do
    it "should parse the path" do
      path = ":abc/def(.:format)"
      @api.parse_path(path, nil).should == "{abc}/def.{format}"
    end

    it "should parse a path that has vars with underscores in the name" do
      path = "abc/:def_g(.:format)"
      @api.parse_path(path, nil).should == "abc/{def_g}.{format}"

    end

    it "should parse a path that has vars with numbers in the name" do
      path = "abc/:sha1(.:format)"
      @api.parse_path(path, nil).should == "abc/{sha1}.{format}"
    end

    it "should parse a path that has multiple variables" do
      path1 = "abc/:def/:geh(.:format)"
      path2 = "abc/:def:geh(.:format)"
      @api.parse_path(path1, nil).should == "abc/{def}/{geh}.{format}"
      @api.parse_path(path2, nil).should == "abc/{def}{geh}.{format}"
    end

    it "should parse the path with a specified version" do
      path = ":abc/{version}/def(.:format)"
      @api.parse_path(path, 'v1').should == "{abc}/v1/def.{format}"
    end
  end

  context "parsing header parameters" do
    it "should parse params for the header" do
      params = {"XAuthToken" => { description: "A required header.", required: true}}
      @api.parse_header_params(params).should ==
        [
          {paramType: "header", name: "XAuthToken", description:"A required header.", dataType: "String", required: true}
      ]
    end
  end

  context "parsing object_fields" do
    it "should parse object_fields" do
      object_fields = {:id=>{:type=>'String', :desc=>'description test'}, :type => 'User', :desc => 'user description', :required => true}
      @api.parse_object_fields(object_fields).should == 
        [{paramType: 'body', name: 'User', dataType: 'User', description: 'user description', required: true}]
    end
  end
end
