import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import IC "ic:aaaaa-aa";
import Array "mo:base/Array";
import Option "mo:base/Option";

// Actor
actor {

  // Function to transform the response
  public query func transform({
    context : Blob;
    response : IC.http_request_result;
  }) : async IC.http_request_result {
    {
      response with headers = []; // not interested in the headers
    };
  };

  // Function to make a custom HTTP GET request
  public func custom_http_get(url: Text) : async Text {
    // 1. Prepare headers for the HTTP request
    let request_headers = [
      { name = "User-Agent"; value = "custom-http-client" },
    ];

    // 2. Create the HTTP request
    let http_request : IC.http_request_args = {
      url = url;
      max_response_bytes = null; // optional for request
      headers = request_headers;
      body = null; // optional for request
      method = #get;
      transform = ?{
        function = transform;
        context = Blob.fromArray([]);
      };
    };

    // 3. Add cycles to pay for the HTTP request
    Cycles.add<system>(230_949_972_000);

    // 4. Make the HTTPS request and wait for the response
    let http_response : IC.http_request_result = await IC.http_request(http_request);

    // 5. Decode the response
    let decoded_text : Text = switch (Text.decodeUtf8(http_response.body)) {
      case (null) { "No value returned" };
      case (?y) { y };
    };

    // 6. Return the decoded response
    decoded_text;
  };

  // Function to fetch and process the RSS feed
  public func fetch_rss_feed(url: Text) : async Text {
    let rss_feed = await custom_http_get(url);
    let parsed_feed = parse_rss_feed(rss_feed);
    //let summary = await summarize_with_gpt(parsed_feed);
    return parsed_feed;
  };

  // Function to parse the RSS feed and extract titles, descriptions, and pubDates
  private func parse_rss_feed(rss_feed: Text) : Text {
    // Initialize an empty string to hold the results
    var result = "";

    // Split the RSS feed into lines for easier processing
    let lines = Text.split(rss_feed, #char('\n'));

    // Iterate through the lines to find relevant information
    for (line in lines) {
      // Check for title
      if (Text.contains(line, #text "<title>")) {
        let title = line;
        result := result # title # "\n";
      };
      // Check for description
      if (Text.contains(line, #text "<description>")) {
        let description = line;
        result := result # description # "\n";
      };
      // Check for pubDate
      if (Text.contains(line, #text "<pubDate>")) {
        let pubDate = line;
        result := result # pubDate # "\n";
      }
    };

    return result;
  };

  private func summarize_with_gpt(parsed_feed: Text) : async Text {
    // Prepare the GPT API request
    let gpt_request_headers = [
      { name = "Content-Type"; value = "application/json" },
      { name = "Authorization"; value = "Bearer YOUR_GPT_API_KEY" }
    ];
    
    var body_string = "{
      \"model\": \"gpt-4\",
      \"prompt\": \"Summarize the following RSS feed data:\n\n" # parsed_feed # "\",
      \"max_tokens\": 100,
      \"temperature\": 0.7
    }";

    let gpt_request_body = Text.encodeUtf8(body_string);

    let gpt_http_request : IC.http_request_args = {
      url = "https://api.openai.com/v1/engines/gpt-4/completions";
      max_response_bytes = null;
      headers = gpt_request_headers;
      body = ?gpt_request_body;
      method = #post;
      transform = null;
    };

    // Add cycles to pay for the HTTP request
    Cycles.add<system>(230_949_972_000);

    // Make the HTTP request to the GPT API and wait for the response
    let gpt_http_response : IC.http_request_result = await IC.http_request(gpt_http_request);

    // Decode the response
    let gpt_response_text : Text = switch (Text.decodeUtf8(gpt_http_response.body)) {
      case (null) { "No value returned" };
      case (?y) { y };
    };

    return gpt_response_text;
  };

};
