export const idlFactory = ({ IDL }) => {
  const http_header = IDL.Record({ 'value' : IDL.Text, 'name' : IDL.Text });
  const http_request_result = IDL.Record({
    'status' : IDL.Nat,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(http_header),
  });
  return IDL.Service({
    'custom_http_get' : IDL.Func([IDL.Text], [IDL.Text], []),
    'fetch_rss_feed' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Int, IDL.Text, IDL.Text],
        [IDL.Text],
        [],
      ),
    'transform' : IDL.Func(
        [
          IDL.Record({
            'context' : IDL.Vec(IDL.Nat8),
            'response' : http_request_result,
          }),
        ],
        [http_request_result],
        ['query'],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
