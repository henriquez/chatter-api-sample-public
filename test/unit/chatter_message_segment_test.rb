require 'test_helper'

class ChatterMessageSegmentTest < ActiveSupport::TestCase
  TEST_POST1 = '@[Kenneth Auchenberg](user:005D0000001L2Hz) what\'s up? And@[David Milo](user:005D0000001L2Hz234)don\'t forget your regex@[his time] and @[ji\'de lys](user:005D0000001L2H22xx)'
  
  test "test build segments base" do
    segments = ChatterMessageSegment.build_segments(TEST_POST1)
    assert_equal 5, segments.length
    assert_equal segments[0].id, "005D0000001L2Hz"
    assert_equal segments[0].type, "mention"
    assert_equal " what\'s up? And", segments[1].text 
    assert_equal segments[1].type, "text"
    assert_equal "005D0000001L2H22xx", segments[4].id      
  end
  
   
  test "test build segments corners" do
    # empty string
    segments = ChatterMessageSegment.build_segments("")
    assert_equal nil, segments
    
    # only text segment
    segments = ChatterMessageSegment.build_segments("whazzup you? @[sss] contact number")
    assert_equal "whazzup you? @[sss] contact number", segments[0].text
    assert_equal 1, segments.length  
    
    # only mention segments
    segments = ChatterMessageSegment.build_segments("@[Kenneth Auchenberg](user:005D0000001L2Hz)@[David Milo](user:005D0000001L2Hz234)")
    assert_equal "005D0000001L2Hz", segments[0].id
    assert_equal 2, segments.length
    assert_equal "mention", segments[1].type 
    
    # invalid segments and weird text
    segments = ChatterMessageSegment.build_segments("@[凄くいいアッ](user:005D0000001L2Hz)blah は凄くいいアップです blah åèüñ blah@[David Milo](user:)\"")
    assert_equal "005D0000001L2Hz", segments[0].id
    assert_equal 2, segments.length
    assert_equal "text", segments[1].type  # because latter mention is not valid format
    
    # text segment after and before mention
    segments = ChatterMessageSegment.build_segments("textseg1 @[Kenneth Auchenberg](user:005D0000001L2Hz)textseg2")
    assert_equal "005D0000001L2Hz", segments[1].id
    assert_equal 3, segments.length
    assert_equal "mention", segments[1].type 
    assert_equal "text", segments[0].type
    assert_equal "textseg1 ", segments[0].text
    assert_equal "textseg2", segments[2].text
  end
  
end