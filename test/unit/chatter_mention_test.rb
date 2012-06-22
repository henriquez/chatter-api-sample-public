require 'test_helper'

class ChatterMentionTest < ActiveSupport::TestCase
  STRNOMENTIONS = 'hey there'
  STRALLMENTIONS = "@[Kenneth Auchenberg](user:005D0000001L2Hz)@[fredflinstone](user:005D0000001xxxz)"
  TEST_POST1 = '@[Kenneth Auchenberg](user:005D0000001L2Hz) what\'s up? And@[David Milo](user:005D0000001L2Hz234)don\'t forget your regex@[his time] and @[ji\'de lys](user:005D0000001L2H22xx)'

  
  test "should extract all mentions from string" do
    testPost = TEST_POST1
    mentions = ChatterMention.extract_mentions(testPost)
    
    assert_equal('@[Kenneth Auchenberg](user:005D0000001L2Hz)', mentions[0].text)
    assert_equal('@[David Milo](user:005D0000001L2Hz234)', mentions[1].text)
    assert_equal('@[ji\'de lys](user:005D0000001L2H22xx)', mentions[2].text)
    assert_equal(0, mentions[0].start)
    assert_equal(58, mentions[1].start)
    assert_equal(135, mentions[2].start)

    #  negative tests
    firstSeg = 'hi there (user:005D0000001L2Hz)'
    lastSeg  = 'more stuff @[Kenneth Auchen (user:005D0000001L2Hz)'
    testStr2 = firstSeg + testPost + lastSeg
    mentions = ChatterMention.extract_mentions(testStr2)
    assert_equal('@[Kenneth Auchenberg](user:005D0000001L2Hz)', mentions[0].text)
    assert_equal('@[David Milo](user:005D0000001L2Hz234)', mentions[1].text)
    assert_equal('@[ji\'de lys](user:005D0000001L2H22xx)', mentions[2].text)

    # corner cases

    # string with no mentions
    mentions = ChatterMention.extract_mentions(STRNOMENTIONS)
    assert mentions.empty?

    # string with all mentions
    mentions = ChatterMention.extract_mentions(STRALLMENTIONS)
    assert_equal(mentions[0].text,'@[Kenneth Auchenberg](user:005D0000001L2Hz)' )
    assert_equal(mentions[1].text, '@[fredflinstone](user:005D0000001xxxz)' )
    assert_equal(mentions.size(), 2)

    # empty string
    mentions = ChatterMention.extract_mentions('')
    assert mentions.empty? 
  end
  
  
  test 'extract user id from mention text' do
      testStr1 = '@[Kenneth Auchenberg](user:005D0000001L2Hz)'
      testStr2 = '@[David Milo](user:005D0000001L2Hz234)'
      testStr3 = '@[ji\'de lys](user:005D0000001L2H22xx)'
      userId1 = '005D0000001L2Hz'
      userId2 = '005D0000001L2Hz234'
      userId3 = '005D0000001L2H22xx'
      assert_equal(userId1, ChatterMention.extract_user_id(testStr1))
      assert_equal(userId2, ChatterMention.extract_user_id(testStr2))
      assert_equal(userId3, ChatterMention.extract_user_id(testStr3))
  end
  
end