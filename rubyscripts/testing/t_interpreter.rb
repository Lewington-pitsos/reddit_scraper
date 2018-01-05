require "minitest/autorun"
require_relative '../crawler/interpreter.rb'
require_relative 'example_comments.rb'
class InterpreterTest < Minitest::Test

  def setup
    @comments = CommentInterpreter.new();
    @expected_comment_data = [
      {:content=>"Bitcoin This is huge news. People have been talking about interledger protocol as a method to bank the unbanked for a few years now. The Gates Foundation partnering with ripple may actually see this happen sooner of later. Amazing for XRP hodlers, crypto-investors as a whole, but most importantly, for humanity! Well done guys!", :user=>"FlashJordanK", :score=>"22"},
      {:content=>"Bitcoin Just wanted to share this with you all.. If you haven't heard about Aurora Mine which just has launched, it is a super cool platform where you can get 100 GH/s for free to mine bitcoins. Basically, you just have to sign up and then it starts mining... And you can pay out with no fees. It won't be free for long.. However, you can also put in investments to gain more computerpower! I really like what I see from them so far.. So check it out!Check it out: <a href=\"https://www.auroramine.com/?ref=363868\" rel=\"nofollow\">https://www.auroramine.com/?ref=363868</a>", :user=>"dobbelDK", :score=>"0"},
      {:content=>"Bitcoin Oh, but I thought this subreddit thought XRP was a \"shitcoin\"? Fools. First it's Stellar Lumens, now it\'s Ripple. Never trust the idiotic herd mentality of this subreddit.Sheep.", :user=>"Rhaeguarco", :score=>"14"},
      {:content=>"Bitcoin I have 25% of my crypto portfolio in XRP but this announcement is pretty shit.", :user=>"the-rooster", :score=>"-3"},
      {:content=>"bitcoin moon mission 2018", :user=>"soul5tice", :score=>"0"}]
      @expected_thread_data = [{:content=>"Crypto hodlers! It's finally time to begin the <a href=\"/r/CryptoCurrency\">r/CryptoCurrency</a> Theme Contest. Here are the details:<strong>Rules:</strong>Anyone can become an entrant. You will need to create your own subreddit to showcase your theme. Just create a link to it inside a top-level comment below. Comments will be sorted by newest first. If you create multiple versions, it might be efficient to take screenshots and show them all in a gallery.When creating your subreddit, this is the suggested naming format: <strong>\"<a href=\"/r/cctheme_username\">/r/cctheme_username</a>\"</strong>The contest duration will last two weeks starting from October 12th 2017. If anyone needs a time extension, send a request to the modmail to see if you will be granted one. If you make a convincing case, the length of the contest will be extended for everyone.<strong>Your theme will be built using one of the three <a href=\"/r/CryptoCurrency\">r/CryptoCurrency</a> winning banner designs. There are plenty of variations to use in the links here:</strong><a href=\"https://imgur.com/a/vFWkI\">/u/abandonlaw Banner</a><a href=\"https://www.reddit.com/r/CryptoCurrency/comments/6xmyrk/new_rcryptocurrency_banner_contest/dn2qe5u/\">/u/phoenixkiller2 Banner</a> <a href=\"https://www.reddit.com/r/CryptoCurrency/comments/6xmyrk/new_rcryptocurrency_banner_contest/dmiybj5/\">/u/scorpyowns Banner</a>Contestants may group into teams if they wish but joining multiple teams is prohibited.<strong>Suggestions and Ideas:</strong> As far as theme appearance goes, feel free to express yourself and create whatever you want. However, we have a small list of ideas/suggestions. If you don't like them, no rules will be violated. If you believe you have a better vision for how the theme should look, make it happen.Try incorporating the use of flyout menus(<a href=\"https://pastebin.com/G0DkLaQG\">CSS</a>) for the sidebar and a drop-down menu for the link-flairs, see <a href=\"/r/spaceengineers\">/r/spaceengineers</a>, <a href=\"/r/ImaginaryArchitecture\">r/ImaginaryArchitecture</a>, and <a href=\"/r/politics\">/r/politics</a> for examples. For a copy of the sidebar text, <a href=\"https://pastebin.com/AUA2udQp\">see here</a>.Experiment with different looking tickers, link-flairs, and user image flairs.As mentioned in the rules, you can team up with other redditors. If you have connections people who are highly skilled in CSS, encourage them to enter the contest with you.<strong>Voting:</strong>In contrast to the prior banner contest, voting will not be limited to the mods this time, so anyone can vote after the entry window has ended. However, there will be a catch as security measures will be in place to reduce voter fraud. To qualify to vote you must donate no less than $10 worth of BTC, ETH, or LTC to the prize money fund. Your account must have 100 comment karma as well as 3 months account age.You must inform the mods at least 1 day in advance of sending your donation.You must provide the precise amount you intend to send(within 5 digits) and precise UTC time(within 5 minutes). Mods will be exempt from these requirements.<strong>Donation Addresses:</strong>Bitcoin - <strong>13TtWiC569BboRropRp9o1Ab4e5JdWyPB6</strong>Ethereum (tokens not accepted) - <strong>0xddfdbc95959e0920e5624221d9331197cd3bbe9e</strong>Litecoin - <strong>LQz6PdYQi1gg8QYt5xAAjQXhb6eXsbE7YR</strong>The prize money will be distributed to the top 3 winners in the ratios of 50% for 1st place, 30% for 2nd place, 20% for 3rd place.&nbsp;<strong>Other Details:</strong>One or multiple winners will be invited to join the mod team to maintain and update the stylesheet.Only theme entries and questions will be allowed in this thread. Off-topic news, advertising, and inappropriate NSFW entries will be promptly removed and potentially banned.EDIT: Added more details, banner designs and subreddit naming.", :user=>"CryptoCurrencyMod", :score=>"0"}, {:content=>"<a href=\"http://reddit.com/r/cryptocurrencycss\">http://reddit.com/r/cryptocurrencycss</a>I'm working with the banner design winner to incorporate his look, and I'm waiting for the mod who takes care of the ticker (the automatically changing top 10 coins bar image) to update it, so we can redesign the top 10 coins bar (it is incomplete, and the one on the CSS subreddit is a demo).Light/dark themes can both be incorporated at the switch of a button, which I will add soon.And of course, I can take suggestions. Reply or message me privately if you have any ideas for changes.p.s. if this were to be incorporated, I would reimplement (redo) the entire user and link flair system. I'm not a big fan of the big, blobby user flair icons (and the \"retina\" wasn't implemented properly). The link flairs need a major overhaul and must be pruned, and should be restylized. I'll get to this later.", :user=>"shy", :score=>"0"},  {:content=>"Do you have a link with more information?", :user=>"DigitalTh0r", :score=>"0"}]
      @example_raw_thread = EG_THREAD.clone
      @example_parsed_thread = {:title=>"placeholder", :comments=>[{:currencies=>["Bitcoin", "Ethereum", "Litecoin", "DigixDAO"], :user=>"CryptoCurrencyMod", :score=>"0"}, {:currencies=>["DigixDAO"], :user=>"shy", :score=>"0"}, {:currencies=>["DigixDAO"], :user=>"DigitalTh0r", :score=>"0"}]}
  end

  def test_interpretes_users_correctly
    @comments.interpret_comment_all(EXAMPLE_COMMENTS)
    current_data = @comments.all_comments
    current_data.each_with_index do |comment, index|
      expected_data = @expected_comment_data[index][:user]
      assert_equal(expected_data, current_data[index][:user])
    end
  end

  def test_interpretes_content_correctly
    EXAMPLE_COMMENTS.each_with_index do |comment, index|
      @comments.current_comment = comment
      comment_data = @comments.send(:search_comment)
      expected_data = @expected_comment_data[index][:content]
      assert_equal(expected_data, comment_data)
    end
  end

  def test_interpretes_score_correctly
    @comments.interpret_comment_all(EXAMPLE_COMMENTS)
    current_data = @comments.all_comments
    current_data.each_with_index do |comment, index|
      expected_data = @expected_comment_data[index][:score]
      assert_equal(expected_data, current_data[index][:score])
    end
  end

  def test_parses_multiple_comments
    @comments.interpret_comment_all(@example_raw_thread[:comments])
    assert_equal(@expected_thread_data.length, @comments.all_comments.length)
    @comments.all_comments.each_with_index do |comment, index|
      expected = @expected_thread_data[index]
      assert_equal(expected[:score], comment[:score])
      assert_equal(expected[:user], comment[:user])
    end
  end

  def test_identifies_currency_mentions
    @comments.send(:get_currencies, EG_CURRENCY_MENTIONS[0]);
    assert_equal("Bitcoin", @comments.comment_data[:currencies][0])
    @comments.send(:get_currencies, EG_CURRENCY_MENTIONS[1]);
    assert_equal("SALT", @comments.comment_data[:currencies][0])
    @comments.send(:get_currencies, EG_CURRENCY_MENTIONS[2]);
    assert_equal("NAV Coin", @comments.comment_data[:currencies][0])
  end

  def test_replaces_raw_thread_data
    @comments.parse_thread(@example_raw_thread)
    assert_equal(@example_parsed_thread, @example_raw_thread)
  end

  # ----------------------------- testing match system -----------------------

  def test_currency_case_insensitive
    @comments.send(:get_currencies, ' BITCOIN vvv')
    uppercase = @comments.comment_data[:currencies]
    @comments.send(:get_currencies, " BiTcOiN bc")
    mixed = @comments.comment_data[:currencies]
    @comments.send(:get_currencies, 'bc bitcoin bbb')
    lowercase = @comments.comment_data[:currencies]
    assert_equal(uppercase, mixed)
    assert_equal(mixed, lowercase)
    @comments.send(:get_currencies, ' BTC vvv')
    uppercase = @comments.comment_data[:currencies]
    @comments.send(:get_currencies, " BtC bc")
    mixed = @comments.comment_data[:currencies]
    @comments.send(:get_currencies, 'bc btc bbb')
    lowercase = @comments.comment_data[:currencies]
    assert_equal(uppercase, mixed)
    assert_equal(mixed, lowercase)
  end

  def test_currency_name_conversion
    @comments.send(:get_currencies, ' BITCOIN vvv')
    normal = @comments.comment_data[:currencies]
    @comments.send(:get_currencies, ' BTC vvv')
    abbr = @comments.comment_data[:currencies]
    assert_equal(normal, abbr)
  end

  def test_catches_start_and_end_mentions
    @comments.send(:get_currencies, 'BITCOIN vvv')
    start = @comments.comment_data[:currencies]
    @comments.send(:get_currencies, 'ggg BITCOIN')
    finish = @comments.comment_data[:currencies]
    assert_equal(start, finish)
  end

  def test_ignores_when_inside_other_words
    @comments.send(:get_currencies, '"BITCOINvvv')
    after = @comments.comment_data[:currencies]
    @comments.send(:get_currencies, '-sssssBITCOIN-')
    before = @comments.comment_data[:currencies]
    @comments.send(:get_currencies, 'sBITCOINss')
    both = @comments.comment_data[:currencies]
    assert_empty(after)
    assert_empty(before)
    assert_empty(both)
  end

  def test_catches_despite_weird_surroundings
    @comments.send(:get_currencies, '"BITCOIN" vvv')
    quotes = @comments.comment_data[:currencies]
    @comments.send(:get_currencies, '-BITCOIN-')
    hyphens = @comments.comment_data[:currencies]
    @comments.send(:get_currencies, ' BITCOIN" vvv')
    one_quote = @comments.comment_data[:currencies]
    @comments.send(:get_currencies, '/BITCOIN/')
    slashes = @comments.comment_data[:currencies]
    @comments.send(:get_currencies, ' BITCOINs')
    small_s = @comments.comment_data[:currencies]
    @comments.send(:get_currencies, ' BITCOINS')
    big_s = @comments.comment_data[:currencies]
    assert_equal(['Bitcoin'], quotes)
    assert_equal(['Bitcoin'], hyphens)
    assert_equal(['Bitcoin'], one_quote)
    assert_equal(['Bitcoin'], slashes)
    assert_equal(['Bitcoin'], small_s)
    assert_equal(['Bitcoin'], big_s)
  end

end
