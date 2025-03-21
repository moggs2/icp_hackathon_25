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
    return parse_rss_feed(rss_feed);
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
        result := result # "Title: " # title # "\n";
      };
      // Check for description
      if (Text.contains(line, #text "<description>")) {
        let description = line;
        result := result # "Description: " # description # "\n";
      };
      // Check for pubDate
      if (Text.contains(line, #text "<pubDate>")) {
        let pubDate = line;
        result := result # "Publication Date: " # pubDate # "\n";
      }
    };

    return result;
  };


};
