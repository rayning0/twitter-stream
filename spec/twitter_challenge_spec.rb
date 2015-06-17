require 'spec_helper'
require 'twitter_challenge'

describe TwitterChallenge do
  describe '#change_word_freq_hash' do
    it 'handles empty string' do
      expect(subject.word_freq_hash('')).to eq({})
    end

    it 'handles a few sentences' do
      expect(subject.word_freq_hash('If the shot Shott shot shot
        Nott, Nott was shot. But if the shot Shott shot shot Shott,
        then Shott was shot, not Nott.')).to eq({"shot"=>8, "shott"=>4, \
        "nott"=>3, "if"=>2, "was"=>2, "but"=>1, "then"=>1, "not"=>1})
    end

    it 'ignores rejected words like "RT", "the", "I", "is", "it", etc.' do
      expect(subject.word_freq_hash("RT I do not know what's happening,
        you know? It seems like what's happening is not as it seems. Seems
        crazy!")).to eq({"seems"=>3, "know"=>2, "not"=>2, "happening"=>2, \
        "what's"=>2, "crazy"=>1, "like"=>1, "as"=>1, "do"=>1})
    end

    it "ignores words starting with '@' or 'http' " do
      expect(subject.word_freq_hash("RT @guy: I do not know what's happening,
        you know? It seems like what's happening is not as it seems. Seems
        crazy! http://t.co/ngrmndmzbm")).to eq({"seems"=>3, "know"=>2, "not"=>2, \
        "happening"=>2, "what's"=>2, "crazy"=>1, "like"=>1, "as"=>1, "do"=>1})
    end
  end
end