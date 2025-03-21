import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Nat64 "mo:base/Nat64";
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
};
