# Client for creating images and managing templates with HTML/CSS to Image.
class HTMLCSSToImage
  include HTTParty

  base_uri "https://hcti.io"
  headers "Content-Type" => "application/json"
  format :json

  # A structured API response with attribute-style access to JSON fields.
  class ApiResponse < OpenStruct
  end

  parser(
    proc do |body, format|
      case format
      when :json
        JSON.parse(body, object_class: ApiResponse)
      else
        body
      end
    end
  )

  # Creates an instance of HTMLCSSToImage with API credentials.
  # If credentials are not provided, the client uses the `HCTI_USER_ID`
  # and `HCTI_API_KEY` environment variables.
  #
  # @see https://htmlcsstoimage.com/dashboard
  #
  # @param user_id [String] the user ID for the account
  # @param api_key [String] the API key for the account
  # @return [HTMLCSSToImage] an instance of the API client
  def initialize(user_id: ENV["HCTI_USER_ID"], api_key: ENV["HCTI_API_KEY"])
    @auth = { username: user_id, password: api_key }
  end
end
