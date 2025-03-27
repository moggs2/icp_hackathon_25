import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Text "mo:base/Text";
import IC "ic:aaaaa-aa";


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
    let summary = await summarize_with_gpt(parsed_feed);
    return summary;
  };

  // Function to parse the RSS feed and extract titles, descriptions, and pubDates
  private func parse_rss_feed(rss_feed: Text) : Text {
    // Initialize an empty string to hold the results
    var result = "";
    
    let rss_feed_2 = Text.replace(rss_feed, #char '\n', "");
    let rss_feed_3 = Text.replace(rss_feed_2, #text "<item>", "\n<item>");
    let rss_feed_4 = Text.replace(rss_feed_3, #text "</item>", "</item>\n");

    // Split the RSS feed into lines for easier processing
    let lines = Text.split(rss_feed_4, #char('\n'));

    // Iterate through the lines to find relevant information
    for (line in lines) {
      let line_2 = Text.replace(line, #text "<title>", "\n<title>");
      let line_3 = Text.replace(line_2, #text "</title>", "</title>\n");
      let line_4 = Text.replace(line_3, #text "<description>", "\n<description>");
      let line_5 = Text.replace(line_4, #text "</description>", "</description>\n");
      let line_6 = Text.replace(line_5, #text "<pubDate>", "\n<pubDate>");
      let line_7 = Text.replace(line_6, #text "</pubDate>", "</pubDate>\n");
      let inner_lines = Text.split(line_7, #char('\n'));

    for (inner_line in inner_lines) {
          // Check for title
          if (Text.contains(inner_line, #text "<title>")) {
            let title = inner_line;
            result := result # title # "\n";
          };
          // Check for description
          if (Text.contains(inner_line, #text "<description>")) {
            let description = inner_line;
            result := result # description # "\n";
          };
          // Check for pubDate
          if (Text.contains(inner_line, #text "<pubDate>")) {
            let pubDate = inner_line;
            result := result # pubDate # "\n";
          }
        };
    };
    return result;
  };

  private func summarize_with_gpt(parsed_feed: Text) : async Text {
    // Prepare the GPT API request
    let gpt_request_headers = 
    [
    { name = "Content-Type"; value = "application/json" }, 
    { name = "Authorization"; value = "Bearer Your Key" }
    ];
    
    var parsed_feed_2 = Text.replace(parsed_feed, #char '=', "  equals  ");
    parsed_feed_2 := Text.replace(parsed_feed_2, #char '\n', "  new line  ");
    parsed_feed_2 := Text.replace(parsed_feed_2, #char '/', " ");
    parsed_feed_2 := Text.replace(parsed_feed_2, #char '\r', " ");
    parsed_feed_2 := Text.replace(parsed_feed_2, #char '\t', " ");
    parsed_feed_2 := Text.replace(parsed_feed_2, #char '\"', "  Quotes  ");
    parsed_feed_2 := Text.replace(parsed_feed_2, #char '\\', "  Backslash  ");

    var body_string = "{
      \"model\": \"gpt-4o\",
      \"messages\": [{ \"role\": \"user\", \"content\": \"Please summarize the following RSS feed: " # parsed_feed_2 # "\"       },
       { \"role\": \"user\", \"content\": \"\"}
       ]
    }";

    let gpt_request_body = Text.encodeUtf8(body_string);

    let gpt_http_request : IC.http_request_args = {
      url = "https://api.openai.com/v1/chat/completions";
      max_response_bytes = null;
      headers = gpt_request_headers;
      body = ?gpt_request_body;
      method = #post;
      transform = ?{
        function = transform;
        context = Blob.fromArray([]);
       };
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
