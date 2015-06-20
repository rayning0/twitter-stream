# I don't use this code. It's here for future reference:

# https://dev.twitter.com/streaming/overview/connecting

# Once an established connection drops, attempt to reconnect immediately. If the reconnect fails, slow down your reconnect attempts according to the type of error experienced:

backoff_network_error = 0.25
backoff_http_error = 5
backoff_420_error = 60

# Back off linearly for TCP/IP level network errors. These problems are generally temporary and tend to clear quickly. Increase the delay in reconnects by 250ms each attempt, up to 16 seconds.

while disconnected
  begin
    reconnect
  rescue NetworkError
    sleep(backoff_network_error)
    backoff_network_error = [backoff_network_error + 0.25, 16].min

# Back off exponentially for HTTP errors for which reconnecting would be appropriate. Start with a 5 second wait, doubling each attempt, up to 320 seconds.

  rescue HTTPError
    sleep(backoff_http_error)
    backoff_http_error = [backoff_http_error * 2, 320].min

# Back off exponentially for HTTP 420 errors. Start with a 1 minute wait and double each attempt. Note that every HTTP 420 received increases the time you must wait until rate limiting will no longer will be in effect for your account.

  rescue HTTP420Error
    sleep(backoff_420_error)
    backoff_420_error *= 2
  end
end