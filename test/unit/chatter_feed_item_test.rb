require 'test_helper'

class ChatterFeedItemTest < ActiveSupport::TestCase
  
  TEST_POST1 = '@[Kenneth Auchenberg](contact:005D0000001L2Hz) what\'s up, he said "hi"? And@[David Milo](contact:005D0000001L2Hz234)don\'t forget your regex@[his time] and @[ji\'de lys](contact:005D0000001L2H22xx)'

  test 'create body' do
    body = ChatterFeedItem.create_body(TEST_POST1)
    correct_body = %Q|{"body":{"messageSegments":[{"id":"005D0000001L2Hz","type":"mention"},{"type":"text","text":" what's up, he said \\\"hi\\\"? And"},{"id":"005D0000001L2Hz234","type":"mention"},{"type":"text","text":"don't forget your regex@[his time] and "},{"id":"005D0000001L2H22xx","type":"mention"}]}}|
    assert_equal correct_body, body
  end
  
end
