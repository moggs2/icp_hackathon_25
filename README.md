# `icp_hackathon_25 - AI RSS Reader`

Welcome to our new `icp_hackathon_25` project and to the Internet Computer development community. This project loads RSS feeds from chosen URLs. After selecting by keywords and date, the user also specifies what they really want to know. The GPT-4 API is then provided with the requested information, which is incorporated into a modern user interface.

It is recommended to use RSS URLs from sites that deliver the article directly in the feed. Examples include RSS feeds from cointelegraph.com, stockcharts.com, thesun.co.uk, or many WordPress blogs. These feeds occasionally contain more than 16,000 characters and cannot be loaded directly into the API. This program can limit the maximum number of items per feed.

The UI provides spaces for RSS URLs, a slider to limit the items per feed, a text field to specify which information is required from the feed, and a word filter. The word filter checks each word (case insensitive) to see if it is present in a feed item. If the AI RSS Reader cannot find a word from the filter in a particular feed item, that item is not considered.

## Running the project locally

If you want to test this project locally, you can use the following commands:

```bash
# Starts the replica, running in the background
dfx start --background

# Deploys your canisters to the replica and generates your candid interface
dfx deploy
```

Once the job completes, your application will be available at `http://localhost:4943?canisterId={asset_canister_id}`.
