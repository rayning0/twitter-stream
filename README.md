__Twitter Challenge__ by Raymond Gan. Based on [Twitter's Streaming APIs](https://dev.twitter.com/streaming/overview).

To run code:

`bundle exec ruby twitter.rb start`

To run tests:

`rspec`

Part A: By default, it analyzes tweets in English for 300 seconds and shows the top 10 words. You may pick your own time and # of top words.

After cloning this code, you need a /config/secrets.yml file with these 4 secret keys [from Twitter](https://apps.twitter.com/):

- consumer_key
- consumer_secret
- oauth_token
- oauth_token_secret

Part B: My code uses a [daemon](https://github.com/thuehlinger/daemons) that monitors this process ("tchallenge") and automatically restarts it, reconnecting to Twitter if ever disconnected.

To simulate a disconnection, kill "tchallenge" by typing:

`pkill -x tchallenge`

After about 20 seconds, "tchallenge" restarts itself! You may keep killing the process, but it will keep restarting till time is up.

Line 40 of my [Twitter Challenge Spec](https://github.com/rayning0/twitter-stream/blob/master/spec/twitter_challenge_spec.rb) starts a VERY thorough test of Part B. My code automatically starts "tchallenge" 4 times, while killing it 3 times.

As my code repeatedly disconnects from and reconnects to Twitter, files "tchallenge.output" and "word_freq.dat" keep updating themselves with the latest tweet info.

Files created:

- __tchallenge.output__, showing final word frequency count, plus array of top words. Shows record of all connections/disconnections from Twitter.

- __word_freq.dat__, a hash of all unique words in all tweets, with their frequencies. The "$$" key shows total number of tweets analyzed.

Output of my personal tests:

__Part B__

- [__rspec-output-5min.png__](https://github.com/rayning0/twitter-stream/blob/master/rspec-output-5min.png), screenshot after running 5 min RSpec tests. In [twitter_challenge_spec.rb](https://github.com/rayning0/twitter-stream/blob/master/spec/twitter_challenge_spec.rb), I simulate disconnecting 3 times from Twitter. After each time, my process automatically restarts.

- [__tchallenge-rspec-5min.output__](https://github.com/rayning0/twitter-stream/blob/master/tchallenge-rspec-5min.output), after 5 min RSpec tests. Shows how it disconnects from Twitter 3 times but restarts each time. It continues to analyze tweets afterwards, for total of 3110 tweets.

- [__word_freq-rspec-5min.dat__](https://github.com/rayning0/twitter-stream/blob/master/word_freq-rspec-5min.dat), after 5 minute RSpec tests. Final word frequency hash. Total number of tweets analyzed, 3110, is on last line at "$$" key.

__Part A__

- [__tchallenge-5min.output__](https://github.com/rayning0/twitter-stream/blob/master/tchallenge-5min.output), analyzing 4328 tweets in 5 min, with no disconnections.

- [__word_freq-5min.dat__](https://github.com/rayning0/twitter-stream/blob/master/word_freq-5min.dat). Word frequency hash after 5 min.

- [__tchallenge-20secs.output__](https://github.com/rayning0/twitter-stream/blob/master/tchallenge-20secs.output), top 8 words after 20 secs.

- [__word_freq-20secs.dat__](https://github.com/rayning0/twitter-stream/blob/master/word_freq-20secs.dat). Word frequency hash after 20 secs.

Final note:

You need my [modified version](https://github.com/rayning0/tweetstream) of the "tweetstream" gem to run all this, on my "on_close_callback" branch. The current "tweetstream" gem won't let you detect when the Twitter connection has closed. I fixed this and made this [pull request](https://github.com/tweetstream/tweetstream/pull/180).
