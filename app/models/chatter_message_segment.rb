class ChatterMessageSegment
  attr_accessor :type, :id, :text
  
  # return array of message segments, given a post string.
  # returns nil if post is an empty string or all whitespace
  def self.build_segments(post) 
    return nil if post.blank? 
    segments = []
    mentions = ChatterMention.extract_mentions(post)        
 
    if (mentions.length > 0) 
      # the cursor is the char position inside post
      cursor = 0
      mentions.each do |mention|               
        #cursor is maintained at the beginning of a mention or text segment by moving it one char past the current 
        # mention at every iteration of this loop.
        if (mention.start > cursor) 
          # there is text between where the cursor is and the start of this mention so store the text first. 
          # we know there is text (and we're not at end of string) because there's a mention with a start point to the right
          # of the cursor.
          text_segment = ChatterMessageSegment.new
          text_segment.text = post[cursor..mention.start-1]
          text_segment.type = 'text'
          segments <<  text_segment  
        end   
        #next store the mention 
        mention_segment = ChatterMessageSegment.new  
        mention_segment.id = ChatterMention.extract_user_id(mention.text)
        mention_segment.type = 'mention'
        segments << mention_segment          
        cursor = mention.end   # move cursor to where this mention ended                    
      end
      
      # After the last mention, there may be a text segment
      if cursor < post.length
        text_segment = ChatterMessageSegment.new
        text_segment.text = post[cursor, post.length]
        text_segment.type = 'text'
        segments <<  text_segment  
      end

    else 
      # no mentions in the post, just store the whole post as a text segment.
      text_segment = ChatterMessageSegment.new
      text_segment.text = post
      text_segment.type = 'text'
      segments <<  text_segment  
    end
    segments
  end
    
    
    
  
end
